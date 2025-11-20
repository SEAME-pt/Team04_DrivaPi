#ifndef VEHICLEDATA_H
#define VEHICLEDATA_H

#include <QObject>
#include <QString>
#include <QTimer> // <-- add this forward declaration
#include "can.hpp"

class QTimer; // <-- add this forward declaration

class VehicleData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString gear READ gear WRITE setGear NOTIFY gearChanged)
    Q_PROPERTY(int speed READ speed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(double energy READ energy WRITE setEnergy NOTIFY energyChanged)
    Q_PROPERTY(int battery READ battery WRITE setBattery NOTIFY batteryChanged)
    Q_PROPERTY(int temperature READ temperature WRITE setTemperature NOTIFY temperatureChanged)
    Q_PROPERTY(int distance READ distance WRITE setDistance NOTIFY distanceChanged)
    Q_PROPERTY(bool autonomousMode READ autonomousMode WRITE setAutonomousMode NOTIFY autonomousModeChanged)
    Q_PROPERTY(bool simulationRunning READ simulationRunning WRITE setSimulationRunning NOTIFY simulationRunningChanged)
    Q_PROPERTY(int simSpeed READ simSpeed WRITE setSimSpeed NOTIFY simSpeedChanged)


public:
    explicit VehicleData(QObject *parent = nullptr);
    ~VehicleData() override;

    Q_INVOKABLE void resetTrip();

    // Getters
    int     speed() const { return m_speed; }
    double  energy() const { return m_energy; }
    int     battery() const { return m_battery; }
    int     distance() const { return m_distance; }
    int     temperature() const { return m_temperature; }
    QString gear() const { return m_gear; }
    bool    autonomousMode() const { return m_autonomousMode; }
    bool    simulationRunning() const { return m_simulationRunning; }
    int     simSpeed() const { return m_simSpeed; }

    // Setters
    void    setSpeed(int speed);
    void    setEnergy(double energy);
    void    setBattery(int battery);
    void    setDistance(int distance);
    void    setGear(const QString &gear);
    void    setTemperature(int temperature);
    void    setAutonomousMode(bool mode);
    void    setSimulationRunning(bool running) {
        if (m_simulationRunning != running) {
            m_simulationRunning = running;
            emit simulationRunningChanged();
        }
    }
    void    setSimSpeed(int speed) {
        if (m_simSpeed != speed) {
            m_simSpeed = speed;
            updateTimerInterval();
            emit simSpeedChanged();
        }
    }

    std::string get_can_msg();
    // Q_INVOKABLE methods - callable from QML
    Q_INVOKABLE void startSimulation();
    Q_INVOKABLE void stopSimulation();
    Q_INVOKABLE void toggleAutonomousMode();
    Q_INVOKABLE void resetValues();
    Q_INVOKABLE void changeGearUp();
    Q_INVOKABLE void changeGearDown();
    Q_INVOKABLE void increaseSimSpeed();
    Q_INVOKABLE void decreaseSimSpeed();

signals:
    void speedChanged();
    void energyChanged();
    void batteryChanged();
    void distanceChanged();
    void temperatureChanged();
    void gearChanged();
    void autonomousModeChanged();
    void simulationRunningChanged();
    void simSpeedChanged();

private slots:
    void updateSimulation();

private:
    // Member variables
    int     m_speed;
    double  m_energy;
    int     m_battery;
    int     m_distance;
    QString m_gear;
    int     m_temperature;
    bool    m_autonomousMode;
    bool    m_simulationRunning;
    int     m_simSpeed;
    int     m_simulationStep;

    QTimer *m_simulationTimer;

    // Helper methods
    void updateTimerInterval();
    int getGearIndex() const;
};

#endif // VEHICLEDATA_H
