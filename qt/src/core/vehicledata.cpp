#include "vehicledata.h"
#include <QDebug>
#include <QRandomGenerator>
#include <QtMath>

VehicleData::VehicleData(QObject *parent)
    : QObject(parent)
    , m_speed(0)
    , m_energy(100.0)
    , m_battery(100)
    , m_distance(0)
    , m_gear("P")
    , m_temperature(20)
    , m_autonomousMode(false)
    , m_simulationRunning(false)
    , m_simSpeed(1)
    , m_simulationStep(0)
    , m_simulationTimer(new QTimer(this))
{
    qDebug() << "VehicleData initialized";

    connect(m_simulationTimer, &QTimer::timeout, this, &VehicleData::updateSimulation);
    m_simulationTimer->setInterval(1000); // Update every 1 second (more realistic)
}

VehicleData::~VehicleData()
{
    qDebug() << "VehicleData destroyed";
}

void VehicleData::setSpeed(int speed)
{
    if (m_speed != speed) {
        m_speed = speed;
        emit speedChanged();
    }
}

void VehicleData::setEnergy(double energy)
{
    if (qAbs(m_energy - energy) > 0.01) {
        m_energy = energy;
        emit energyChanged();
    }
}

void VehicleData::setBattery(int battery)
{
    if (m_battery != battery) {
        m_battery = battery;
        emit batteryChanged();
    }
}

void VehicleData::setDistance(int distance)
{
    if (m_distance != distance) {
        m_distance = distance;
        emit distanceChanged();
    }
}

void VehicleData::setGear(const QString &gear)
{
    if (m_gear != gear) {
        m_gear = gear;
        qDebug() << "Gear changed to:" << m_gear;
        emit gearChanged();
    }
}

void VehicleData::setTemperature(int temperature)
{
    if (m_temperature != temperature) {
        m_temperature = temperature;
        emit temperatureChanged();
    }
}

void VehicleData::setAutonomousMode(bool mode)
{
    if (m_autonomousMode != mode) {
        m_autonomousMode = mode;
        qDebug() << "Autonomous mode:" << (m_autonomousMode ? "ON" : "OFF");
        emit autonomousModeChanged();
    }
}

void VehicleData::startSimulation()
{
    if (!m_simulationRunning) {
        m_simulationRunning = true;
        m_simulationStep = 0;
        m_simulationTimer->start();
        setGear("D");
        qDebug() << "Simulation started";
        emit simulationRunningChanged();
    }
}

void VehicleData::stopSimulation()
{
    if (m_simulationRunning) {
        m_simulationRunning = false;
        m_simulationTimer->stop();
        setSpeed(0);
        setGear("P");
        qDebug() << "Simulation stopped";
        emit simulationRunningChanged();
    }
}

void VehicleData::toggleAutonomousMode()
{
    setAutonomousMode(!m_autonomousMode);
}

void VehicleData::resetValues()
{
    setSpeed(0);
    setEnergy(100.0);
    setBattery(100);
    setDistance(0);
    setGear("P");
    setTemperature(20);
    setAutonomousMode(false);
    qDebug() << "Values reset";
}

void VehicleData::resetTrip()
{
    setDistance(0);
    qDebug() << "Trip distance reset";
}

int VehicleData::getGearIndex() const
{
    QStringList gears = {"P", "R", "N", "D"};
    return gears.indexOf(m_gear);
}

void VehicleData::changeGearUp()
{
    int currentIndex = getGearIndex();
    QStringList gears = {"P", "R", "N", "D"};
    if (currentIndex >= 0 && currentIndex < gears.length() - 1) {
        setGear(gears[currentIndex + 1]);
    }
}

void VehicleData::changeGearDown()
{
    int currentIndex = getGearIndex();
    QStringList gears = {"P", "R", "N", "D"};
    if (currentIndex > 0) {
        setGear(gears[currentIndex - 1]);
    }
}

void VehicleData::increaseSimSpeed()
{
    if (m_simSpeed < 5) {
        m_simSpeed++;
        updateTimerInterval();
        emit simSpeedChanged();
        qDebug() << "Simulation speed increased to" << m_simSpeed << "x";
    }
}

void VehicleData::decreaseSimSpeed()
{
    if (m_simSpeed > 1) {
        m_simSpeed--;
        updateTimerInterval();
        emit simSpeedChanged();
        qDebug() << "Simulation speed decreased to" << m_simSpeed << "x";
    }
}

void VehicleData::updateTimerInterval()
{
    // Base interval is 1000ms (1 second), divided by speed multiplier
    int interval = 1000 / m_simSpeed;
    m_simulationTimer->setInterval(interval);
    qDebug() << "Timer interval set to" << interval << "ms";
}

void VehicleData::updateSimulation()
{
    if (!m_simulationRunning) {
        return;
    }

    m_simulationStep++;

    // Smoother, more realistic speed changes
    // Speed oscillates between 40-100 km/h with a slow sine wave
    double speedFactor = qSin(m_simulationStep * 0.02) * 0.3 + 0.7;  // 0.4 to 1.0
    int targetSpeed = static_cast<int>(speedFactor * 100);            // 40-100 km/h

    // Gradual speed change (accelerate/decelerate by max 5 km/h per update)
    int speedDiff = targetSpeed - m_speed;
    int speedChange = qBound(-5, speedDiff, 5);
    int newSpeed = qBound(0, m_speed + speedChange, 120);
    setSpeed(newSpeed);

    // Energy consumption based on speed (more realistic)
    double energyConsumption = (m_speed / 120.0) * 0.02 * m_simSpeed;  // Reduced consumption
    double newEnergy = qMax(0.0, m_energy - energyConsumption);
    setEnergy(newEnergy);

    // Update battery
    int newBattery = qMax(0, static_cast<int>(newEnergy));
    setBattery(newBattery);

    // Distance calculation (km traveled per second at current speed)
    // speed (km/h) / 3600 (seconds per hour) = km per second
    double distanceIncrement = (m_speed / 3600.0) * m_simSpeed;
    setDistance(m_distance + static_cast<int>(distanceIncrement * 10));  // x10 for visible changes

    // Temperature changes (very slow, every 20 seconds)
    if (m_simulationStep % 20 == 0) {
        int tempChange = QRandomGenerator::global()->bounded(-1, 2);
        int newTemp = qBound(15, m_temperature + tempChange, 30);
        setTemperature(newTemp);
    }

    // Stop if battery depleted
    if (m_battery <= 0) {
        stopSimulation();
        qDebug() << "Battery depleted! Simulation stopped.";
    }
}
