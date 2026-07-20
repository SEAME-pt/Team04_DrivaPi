/**
 * @file vehicle_data.cpp
 * @author DrivaPi Team
 * @brief Vehicle telemetry model implementation — getters, setters, staleness watchdog + IPC Shared Memory.
 */

#include "vehicle_data.hpp"

#include <QDebug>
#include <QSettings>
#include <cstring>
#include <algorithm>
#include <QDateTime>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>

namespace drivaui {

	struct PerceptionOutput {
		float cte;
		float heading_error;
		float confidence;
		uint8_t valid;
		uint8_t padding[3];
		uint64_t timestamp;
	};

	// CAN IDs
	static constexpr uint32_t SPEED_CAN_ID         = 0x100;
	static constexpr uint32_t STM32_BATTERY_CAN_ID = 0x200;
	static constexpr uint32_t GEAR_CAN_ID          = 0x300;
	static constexpr uint32_t ENV_CAN_ID           = 0x400;
	static constexpr uint32_t EMERGENCY_VEHICLE_CAN_ID = 0x500;

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
		, m_rpiBatteryCurrent(0.0)
		, m_distance(0)
		, m_odometer(0)
		, m_gear("N")
		, m_temperature(0)
		, m_autonomousMode(false)
		, m_settings(new QSettings(this))
		, m_watchdogTimer(new QTimer(this))
		, m_emergencyPriorityActive(false)
		, m_emergencyPriorityLevel(0)
		, m_speedLimitValue(0)
		, m_speedLimitActive(false)
		, m_emergencyTimeoutTimer(new QTimer(this))
		, m_speedLimitTimeoutTimer(new QTimer(this))
		, m_trafficSignClassId(0)
		, m_laneOffset(0.0f)
		, m_laneHeading(0.0f)
		, m_shm_fd(-1)
		, m_shm_ptr(MAP_FAILED)
		, m_shmTimer(new QTimer(this))
	{
		loadOdometerFromSettings();

		// Watchdog period for CAN
		m_watchdogTimer->setInterval(200);
		connect(m_watchdogTimer, &QTimer::timeout, this, &VehicleData::checkStaleProperties);
		m_watchdogTimer->start();

		// Timers for UI
		m_emergencyTimeoutTimer->setSingleShot(true);
		m_emergencyTimeoutTimer->setInterval(3000);
		connect(m_emergencyTimeoutTimer, &QTimer::timeout, this, &VehicleData::clearAlert);

		m_speedLimitTimeoutTimer->setSingleShot(true);
		m_speedLimitTimeoutTimer->setInterval(3000);
		connect(m_speedLimitTimeoutTimer, &QTimer::timeout, this, &VehicleData::clearSpeedLimit);

		// Timers for Shared Memory
		m_shmTimer->setInterval(16);
		connect(m_shmTimer, &QTimer::timeout, this, &VehicleData::readSharedMemory);
		m_shmTimer->start();
	}

	VehicleData::~VehicleData() {
		if (m_shm_ptr != MAP_FAILED) {
			munmap(m_shm_ptr, sizeof(PerceptionOutput));
		}
		if (m_shm_fd >= 0) {
			close(m_shm_fd);
		}
	}

	// ====================================================================================
	// Shared Memory Reading for Lane Detection
	// ====================================================================================
	void VehicleData::readSharedMemory()
	{
		// 1. Try to open the shared memory file if not already opened
		if (m_shm_fd < 0) {
			m_shm_fd = open("/dev/shm/perception.buf", O_RDONLY);
			if (m_shm_fd >= 0) {
				m_shm_ptr = mmap(0, sizeof(PerceptionOutput), PROT_READ, MAP_SHARED, m_shm_fd, 0);
				if (m_shm_ptr == MAP_FAILED) {
					close(m_shm_fd);
					m_shm_fd = -1;
				}
			}
			return; // Return if the shared memory file could not be opened
		}

		// 2. Try to read the shared memory
		if (m_shm_ptr != MAP_FAILED) {
			auto* data = static_cast<PerceptionOutput*>(m_shm_ptr);

			// Verify if the inference has been updated with valid data
			if (data->valid == 1) {
				setLaneOffset(data->cte);
				setLaneHeading(data->heading_error);
			}
		}
	}

	// ===== Getters =====
	float VehicleData::getSpeed() const { return m_speed; }
	double VehicleData::getEnergy() const { return m_energy; }

