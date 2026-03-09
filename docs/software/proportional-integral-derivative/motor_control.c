#include "motor_control.h"
#include "dc_motor.h"

void MotorPIDUpdate(MotorPIDState *state, float current_speed)
{
    // Step 1: Calculate error (difference between target and current speed)
    state->error = state->target_speed - current_speed;
    
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
    
    // Step 6: Clamp output to valid normalized range [-1.0, 1.0]
    if (state->pwm_output > 1.0f) 
        state->pwm_output = 1.0f;
    if (state->pwm_output < -1.0f) 
        state->pwm_output = -1.0f;
    
    // Step 7: Convert normalized PWM (-1.0 to 1.0) to raw signed value (-4095 to 4095)
    state->pwm_raw = (int16_t)(state->pwm_output * (float)PWM_MAX);
    
    // Step 8: Apply dead zone minimum on absolute PWM magnitude
    if ((state->pwm_raw > 0) && (state->pwm_raw < (int16_t)PWM_MIN))
        state->pwm_raw = (int16_t)PWM_MIN;
    else if ((state->pwm_raw < 0) && (state->pwm_raw > -(int16_t)PWM_MIN))
        state->pwm_raw = -(int16_t)PWM_MIN;
    
    // Step 9: Send signed PWM counts to motor driver (left_counts, right_counts)
    MotorSetPWM((int32_t)state->pwm_raw, (int32_t)state->pwm_raw);
    
    // Step 10: Store current error for derivative calculation in next cycle
    state->error_prev = state->error;
    state->current_speed = current_speed;
}

void UpdateMotorControl(void)
{
    // CAN receiver has already populated g_targetSpeed
    
    // Update motor PID controller with current speed feedback
    g_motorPidState.target_speed = g_targetSpeed;
    MotorPIDUpdate(&g_motorPidState, g_vehicleSpeed);
}

void MotorPIDInit(MotorPIDState *state, float kp, float ki, float kd)
{
    state->gain_p = kp;
    state->gain_i = ki;
    state->gain_d = kd;

    state->target_speed = 0.0f;
    state->current_speed = 0.0f;

    state->error = 0.0f;
    state->error_prev = 0.0f;

    state->integral = 0.0f;

    state->pwm_output = 0.0f;
    state->pwm_raw = 0;
}
