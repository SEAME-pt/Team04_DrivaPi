/**
 * @file vehicle_data.hpp
 * @brief Vehicle telemetry data model exposed to QML (speed, battery, gear, etc.).
 * @note Thread-safe property setters for main thread; use queued connections from workers.
 */

#ifndef VEHICLEDATA_HPP
#define VEHICLEDATA_HPP

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QHash>
#include <QTimer>
#include <QDebug>
#include <QDateTime>
#include <QSettings>
#include <QtMath>

namespace drivaui {

/**
 * @class VehicleData
 * @brief QObject-based vehicle telemetry model for QML (properties, signals, staleness detection).
 */
class VehicleData : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString gear READ getGear WRITE setGear NOTIFY gearChanged)
    Q_PROPERTY(double speed READ getSpeed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(double energy READ getEnergy WRITE setEnergy NOTIFY energyChanged)

    Q_PROPERTY(int stm32Battery READ getStm32Battery WRITE setStm32Battery NOTIFY stm32BatteryChanged)
    Q_PROPERTY(double stm32BatteryVoltage READ getStm32BatteryVoltage WRITE setStm32BatteryVoltage NOTIFY stm32BatteryVoltageChanged)
    Q_PROPERTY(double stm32Temperature READ getStm32Temperature WRITE setStm32Temperature NOTIFY stm32TemperatureChanged)
    Q_PROPERTY(double stm32Humidity READ getStm32Humidity WRITE setStm32Humidity NOTIFY stm32HumidityChanged)

    Q_PROPERTY(int rpiBattery READ getRpiBattery WRITE setRpiBattery NOTIFY rpiBatteryChanged)
    Q_PROPERTY(int distance READ getDistance WRITE setDistance NOTIFY distanceChanged)
    Q_PROPERTY(int odo READ getOdometer WRITE setOdometer NOTIFY odometerChanged)
    Q_PROPERTY(bool autonomousMode READ getAutonomousMode WRITE setAutonomousMode NOTIFY autonomousModeChanged)

public:
    /// @brief Construct VehicleData.
    explicit VehicleData(QObject *parent = nullptr);
    /// @brief Destructor.
    ~VehicleData() override;

    // ===== Getters =====
    float   getSpeed() const;
    double  getEnergy() const;

    int     getStm32Battery() const;
    double  getStm32BatteryVoltage() const;
    double  getStm32Temperature() const;
    double  getStm32Humidity() const;

    int     getRpiBattery() const;
    int     getDistance() const;
    int     getOdometer() const;
    int     getTemperature() const;
    QString getGear() const;
    bool    getAutonomousMode() const;

    // ===== Setters =====
    void    setSpeed(float mps);
    void    setEnergy(double energy);

    void    setStm32Battery(int battery);
    void    setStm32BatteryVoltage(double volts);
    void    setStm32Temperature(double tempC);
    void    setStm32Humidity(double humidityPct);

    void    setRpiBattery(int battery);
    void    setDistance(int distance);
    void    setOdometer(int odo);
    void    setGear(const QString &gear);
    void    setTemperature(int temperature);
    void    setAutonomousMode(bool mode);

    // ===== QML-Invokable Methods =====
    Q_INVOKABLE void toggleAutonomousMode();
    Q_INVOKABLE void resetValues();
    Q_INVOKABLE void resetTrip();

    // Existing hook used in KUKSA mode
    void handleSpeedUpdate(float speed);

    // New hooks used in KUKSA mode
    void handleStm32BatteryUpdate(int percent);
    void handleStm32BatteryVoltageUpdate(float volts);
    void handleStm32TemperatureUpdate(float tempC);
    void handleStm32HumidityUpdate(float humidityPct);
    void handleCurrentGearUpdate(int currentGear); // VSS: 0=N, negative=R, positive=D/forward

public slots:
    /// @brief Process CAN frame and update vehicle data.
    void handleCanMessage(const QByteArray &payload, uint32_t canId);

signals:
    void speedChanged();
    void energyChanged();
    void batteryChanged();

    void stm32BatteryChanged();
    void stm32BatteryVoltageChanged();
    void stm32TemperatureChanged();
    void stm32HumidityChanged();

    void rpiBatteryChanged();
    void distanceChanged();
    void odometerChanged();
    void temperatureChanged();
    void gearChanged();
    void autonomousModeChanged();

private slots:
    /// @brief Check all properties for staleness (timestamps exceed threshold).
    void checkStaleProperties();

private:
    // ===== Member Variables =====
    float   m_speed;
    double  m_energy;
    int     m_battery;

    int     m_stm32Battery;
    double  m_stm32BatteryVoltage;
    double  m_stm32Temperature;
    double  m_stm32Humidity;

    int     m_rpiBattery;
    int     m_distance;
    int     m_odometer;
    QString m_gear;
    int     m_temperature;
    bool    m_autonomousMode;

    // ===== Persistence =====
    QSettings *m_settings;
    void loadOdometerFromSettings();
    void saveOdometerToSettings();

    // ===== Helpers =====
    void    updateTimestamp(const QString &propName);
    qint64  lastUpdate(const QString &propName) const;
    void    markPropertyStale(const QString &propName);
    int     getGearIndex() const;

    QHash<QString, qint64> m_lastUpdateMs;  ///< Property → last update time (ms).
    QTimer *m_watchdogTimer;                 ///< Stale detection timer.

    static constexpr qint64 SPEED_STALE_MS = 500;     // High-frequency timeout
    static constexpr qint64 OTHER_STALE_MS = 2000;    // Low-frequency timeout
};

}  // namespace drivaui

#endif // VEHICLEDATA_HPP
