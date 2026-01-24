#include "SpotifyController.h"
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
    // ... implement play/pause using Spotify API ...
}
void SpotifyController::nextTrack() {
    // ... implement next track using Spotify API ...
}
void SpotifyController::previousTrack() {
    // ... implement previous track using Spotify API ...
}

QString SpotifyController::trackTitle() const { return m_trackTitle; }
QString SpotifyController::artistName() const { return m_artistName; }
QString SpotifyController::albumArtUrl() const { return m_albumArtUrl; }
bool SpotifyController::isPlaying() const { return m_isPlaying; }

void SpotifyController::refreshTokenIfNeeded() {
    // ... implement token refresh if needed ...
}
