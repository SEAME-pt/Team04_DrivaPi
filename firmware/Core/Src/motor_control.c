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
 * 
 * Algorithm: Two-stage control
 * 1. FEEDFORWARD (90%): Direct PWM mapping based on motor calibration
 *    - base_pwm = (target / 100.0) * 4095
 *    - Handles ideal case (flat road, no load, etc.)
 * 
 * 2. FEEDBACK (10%): PI controller for real-world corrections
 *    - Handles: curves, hills, weight changes, wind, etc.
 *    - P term: immediate response to error
 *    - I term: eliminates steady-state error from disturbances
 */
void MotorControlUpdate(MotorControlState *state, float current_speed)
{
    // Convert m/s to hm/h (1 m/s = 36 hm/h)
    float current_hm = current_speed * 36.0f;
    
    // Extract magnitude and direction from target
    float target_magnitude = (state->target_speed < 0.0f) ? -state->target_speed : state->target_speed;
    int8_t target_direction = (state->target_speed >= 0.0f) ? 1 : -1;
    
    // Stop motor if target is zero
    if (target_magnitude < 0.5f)
    {
        state->pwm_raw = 0;
        state->integral = 0.0f;  // Reset integral when stopped
        tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
        MotorSetPWM(0, 0);
        tx_mutex_put(&g_motorMutex);
        state->current_speed = current_hm;
        return;
    }
    
    // Calculate error on magnitude
    state->error = target_magnitude - current_hm;
    
    // ===== STAGE 1: FEEDFORWARD (Direct Mapping) =====
    // Motor calibration: ~100 hm/h at PWM 4095
    // Direct ratio: PWM = (target / 100) * 4095
    float base_pwm = target_magnitude / 100.0f;  // Normalized to [0, 1]
    
    // ===== STAGE 2: PI FEEDBACK (Correction for Disturbances) =====
    
    // Proportional term: immediate response to current error
    float p_term = state->error * state->proportional_gain;
    
    // Integral term: accumulate error to eliminate steady-state offset
    // Only integrate if not saturated (anti-windup)
    float pwm_test = base_pwm + p_term + (state->integral * state->integral_gain);
    
    if (pwm_test < 1.0f && pwm_test > 0.0f)
    {
        // Not saturated: safe to integrate
        state->integral += state->error * 0.1f;  // 0.1s sample time
        
        // Clamp integral to prevent excessive windup
        if (state->integral > INTEGRAL_LIMIT)
            state->integral = INTEGRAL_LIMIT;
        if (state->integral < -INTEGRAL_LIMIT)
            state->integral = -INTEGRAL_LIMIT;
    }
    
    float i_term = state->integral * state->integral_gain;
    
    // Total PWM: feedforward + PI correction
    float pwm_normalized = base_pwm + p_term + i_term;
    
    // Clamp to valid range [0.0, 1.0]
    if (pwm_normalized > 1.0f)
        pwm_normalized = 1.0f;
    if (pwm_normalized < 0.0f)
        pwm_normalized = 0.0f;
    
    // Convert to raw PWM (0 to 4095)
    int16_t pwm_magnitude = (int16_t)(pwm_normalized * 4095.0f);
    
    // Apply deadzone minimum ONLY when starting from stop
    float error_magnitude = (state->error < 0) ? -state->error : state->error;
    if (error_magnitude > 20.0f && pwm_magnitude > 0 && pwm_magnitude < (int16_t)PWM_MIN)
    {
        pwm_magnitude = (int16_t)PWM_MIN;
    }
    
    // Apply direction to get signed PWM
    state->pwm_raw = pwm_magnitude * target_direction;
    
    // Send PWM to motor driver
    tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
    MotorSetPWM((int32_t)state->pwm_raw, (int32_t)state->pwm_raw);
    tx_mutex_put(&g_motorMutex);
    
    // Update state
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
    /* Hybrid feedforward + PI feedback controller */
    
    /* Feedforward: Direct mapping (built-in, no separate gain needed)
     * base_pwm = target / 100.0
     * This handles the bulk of the control (~90%)
     */
    state->feedforward_gain = 0.01f;  // 1/100 (for reference, not used directly)
    
    /* PI Feedback Gains: Small corrections for real-world disturbances */
    
    /* Proportional gain (Kp): Response to current error
     * Units: PWM correction per hm/h of error
     * Start small: 0.002 = 0.2% PWM correction per 1 hm/h error
     * Example: 10 hm/h error → 2% PWM adjustment
     */
    state->proportional_gain = 0.002f;
    
    /* Integral gain (Ki): Eliminates steady-state errors
     * Units: PWM correction per (hm/h * second) accumulated error
     * Start very small: 0.001 
     * This slowly corrects for hills, weight, wind, etc.
     */
    state->integral_gain = 0.001f;

    state->target_speed = 0.0f;
    state->current_speed = 0.0f;
    state->error = 0.0f;
    state->integral = 0.0f;
    state->pwm_output = 0.0f;
    state->pwm_raw = 0;
}

