#include "vehicledata.hpp"
#include <QDebug>
#include <QDateTime>
#include <QtMath>

// CAN ID that we agreed for speed
static const uint32_t SPEED_CAN_ID = 0x100;

VehicleData::VehicleData(QObject *parent)
    : QObject(parent)
    , m_speed(0.0)
    , m_energy(100.0)
    , m_battery(100)
    , m_distance(0)
    , m_gear("P")
    , m_temperature(20)
    , m_autonomousMode(false)
	, m_watchdogTimer(new QTimer(this))
{
    // Single watchdog timer, checks all properties periodically
    m_watchdogTimer->setInterval(200); // 200 ms tick
    connect(m_watchdogTimer, &QTimer::timeout, this, &VehicleData::checkStaleProperties);
    m_watchdogTimer->start();

    qDebug() << "VehicleData initialized";
}

VehicleData::~VehicleData()
{
    qDebug() << "VehicleData destroyed";
}

void VehicleData::setSpeed(double mps)
{
    if (!qFuzzyCompare(1.0 + mps, 1.0 + m_speed)) {
        m_speed = mps;
        emit speedChanged();
    }
    updateTimestamp(QStringLiteral("speed"));
}

void VehicleData::setEnergy(double energy)
{
    if (qAbs(m_energy - energy) > 0.01) {
        m_energy = energy;
        emit energyChanged();
    }
    updateTimestamp(QStringLiteral("energy"));
}

void VehicleData::setBattery(int battery)
{
    if (m_battery != battery) {
        m_battery = battery;
        emit batteryChanged();
    }
    updateTimestamp(QStringLiteral("battery"));
}

void VehicleData::setDistance(int distance)
{
    if (m_distance != distance) {
        m_distance = distance;
        emit distanceChanged();
    }
    updateTimestamp(QStringLiteral("distance"));
}

void VehicleData::setGear(const QString &gear)
{
    if (m_gear != gear) {
        m_gear = gear;
        qDebug() << "Gear changed to:" << m_gear;
        emit gearChanged();
    }
    updateTimestamp(QStringLiteral("gear"));
}

void VehicleData::setTemperature(int temperature)
{
    if (m_temperature != temperature) {
        m_temperature = temperature;
        emit temperatureChanged();
    }
    updateTimestamp(QStringLiteral("temperature"));
}

void VehicleData::setAutonomousMode(bool mode)
{
    if (m_autonomousMode != mode) {
        m_autonomousMode = mode;
        qDebug() << "Autonomous mode:" << (m_autonomousMode ? "ON" : "OFF");
        emit autonomousModeChanged();
    }
    updateTimestamp(QStringLiteral("autonomousMode"));
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

void VehicleData::updateTimestamp(const QString &propName)
{
    m_lastUpdateMs[propName] = QDateTime::currentMSecsSinceEpoch();
}

qint64 VehicleData::lastUpdate(const QString &propName) const
{
    return m_lastUpdateMs.value(propName, 0);
}

void VehicleData::markPropertyStale(const QString &propName)
{
    // Behavior on stale: reset to safe default (customize per property)
    if (propName == QStringLiteral("speed")) {
        if (!qFuzzyCompare(1.0 + m_speed, 1.0)) {
            m_speed = 0.0;
            emit speedChanged();
            qDebug() << "Speed marked stale -> 0.0 m/s";
        }
    } else {
        // add special handling if needed
    }
}

// CAN message handler
void VehicleData::handleCanMessage(const QByteArray &payload, uint32_t canId)
{
    if (canId == SPEED_CAN_ID) {
        // Expect 2 bytes: uint16_t big-endian = speed_mps_x100
        if (payload.size() < 2) {
            qWarning() << "SPEED frame too short: " << payload.size();
            return;
        }
        const unsigned char *d = reinterpret_cast<const unsigned char*>(payload.constData());
        uint16_t raw = (static_cast<uint16_t>(d[0]) << 8) | static_cast<uint16_t>(d[1]);

        double mps = static_cast<double>(raw) / 100.0;
        setSpeed(mps);                // updates timestamp inside
        // debug
        // qDebug() << "Updated speed (m/s):" << mps;
    }

    // TODO: expand handling for other CAN IDs (battery, energy, etc.)
}

// Watchdog: check timestamps and mark stale
void VehicleData::checkStaleProperties()
{
    qint64 now = QDateTime::currentMSecsSinceEpoch();

    // Speed (high-rate)
    qint64 lastSpeed = lastUpdate(QStringLiteral("speed"));
    if (lastSpeed == 0 || (now - lastSpeed) > SPEED_STALE_MS) {
        markPropertyStale(QStringLiteral("speed"));
    }

    // Other properties: mark as stale only if very old
    qint64 lastOther = lastUpdate(QStringLiteral("battery"));
    if (lastOther == 0 || (now - lastOther) > OTHER_STALE_MS) {
        // we don't aggressively reset battery; implement if needed
    }
    // Repeat for other keys if you want special handling
}
