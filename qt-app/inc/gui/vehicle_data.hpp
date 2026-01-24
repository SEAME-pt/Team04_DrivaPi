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
    Q_PROPERTY(int battery READ getBattery WRITE setBattery NOTIFY batteryChanged)
    Q_PROPERTY(int temperature READ getTemperature WRITE setTemperature NOTIFY temperatureChanged)
    Q_PROPERTY(int distance READ getDistance WRITE setDistance NOTIFY distanceChanged)
    Q_PROPERTY(bool autonomousMode READ getAutonomousMode WRITE setAutonomousMode NOTIFY autonomousModeChanged)

public:
    /// @brief Construct VehicleData.
    explicit VehicleData(QObject *parent = nullptr);
    /// @brief Destructor.
    ~VehicleData() override;

    // ===== Getters =====
    float   getSpeed() const;
    double  getEnergy() const;
    int     getBattery() const;
    int     getDistance() const;
    int     getTemperature() const;
    QString getGear() const;
    bool    getAutonomousMode() const;

    // ===== Setters =====
    void    setSpeed(float mps);
    void    setEnergy(double energy);
    void    setBattery(int battery);
    void    setDistance(int distance);
    void    setGear(const QString &gear);
    void    setTemperature(int temperature);
    void    setAutonomousMode(bool mode);

    // ===== QML-Invokable Methods =====
    Q_INVOKABLE void toggleAutonomousMode();
    Q_INVOKABLE void resetValues();
    Q_INVOKABLE void resetTrip();
    Q_INVOKABLE void changeGearUp();
    Q_INVOKABLE void changeGearDown();

    void handleSpeedUpdate(float speed);

public slots:
    /// @brief Process CAN frame and update vehicle data.
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
    /// @brief Check all properties for staleness (timestamps exceed threshold).
    void checkStaleProperties();

private:
    // ===== Member Variables =====
    float   m_speed;
    double  m_energy;
    int     m_battery;
    int     m_distance;
    QString m_gear;
    int     m_temperature;
    bool    m_autonomousMode;

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
