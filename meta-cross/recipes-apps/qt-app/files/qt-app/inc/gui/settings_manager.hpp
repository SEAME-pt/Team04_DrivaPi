/**
 * @file settings_manager.hpp
 * @author DrivaPi Team
 * @brief Persistent application settings manager backed by JSON on disk.
 */

#pragma once
#include <QObject>
#include <QString>
#include <QJsonObject>
#include <QJsonDocument>
#include <QVariant>

namespace drivaui {

class SettingsManager : public QObject {
    Q_OBJECT

public:
    explicit SettingsManager(QObject* parent = nullptr);

    // Generic get/set for any setting
    Q_INVOKABLE QVariant get(const QString& key, const QVariant& defaultValue = QVariant()) const;
    Q_INVOKABLE void set(const QString& key, const QVariant& value);

    // Specific properties for quick access
    Q_PROPERTY(QString lastPlayedTrack READ lastPlayedTrack WRITE setLastPlayedTrack NOTIFY lastPlayedTrackChanged)
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(QString musicLibraryPath READ musicLibraryPath WRITE setMusicLibraryPath NOTIFY musicLibraryPathChanged)
    Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY themeChanged)

    Q_PROPERTY(double screenBrightness READ screenBrightness WRITE setScreenBrightness NOTIFY screenBrightnessChanged)
    Q_PROPERTY(QString speedUnit READ speedUnit WRITE setSpeedUnit NOTIFY speedUnitChanged)
    Q_PROPERTY(QString temperatureUnit READ temperatureUnit WRITE setTemperatureUnit NOTIFY temperatureUnitChanged)
    Q_PROPERTY(QString distanceUnit READ distanceUnit WRITE setDistanceUnit NOTIFY distanceUnitChanged)
    Q_PROPERTY(QString windSpeedUnit READ windSpeedUnit WRITE setWindSpeedUnit NOTIFY windSpeedUnitChanged)
    Q_PROPERTY(QString precipitationUnit READ precipitationUnit WRITE setPrecipitationUnit NOTIFY precipitationUnitChanged)

    QString lastPlayedTrack() const;
    void setLastPlayedTrack(const QString& track);

    int volume() const;
    void setVolume(int vol);

    QString musicLibraryPath() const;
    void setMusicLibraryPath(const QString& path);

    QString theme() const;
    void setTheme(const QString& thm);

    double screenBrightness() const;
    void setScreenBrightness(double brightness);

    QString speedUnit() const;
    void setSpeedUnit(const QString& unit);

    QString temperatureUnit() const;
    void setTemperatureUnit(const QString& unit);

    QString distanceUnit() const;
    void setDistanceUnit(const QString& unit);

    QString windSpeedUnit() const;
    void setWindSpeedUnit(const QString& unit);

    QString precipitationUnit() const;
    void setPrecipitationUnit(const QString& unit);

    QString getDefaultMusicPath() const;

signals:
    void lastPlayedTrackChanged();
    void volumeChanged();
    void musicLibraryPathChanged();
    void themeChanged();
    void settingChanged(const QString& key);
    void screenBrightnessChanged();
    void speedUnitChanged();
    void temperatureUnitChanged();
    void distanceUnitChanged();
    void windSpeedUnitChanged();
    void precipitationUnitChanged();
    
private:
    void loadSettings();
    void saveSettings();
    QString getConfigPath() const;

    QJsonObject m_settings;
    QString m_configPath;
};

} // namespace drivaui
