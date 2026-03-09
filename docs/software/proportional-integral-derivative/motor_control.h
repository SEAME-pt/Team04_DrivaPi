#ifndef MOTOR_CONTROL_H
#define MOTOR_CONTROL_H

#include <app_threadx.h>

#define PID_SAMPLE_TIME 	0.1f   	// 100 ms update rate (matches SpeedSensor thread)
#define PWM_MIN 			300u   	// Minimum absolute PWM to overcome dead zone
#define PWM_MAX				4095u  	// Maximum absolute PWM value
#define PID_INTEGRAL_LIMIT	100.0f	// Anti-windup clamp for integral state (error * seconds)

/**
 * @struct MotorPIDState
 * @brief PID controller state for the motor
 */
typedef struct {
	float       target_speed;      		// desired speed (m/s)
	float       current_speed;     		// measured speed (m/s) from speed_sensor.c
	float       error;             		// e[n]
	float       error_prev;        		// e[n-1] for derivative
	float       integral;          		// sum of errors for integral term
	
	float       gain_p, gain_i, gain_d;	// PID gains
	float       pwm_output;        		// computed normalized PWM (-1.0 to 1.0)
	int16_t     pwm_raw;				// signed PWM counts for MotorSetPWM (-4095 to 4095)
} MotorPIDState;

extern float         g_vehicleSpeed;   // from speed_sensor.c (measured m/s)
extern float         g_targetSpeed;    // from CAN message (remote command m/s)
extern MotorPIDState g_motorPidState;  // motor PID controller state

/**
 * @brief Compute PID control output and send signed PWM counts to motor driver
 * @param state PID state structure with gains and controller memory
 * @param current_speed Current measured vehicle speed (m/s)
 */
void MotorPIDUpdate(MotorPIDState *state, float current_speed);

/**
 * @brief Update motor control loop using current target and measured speed
 */
void UpdateMotorControl(void);

/**
 * @brief Initialize PID controller gains and internal state
 * @param state PID state structure to initialize
 * @param kp Proportional gain
 * @param ki Integral gain
 * @param kd Derivative gain
 */
void MotorPIDInit(MotorPIDState *state, float kp, float ki, float kd);

#endif