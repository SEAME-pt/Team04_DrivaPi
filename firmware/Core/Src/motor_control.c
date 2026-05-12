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
    else if (state->direction == BACKWARD)
        target_direction = -1;
    
    if (state->target_speed < 1.0f)
    {
        state->pwm_raw = 0;
        state->integral = 0.0f;  // Reset integral when stopped
        tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
        MoveMotors(state->pwm_raw, false);
        tx_mutex_put(&g_motorMutex);
        state->current_speed = current_hm;
        return;
    }
    
    state->error = state->target_speed - current_hm;
    
    float base_pwm = state->target_speed / 100.0f;
    if (base_pwm > 1.0f)
        base_pwm = 1.0f;
    
    float p_term = state->error * state->proportional_gain;
    float pwm_test = base_pwm + p_term + (state->integral * state->integral_gain);
    if (pwm_test < 1.0f && pwm_test > 0.0f)
    {
        state->integral += state->error * 0.1f;

        if (state->integral >= INTEGRAL_LIMIT)
            state->integral = INTEGRAL_LIMIT;
        else if (state->integral <= -INTEGRAL_LIMIT)
            state->integral = -INTEGRAL_LIMIT;
    }
    
    float i_term = state->integral * state->integral_gain;
    
    float pwm_normalized = base_pwm + p_term + i_term;
    
    if (pwm_normalized > 1.0f)
        pwm_normalized = 1.0f;
    if (pwm_normalized < 0.0f)
        pwm_normalized = 0.0f;

    int16_t pwm_magnitude = (int16_t)(pwm_normalized * 4095.0f);

    if (pwm_magnitude > 0 && pwm_magnitude < (int16_t)PWM_MIN)
        pwm_magnitude = (int16_t)PWM_MIN;
    state->pwm_raw = pwm_magnitude * target_direction;
    
    tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
    MoveMotors(state->pwm_raw, false);
    tx_mutex_put(&g_motorMutex);
    
    state->current_speed = current_hm;
}

void UpdateMotorControl(void)
{
    // CAN receiver has already populated g_targetSpeed
    // Update motor controller with current speed feedback
    g_motorControlState.target_speed = g_targetSpeed;
    MotorControlUpdate(&g_motorControlState, g_vehicleSpeed);
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

