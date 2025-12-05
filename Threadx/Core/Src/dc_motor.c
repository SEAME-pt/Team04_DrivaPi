#include "app_threadx.h"
#include "dc_motor.h"
#include "pca9685.h"
#include "main.h"
#include "dc_motor_test.h"
#include <string.h>
#include <stdio.h>

static inline uint16_t clamp_u16(int32_t v) {
    if (v < 0) return 0;
    if (v >= (int32_t)PCA9685_COUNTS) return (uint16_t)(PCA9685_COUNTS - 1u);
    return (uint16_t)v;
}

static inline uint16_t sub_sat_u16(uint16_t a, uint16_t b) {
    if (b >= a) return 0;
    return (uint16_t)(a - b);
}

void Motor_Stop(void) {
    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0);
    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0);
    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, 0);

    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0);
    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0);
    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, 0);
}

void Motor_Forward(double speed) {
    uint16_t max = 4095;
    uint16_t pwm_val = (uint16_t)(speed * max);


  PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max);
  PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0);
  PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm_val);

  PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0);
  PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max);
  PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm_val);
}

void Motor_Backward(double speed) {
    uint16_t max = 4095;
    uint16_t pwm_val = (uint16_t)(speed * max);


  PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0);
  PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, max);
  PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm_val);


  PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max);
  PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0);
  PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm_val);
}

void Motor_Left(double speed) {
    const uint16_t max = (uint16_t)(PCA9685_COUNTS - 1u);
    uint16_t pwm_val = clamp_u16((int32_t)(speed * (double)max + 0.5));

    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max);
    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0);
    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm_val);

    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0);
    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max);
    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm_val);
}

void Motor_Right(double speed) {
    const uint16_t max = (uint16_t)(PCA9685_COUNTS - 1u);
    uint16_t pwm_val = clamp_u16((int32_t)(speed * (double)max + 0.5));

    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0);
    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, max);
    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm_val);

    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max);
    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0);
    PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm_val);
}

void Motor_SetMotor(double value) {
    const uint16_t max = (uint16_t)(PCA9685_COUNTS - 1u);
    uint16_t pwm_val = clamp_u16((int32_t)(fabs(value) * (double)max + 0.5));

    if (fabs(value) < 1e-6) {
        Motor_Stop();
        return;
    }

    if (value > 0.0) {
        // Forward
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm_val);

        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm_val);
    } else {
        // Backward
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, max);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm_val);

        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm_val);
    }
}

void Motor_SetPWM(int32_t left_counts, int32_t right_counts)
{
    const uint16_t max = (uint16_t)(PCA9685_COUNTS - 1u);

    /* Left motor */
    if (left_counts > 0) {
        uint16_t pwm = clamp_u16(left_counts);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm);
    } else if (left_counts < 0) {
        uint16_t pwm = clamp_u16(-left_counts);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, max);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm);
    } else {
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, 0);
    }

    /* Right motor */
    if (right_counts > 0) {
        uint16_t pwm = clamp_u16(right_counts);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm);
    } else if (right_counts < 0) {
        uint16_t pwm = clamp_u16(-right_counts);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm);
    } else {
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0);
        PCA9685_SetPWM(&MOTOR_I2C, PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, 0);
    }
}


VOID dc_motor(ULONG initial_input)
{
	t_can_message 	msg;
    ULONG			actual_flags;

    while (1)
    {
        Motor_Test_High(0.6);
        tx_event_flags_get(&event_flags, FLAG_CAN_SPEED_CMD,
        TX_OR_CLEAR, &actual_flags, TX_NO_WAIT);

        while (tx_queue_receive(&queue_speed_cmd, &msg, TX_NO_WAIT) == TX_SUCCESS)
        {

            if (msg.len >= 8) {
                int32_t left_counts = 0;
                int32_t right_counts = 0;
                memcpy(&left_counts, msg.data, sizeof(int32_t));
                memcpy(&right_counts, msg.data + sizeof(int32_t), sizeof(int32_t));

//                if (i2c_debug) {
//                    char buf[96];
//                    snprintf(buf, sizeof(buf), "DC Motor: left=%ld right=%ld\r\n", (long)left_counts, (long)right_counts);
//                    HAL_UART_Transmit(&huart1, (uint8_t*)buf, strlen(buf), HAL_MAX_DELAY);
//                }

                Motor_SetPWM(left_counts, right_counts);
            } else if (msg.len >= 4) {
                int32_t counts = 0;
                memcpy(&counts, msg.data, sizeof(int32_t));

//                if (i2c_debug) {
//                    char buf[64];
//                    snprintf(buf, sizeof(buf), "DC Motor: signed_counts=%ld\r\n", (long)counts);
//                    HAL_UART_Transmit(&huart1, (uint8_t*)buf, strlen(buf), HAL_MAX_DELAY);
//                }

                Motor_SetPWM(counts, counts);
            } else {
            }
		}
        tx_thread_sleep(50);
	}
}
