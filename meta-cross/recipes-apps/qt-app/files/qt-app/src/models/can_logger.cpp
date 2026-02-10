#include "can_logger.hpp"
#include <QDebug>
#include <QDateTime>
#include <QDir>
#include <QStandardPaths>
#include <QProcess>
#include <cstring>

CANLogger::CANLogger(QObject *parent)
    : QObject(parent),
      m_isRecording(false),
      m_recordStartTime(0),
      m_isPlayback(false),
      m_isPaused(false),
      m_playbackSpeed(100),
      m_playbackPosition(0.0),
      m_playbackDuration(0.0),
      m_currentFrameIndex(0),
      m_playbackStartTime(0),
      m_playbackOffset(0)
{
    m_playbackTimer = new QTimer(this);
    connect(m_playbackTimer, &QTimer::timeout, this, &CANLogger::onPlaybackTick);
}

CANLogger::~CANLogger()
{
    stopRecording();
    stopPlayback();
}

bool CANLogger::startRecording(const QString &filePath)
{
    if (m_isRecording) {
        emit recordingError("Recording already in progress");
        return false;
    }
    
    // Ensure directory exists
    QDir dir(QFileInfo(filePath).absolutePath());
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    
    m_recordFile.setFileName(filePath);
    if (!m_recordFile.open(QIODevice::WriteOnly)) {
        emit recordingError(QString("Failed to open file: %1").arg(filePath));
        return false;
    }
    
    // Write file header: magic (8 bytes) + version (4 bytes) + reserved (8 bytes)
    m_recordFile.write(FILE_MAGIC, 8);
    m_recordFile.write(reinterpret_cast<const char *>(&FILE_VERSION), sizeof(FILE_VERSION));
    uint64_t reserved = 0;
    m_recordFile.write(reinterpret_cast<const char *>(&reserved), 8);
    
    m_recordStartTime = QDateTime::currentMSecsSinceEpoch();
    m_isRecording = true;
    
    qInfo() << "[CANLogger] Recording started:" << filePath;
    emit recordingStateChanged();
    return true;
}

void CANLogger::stopRecording()
{
    if (!m_isRecording) return;
    
    m_recordFile.close();
    m_isRecording = false;
    
    // Save the path for easy playback
    m_lastRecordedFile = m_recordFile.fileName();
    emit lastRecordedFileChanged();
    
    qInfo() << "[CANLogger] Recording stopped";
    emit recordingStateChanged();
}

void CANLogger::recordFrame(uint32_t canId, uint8_t dlc, const uint8_t *data)
{
    if (!m_isRecording || !m_recordFile.isOpen()) return;
    
    CANFrame frame;
    frame.timestamp = QDateTime::currentMSecsSinceEpoch() - m_recordStartTime;
    frame.canId = canId;
    frame.dlc = dlc;
    std::memcpy(frame.data, data, 8);
    
    writeFrameToFile(frame);
}

bool CANLogger::loadPlayback(const QString &filePath)
{
    if (m_isPlayback) {
        emit playbackError("Playback already in progress");
        return false;
    }
    
    if (!readFramesFromFile(filePath)) {
        emit playbackError(QString("Failed to load file: %1").arg(filePath));
        return false;
    }
    
    m_playbackFile.setFileName(filePath);
    m_playbackDuration = m_playbackFrames.isEmpty() ? 0.0 : m_playbackFrames.last().timestamp;
    
    qInfo() << "[CANLogger] Loaded" << m_playbackFrames.size() << "frames," << m_playbackDuration << "ms";
    emit playbackDurationChanged();
    return true;
}

void CANLogger::playPlayback()
{
    if (m_playbackFrames.isEmpty()) {
        emit playbackError("No frames loaded for playback");
        return;
    }
    
    if (m_isPaused) {
        // Resume from pause
        m_isPaused = false;
        m_playbackStartTime = QDateTime::currentMSecsSinceEpoch() - m_playbackPosition * 100 / m_playbackSpeed;
        m_playbackTimer->start(33); // ~30 FPS
        m_isPlayback = true;
        emit playbackStateChanged();
        return;
    }
    
    if (m_isPlayback) return; // Already playing
    
    m_isPlayback = true;
    m_isPaused = false;
    m_currentFrameIndex = 0;
    m_playbackStartTime = QDateTime::currentMSecsSinceEpoch();
    m_playbackPosition = 0.0;
    m_playbackOffset = 0;
    
    m_playbackTimer->start(33); // ~30 FPS
    emit playbackStateChanged();
}

void CANLogger::pausePlayback()
{
    if (!m_isPlayback) return;
    
    m_playbackTimer->stop();
    m_isPaused = true;
}

void CANLogger::stopPlayback()
{
    if (!m_isPlayback) return;
    
    m_playbackTimer->stop();
    m_isPlayback = false;
    m_isPaused = false;
    m_currentFrameIndex = 0;
    m_playbackPosition = 0.0;
    
    emit playbackStateChanged();
    emit playbackPositionChanged();
}

