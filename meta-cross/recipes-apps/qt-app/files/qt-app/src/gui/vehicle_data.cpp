/**
 * @file vehicle_data.cpp
 * @author DrivaPi Team
 * @brief Vehicle telemetry model implementation — getters, setters, staleness watchdog.
 */

#include "vehicle_data.hpp"

#include <QDebug>
#include <QSettings>
#include <cstring>
#include <algorithm>

namespace drivaui {

// CAN IDs
static constexpr uint32_t SPEED_CAN_ID         = 0x100; // float (LE) speed (m/s)
static constexpr uint32_t STM32_BATTERY_CAN_ID = 0x200; // u8 % + float (LE) voltage
static constexpr uint32_t GEAR_CAN_ID          = 0x300; // u8: 0=N, 1=R, 2=D
static constexpr uint32_t ENV_CAN_ID           = 0x400; // float (LE) temp + float (LE) humidity

static inline float readFloatLe(const uint8_t* p)
{
    float f = 0.0f;
    std::memcpy(&f, p, sizeof(float));
    return f;
}

VehicleData::VehicleData(QObject *parent)
    : QObject(parent)
    , m_speed(0.0f)
    , m_energy(0.0)
    , m_stm32Battery(0)
    , m_stm32BatteryVoltage(0.0f)
    , m_stm32Temperature(0.0f)
    , m_stm32Humidity(0.0f)
    , m_rpiBattery(0)
    , m_rpiBatteryVoltage(0.0)
    , m_distance(0)
    , m_odometer(0)
    , m_gear("N")
    , m_temperature(0)
    , m_autonomousMode(false)
    , m_settings(new QSettings(this))
    , m_watchdogTimer(new QTimer(this))
{
    loadOdometerFromSettings();

    m_watchdogTimer->setInterval(200);
    connect(m_watchdogTimer, &QTimer::timeout, this, &VehicleData::checkStaleProperties);
    m_watchdogTimer->start();
}

VehicleData::~VehicleData() = default;

// ===== Getters =====
float VehicleData::getSpeed() const { return m_speed; }
double VehicleData::getEnergy() const { return m_energy; }

int VehicleData::getStm32Battery() const { return m_stm32Battery; }
float VehicleData::getStm32BatteryVoltage() const { return m_stm32BatteryVoltage; }
float VehicleData::getStm32Temperature() const { return m_stm32Temperature; }
float VehicleData::getStm32Humidity() const { return m_stm32Humidity; }

int VehicleData::getRpiBattery() const { return m_rpiBattery; }
double VehicleData::getRpiBatteryVoltage() const { return m_rpiBatteryVoltage; }
int VehicleData::getDistance() const { return m_distance; }
int VehicleData::getOdometer() const { return m_odometer; }
int VehicleData::getTemperature() const { return m_temperature; }
QString VehicleData::getGear() const { return m_gear; }
bool VehicleData::getAutonomousMode() const { return m_autonomousMode; }

// ===== Setters =====
void VehicleData::setSpeed(float mps)
{
    if (!qFuzzyCompare(m_speed, mps)) {
        m_speed = mps;
        emit speedChanged();
    }
    updateTimestamp("speed");
}

void VehicleData::setEnergy(double energy)
{
    if (!qFuzzyCompare(m_energy, energy)) {
        m_energy = energy;
        emit energyChanged();
    }
    updateTimestamp("energy");
}

void VehicleData::setStm32Battery(int battery)
{
    battery = std::clamp(battery, 0, 100);
    if (m_stm32Battery != battery) {
        m_stm32Battery = battery;
        emit stm32BatteryChanged();
    }
    updateTimestamp("stm32Battery");
}

void VehicleData::setStm32BatteryVoltage(float volts)
{
    if (!qFuzzyCompare(m_stm32BatteryVoltage, volts)) {
        m_stm32BatteryVoltage = volts;
        emit stm32BatteryVoltageChanged();
    }
    updateTimestamp("stm32BatteryVoltage");
}

void VehicleData::setStm32Temperature(float tempC)
{
    if (!qFuzzyCompare(m_stm32Temperature, tempC)) {
        m_stm32Temperature = tempC;
        emit stm32TemperatureChanged();
    }
    updateTimestamp("stm32Temperature");
}

void VehicleData::setStm32Humidity(float humidityPct)
{
    if (!qFuzzyCompare(m_stm32Humidity, humidityPct)) {
        m_stm32Humidity = humidityPct;
        emit stm32HumidityChanged();
    }
    updateTimestamp("stm32Humidity");
}

void VehicleData::setRpiBattery(int battery)
{
    battery = std::clamp(battery, 0, 100);
    if (m_rpiBattery != battery) {
        m_rpiBattery = battery;
        emit rpiBatteryChanged();
    }
    updateTimestamp("rpiBattery");
}

void VehicleData::setRpiBatteryVoltage(double volts)
{
    if (!qFuzzyCompare(m_rpiBatteryVoltage, volts)) {
        m_rpiBatteryVoltage = volts;
        emit rpiBatteryVoltageChanged();
    }
    updateTimestamp("rpiBatteryVoltage");
}

void VehicleData::setDistance(int distance)
{
    if (m_distance != distance) {
        m_distance = distance;
        emit distanceChanged();
    }
    updateTimestamp("distance");
}

void VehicleData::setOdometer(int odo)
{
    if (m_odometer != odo) {
        m_odometer = odo;
        emit odometerChanged();
        saveOdometerToSettings();
    }
    updateTimestamp("odo");
}

void VehicleData::setGear(const QString &gear)
{
    if (m_gear != gear) {
        m_gear = gear;
        emit gearChanged();
    }
    updateTimestamp("gear");
}

void VehicleData::setTemperature(int temperature)
{
    if (m_temperature != temperature) {
        m_temperature = temperature;
        emit temperatureChanged();
    }
    updateTimestamp("temperature");
}

void VehicleData::setAutonomousMode(bool mode)
{
    if (m_autonomousMode != mode) {
        m_autonomousMode = mode;
        emit autonomousModeChanged();
    }
    updateTimestamp("autonomousMode");
}

// ===== QML methods =====
void VehicleData::toggleAutonomousMode()
{
    setAutonomousMode(!m_autonomousMode);
}

void VehicleData::resetValues()
{
    setSpeed(0.0f);
    setEnergy(0.0);

    setStm32Battery(0);
    setStm32BatteryVoltage(0.0f);
    setStm32Temperature(0.0f);
    setStm32Humidity(0.0f);

    setGear("N");
}

void VehicleData::resetTrip()
{
    setDistance(0);
}

void VehicleData::handleCurrentGearUpdate(int currentGear)
{
    // VSS CurrentGear: 0=N, negative=Reverse, positive=Forward
    if (currentGear == 0) setGear("N");
    else if (currentGear < 0) setGear("R");
    else setGear("D");
}

// ===== CAN slot =====
void VehicleData::handleCanMessage(const QByteArray &payload, uint32_t canId)
{
    const int dlc = qMin(payload.size(), 8);
    const uint8_t *data = reinterpret_cast<const uint8_t*>(payload.constData());

    if (canId == SPEED_CAN_ID) {
        if (dlc < 4) return;
        const float speed_mps = readFloatLe(&data[0]);
        const float speed_kmh = speed_mps;
        setSpeed(speed_kmh);
        return;
    }

    if (canId == STM32_BATTERY_CAN_ID) {
        if (dlc < 5) return;
        const int pct = static_cast<int>(data[0]);
        const float volts = readFloatLe(&data[1]);
        setStm32Battery(pct);
        setStm32BatteryVoltage(volts);
        return;
    }

    if (canId == GEAR_CAN_ID) {
        if (dlc < 1) return;
        const uint8_t g = data[0];
        if (g == 0) setGear("N");
        else if (g == 1) setGear("R");
        else if (g == 2) setGear("D");
        return;
    }

    if (canId == ENV_CAN_ID) {
        if (dlc < 8) return;
        const float tempC = readFloatLe(&data[0]);
        const float humPct = readFloatLe(&data[4]);
        setStm32Temperature(tempC);
        setStm32Humidity(humPct);
        return;
    }
}

// ===== Persistence =====
void VehicleData::loadOdometerFromSettings()
{
    if (!m_settings) return;
    m_odometer = m_settings->value("odometer", 0).toInt();
}

void VehicleData::saveOdometerToSettings()
{
    if (!m_settings) return;
    m_settings->setValue("odometer", m_odometer);
    m_settings->sync();
}

// ===== Helpers =====
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
    // Keep your existing policy here.
    // If you previously set fallback values / raised notifications, implement it.
    Q_UNUSED(propName);
}

void VehicleData::checkStaleProperties()
{
    const qint64 now = QDateTime::currentMSecsSinceEpoch();

    if (now - lastUpdate("speed") > SPEED_STALE_MS) {
        markPropertyStale("speed");
    }

    const QStringList others = {
        "energy", "stm32Battery", "stm32BatteryVoltage", "stm32Temperature", "stm32Humidity",
        "rpiBattery", "distance", "odo", "gear", "temperature", "autonomousMode"
    };

    for (const QString& p : others) {
        if (now - lastUpdate(p) > OTHER_STALE_MS) {
            markPropertyStale(p);
        }
    }
}

} // namespace drivaui
