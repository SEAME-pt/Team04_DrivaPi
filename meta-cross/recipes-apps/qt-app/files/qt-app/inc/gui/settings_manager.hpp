#pragma once
#include <QObject>
#include <QString>
#include <QJsonObject>
#include <QJsonDocument>
#include <QVariant>

class SettingsManager : public QObject {
    Q_OBJECT

public:
    explicit SettingsManager(QObject* parent = nullptr);

    // Generic get/set for any setting
    Q_INVOKABLE QVariant get(const QString& key, const QVariant& defaultValue = QVariant());
    Q_INVOKABLE void set(const QString& key, const QVariant& value);

    // Specific properties for quick access
    Q_PROPERTY(QString lastPlayedTrack READ lastPlayedTrack WRITE setLastPlayedTrack NOTIFY lastPlayedTrackChanged)
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(QString musicLibraryPath READ musicLibraryPath WRITE setMusicLibraryPath NOTIFY musicLibraryPathChanged)
    Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY themeChanged)

    QString lastPlayedTrack() const;
    void setLastPlayedTrack(const QString& track);

    int volume() const;
    void setVolume(int vol);

    QString musicLibraryPath() const;
    void setMusicLibraryPath(const QString& path);

    QString theme() const;
    void setTheme(const QString& thm);

	QString getDefaultMusicPath() const;

signals:
    void lastPlayedTrackChanged();
    void volumeChanged();
    void musicLibraryPathChanged();
    void themeChanged();
    void settingChanged(const QString& key);

private:
    void loadSettings();
    void saveSettings();
    QString getConfigPath() const;

    QJsonObject m_settings;
    QString m_configPath;
};