	int VehicleData::getStm32Battery() const { return m_stm32Battery; }
	float VehicleData::getStm32BatteryVoltage() const { return m_stm32BatteryVoltage; }
	float VehicleData::getStm32Temperature() const { return m_stm32Temperature; }
	float VehicleData::getStm32Humidity() const { return m_stm32Humidity; }

	int VehicleData::getRpiBattery() const { return m_rpiBattery; }
	double VehicleData::getRpiBatteryVoltage() const { return m_rpiBatteryVoltage; }
	double VehicleData::getRpiBatteryCurrent() const { return m_rpiBatteryCurrent; }
	int VehicleData::getDistance() const { return m_distance; }
	int VehicleData::getOdometer() const { return m_odometer; }
	int VehicleData::getTemperature() const { return m_temperature; }
	QString VehicleData::getGear() const { return m_gear; }
	bool VehicleData::getAutonomousMode() const { return m_autonomousMode; }

	int VehicleData::getTrafficSignClassId() const { return m_trafficSignClassId; }
	bool VehicleData::getEmergencyPriorityActive() const { return m_emergencyPriorityActive; }
	int VehicleData::getEmergencyPriorityLevel() const { return m_emergencyPriorityLevel; }
	QString VehicleData::getEmergencyMessage() const { return m_emergencyMessage; }
	QString VehicleData::getEmergencyIconSource() const { return m_emergencyIconSource; }
	int VehicleData::getSpeedLimitValue() const { return m_speedLimitValue; }
	bool VehicleData::getSpeedLimitActive() const { return m_speedLimitActive; }
	float VehicleData::getLaneOffset() const { return m_laneOffset; }
	float VehicleData::getLaneHeading() const { return m_laneHeading; }

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

