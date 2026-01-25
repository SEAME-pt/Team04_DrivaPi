#include "gui/spotify_controller.hpp"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDesktopServices>
#include <QUrlQuery>
#include <QNetworkRequest>
#include <QNetworkReply>

// TODO: Fill in your Spotify app credentials
static const QString CLIENT_ID = "YOUR_CLIENT_ID";
static const QString CLIENT_SECRET = "YOUR_CLIENT_SECRET";
static const QString REDIRECT_URI = "http://localhost:8888/callback";

SpotifyController::SpotifyController(QObject* parent) : QObject(parent) {
    connect(&m_pollTimer, &QTimer::timeout, this, &SpotifyController::fetchPlaybackInfo);
    m_pollTimer.start(5000); // Poll every 5 seconds
}

void SpotifyController::authenticate() {
    // Open Spotify OAuth2 login in browser
    QUrl url("https://accounts.spotify.com/authorize");
    QUrlQuery query;
    query.addQueryItem("client_id", CLIENT_ID);
    query.addQueryItem("response_type", "token");
    query.addQueryItem("redirect_uri", REDIRECT_URI);
    query.addQueryItem("scope", "user-read-playback-state user-modify-playback-state");
    url.setQuery(query);
    QDesktopServices::openUrl(url);
    emit authenticationRequired();
}

void SpotifyController::fetchPlaybackInfo() {
    if (m_accessToken.isEmpty()) return;
    QNetworkRequest req(QUrl("https://api.spotify.com/v1/me/player/currently-playing"));
    req.setRawHeader("Authorization", "Bearer " + m_accessToken.toUtf8());
    QNetworkReply* reply = m_network.get(req);
    connect(reply, &QNetworkReply::finished, [this, reply]() { handleNetworkReply(reply); });
}

void SpotifyController::handleNetworkReply(QNetworkReply* reply) {
    if (reply->error() != QNetworkReply::NoError) {
        reply->deleteLater();
        return;
    }
    QByteArray data = reply->readAll();
    updatePlaybackInfo(data);
    reply->deleteLater();
}

void SpotifyController::updatePlaybackInfo(const QByteArray& data) {
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isObject()) return;
    QJsonObject obj = doc.object();
    if (!obj.contains("item")) return;
    QJsonObject item = obj["item"].toObject();
    m_trackTitle = item["name"].toString();
    QJsonArray artists = item["artists"].toArray();
    m_artistName = artists.size() > 0 ? artists[0].toObject()["name"].toString() : "";
    m_albumArtUrl = item["album"].toObject()["images"].toArray()[0].toObject()["url"].toString();
    m_isPlaying = obj["is_playing"].toBool();
    emit playbackInfoChanged();
}


void SpotifyController::playPause() {
    if (m_accessToken.isEmpty()) return;
    QNetworkRequest req(QUrl("https://api.spotify.com/v1/me/player/play"));
    req.setRawHeader("Authorization", "Bearer " + m_accessToken.toUtf8());
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    // Toggle play/pause based on current state
    QString endpoint = m_isPlaying ? "https://api.spotify.com/v1/me/player/pause" : "https://api.spotify.com/v1/me/player/play";
    req.setUrl(QUrl(endpoint));
    QNetworkReply* reply = m_network.put(req, QByteArray());
    connect(reply, &QNetworkReply::finished, reply, &QNetworkReply::deleteLater);
}

void SpotifyController::nextTrack() {
    if (m_accessToken.isEmpty()) return;
    QNetworkRequest req(QUrl("https://api.spotify.com/v1/me/player/next"));
    req.setRawHeader("Authorization", "Bearer " + m_accessToken.toUtf8());
    QNetworkReply* reply = m_network.post(req, QByteArray());
    connect(reply, &QNetworkReply::finished, reply, &QNetworkReply::deleteLater);
}

void SpotifyController::previousTrack() {
    if (m_accessToken.isEmpty()) return;
    QNetworkRequest req(QUrl("https://api.spotify.com/v1/me/player/previous"));
    req.setRawHeader("Authorization", "Bearer " + m_accessToken.toUtf8());
    QNetworkReply* reply = m_network.post(req, QByteArray());
    connect(reply, &QNetworkReply::finished, reply, &QNetworkReply::deleteLater);
}

void SpotifyController::refreshTokenIfNeeded() {
    // Example: refresh token if expired (requires storing refresh token and expiry)
    if (m_refreshToken.isEmpty()) return;
    QUrl url("https://accounts.spotify.com/api/token");
    QNetworkRequest req(url);
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    QUrlQuery params;
    params.addQueryItem("grant_type", "refresh_token");
    params.addQueryItem("refresh_token", m_refreshToken);
    params.addQueryItem("client_id", CLIENT_ID);
    params.addQueryItem("client_secret", CLIENT_SECRET);
    QNetworkReply* reply = m_network.post(req, params.query(QUrl::FullyEncoded).toUtf8());
    connect(reply, &QNetworkReply::finished, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
            QJsonObject obj = doc.object();
            m_accessToken = obj["access_token"].toString();
            // Optionally update m_refreshToken if present
        }
        reply->deleteLater();
    });
}

QString SpotifyController::trackTitle() const { return m_trackTitle; }
QString SpotifyController::artistName() const { return m_artistName; }
QString SpotifyController::albumArtUrl() const { return m_albumArtUrl; }
bool SpotifyController::isPlaying() const { return m_isPlaying; }