void CANLogger::seekPlayback(double positionMs)
{
    if (m_playbackFrames.isEmpty()) return;
    
    m_playbackPosition = qBound(0.0, positionMs, m_playbackDuration);
    m_playbackOffset = static_cast<uint64_t>(m_playbackPosition);
    
    // Find first frame at or after this position
    m_currentFrameIndex = 0;
    for (int i = 0; i < m_playbackFrames.size(); ++i) {
        if (m_playbackFrames[i].timestamp >= m_playbackOffset) {
            m_currentFrameIndex = i;
            break;
        }
    }
    
    if (m_isPlayback) {
        m_playbackStartTime = QDateTime::currentMSecsSinceEpoch() - m_playbackPosition * 100 / m_playbackSpeed;
    }
    
    emit playbackPositionChanged();
}

void CANLogger::setPlaybackSpeed(int speedPercent)
{
    if (m_playbackSpeed != speedPercent) {
        m_playbackSpeed = qBound(10, speedPercent, 400); // 0.1x to 4x
        
        // Adjust timer if playing
        if (m_isPlayback && !m_isPaused) {
            m_playbackStartTime = QDateTime::currentMSecsSinceEpoch() - m_playbackPosition * 100 / m_playbackSpeed;
        }
        
        emit playbackSpeedChanged();
    }
}

void CANLogger::onPlaybackTick()
{
    if (m_isPaused) {
        m_playbackTimer->stop();
        return;
    }
    
    uint64_t elapsed = QDateTime::currentMSecsSinceEpoch() - m_playbackStartTime;
    m_playbackPosition = elapsed * m_playbackSpeed / 100.0;
    m_playbackOffset = static_cast<uint64_t>(m_playbackPosition);
    
    if (m_playbackPosition > m_playbackDuration) {
        stopPlayback();
        return;
    }
    
    injectNextFrame();
    emit playbackPositionChanged();
}

void CANLogger::injectNextFrame()
{
    while (m_currentFrameIndex < m_playbackFrames.size()) {
        const CANFrame &frame = m_playbackFrames[m_currentFrameIndex];
        
        if (frame.timestamp <= m_playbackOffset) {
            // Inject this frame
            injectFrameTocan1(frame);
            m_currentFrameIndex++;
        } else {
            break; // Wait for next tick
        }
    }
}

bool CANLogger::writeFrameToFile(const CANFrame &frame)
{
    m_recordFile.write(reinterpret_cast<const char *>(&frame.timestamp), sizeof(frame.timestamp));
    m_recordFile.write(reinterpret_cast<const char *>(&frame.canId), sizeof(frame.canId));
    m_recordFile.write(reinterpret_cast<const char *>(&frame.dlc), sizeof(frame.dlc));
    m_recordFile.write(reinterpret_cast<const char *>(frame.data), 8);
    
    return m_recordFile.error() == QFile::NoError;
}

bool CANLogger::readFramesFromFile(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        return false;
    }
    
    // Read and verify header
    char magic[8];
    file.read(magic, 8);
    if (std::strncmp(magic, FILE_MAGIC, 8) != 0) {
        qWarning() << "[CANLogger] Invalid file magic";
        return false;
    }
    
    uint32_t version;
    file.read(reinterpret_cast<char *>(&version), sizeof(version));
    if (version != FILE_VERSION) {
        qWarning() << "[CANLogger] Incompatible file version:" << version;
        return false;
    }
    
    uint64_t reserved;
    file.read(reinterpret_cast<char *>(&reserved), 8);
    
    // Read all frames
    m_playbackFrames.clear();
    while (!file.atEnd()) {
        CANFrame frame;
        qint64 bytesRead;
        
        bytesRead = file.read(reinterpret_cast<char *>(&frame.timestamp), sizeof(frame.timestamp));
        if (bytesRead != sizeof(frame.timestamp)) break;
        
        bytesRead = file.read(reinterpret_cast<char *>(&frame.canId), sizeof(frame.canId));
        if (bytesRead != sizeof(frame.canId)) break;
        
        bytesRead = file.read(reinterpret_cast<char *>(&frame.dlc), sizeof(frame.dlc));
        if (bytesRead != sizeof(frame.dlc)) break;
        
        bytesRead = file.read(reinterpret_cast<char *>(frame.data), 8);
        if (bytesRead != 8) break;
        
        m_playbackFrames.append(frame);
    }
    
    file.close();
    return true;
}

void CANLogger::injectFrameTocan1(const CANFrame &frame)
{
    // Use cansend command to inject frame into can1
    // Format: cansend can1 <canid>#<data bytes>
    
    QString hexData;
    for (int i = 0; i < frame.dlc; ++i) {
        hexData += QString("%1").arg(frame.data[i], 2, 16, QChar('0'));
    }
    
    QString cmd = QString("cansend can1 %1#%2").arg(frame.canId, 3, 16, QChar('0')).arg(hexData);
    
    // Execute in background (suppress output)
    QProcess::startDetached("bash", QStringList() << "-c" << cmd);
}
