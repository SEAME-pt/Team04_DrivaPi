/**
 * @file music_player_controller.cpp
 * @author DrivaPi Team
 * @brief Qt media player controller implementation with TagLib metadata extraction.
 */

#include "music_player_controller.hpp"
#include "settings_manager.hpp"
#include <QDir>
#include <QFileInfo>
#include <QUrl>
#include <QMediaMetaData>
#include <QStandardPaths>
#include <QImage>
#include <QDebug>
#include <taglib/fileref.h>
#include <taglib/tag.h>
#include <taglib/mpegfile.h>
#include <taglib/id3v2tag.h>
#include <taglib/attachedpictureframe.h>

namespace drivaui {

MusicPlayerController::MusicPlayerController(SettingsManager* settings, QObject* parent)
    : QObject(parent), m_settings(settings) {

    // Setup audio output
    m_mediaPlayer.setAudioOutput(&m_audioOutput);

    // Connect media player signals
    connect(&m_mediaPlayer, &QMediaPlayer::mediaStatusChanged, this, &MusicPlayerController::onMediaStatusChanged);
    connect(&m_mediaPlayer, &QMediaPlayer::playbackStateChanged, this, &MusicPlayerController::onPlaybackStateChanged);
    connect(&m_mediaPlayer, &QMediaPlayer::durationChanged, this, &MusicPlayerController::onDurationChanged);
    connect(&m_mediaPlayer, &QMediaPlayer::positionChanged, this, &MusicPlayerController::onPositionChanged);
    connect(&m_mediaPlayer, &QMediaPlayer::errorOccurred, this, &MusicPlayerController::onError);
    connect(&m_mediaPlayer, &QMediaPlayer::metaDataChanged, this, &MusicPlayerController::extractMetadata);

    // Load settings
    setVolume(m_settings->volume());

    // Load music library from saved path
    QString musicPath = m_settings->musicLibraryPath();
    loadMusicLibrary(musicPath);
}

MusicPlayerController::~MusicPlayerController() {
    // Disconnect all signals before stopping to prevent slots firing on a
    // partially-destroyed object (AVFoundation backend can crash otherwise).
    m_mediaPlayer.disconnect();
    m_mediaPlayer.stop();
    m_mediaPlayer.setSource(QUrl());
    m_mediaPlayer.setAudioOutput(nullptr);
}

void MusicPlayerController::loadMusicLibrary(const QString& path) {
    qDebug() << "Loading music library from:" << path;
    m_trackList.clear();
    m_currentTrackIndex = 0;

    QDir musicDir(path);
    QStringList filters;
    filters << "*.mp3" << "*.flac" << "*.wav" << "*.m4a" << "*.ogg" << "*.wma";

    musicDir.setNameFilters(filters);
    musicDir.setFilter(QDir::Files);

    QFileInfoList files = musicDir.entryInfoList();
    for (const QFileInfo& file : files) {
        m_trackList.append(file.absoluteFilePath());
        qDebug() << "Found track:" << file.fileName();
    }

    if (m_trackList.isEmpty()) {
        qWarning() << "No music files found in:" << path;
    } else {
        qDebug() << "Loaded" << m_trackList.size() << "tracks";
        emit trackListChanged();

        // Load first track metadata but don't auto-play
        if (!m_trackList.isEmpty()) {
            setCurrentTrackIndex(0);
        }
    }
}

void MusicPlayerController::play() {
    m_mediaPlayer.play();
}

void MusicPlayerController::pause() {
    m_mediaPlayer.pause();
}

void MusicPlayerController::togglePlayPause() {
    if (isPlaying()) {
        pause();
    } else {
        play();
    }
}

void MusicPlayerController::next() {
    bool wasPlaying = isPlaying();

    if (m_currentTrackIndex < m_trackList.size() - 1) {
        setCurrentTrackIndex(m_currentTrackIndex + 1);
    } else if (!m_trackList.isEmpty()) {
        setCurrentTrackIndex(0);
    }

    // Resume playback if it was playing before
    if (wasPlaying) {
        play();
    }
}

void MusicPlayerController::previous() {
    bool wasPlaying = isPlaying();

    if (m_currentTrackIndex > 0) {
        setCurrentTrackIndex(m_currentTrackIndex - 1);
    } else if (!m_trackList.isEmpty()) {
        setCurrentTrackIndex(m_trackList.size() - 1);
    }

    // Resume playback if it was playing before
    if (wasPlaying) {
        play();
    }
}

void MusicPlayerController::setPosition(int ms) {
    m_mediaPlayer.setPosition(ms);
}

void MusicPlayerController::setCurrentTrackIndex(int index) {
    if (index >= 0 && index < m_trackList.size()) {
        m_currentTrackIndex = index;
        QString trackPath = m_trackList.at(index);

        qDebug() << "Loading track:" << trackPath;
        m_mediaPlayer.setSource(QUrl::fromLocalFile(trackPath));

        m_settings->setLastPlayedTrack(trackPath);

        emit currentTrackIndexChanged();

        // Don't auto-play - wait for user to click play
    }
}

void MusicPlayerController::extractMetadata() {
    const QString path = (m_currentTrackIndex >= 0 && m_currentTrackIndex < m_trackList.size())
                         ? m_trackList.at(m_currentTrackIndex) : QString();
    if (path.isEmpty()) {
        qDebug() << "No current track to extract metadata from";
        return;
    }
    qDebug() << "Extracting metadata from:" << path;
    extractTagLibMetadata(path);
    extractAlbumArt(path);
    applyMetadataFallbacks();
    emit playbackInfoChanged();
}

void MusicPlayerController::extractTagLibMetadata(const QString& path) {
    TagLib::FileRef fileRef(path.toUtf8().constData());
    if (!fileRef.isNull() && fileRef.tag()) {
        TagLib::Tag *tag = fileRef.tag();
        m_trackTitle = QString::fromStdString(tag->title().to8Bit(true));
        m_artistName = QString::fromStdString(tag->artist().to8Bit(true));
        qDebug() << "TagLib extracted - Title:" << m_trackTitle << "Artist:" << m_artistName;
    }
}

void MusicPlayerController::extractAlbumArt(const QString& path) {
    m_albumArtUrl.clear();
    TagLib::MPEG::File mpegFile(path.toUtf8().constData());
    if (!mpegFile.isValid() || !mpegFile.ID3v2Tag()) {
        qDebug() << "Not a valid MP3 file or no ID3v2 tag";
        return;
    }

    TagLib::ID3v2::FrameList frameList = mpegFile.ID3v2Tag()->frameList("APIC");
    if (frameList.isEmpty()) {
        qDebug() << "No APIC frames found in ID3v2 tag";
        return;
    }

    auto *frame = static_cast<TagLib::ID3v2::AttachedPictureFrame*>(frameList.front());
    if (!frame) return;

    TagLib::ByteVector imageData = frame->picture();
    qDebug() << "Found album art:" << imageData.size() << "bytes";

    QImage image;
    if (!image.loadFromData(reinterpret_cast<const uchar*>(imageData.data()), imageData.size())) {
        qDebug() << "Failed to load image data into QImage";
        return;
    }
    qDebug() << "QImage loaded - size:" << image.size();

    QString tempPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation) +
                       "/album_art_" + QString::number(m_currentTrackIndex) + ".jpg";
    if (image.save(tempPath, "JPG", 95)) {
        m_albumArtUrl = "file://" + tempPath;
        qDebug() << "Album art saved and URL set:" << m_albumArtUrl;
    } else {
        qDebug() << "Failed to save album art to:" << tempPath;
    }
}

