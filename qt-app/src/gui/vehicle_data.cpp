#include "gui/vehicle_data.hpp"

namespace drivaui {

// CAN IDs for various signals
static const uint32_t SPEED_CAN_ID = 0x100;
static const uint32_t STM32_BATTERY_CAN_ID = 0x200;

typedef union{
    float float_val;
    uint8_t byte_array[4];
} FloatBytes;

VehicleData::VehicleData(QObject *parent)
    : QObject(parent)
    , m_speed(0.0)
    , m_energy(100.0)
    , m_battery(100)
    , m_stm32Battery(100)
    , m_rpiBattery(100)
    , m_distance(0)
    , m_odometer(0)
    , m_gear("P")
    , m_temperature(20)
    , m_autonomousMode(false)
	, m_watchdogTimer(new QTimer(this))
    , m_settings(new QSettings("DrivaPi", "HMI", this))
{
    // Single watchdog timer, checks all properties periodically
    m_watchdogTimer->setInterval(200); // 200 ms tick
    connect(m_watchdogTimer, &QTimer::timeout, this, &VehicleData::checkStaleProperties);
    m_watchdogTimer->start();

    // Load odometer from persistent storage
    loadOdometerFromSettings();

    qDebug() << "VehicleData initialized with odometer:" << m_odometer << "km";
}

VehicleData::~VehicleData()
{
    qDebug() << "VehicleData destroyed";
}

void VehicleData::setSpeed(float mps)
{
    if (!qFuzzyCompare(1.0 + mps, 1.0 + m_speed)) {
        m_speed = mps;
        qDebug() << "Speed set to (m/s):" << m_speed;
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

void VehicleData::setStm32Battery(int battery)
{
    if (m_stm32Battery != battery) {
        m_stm32Battery = battery;
        // Update overall battery as the minimum of both sources
        int newBattery = qMin(m_stm32Battery, m_rpiBattery);
        if (m_battery != newBattery) {
            m_battery = newBattery;
            emit batteryChanged();
        }
        emit stm32BatteryChanged();
        qDebug() << "STM32 Battery updated to:" << m_stm32Battery << "%, Overall battery:" << m_battery << "%";
    }
    updateTimestamp(QStringLiteral("stm32Battery"));
}

void VehicleData::setRpiBattery(int battery)
{
    if (m_rpiBattery != battery) {
        m_rpiBattery = battery;
        // Update overall battery as the minimum of both sources
        int newBattery = qMin(m_stm32Battery, m_rpiBattery);
        if (m_battery != newBattery) {
            m_battery = newBattery;
            emit batteryChanged();
        }
        emit rpiBatteryChanged();
        qDebug() << "RPi Battery updated to:" << m_rpiBattery << "%, Overall battery:" << m_battery << "%";
    }
    updateTimestamp(QStringLiteral("rpiBattery"));
}

void VehicleData::setDistance(int distance)
{
    if (m_distance != distance) {
        m_distance = distance;
        emit distanceChanged();
    }
    updateTimestamp(QStringLiteral("distance"));
}

void VehicleData::setOdometer(int odo)
{
    if (m_odometer != odo) {
        m_odometer = odo;
        qDebug() << "Odometer set to:" << m_odometer << "km";
        saveOdometerToSettings();  // Save to persistent storage
        emit odometerChanged();
    }
    updateTimestamp(QStringLiteral("odo"));
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
    static const QStringList gears = {"P", "R", "N", "D"};
    return gears.indexOf(m_gear);
}

void VehicleData::changeGearUp()
{
    int currentIndex = getGearIndex();
    static const QStringList gears = {"P", "R", "N", "D"};
    if (currentIndex >= 0 && currentIndex < gears.length() - 1) {
        setGear(gears[currentIndex + 1]);
    }
}

void VehicleData::changeGearDown()
{
    int currentIndex = getGearIndex();
    static const QStringList gears = {"P", "R", "N", "D"};
    if (currentIndex > 0) {
        setGear(gears[currentIndex - 1]);
    }
}

float VehicleData::getSpeed() const
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

int VehicleData::getStm32Battery() const
{
	return m_stm32Battery;
}

int VehicleData::getRpiBattery() const
{
	return m_rpiBattery;
}

int VehicleData::getDistance() const
{
	return m_distance;
}

int VehicleData::getOdometer() const
{
	return m_odometer;
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
        // Expect 4 bytes: little-endian float32 speed in m/s
        if (payload.size() < 4) {
            qWarning() << "SPEED frame too short: " << payload.size();
            return;
        }
        FloatBytes received_data;
        float speed_value;

        std::memcpy(received_data.byte_array, payload.constData(), 4);
        speed_value = received_data.float_val;

        setSpeed(speed_value);                // updates timestamp inside
        // debug
        // qDebug() << "Updated speed (m/s):" << mps;
    }
    else if (canId == STM32_BATTERY_CAN_ID) {
        // Expect 1 byte: battery percentage (0-100)
        if (payload.size() < 1) {
            qWarning() << "STM32 BATTERY frame too short: " << payload.size();
            return;
        }
        uint8_t battery_value = static_cast<uint8_t>(payload[0]);
        setStm32Battery(static_cast<int>(battery_value));
    }

    // TODO: expand handling for other CAN IDs (energy, temperature, etc.)
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

// KUKSA speed update handler
void VehicleData::handleSpeedUpdate(float speed)
{
    setSpeed(speed); // updates timestamp inside
    // debug
    // qDebug() << "Updated speed from KUKSA (m/s):" << speed;
}
// ===== Persistence Methods =====
void VehicleData::loadOdometerFromSettings()
{
    // Load from QSettings with default fallback
    m_odometer = m_settings->value("vehicle/odometer", 0).toInt();
    qDebug() << "[Odometer] Loaded from persistent storage:" << m_odometer << "km";
}

void VehicleData::saveOdometerToSettings()
{
    m_settings->setValue("vehicle/odometer", m_odometer);
    m_settings->sync();  // Ensure it's written to disk immediately
    qDebug() << "[Odometer] Saved to persistent storage:" << m_odometer << "km";
}
}  // namespace drivaui
