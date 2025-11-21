#include "vehicledata.hpp"
#include <QDebug>

VehicleData::VehicleData(QObject *parent)
    : QObject(parent)
    , m_speed(0)
    , m_energy(100.0)
    , m_battery(100)
    , m_distance(0)
    , m_gear("P")
    , m_temperature(20)
    , m_autonomousMode(false)
{
    qDebug() << "VehicleData initialized";
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

int VehicleData::getSpeed() const
{
	return m_speed;
}

double VehicleData::getEnergy() const
{
	return m_energy;
}

int VehicleData::getBattery() const
{
	return m_battery;
}

int VehicleData::getDistance() const
{
	return m_distance;
}

int VehicleData::getTemperature() const
{
	return m_temperature;
}

QString VehicleData::getGear() const
{
	return m_gear;
}

bool VehicleData::getAutonomousMode() const
{
	return m_autonomousMode;
}