void MusicPlayerController::applyMetadataFallbacks() {
    if (m_trackTitle.isEmpty() && m_currentTrackIndex >= 0 && m_currentTrackIndex < m_trackList.size()) {
        m_trackTitle = QFileInfo(m_trackList.at(m_currentTrackIndex)).baseName();
    }
    if (m_artistName.isEmpty()) {
        m_artistName = "Local Music";
    }
    if (m_albumArtUrl.isEmpty()) {
        qDebug() << "Using fallback color gradient (no album art available from Qt backend)";
    }
}

bool MusicPlayerController::isPlaying() const {
    return m_mediaPlayer.playbackState() == QMediaPlayer::PlayingState;
}

int MusicPlayerController::duration() const {
    return static_cast<int>(m_duration);
}

int MusicPlayerController::position() const {
    return static_cast<int>(m_position);
}

int MusicPlayerController::volume() const {
    return qRound(m_audioOutput.volume() * 100);
}

void MusicPlayerController::setVolume(int vol) {
    int clampedVol = qBound(0, vol, 100);
    m_audioOutput.setVolume(clampedVol / 100.0);
    m_settings->setVolume(clampedVol);
    emit volumeChanged();
}

void MusicPlayerController::onMediaStatusChanged(QMediaPlayer::MediaStatus status) {
    qDebug() << "Media status changed:" << status;
    if (status == QMediaPlayer::EndOfMedia) {
        next(); // Auto-advance; next() resumes playback if already playing
    }
}

void MusicPlayerController::onPlaybackStateChanged(QMediaPlayer::PlaybackState state) {
    emit playStateChanged();
}

void MusicPlayerController::onDurationChanged(qint64 duration) {
    m_duration = duration;
    emit durationChanged();
}

void MusicPlayerController::onPositionChanged(qint64 position) {
    m_position = position;
    emit positionChanged();
}

void MusicPlayerController::onError(QMediaPlayer::Error error, const QString& errorString) {
    qWarning() << "Media player error:" << errorString;
    emit this->error(errorString);
}

} // namespace drivaui
