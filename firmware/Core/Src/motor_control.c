#include "motor_control.h"

void MotorPIDUpdate(MotorPIDState *state, float current_speed)
{
	static ULONG last_debug_ticks = 0;
	char debug_msg[192];
	ULONG now_ticks;
	ULONG elapsed_ms;
	int len;
    float   hm_speed = current_speed * 36.0f;

	// Step 1: Calculate error (difference between target and current speed)
	state->error = state->target_speed - hm_speed;

	// Step 2: Proportional term (immediate response)
	float p_term = state->gain_p * state->error;

	// Step 3: Integral term (eliminates steady-state error)
	state->integral += state->error * PID_SAMPLE_TIME;

	// Anti-windup: limit integral state to keep recovery fast after saturation.
	// Tune PID_INTEGRAL_LIMIT together with gain_i (larger gain_i generally needs a smaller limit).
	if (state->integral > PID_INTEGRAL_LIMIT)
		state->integral = PID_INTEGRAL_LIMIT;
	if (state->integral < -PID_INTEGRAL_LIMIT)
		state->integral = -PID_INTEGRAL_LIMIT;

	float i_term = state->gain_i * state->integral;

	// Step 4: Derivative term (reduces overshoot)
	float derivative = (state->error - state->error_prev) / PID_SAMPLE_TIME;
	float d_term = state->gain_d * derivative;

	// Step 5: Sum all three terms
	state->pwm_output = p_term + i_term + d_term;

	// Step 6: Clamp output direction to avoid forward/reverse flip near overshoot.
	// For a forward target, braking is achieved by reducing PWM to 0, not commanding reverse.
	if ((state->target_speed > 0.0f) && (state->pwm_output < 0.0f))
	{
		state->pwm_output = 0.0f;
		// Unwind integral quickly when clamped by direction constraint.
		state->integral *= 0.9f;
	}
	else if ((state->target_speed < 0.0f) && (state->pwm_output > 0.0f))
	{
		state->pwm_output = 0.0f;
		state->integral *= 0.9f;
	}

	// Step 7: Clamp output to valid normalized range [-1.0, 1.0]
	if (state->pwm_output > 1.0f)
		state->pwm_output = 1.0f;
	if (state->pwm_output < -1.0f)
		state->pwm_output = -1.0f;

	// Step 8: Convert normalized PWM (-1.0 to 1.0) to raw signed value (-4095 to 4095)
	state->pwm_raw = (int16_t)(state->pwm_output * (float)PWM_MAX);

	// Step 9: Apply dead zone minimum on absolute PWM magnitude
	if ((state->pwm_raw > 0) && (state->pwm_raw < (int16_t)PWM_MIN))
		state->pwm_raw = (int16_t)PWM_MIN;
	else if ((state->pwm_raw < 0) && (state->pwm_raw > -(int16_t)PWM_MIN))
		state->pwm_raw = -(int16_t)PWM_MIN;

	// Keep integrator neutral near stop command to avoid direction "memory".
	if ((state->target_speed < SPEED_MARGIN) && (state->target_speed > -SPEED_MARGIN))
		state->integral = 0.0f;

	// Step 10: Send to motor (keep critical section short)
	tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
	MotorSetPWM((int32_t)state->pwm_raw, (int32_t)state->pwm_raw);
	tx_mutex_put(&g_motorMutex);

	// Step 11: Store state
	state->error_prev = state->error;
	state->current_speed = hm_speed;

	now_ticks = tx_time_get();
	elapsed_ms = ((now_ticks - last_debug_ticks) * 1000u) / TX_TIMER_TICKS_PER_SECOND;
//	if (elapsed_ms >= PID_DEBUG_PRINT_EVERY_MS)
//	{
		len = snprintf(debug_msg, sizeof(debug_msg),
			"[PID] tgt=%.2f hm/h spd=%.2f hm/h err=%.2f p=%.3f i=%.3f d=%.3f out=%.3f raw=%d\r\n",
			state->target_speed, hm_speed, state->error, p_term, i_term, d_term, state->pwm_output, (int)state->pwm_raw);
		if (len > (int)sizeof(debug_msg) - 1)
			len = (int)sizeof(debug_msg) - 1;
		if (len > 0)
			HAL_UART_Transmit(&huart1, (uint8_t *)debug_msg, (uint16_t)len, 20);
		last_debug_ticks = now_ticks;
//	}
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
    /* PID gains tuned for motor speed control (hm/h units)
     * Kd is increased to dampen oscillations at high speeds
     * Ki is reduced to prevent integral windup
     * Kp is moderate for stable response across speed range
     */
    state->gain_p = 0.008f;  /* Proportional: smooth error correction */
    state->gain_i = 0.0005f; /* Integral: minimal to prevent windup */
    state->gain_d = 0.02f;   /* Derivative: strong damping for overshoot control */

    state->target_speed = 0.0f;
    state->current_speed = 0.0f;

    state->error = 0.0f;
    state->error_prev = 0.0f;

    state->integral = 0.0f;

    state->pwm_output = 0.0f;
    state->pwm_raw = 0;
}
