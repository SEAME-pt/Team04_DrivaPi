/**
 * @file music_player_controller.hpp
 * @author DrivaPi Team
 * @brief Qt media player controller exposing playback state and controls to QML.
 */

#pragma once
#include <QObject>
#include <QMediaPlayer>
#include <QAudioOutput>
#include <QString>
#include <QStringList>

namespace drivaui { class SettingsManager; }

namespace drivaui {

class MusicPlayerController : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString trackTitle READ trackTitle NOTIFY playbackInfoChanged)
    Q_PROPERTY(QString artistName READ artistName NOTIFY playbackInfoChanged)
    Q_PROPERTY(QString albumArtUrl READ albumArtUrl NOTIFY playbackInfoChanged)
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY playStateChanged)
    Q_PROPERTY(int duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(int position READ position NOTIFY positionChanged)
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(QStringList trackList READ trackList NOTIFY trackListChanged)
    Q_PROPERTY(int currentTrackIndex READ currentTrackIndex WRITE setCurrentTrackIndex NOTIFY currentTrackIndexChanged)

public:
    explicit MusicPlayerController(SettingsManager* settings, QObject* parent = nullptr);
    ~MusicPlayerController();

    Q_INVOKABLE void play();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void togglePlayPause();
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();
    Q_INVOKABLE void setPosition(int ms);
    Q_INVOKABLE void loadMusicLibrary(const QString& path);

    QString trackTitle() const { return m_trackTitle; }
    QString artistName() const { return m_artistName; }
    QString albumArtUrl() const { return m_albumArtUrl; }
    bool isPlaying() const;
    int duration() const;
    int position() const;
    int volume() const;
    void setVolume(int vol);
    QStringList trackList() const { return m_trackList; }
    int currentTrackIndex() const { return m_currentTrackIndex; }
    void setCurrentTrackIndex(int index);

signals:
    void playbackInfoChanged();
    void playStateChanged();
    void durationChanged();
    void positionChanged();
    void volumeChanged();
    void trackListChanged();
    void currentTrackIndexChanged();
    void error(const QString& message);

private slots:
    void onMediaStatusChanged(QMediaPlayer::MediaStatus status);
    void onPlaybackStateChanged(QMediaPlayer::PlaybackState state);
    void onDurationChanged(qint64 duration);
    void onPositionChanged(qint64 position);
    void onError(QMediaPlayer::Error error, const QString& errorString);

private:
    void scanMusicFolder(const QString& path);
    void extractMetadata();
    void extractTagLibMetadata(const QString& path);
    void extractAlbumArt(const QString& path);
    void applyMetadataFallbacks();

    QMediaPlayer m_mediaPlayer;
    QAudioOutput m_audioOutput;
    SettingsManager* m_settings;

    QString m_trackTitle;
    QString m_artistName;
    QString m_albumArtUrl;
    QStringList m_trackList;
    int m_currentTrackIndex = 0;
    qint64 m_duration = 0;
    qint64 m_position = 0;
};

} // namespace drivaui
