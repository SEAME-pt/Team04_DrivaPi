#ifndef VEHICLEDATA_HPP
#define VEHICLEDATA_HPP

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QHash>
#include <QTimer>

class VehicleData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString gear READ getGear WRITE setGear NOTIFY gearChanged)
    Q_PROPERTY(double speed READ getSpeed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(double energy READ getEnergy WRITE setEnergy NOTIFY energyChanged)
    Q_PROPERTY(int battery READ getBattery WRITE setBattery NOTIFY batteryChanged)
    Q_PROPERTY(int temperature READ getTemperature WRITE setTemperature NOTIFY temperatureChanged)
    Q_PROPERTY(int distance READ getDistance WRITE setDistance NOTIFY distanceChanged)
    Q_PROPERTY(bool autonomousMode READ getAutonomousMode WRITE setAutonomousMode NOTIFY autonomousModeChanged)

public:
    explicit VehicleData(QObject *parent = nullptr);
    ~VehicleData() override;

    Q_INVOKABLE void resetTrip();

    // Getters
	double  getSpeed() const;
	double  getEnergy() const;
	int     getBattery() const;
	int     getDistance() const;
    int     getTemperature() const;
    QString getGear() const;
    bool    getAutonomousMode() const;

    // Setters
    void    setSpeed(int speed);
    void    setEnergy(double energy);
    void    setBattery(int battery);
    void    setDistance(int distance);
    void    setGear(const QString &gear);
    void    setTemperature(int temperature);
    void    setAutonomousMode(bool mode);

    // Q_INVOKABLE methods - callable from QML
    Q_INVOKABLE void toggleAutonomousMode();
    Q_INVOKABLE void resetValues();
    Q_INVOKABLE void resetTrip();
    Q_INVOKABLE void changeGearUp();
    Q_INVOKABLE void changeGearDown();

public slots:
    // Called by CANReader (queued connection) with raw payload + canId
    void handleCanMessage(const QByteArray &payload, uint32_t canId);

signals:
    void speedChanged();
    void energyChanged();
    void batteryChanged();
    void distanceChanged();
    void temperatureChanged();
    void gearChanged();
    void autonomousModeChanged();

private slots:
    // Single watchdog that checks timestamps for all properties
    void checkStaleProperties();

private:

    // Internal helpers
    void    updateTimestamp(const QString &propName);
    qint64  lastUpdate(const QString &propName) const;
    void    markPropertyStale(const QString &propName);

    // Member variables
    double  m_speed;
    double  m_energy;
    int     m_battery;
    int     m_distance;
    QString m_gear;
    int     m_temperature;
    bool    m_autonomousMode;

    // Helper methods
    int getGearIndex() const;

	// timestamps: property name -> last update epoch ms
    QHash<QString, qint64> m_lastUpdateMs;

    // watchdog timer (single)
    QTimer *m_watchdogTimer;

    // Stale thresholds (ms)
    static constexpr qint64 SPEED_STALE_MS = 500;     // speed is high-rate -> short timeout
    static constexpr qint64 OTHER_STALE_MS = 2000;    // other properties slower
};

#endif // VEHICLEDATA_HPP
