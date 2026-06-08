/**
 * @file motor_control.c
 * @author DrivaPi Team
 * @brief Simple feedforward + proportional motor speed controller
 * @note Uses magnitude-only speed sensor with direction applied separately
 */

#include "motor_control.h"

/**
 * @brief Update motor control using hybrid feedforward + PID feedback
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
        state->previous_error = 0.0f;
        state->ff_smooth = 0.0f;
        tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
        MoveMotors(state->pwm_raw, true);
        tx_mutex_put(&g_motorMutex);
        state->current_speed = current_hm;
        return;
    }
    
    state->error = state->target_speed - current_hm;
    
    // PID + feedforward controller (dt = 0.1s assumed from control loop rate)
    const float dt = 0.1f;
    
    // Feedforward: compute target rate-of-change and smooth it
    float feedforward_raw = (state->target_speed - state->previous_target) / dt;
    state->ff_smooth = state->ff_smooth * (1.0f - state->ff_alpha) 
                       + feedforward_raw * state->ff_alpha;
    
    // Integral term with anti-windup
    state->integral += state->error * dt;
    if (state->integral >= INTEGRAL_LIMIT)
        state->integral = INTEGRAL_LIMIT;
    else if (state->integral <= -INTEGRAL_LIMIT)
        state->integral = -INTEGRAL_LIMIT;
    
    // Derivative term from previous error
    float derivative = (state->error - state->previous_error) / dt;
    
    // Compute PID terms
    float base_pwm = state->feedforward_gain * state->target_speed;
    if (base_pwm > 1.0f)
        base_pwm = 1.0f;
    
    float p_term = state->error * state->proportional_gain;
    float i_term = state->integral * state->integral_gain;
    float d_term = derivative * state->derivative_gain;
    float ff_term = state->feedforward_gain * state->ff_smooth;
    
    float pwm_normalized = base_pwm + p_term + i_term + d_term + ff_term;
    
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
    
    // Store current values for next iteration
    state->previous_error = state->error;
    state->previous_target = state->target_speed;
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
    state->derivative_gain = 0.0005f;
    state->ff_alpha = 0.1f;

    state->target_speed = 0.0f;
    state->current_speed = 0.0f;
    state->error = 0.0f;
    state->previous_error = 0.0f;
    state->integral = 0.0f;
    state->ff_smooth = 0.0f;
    state->previous_target = 0.0f;
    state->pwm_output = 0.0f;
    state->pwm_raw = 0;
    state->direction = -1;
}
