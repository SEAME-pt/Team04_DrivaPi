/*
 * motor_control.h
 *
 *  Created on: Mar 25, 2026
 *      Author: hugofslopes
 */

#ifndef INC_MOTOR_CONTROL_H_
#define INC_MOTOR_CONTROL_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "app_threadx.h"

#define PWM_MIN 			300u   	// Minimum absolute PWM to overcome dead zone
#define PWM_MAX				4095u  	// Maximum absolute PWM value
#define SPEED_MARGIN		5.0f    // hm/h tolerance for "at target" detection
#define INTEGRAL_LIMIT		500.0f  // Anti-windup limit for PI controller

/**
 * @struct MotorControlState
 * @brief Hybrid feedforward + PI feedback controller
 * 
 * Strategy:
 * 1. Feedforward: Direct PWM mapping (target/100 * 4095) - handles ~90% of control
 * 2. PI Feedback: Small corrections for disturbances (curves, hills, weight, etc.)
 */
typedef struct {
	float       target_speed;      		// desired speed (hm/h)
	float       current_speed;     		// measured speed (hm/h) from speed_sensor.c
	float       error;             		// current error (target - actual)
	float       integral;          		// accumulated error for I term

	float       feedforward_gain;  		// Direct mapping ratio (1/100 for 100 hm/h max)
	float       proportional_gain; 		// Kp: Proportional gain for error correction (PWM per hm/h error)
	float       integral_gain;     		// Ki: Integral gain for steady-state error elimination
	float       pwm_output;        		// computed normalized PWM (-1.0 to 1.0)
	int16_t     pwm_raw;				// signed PWM counts for MotorSetPWM (-4095 to 4095)
} MotorControlState;

extern MotorControlState g_motorControlState;  // motor controller state
extern float             g_vehicleSpeed;       // from speed_sensor.c (measured m/s)
extern float             g_targetSpeed;        // from CAN message (remote command m/s)

/**
 * @brief Compute feedforward + proportional control output and send signed PWM to motor
 * @param state Controller state structure with gains
 * @param current_speed Current measured vehicle speed (m/s)
 */
void MotorControlUpdate(MotorControlState *state, float current_speed);

/**
 * @brief Update motor control loop using current target and measured speed
 */
void UpdateMotorControl(void);

/**
 * @brief Initialize controller gains
 * @param state Controller state structure to initialize
 */
void MotorControlInit(MotorControlState *state);

#ifdef __cplusplus
}
#endif

#endif /* INC_MOTOR_CONTROL_H_ */
