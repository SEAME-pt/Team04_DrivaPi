/**
 * @file handlers.cpp
 * @brief CAN frame handler implementations
 */

#include "handlers.hpp"
#include "publisher.hpp"
#include "can_decode.hpp"
#include "signals.hpp"
#include <iostream>

namespace handlers {

	void HandleSpeed(const can_frame& frame, kuksa::Publisher& publisher) {
		// Validate payload size (expect 4 bytes for float)
		if (frame.can_dlc < 4) {
			std::cerr << "[Handler] Speed frame too short: " << static_cast<int>(frame.can_dlc)
					<< " bytes" << std::endl;
			return;
		}

		// Decode float from CAN payload (little-endian)
		float speed_mps = can_decode::FloatLe(frame.data);  // STM32 sends m/s
		float speed_kmh = speed_mps * 3.6f;  // Convert to km/h for VSS compliance

		// Publish to KUKSA
		if (publisher.PublishFloat(vss::VEHICLE_SPEED, speed_kmh)) {
			std::cout << "[Handler] Published Vehicle.Speed = " << speed_kmh << " km/h ("
					<< speed_mps << " m/s)" << std::endl;
		}
	}

	void HandleStm32Battery(const can_frame& frame, kuksa::Publisher& publisher)
	{
		// Payload: [0]=u8 percent, [1..4]=float voltage LE
		if (frame.can_dlc < 5) {
			std::cerr << "[Handler] Battery frame too short: "
					<< static_cast<int>(frame.can_dlc) << " bytes\n";
			return;
		}

		const uint8_t percent_u8 = can_decode::U8(frame.data);
		const float voltage_v = can_decode::FloatLe(frame.data + 1);

		// Publish SOC as float percent (VSS)
		publisher.PublishFloat(vss::BATTERY_SOC_DISPLAYED, static_cast<float>(percent_u8));
		publisher.PublishFloat(vss::BATTERY_VOLTAGE, voltage_v);

		std::cout << "[Handler] Published " << vss::BATTERY_SOC_DISPLAYED
				<< " = " << static_cast<int>(percent_u8) << " %\n";
		std::cout << "[Handler] Published " << vss::BATTERY_VOLTAGE
				<< " = " << voltage_v << " V\n";
	}

	void HandleGear(const can_frame& frame, kuksa::Publisher& publisher)
	{
		// Payload: [0]=u8 gear 0=N, 1=R, 2=D
		if (frame.can_dlc < 1) {
			std::cerr << "[Handler] Gear frame too short: "
					<< static_cast<int>(frame.can_dlc) << " bytes\n";
			return;
		}

		const uint8_t g = can_decode::U8(frame.data);

		// Map to VSS CurrentGear semantics:
		// Neutral = 0, Reverse = -1, Drive/Forward = 1
		int32_t currentGear = 0;
		if (g == 0) currentGear = 0;
		else if (g == 1) currentGear = -1;
		else if (g == 2) currentGear = 1;
		else currentGear = 0;

		publisher.PublishInt32(vss::CURRENT_GEAR, currentGear);

		std::cout << "[Handler] Published " << vss::CURRENT_GEAR
				<< " = " << currentGear << " (raw=" << static_cast<int>(g) << ")\n";
	}

	void HandleEnv(const can_frame& frame, kuksa::Publisher& publisher)
	{
		// Payload: [0..3]=float temp LE, [4..7]=float humidity LE
		if (frame.can_dlc < 8) {
			std::cerr << "[Handler] Env frame too short: "
					<< static_cast<int>(frame.can_dlc) << " bytes\n";
			return;
		}

		const float temp_c = can_decode::FloatLe(frame.data);
		const float hum_pct = can_decode::FloatLe(frame.data + 4);

		publisher.PublishFloat(vss::STM32_TEMPERATURE, temp_c);
		publisher.PublishFloat(vss::STM32_HUMIDITY, hum_pct);

		std::cout << "[Handler] Published " << vss::STM32_TEMPERATURE
				<< " = " << temp_c << " C\n";
		std::cout << "[Handler] Published " << vss::STM32_HUMIDITY
				<< " = " << hum_pct << " %\n";
	}

} // namespace handlers
