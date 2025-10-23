#ifndef VEHICLEDATA_H
#define VEHICLEDATA_H

#include <QObject>
#include <QString>
#include <QTimer>

/**
 * @brief VehicleData class - Manages all vehicle telemetry data
 *
 * This class acts as the data model for the HMI dashboard,
 * providing real-time updates for speed, energy, battery, etc.
 */
class VehicleData : public QObject
{
    Q_OBJECT

    // Properties exposed to QML
    Q_PROPERTY(int speed READ speed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(double energy READ energy WRITE setEnergy NOTIFY energyChanged)
    Q_PROPERTY(int battery READ battery WRITE setBattery NOTIFY batteryChanged)
    Q_PROPERTY(int distance READ distance WRITE setDistance NOTIFY distanceChanged)
    Q_PROPERTY(QString gear READ gear WRITE setGear NOTIFY gearChanged)
    Q_PROPERTY(int temperature READ temperature WRITE setTemperature NOTIFY temperatureChanged)
    Q_PROPERTY(bool autonomousMode READ autonomousMode WRITE setAutonomousMode NOTIFY autonomousModeChanged)
    Q_PROPERTY(bool simulationRunning READ simulationRunning NOTIFY simulationRunningChanged)
    Q_PROPERTY(int simSpeed READ simSpeed NOTIFY simSpeedChanged)

public:
    explicit VehicleData(QObject *parent = nullptr);
    ~VehicleData();

    // Getters
    int speed() const { return m_speed; }
    double energy() const { return m_energy; }
    int battery() const { return m_battery; }
    int distance() const { return m_distance; }
    QString gear() const { return m_gear; }
    int temperature() const { return m_temperature; }
    bool autonomousMode() const { return m_autonomousMode; }
    bool simulationRunning() const { return m_simulationRunning; }
    int simSpeed() const { return m_simSpeed; }

    // Setters
    void setSpeed(int speed);
    void setEnergy(double energy);
    void setBattery(int battery);
    void setDistance(int distance);
    void setGear(const QString &gear);
    void setTemperature(int temperature);
    void setAutonomousMode(bool mode);

    // Q_INVOKABLE methods - callable from QML
    Q_INVOKABLE void startSimulation();
    Q_INVOKABLE void stopSimulation();
    Q_INVOKABLE void toggleAutonomousMode();
    Q_INVOKABLE void resetValues();
    Q_INVOKABLE void resetTrip();
    Q_INVOKABLE void changeGearUp();
    Q_INVOKABLE void changeGearDown();
    Q_INVOKABLE void increaseSimSpeed();
    Q_INVOKABLE void decreaseSimSpeed();

signals:
    void speedChanged();
    void energyChanged();
    void batteryChanged();
    void distanceChanged();
    void gearChanged();
    void temperatureChanged();
    void autonomousModeChanged();
    void simulationRunningChanged();
    void simSpeedChanged();

private slots:
    void updateSimulation();

private:
    // Member variables
    int m_speed;
    double m_energy;
    int m_battery;
    int m_distance;
    QString m_gear;
    int m_temperature;
    bool m_autonomousMode;
    bool m_simulationRunning;
    int m_simSpeed;
    int m_simulationStep;

    QTimer *m_simulationTimer;

    // Helper methods
    void updateTimerInterval();
    int getGearIndex() const;
};

#endif // VEHICLEDATA_H
