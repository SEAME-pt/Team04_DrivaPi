/**
 * @file motor_control.c
 * @author DrivaPi Team
 * @brief Simple feedforward + proportional motor speed controller
 * @note Uses magnitude-only speed sensor with direction applied separately
 */

#include "motor_control.h"

/**
 * @brief Update motor control using hybrid feedforward + PI feedback
 * @param state Controller state with target
 * @param current_speed Measured speed in m/s (magnitude only, always positive)
 */
void MotorControlUpdate(MotorControlState *state, float current_speed)
{
    // Convert m/s to hm/h (1 m/s = 36 hm/h)
	uint16_t current_hm = (uint16_t)ceilf(current_speed * 36.0f);
    
    int8_t target_direction;
    if (state->direction == FORWARD)
        target_direction = 1;
    else if (state->direction == REVERSE)
        target_direction = 0;
    
    if (state->target_speed < 1.0f)
    {
        state->pwm_raw = 0;
        state->integral = 0.0f;  // Reset integral when stopped
        tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
        MoveMotors(state->pwm_raw, true);
        tx_mutex_put(&g_motorMutex);
        state->current_speed = current_hm;
        return;
    }
    
    state->error = state->target_speed - current_hm;
    
    // BASE: PID + feedforward (discrete time)
    // error = target - current
    // integral = clamp(integral + (error * dt), -limit, limit)
    // derivative = (error - prev_error) / dt
    // feedforward_raw = (target - prev_target) / dt        (simulator-style)
    // feedforward = ff_smooth * (1 - ff_alpha) + feedforward_raw * ff_alpha
    // output = (Kp * error) + (Ki * integral) + (Kd * derivative) + (Kff * feedforward)
    // base_pwm = feedforward_gain * target                  (static mapping)
    // pwm_normalized = clamp(base_pwm + output, 0.0f, 1.0f)
    float pwm_normalized = 0.0f;

#if 0
    /* Requires adding previous_error, previous_target, derivative_gain,
     * ff_alpha, and ff_smooth to MotorControlState. */
    /* PID base (example with feedforward):
     * float dt = 0.1f;
     * float base_pwm = clamp(state->feedforward_gain * state->target_speed, 0.0f, 1.0f);
     * state->integral = clamp(state->integral + (state->error * dt),
     *                         -INTEGRAL_LIMIT, INTEGRAL_LIMIT);
     * float derivative = (state->error - state->previous_error) / dt;
     * float feedforward_raw = (state->target_speed - state->previous_target) / dt;
     * state->ff_smooth = state->ff_smooth * (1.0f - state->ff_alpha)
     *                    + feedforward_raw * state->ff_alpha;
     * float p_term = state->error * state->proportional_gain;
     * float i_term = state->integral * state->integral_gain;
     * float d_term = derivative * state->derivative_gain;
     * float ff_term = state->feedforward_gain * state->ff_smooth;
     * pwm_normalized = base_pwm + p_term + i_term + d_term + ff_term;
     * state->previous_error = state->error;
     * state->previous_target = state->target_speed;
     */
#endif
    
    if (pwm_normalized > 1.0f)
        pwm_normalized = 1.0f;
    if (pwm_normalized < 0.0f)
        pwm_normalized = 0.0f;

    int16_t pwm_magnitude = (int16_t)(pwm_normalized * 665.0f);

    if (pwm_magnitude > 0 && pwm_magnitude < (int16_t)PWM_MIN)
        pwm_magnitude = (int16_t)PWM_MIN;
    state->pwm_raw = pwm_magnitude;
    
	tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
	MoveMotors(state->pwm_raw, target_direction);
	tx_mutex_put(&g_motorMutex);
    
    state->current_speed = current_hm;
}

void UpdateMotorControl(void)
{
    float current_speed;

    tx_mutex_get(&g_speedDataMutex, TX_WAIT_FOREVER);
    current_speed = g_vehicleSpeed;
    tx_mutex_put(&g_speedDataMutex);

    g_motorControlState.target_speed = g_targetSpeed;
    MotorControlUpdate(&g_motorControlState, current_speed);
}

void MotorControlInit(MotorControlState *state)
{
    state->feedforward_gain = 0.01f;
    state->proportional_gain = 0.002f;
    state->integral_gain = 0.001f;

    state->target_speed = 0.0f;
    state->current_speed = 0.0f;
    state->error = 0.0f;
    state->integral = 0.0f;
    state->pwm_output = 0.0f;
    state->pwm_raw = 0;
    state->direction = -1;
}
