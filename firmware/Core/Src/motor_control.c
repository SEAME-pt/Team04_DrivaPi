/*
 * motor_control.c
 *
 *  Created on: Mar 25, 2026
 *      Author: hugofslopes
 */


#include "motor_control.h"

void MotorPIDUpdate(MotorPIDState *state, float current_speed)
{
    float   hm_speed = current_speed * 36.0f;
    
    if (fabs(hm_speed - state->target_speed) < SPEED_MARGIN)
    {
//    	tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
//		MotorSetPWM((int32_t)state->pwm_raw, (int32_t)state->pwm_raw);
//		tx_mutex_put(&g_motorMutex);
		return ;
    }

    // Extract direction from target and magnitude from target
    float target_magnitude = (state->target_speed < 0.0f) ? -state->target_speed : state->target_speed;
    int8_t target_direction = (state->target_speed >= 0.0f) ? 1 : -1;
    
    // Speed sensor gives magnitude only, so control magnitude with PID
    // Step 1: Calculate error on MAGNITUDE only
	state->error = target_magnitude - hm_speed;

	// Step 2: Proportional term (immediate response)
	float p_term = state->gain_p * state->error;

	// Step 3: Integral term (eliminates steady-state error)
	state->integral += state->error * PID_SAMPLE_TIME;

	// Anti-windup: limit integral state to keep recovery fast after saturation.
	if (state->integral > PID_INTEGRAL_LIMIT)
		state->integral = PID_INTEGRAL_LIMIT;
	if (state->integral < -PID_INTEGRAL_LIMIT)
		state->integral = -PID_INTEGRAL_LIMIT;

	float i_term = state->gain_i * state->integral;

	// Step 4: Derivative term (derivative on measurement to avoid derivative kick)
	float derivative = (hm_speed - state->current_speed) / PID_SAMPLE_TIME;
	float d_term = -state->gain_d * derivative;  // Negative because we're using derivative on measurement

	// Step 5: Sum all three terms to get magnitude PWM
	state->pwm_output = p_term + i_term + d_term;

	// Step 6: Clamp output to valid normalized range [0.0, 1.0] for magnitude
	if (state->pwm_output > 1.0f)
		state->pwm_output = 1.0f;
	if (state->pwm_output < 0.0f)
		state->pwm_output = 0.0f;

	// Step 7: Apply direction to PWM output
	state->pwm_output = state->pwm_output * (float)target_direction;
	
	// Step 8: Convert normalized PWM to raw signed value (-4095 to 4095)
	state->pwm_raw = (int16_t)(state->pwm_output * (float)PWM_MAX);

	// Step 9: Apply dead zone minimum ONLY if motor should be moving
	// If target is non-zero but PWM is below minimum, boost to minimum
	// If target is zero, allow PWM to be zero
	if (target_magnitude > 0.1f)  // Only apply deadzone if we want motion
	{
		if (state->pwm_raw > 0 && state->pwm_raw < (int16_t)PWM_MIN)
			state->pwm_raw = (int16_t)PWM_MIN;
		else if (state->pwm_raw < 0 && state->pwm_raw > -(int16_t)PWM_MIN)
			state->pwm_raw = -(int16_t)PWM_MIN;
	}
	else if (target_magnitude == 0.0f)
	{
		state->pwm_raw = 0;  // Explicitly stop if target is zero
	}

	// Step 10: Send to motor
	tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
	MotorSetPWM((int32_t)state->pwm_raw, (int32_t)state->pwm_raw);
	tx_mutex_put(&g_motorMutex);
	
	// Debug output every 10 iterations (1 second at 100ms loop)
	static uint8_t debug_counter = 0;
	if (++debug_counter >= 10)
	{
		debug_counter = 0;
		char debug_msg[100];
		sprintf(debug_msg, "T:%.1f C:%.1f E:%.1f I:%.2f PWM:%d\r\n", 
		        target_magnitude * target_direction, hm_speed * target_direction, 
		        state->error, state->integral, state->pwm_raw);
		UartPrint(debug_msg);
	}

	// Step 11: Store state
	state->error_prev = state->error;
	state->current_speed = hm_speed;
}

void UpdateMotorControl(void)
{
    // CAN receiver has already populated g_targetSpeed

    // Update motor PID controller with current speed feedback
    g_motorPidState.target_speed = g_targetSpeed;
    MotorPIDUpdate(&g_motorPidState, g_vehicleSpeed);
}

void MotorPIDInit(MotorPIDState *state)
{
    /* PID gains tuned for motor speed control (hm/h units) */
    state->gain_p = 0.05f;   /* Proportional gain - adjust error response */
    state->gain_i = 0.01f;   /* Integral gain - eliminate steady-state error */
    state->gain_d = 0.002f;  /* Derivative gain - reduce overshoot */

    state->target_speed = 0.0f;
    state->current_speed = 0.0f;

    state->error = 0.0f;
    state->error_prev = 0.0f;

    state->integral = 0.0f;

    state->pwm_output = 0.0f;
    state->pwm_raw = 0;
}
