#include "gui/settings_manager.hpp"
#include <QStandardPaths>
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QCoreApplication>

SettingsManager::SettingsManager(QObject* parent) : QObject(parent) {
    m_configPath = getConfigPath();
    loadSettings();
}

QString SettingsManager::getConfigPath() const {
    QString configDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(configDir);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    return configDir + "/settings.json";
}

void SettingsManager::loadSettings() {
    QFile file(m_configPath);
    if (file.exists() && file.open(QIODevice::ReadOnly)) {
        QByteArray data = file.readAll();
        QJsonDocument doc = QJsonDocument::fromJson(data);
        if (doc.isObject()) {
            m_settings = doc.object();
        }
        file.close();
        qDebug() << "Settings loaded from:" << m_configPath;
    } else {
        qDebug() << "Creating new settings file at:" << m_configPath;
        // Set defaults - use the mp3 folder in the project
        QString projectMp3Path = QCoreApplication::applicationDirPath() + "/../mp3";
        m_settings["lastPlayedTrack"] = "";
        m_settings["volume"] = 50;
        m_settings["musicLibraryPath"] = projectMp3Path;
        m_settings["theme"] = "dark";
        saveSettings();
    }
}

void SettingsManager::saveSettings() {
    QFile file(m_configPath);
    if (file.open(QIODevice::WriteOnly)) {
        QJsonDocument doc(m_settings);
        file.write(doc.toJson());
        file.close();
        qDebug() << "Settings saved to:" << m_configPath;
    } else {
        qWarning() << "Failed to save settings to:" << m_configPath;
    }
}

QVariant SettingsManager::get(const QString& key, const QVariant& defaultValue) {
    if (m_settings.contains(key)) {
        return m_settings.value(key).toVariant();
    }
    return defaultValue;
}

void SettingsManager::set(const QString& key, const QVariant& value) {
    m_settings[key] = QJsonValue::fromVariant(value);
    saveSettings();
    emit settingChanged(key);
}

QString SettingsManager::lastPlayedTrack() const {
    return m_settings.contains("lastPlayedTrack") ? m_settings.value("lastPlayedTrack").toString() : "";
}

void SettingsManager::setLastPlayedTrack(const QString& track) {
    m_settings["lastPlayedTrack"] = track;
    saveSettings();
    emit lastPlayedTrackChanged();
}

int SettingsManager::volume() const {
    return m_settings.contains("volume") ? m_settings.value("volume").toInt() : 50;
}

void SettingsManager::setVolume(int vol) {
    int clampedVol = qBound(0, vol, 100);
    m_settings["volume"] = clampedVol;
    saveSettings();
    emit volumeChanged();
}

QString SettingsManager::musicLibraryPath() const {
    return m_settings.contains("musicLibraryPath") ? m_settings.value("musicLibraryPath").toString() : QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
}

void SettingsManager::setMusicLibraryPath(const QString& path) {
    m_settings["musicLibraryPath"] = path;
    saveSettings();
    emit musicLibraryPathChanged();
}

QString SettingsManager::theme() const {
    return m_settings.contains("theme") ? m_settings.value("theme").toString() : "dark";
}

void SettingsManager::setTheme(const QString& thm) {
    m_settings["theme"] = thm;
    saveSettings();
    emit themeChanged();
}
