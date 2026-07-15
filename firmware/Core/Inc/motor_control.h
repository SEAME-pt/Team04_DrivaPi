/*
 * motor_control.h
 *
 *  Created on: Mar 25, 2026
 *      Author: TeamDrivaPi
 */

#ifndef INC_MOTOR_CONTROL_H_
#define INC_MOTOR_CONTROL_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "app_threadx.h"

#define PWM_MIN 			40u   	// Minimum absolute PWM to overcome dead zone
#define PWM_MAX				665u  	// Maximum absolute PWM value
#define SPEED_MARGIN		5.0f    // hm/h tolerance for "at target" detection
#define INTEGRAL_LIMIT		500.0f  // Anti-windup limit for PI controller

/**
 * @struct MotorControlState
 * @brief Hybrid feedforward + PID feedback controller
 */
typedef struct {
	uint16_t    target_speed;      		// desired speed (hm/h)
	float       current_speed;     		// measured speed (hm/h) from speed_sensor.c
	float       error;             		// current error (target - actual)
	float       integral;          		// accumulated error for I term
	float       previous_error;    		// previous error for D term computation

	float       feedforward_gain;  		// Direct mapping ratio (1/100 for 100 hm/h max)
	float       proportional_gain; 		// Kp: Proportional gain for error correction
	float       integral_gain;     		// Ki: Integral gain for steady-state error elimination
	float       derivative_gain;   		// Kd: Derivative gain for damping
	float       ff_alpha;          		// Feedforward smoothing factor (0.0 to 1.0)
	float       ff_smooth;         		// Smoothed feedforward term
	uint16_t    previous_target;   		// previous target for feedforward computation

	float       pwm_output;        		// computed normalized PWM (-1.0 to 1.0)
	int16_t     pwm_raw;				// signed PWM counts for MotorSetPWM (-4095 to 4095)
	int32_t		direction;
} MotorControlState;

extern MotorControlState g_motorControlState;  // motor controller state
extern float             g_vehicleSpeed;       // from speed_sensor.c (measured m/s)
extern uint16_t          g_targetSpeed;        // from CAN message (remote command m/s)

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