	void VehicleData::setRpiBatteryCurrent(double amps)
	{
		if (!qFuzzyCompare(m_rpiBatteryCurrent, amps)) {
			m_rpiBatteryCurrent = amps;
			emit rpiBatteryCurrentChanged();
		}
		updateTimestamp("rpiBatteryCurrent");
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

	void VehicleData::requestOdometerReset()
	{
		setOdometer(0);
	}

	void VehicleData::setTrafficSignClassId(int classId) {
		if (m_trafficSignClassId != classId) {
			m_trafficSignClassId = classId;
			emit trafficSignClassIdChanged();
		}
	}

	void VehicleData::setLaneOffset(float offset) {
		if (!qFuzzyCompare(m_laneOffset, offset)) {
			m_laneOffset = offset;
			emit laneOffsetChanged();
		}
		updateTimestamp("laneOffset");
	}

	void VehicleData::setLaneHeading(float heading) {
		if (!qFuzzyCompare(m_laneHeading, heading)) {
			m_laneHeading = heading;
			emit laneHeadingChanged();
		}
		updateTimestamp("laneHeading");
	}

	void VehicleData::updateTrafficSign(int classId) {
		setTrafficSignClassId(classId);
		emit trafficSignChanged(classId);

		// classId 0 means clear from detector stream; ignore to avoid rapid flicker.
		if (classId == 0) {
			return;
		}

		switch (classId) {
		case 1: // 50_sign
			showSpeedLimit(50);
			return;
		case 2: // 80_sign
			showSpeedLimit(80);
			return;
		case 3: // gate
			showAdasSign("gate-sign.png", 1, "GATE AHEAD");
			return;
		case 4: // crosswalk_sign
			showAdasSign("crosswalk-sign.png", 1, "CROSSWALK AHEAD");
			return;
		case 5: // stop_sign
			showAdasSign("stop-sign.png", 2, "STOP SIGN");
			return;
		case 6: // yield_sign
			showAdasSign("yield-sign.svg", 1, "YIELD SIGN");
			return;
		case 7: // car
			showAdasSign("obstacle-sign.png", 2, "CAR AHEAD");
			return;
		case 8: // danger_sign
			showAdasSign("danger-sign.png", 1, "DANGER SIGN");
			return;
		case 9: // obstacle
			showAdasSign("obstacle-sign.png", 2, "OBSTACLE AHEAD");
			return;
		case 10: // traffic_light_green
			showAdasSign("traffic-light-green.svg", 1, "GREEN LIGHT");
			return;
		case 11: // traffic_light_off
			showAdasSign("traffic-light-off.svg", 1, "TRAFFIC LIGHT OFF");
			return;
		case 12: // traffic_light_red
			showAdasSign("traffic-light-red.svg", 2, "RED LIGHT");
			return;
		case 13: // traffic_light_yellow
			showAdasSign("traffic-light-yellow.svg", 1, "YELLOW LIGHT");
			return;
		default:
			return;
		}
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
		setLaneOffset(0.0f);
		setLaneHeading(0.0f);
	}

	void VehicleData::resetTrip()
	{
		setDistance(0);
	}

	void VehicleData::handleCurrentGearUpdate(int currentGear)
	{
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

		if (canId == EMERGENCY_VEHICLE_CAN_ID) {
			if (dlc < 1) return;
			const int priorityLevel = static_cast<int>(data[0]);
			updateEmergencyAlert(priorityLevel);
			return;
		}
	}

	void VehicleData::updateEmergencyAlert(int priorityLevel)
	{
		emit emergencyAlertChanged(priorityLevel);

		if (priorityLevel >= 2) {
			showTextAlert("PULL OVER - EMERGENCY", 2);
			return;
		}

		if (priorityLevel == 1) {
			showTextAlert("EMERGENCY VEHICLE AHEAD", 1);
			return;
		}

		clearAlert();
		m_emergencyTimeoutTimer->stop();
	}

	void VehicleData::showAdasSign(const QString &fileName, int priorityLevel, const QString &message)
	{
		const QString icon_source = QStringLiteral("qrc:/assets/adas-signs/") + fileName;

		if (m_emergencyIconSource != icon_source) {
			m_emergencyIconSource = icon_source;
			emit emergencyIconSourceChanged();
		}
		if (m_emergencyMessage != message) {
			m_emergencyMessage = message;
			emit emergencyMessageChanged();
		}
		if (m_emergencyPriorityLevel != priorityLevel) {
			m_emergencyPriorityLevel = priorityLevel;
			emit emergencyPriorityLevelChanged();
		}
		if (!m_emergencyPriorityActive) {
			m_emergencyPriorityActive = true;
			emit emergencyPriorityActiveChanged();
		}

		m_emergencyTimeoutTimer->start();
	}

	void VehicleData::showSpeedLimit(int limitValue)
	{
		if (m_speedLimitValue != limitValue) {
			m_speedLimitValue = limitValue;
			emit speedLimitValueChanged();
		}
		if (!m_speedLimitActive) {
			m_speedLimitActive = true;
			emit speedLimitActiveChanged();
		}

		m_speedLimitTimeoutTimer->start();
	}

	void VehicleData::showTextAlert(const QString &message, int priorityLevel)
	{
		if (!m_emergencyIconSource.isEmpty()) {
			m_emergencyIconSource.clear();
			emit emergencyIconSourceChanged();
		}
		if (m_emergencyMessage != message) {
			m_emergencyMessage = message;
			emit emergencyMessageChanged();
		}
		if (m_emergencyPriorityLevel != priorityLevel) {
			m_emergencyPriorityLevel = priorityLevel;
			emit emergencyPriorityLevelChanged();
		}
		if (!m_emergencyPriorityActive) {
			m_emergencyPriorityActive = true;
			emit emergencyPriorityActiveChanged();
		}

		m_emergencyTimeoutTimer->start();
	}

	void VehicleData::clearAlert()
	{
		if (!m_emergencyIconSource.isEmpty()) {
			m_emergencyIconSource.clear();
			emit emergencyIconSourceChanged();
		}
		if (!m_emergencyMessage.isEmpty()) {
			m_emergencyMessage.clear();
			emit emergencyMessageChanged();
		}
		if (m_emergencyPriorityLevel != 0) {
			m_emergencyPriorityLevel = 0;
			emit emergencyPriorityLevelChanged();
		}
		if (m_emergencyPriorityActive) {
			m_emergencyPriorityActive = false;
			emit emergencyPriorityActiveChanged();
		}
	}

	void VehicleData::clearSpeedLimit()
	{
		if (m_speedLimitActive) {
			m_speedLimitActive = false;
			emit speedLimitActiveChanged();
		}
		if (m_speedLimitValue != 0) {
			m_speedLimitValue = 0;
			emit speedLimitValueChanged();
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
			"rpiBattery", "rpiBatteryVoltage", "rpiBatteryCurrent", "distance", "odo", "gear", "temperature", "autonomousMode",
			"laneOffset", "laneHeading"
		};

		for (const QString& p : others) {
			if (now - lastUpdate(p) > OTHER_STALE_MS) {
				markPropertyStale(p);
			}
		}
	}

} // namespace drivaui
