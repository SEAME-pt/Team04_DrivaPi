/**
  ******************************************************************************
  * @file    firmware/Core/Src/dc_motor.c
  * @author  DrivaPi Team
  * @brief   This file contains the DC motor control functions.
  ******************************************************************************
  * @attention
  *
*/
#include "dc_motor.h"

/**
  * @brief Controls motor direction and speed
  * @param speed Target speed (0 to 665)
  * @param forward True for forward, False for backward
  */
void MoveMotors(uint16_t speed, bool forward)
{
    if (speed > 665)
        speed = 665;

    __HAL_TIM_SET_COMPARE(&htim4, TIM_CHANNEL_1, speed);
    __HAL_TIM_SET_COMPARE(&htim16, TIM_CHANNEL_1, speed);

    if (forward)
    {
        HAL_GPIO_WritePin(GPIOE, AIN1_Pin, GPIO_PIN_SET);
        HAL_GPIO_WritePin(GPIOD, AIN2_Pin, GPIO_PIN_RESET);
        HAL_GPIO_WritePin(GPIOD, BIN1_Pin, GPIO_PIN_SET);
        HAL_GPIO_WritePin(GPIOD, BIN2_Pin, GPIO_PIN_RESET);
    }
    else
    {
        HAL_GPIO_WritePin(GPIOE, AIN1_Pin, GPIO_PIN_RESET);
        HAL_GPIO_WritePin(GPIOD, AIN2_Pin, GPIO_PIN_SET);
        HAL_GPIO_WritePin(GPIOD, BIN1_Pin, GPIO_PIN_RESET);
        HAL_GPIO_WritePin(GPIOD, BIN2_Pin, GPIO_PIN_SET);
    }
}

/**
  * @brief Stops both DC motors and cuts PWM signals
  */
void MotorCoast(void)
{
    // Clear direction pins
    HAL_GPIO_WritePin(GPIOE, AIN1_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(GPIOD, AIN2_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(GPIOD, BIN1_Pin, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(GPIOD, BIN2_Pin, GPIO_PIN_RESET);

    // Set PWM duty cycles to 0
    __HAL_TIM_SET_COMPARE(&htim4, TIM_CHANNEL_1, 0);
    __HAL_TIM_SET_COMPARE(&htim16, TIM_CHANNEL_1, 0);
}

/**
  * @brief Applies active braking to both DC motors.
  *
  * Sets both H-bridge direction pins high and applies maximum PWM,
  * forcing the motors to stop quickly.
  */
void StopMotors(void)
{
    HAL_GPIO_WritePin(GPIOE, AIN1_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(GPIOD, AIN2_Pin, GPIO_PIN_SET);

    HAL_GPIO_WritePin(GPIOD, BIN1_Pin, GPIO_PIN_SET);
    HAL_GPIO_WritePin(GPIOD, BIN2_Pin, GPIO_PIN_SET);

    __HAL_TIM_SET_COMPARE(&htim4, TIM_CHANNEL_1, 665);
    __HAL_TIM_SET_COMPARE(&htim16, TIM_CHANNEL_1, 665);
}

/**
* @brief DC motor thread entry that consumes speed commands from CAN.
*
* @param initial_input ThreadX initial input (unused).
* @return VOID
*/
VOID DcMotor(ULONG initial_input)
{
	t_can_message 	msg;
	ULONG			actual_flags;

	while (1)
	{
		if (tx_event_flags_get(&g_eventFlags, FLAG_CAN_SPEED_CMD, TX_OR_CLEAR, &actual_flags, TX_NO_WAIT) == TX_SUCCESS)
		{
			while (tx_queue_receive(&g_queueSpeedCmd, &msg, TX_NO_WAIT) == TX_SUCCESS)
			{
				g_targetSpeed = 0;
				memcpy(&g_targetSpeed, msg.data , sizeof(int16_t));
				memcpy(&g_motorControlState.direction, msg.data + sizeof(int32_t), sizeof(int32_t));
			}
		}

		tx_mutex_get(&g_emergencyMutex, TX_WAIT_FOREVER);
		if(g_emergencyBrake && g_motorControlState.direction == FORWARD)
		{
			tx_mutex_put(&g_emergencyMutex);
			tx_thread_sleep(10);
			continue ;
		}
		tx_mutex_put(&g_emergencyMutex);

		if (g_motorControlState.direction == FORWARD || g_motorControlState.direction == REVERSE)
			UpdateMotorControl();
		else if (g_motorControlState.direction == NEUTRAL)
		{
			tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
			MotorCoast();
			tx_mutex_put(&g_motorMutex);
		}
		else
		{
			tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
			StopMotors();
			tx_mutex_put(&g_motorMutex);
		}
		tx_thread_sleep(10);
	}
}
