/**
 * @file settings_manager.cpp
 * @author DrivaPi Team
 * @brief Persistent application settings implementation — JSON load/save.
 */

#include "settings_manager.hpp"
#include <QStandardPaths>
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QCoreApplication>

namespace drivaui {

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

QString SettingsManager::getDefaultMusicPath() const {
    // Production path (AGL): /usr/mp3
    QString aglPath = "/usr/mp3";
    if (QDir(aglPath).exists()) {
        qDebug() << "Using AGL music path:" << aglPath;
        return aglPath;
    }

    // Development fallback: project-relative music/mp3
    QString devPath = QCoreApplication::applicationDirPath() + "/music/mp3";
    if (QDir(devPath).exists()) {
        qDebug() << "Using development music path:" << devPath;
        return devPath;
    }

    // Last resort: user's Music folder
    QString musicDir = QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
    qDebug() << "Using fallback music path:" << musicDir;
    return musicDir;
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
        // Set defaults
        m_settings["lastPlayedTrack"] = "";
        m_settings["volume"] = 50;
        m_settings["musicLibraryPath"] = getDefaultMusicPath();  // Auto-detect path
        m_settings["theme"] = "dark";
        m_settings["screenBrightness"] = 0.75;
        m_settings["speedUnit"] = "km/h";
        m_settings["temperatureUnit"] = "°C";
        m_settings["distanceUnit"] = "km";
        m_settings["windSpeedUnit"] = "m/s";
        m_settings["precipitationUnit"] = "mm";
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

QVariant SettingsManager::get(const QString& key, const QVariant& defaultValue) const {
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
    return get("lastPlayedTrack", "").toString();
}

void SettingsManager::setLastPlayedTrack(const QString& track) {
    m_settings["lastPlayedTrack"] = track;
    saveSettings();
    emit lastPlayedTrackChanged();
}

int SettingsManager::volume() const {
    return get("volume", 50).toInt();
}

void SettingsManager::setVolume(int vol) {
    int clampedVol = qBound(0, vol, 100);
    m_settings["volume"] = clampedVol;
    saveSettings();
    emit volumeChanged();
}

QString SettingsManager::musicLibraryPath() const {
    // Return the configured path; if missing, auto-detect
    if (m_settings.contains("musicLibraryPath")) {
        QString configuredPath = m_settings.value("musicLibraryPath").toString();
        if (!configuredPath.isEmpty() && QDir(configuredPath).exists()) {
            return configuredPath;
        }
    }
    // Fall back to auto-detection if configured path doesn't exist
    return getDefaultMusicPath();
}

void SettingsManager::setMusicLibraryPath(const QString& path) {
    // Validate path exists before saving
    if (QDir(path).exists()) {
        m_settings["musicLibraryPath"] = path;
        saveSettings();
        emit musicLibraryPathChanged();
        qDebug() << "Music library path updated to:" << path;
    } else {
        qWarning() << "Music library path does not exist:" << path;
    }
}

QString SettingsManager::theme() const {
    return get("theme", "dark").toString();
}

void SettingsManager::setTheme(const QString& thm) {
    m_settings["theme"] = thm;
    saveSettings();
    emit themeChanged();
}

double SettingsManager::screenBrightness() const {
    return get("screenBrightness", 0.75).toDouble();
}

void SettingsManager::setScreenBrightness(double brightness) {
    m_settings["screenBrightness"] = brightness;
    saveSettings();
    emit screenBrightnessChanged();
}

QString SettingsManager::speedUnit() const {
    return get("speedUnit", "km/h").toString();
}

void SettingsManager::setSpeedUnit(const QString& unit) {
    m_settings["speedUnit"] = unit;
    saveSettings();
    emit speedUnitChanged();
}

QString SettingsManager::temperatureUnit() const {
    return get("temperatureUnit", "°C").toString();
}

void SettingsManager::setTemperatureUnit(const QString& unit) {
    m_settings["temperatureUnit"] = unit;
    saveSettings();
    emit temperatureUnitChanged();
}

QString SettingsManager::distanceUnit() const {
    return get("distanceUnit", "km").toString();
}

void SettingsManager::setDistanceUnit(const QString& unit) {
    m_settings["distanceUnit"] = unit;
    saveSettings();
    emit distanceUnitChanged();
}

QString SettingsManager::windSpeedUnit() const {
    return get("windSpeedUnit", "m/s").toString();
}

void SettingsManager::setWindSpeedUnit(const QString& unit) {
    m_settings ["windSpeedUnit"] = unit;
    saveSettings();
    emit windSpeedUnitChanged();
}

QString SettingsManager::precipitationUnit() const {
    return get("precipitationUnit", "mm").toString();
}

void SettingsManager::setPrecipitationUnit(const QString& unit) {
    m_settings["precipitationUnit"] = unit;
    saveSettings();
    emit precipitationUnitChanged();
}

} // namespace drivaui
