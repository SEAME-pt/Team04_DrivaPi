/**
 * @file vehicle_data.hpp
 * @author DrivaPi Team
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
#include <QDateTime>
#include <QtMath>

class QSettings;

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
    Q_PROPERTY(float stm32BatteryVoltage READ getStm32BatteryVoltage WRITE setStm32BatteryVoltage NOTIFY stm32BatteryVoltageChanged)
    Q_PROPERTY(float stm32Temperature READ getStm32Temperature WRITE setStm32Temperature NOTIFY stm32TemperatureChanged)
    Q_PROPERTY(float stm32Humidity READ getStm32Humidity WRITE setStm32Humidity NOTIFY stm32HumidityChanged)

    Q_PROPERTY(int rpiBattery READ getRpiBattery WRITE setRpiBattery NOTIFY rpiBatteryChanged)
    Q_PROPERTY(double rpiBatteryVoltage READ getRpiBatteryVoltage WRITE setRpiBatteryVoltage NOTIFY rpiBatteryVoltageChanged)
    Q_PROPERTY(int distance READ getDistance WRITE setDistance NOTIFY distanceChanged)
    Q_PROPERTY(int odo READ getOdometer WRITE setOdometer NOTIFY odometerChanged)
    Q_PROPERTY(bool autonomousMode READ getAutonomousMode WRITE setAutonomousMode NOTIFY autonomousModeChanged)
    Q_PROPERTY(int temperature READ getTemperature WRITE setTemperature NOTIFY temperatureChanged)

public:
    /// @brief Construct VehicleData.
    explicit VehicleData(QObject *parent = nullptr);
    /// @brief Destructor.
    ~VehicleData() override;

    // ===== Getters =====
    float   getSpeed() const;
    double  getEnergy() const;

    int     getStm32Battery() const;
    float   getStm32BatteryVoltage() const;
    float   getStm32Temperature() const;
    float   getStm32Humidity() const;

    int     getRpiBattery() const;
    double  getRpiBatteryVoltage() const;
    int     getDistance() const;
    int     getOdometer() const;
    int     getTemperature() const;
    QString getGear() const;
    bool    getAutonomousMode() const;

    // ===== Setters =====
    void    setSpeed(float mps);
    void    setEnergy(double energy);

    void    setStm32Battery(int battery);
    void    setStm32BatteryVoltage(float volts);
    void    setStm32Temperature(float tempC);
    void    setStm32Humidity(float humidityPct);
    void    setRpiBattery(int battery);
    void    setRpiBatteryVoltage(double volts);
    void    setDistance(int distance);
    void    setOdometer(int odo);
    void    setGear(const QString &gear);
    void    setTemperature(int temperature);
    void    setAutonomousMode(bool mode);

    // ===== QML-Invokable Methods =====
    Q_INVOKABLE void toggleAutonomousMode();
    Q_INVOKABLE void resetValues();
    Q_INVOKABLE void resetTrip();

    void handleCurrentGearUpdate(int currentGear); ///< Maps VSS int (0=N, neg=R, pos=D) to gear string.

public slots:
    /// @brief Process CAN frame and update vehicle data.
    void handleCanMessage(const QByteArray &payload, uint32_t canId);

signals:
    void speedChanged();
    void energyChanged();

    void stm32BatteryChanged();
    void stm32BatteryVoltageChanged();
    void stm32TemperatureChanged();
    void stm32HumidityChanged();

    void rpiBatteryChanged();
    void rpiBatteryVoltageChanged();
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

    int     m_stm32Battery;
    float   m_stm32BatteryVoltage;
    float   m_stm32Temperature;
    float   m_stm32Humidity;

    int     m_rpiBattery;
    double  m_rpiBatteryVoltage;
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

    QHash<QString, qint64> m_lastUpdateMs;  ///< Property → last update time (ms).
    QTimer *m_watchdogTimer;                 ///< Stale detection timer.

    static constexpr qint64 SPEED_STALE_MS = 500;     // High-frequency timeout
    static constexpr qint64 OTHER_STALE_MS = 2000;    // Low-frequency timeout
};

}  // namespace drivaui

#endif // VEHICLEDATA_HPP
