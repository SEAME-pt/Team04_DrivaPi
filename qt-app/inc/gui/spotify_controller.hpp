#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QTimer>

class SpotifyController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString trackTitle READ trackTitle NOTIFY playbackInfoChanged)
    Q_PROPERTY(QString artistName READ artistName NOTIFY playbackInfoChanged)
    Q_PROPERTY(QString albumArtUrl READ albumArtUrl NOTIFY playbackInfoChanged)
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY playbackInfoChanged)
public:
    explicit SpotifyController(QObject* parent = nullptr);

    Q_INVOKABLE void authenticate();
    Q_INVOKABLE void playPause();
    Q_INVOKABLE void nextTrack();
    Q_INVOKABLE void previousTrack();

    QString trackTitle() const;
    QString artistName() const;
    QString albumArtUrl() const;
    bool isPlaying() const;

signals:
    void playbackInfoChanged();
    void authenticationRequired();

private slots:
    void fetchPlaybackInfo();
    void handleNetworkReply(QNetworkReply* reply);

private:
    void refreshTokenIfNeeded();
    void updatePlaybackInfo(const QByteArray& data);
    QNetworkAccessManager m_network;
    QTimer m_pollTimer;
    QString m_accessToken;
    QString m_refreshToken;
    QString m_trackTitle;
    QString m_artistName;
    QString m_albumArtUrl;
    bool m_isPlaying = false;
};
