/**
 * @file can_logger.hpp
 * @brief CAN frame recording and playback system
 * 
 * Captures CAN frames to timestamped binary log files and replays them
 * at configurable speeds for testing and demo purposes.
 */

#pragma once

#include <QObject>
#include <QString>
#include <QFile>
#include <QTimer>
#include <QList>
#include <cstdint>

struct CANFrame {
    uint64_t timestamp;    // milliseconds since epoch
    uint32_t canId;        // CAN identifier
    uint8_t dlc;           // Data length code
    uint8_t data[8];       // CAN data bytes
};

class CANLogger : public QObject
{
    Q_OBJECT
    
    Q_PROPERTY(bool isRecording READ isRecording NOTIFY recordingStateChanged)
    Q_PROPERTY(bool isPlayback READ isPlayback NOTIFY playbackStateChanged)
    Q_PROPERTY(int playbackSpeed READ playbackSpeed WRITE setPlaybackSpeed NOTIFY playbackSpeedChanged)
    Q_PROPERTY(double playbackPosition READ playbackPosition NOTIFY playbackPositionChanged)
    Q_PROPERTY(double playbackDuration READ playbackDuration NOTIFY playbackDurationChanged)
    Q_PROPERTY(QString lastRecordedFile READ lastRecordedFile NOTIFY lastRecordedFileChanged)

public:
    explicit CANLogger(QObject *parent = nullptr);
    ~CANLogger() override;
    
    // Recording
    Q_INVOKABLE bool startRecording(const QString &filePath);
    Q_INVOKABLE void stopRecording();
    Q_INVOKABLE void recordFrame(uint32_t canId, uint8_t dlc, const uint8_t *data);
    
    // Playback
    Q_INVOKABLE bool loadPlayback(const QString &filePath);
    Q_INVOKABLE void playPlayback();
    Q_INVOKABLE void pausePlayback();
    Q_INVOKABLE void stopPlayback();
    Q_INVOKABLE void seekPlayback(double positionMs);
    
    // Getters
    bool isRecording() const { return m_isRecording; }
    bool isPlayback() const { return m_isPlayback; }
    int playbackSpeed() const { return m_playbackSpeed; }
    double playbackPosition() const { return m_playbackPosition; }
    double playbackDuration() const { return m_playbackDuration; }
    QString lastRecordedFile() const { return m_lastRecordedFile; }
    
    // Setter (callable from QML)
    Q_INVOKABLE void setPlaybackSpeed(int speedPercent);

signals:
    void recordingStateChanged();
    void playbackStateChanged();
    void playbackSpeedChanged();
    void playbackPositionChanged();
    void playbackDurationChanged();
    void lastRecordedFileChanged();
    void framePlaybackReady(uint32_t canId, uint8_t dlc, const uint8_t *data, uint64_t timestamp);
    void recordingError(const QString &error);
    void playbackError(const QString &error);

private slots:
    void onPlaybackTick();
    void injectNextFrame();

private:
    // Binary file format constants
    static constexpr const char *FILE_MAGIC = "CANLOG\0\0";
    static constexpr uint32_t FILE_VERSION = 1;
    static constexpr int FRAME_SIZE = 21; // 8 + 4 + 1 + 8
    
    // Recording
    QFile m_recordFile;
    QString m_lastRecordedFile;
    bool m_isRecording;
    uint64_t m_recordStartTime;
    
    // Playback
    QList<CANFrame> m_playbackFrames;
    QFile m_playbackFile;
    bool m_isPlayback;
    bool m_isPaused;
    int m_playbackSpeed;              // percentage (100 = 1x, 200 = 2x, 50 = 0.5x)
    double m_playbackPosition;        // milliseconds
    double m_playbackDuration;        // milliseconds
    int m_currentFrameIndex;
    uint64_t m_playbackStartTime;     // wall clock time when playback started
    uint64_t m_playbackOffset;        // offset in milliseconds from original timestamp
    
    QTimer *m_playbackTimer;
    
    // Helper methods
    bool writeFrameToFile(const CANFrame &frame);
    bool readFramesFromFile(const QString &filePath);
    void injectFrameTocan1(const CANFrame &frame);
};
