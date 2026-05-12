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

    // Set Motor PWM Speeds
    __HAL_TIM_SET_COMPARE(&htim4, TIM_CHANNEL_1, speed);
    __HAL_TIM_SET_COMPARE(&htim16, TIM_CHANNEL_1, speed);

    if (forward)
    {
        // Motor A Forward
        HAL_GPIO_WritePin(GPIOE, AIN1_Pin, GPIO_PIN_SET);   // AIN1 -> HIGH
        HAL_GPIO_WritePin(GPIOD, AIN2_Pin, GPIO_PIN_RESET);// AIN2 -> LOW
        // Motor B Forward
        HAL_GPIO_WritePin(GPIOD, BIN1_Pin, GPIO_PIN_SET);   // BIN1 -> HIGH
        HAL_GPIO_WritePin(GPIOD, BIN2_Pin, GPIO_PIN_RESET); // BIN2 -> LOW
    }
    else
    {
        // Motor A Backward
        HAL_GPIO_WritePin(GPIOE, GPIO_PIN_7, GPIO_PIN_RESET); // AIN1 -> LOW
        HAL_GPIO_WritePin(GPIOD, GPIO_PIN_15, GPIO_PIN_SET);  // AIN2 -> HIGH
        // Motor B Backward
        HAL_GPIO_WritePin(GPIOD, GPIO_PIN_8, GPIO_PIN_RESET); // BIN1 -> LOW
        HAL_GPIO_WritePin(GPIOD, GPIO_PIN_9, GPIO_PIN_SET);   // BIN2 -> HIGH
    }
}

/**
  * @brief Stops both DC motors and cuts PWM signals
  */
void StopMotors(void)
{
    // Clear direction pins
    HAL_GPIO_WritePin(GPIOE, GPIO_PIN_7, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(GPIOD, GPIO_PIN_15, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(GPIOD, GPIO_PIN_8, GPIO_PIN_RESET);
    HAL_GPIO_WritePin(GPIOD, GPIO_PIN_9, GPIO_PIN_RESET);

    // Set PWM duty cycles to 0
    __HAL_TIM_SET_COMPARE(&htim4, TIM_CHANNEL_1, 0);
    __HAL_TIM_SET_COMPARE(&htim16, TIM_CHANNEL_1, 0);
}

void BrakeMotors(void)
{
    // Motor A brake
    HAL_GPIO_WritePin(GPIOE, GPIO_PIN_7, GPIO_PIN_SET);
    HAL_GPIO_WritePin(GPIOD, GPIO_PIN_15, GPIO_PIN_SET);

    // Motor B brake
    HAL_GPIO_WritePin(GPIOD, GPIO_PIN_8, GPIO_PIN_SET);
    HAL_GPIO_WritePin(GPIOD, GPIO_PIN_9, GPIO_PIN_SET);

    // PWM = 0
    __HAL_TIM_SET_COMPARE(&htim4, TIM_CHANNEL_1, 0);
    __HAL_TIM_SET_COMPARE(&htim16, TIM_CHANNEL_1, 0);
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
		// Check for new CAN messages (non-blocking)
		if (tx_event_flags_get(&g_eventFlags, FLAG_CAN_SPEED_CMD,
		    TX_OR_CLEAR, &actual_flags, TX_NO_WAIT) == TX_SUCCESS)
		{
			// Process all pending CAN messages
			while (tx_queue_receive(&g_queueSpeedCmd, &msg, TX_NO_WAIT) == TX_SUCCESS)
			{
				g_targetSpeed = 0;
				memcpy(&g_targetSpeed, msg.data , sizeof(int16_t));
				memcpy(&g_motorControlState.direction, msg.data + sizeof(int32_t), sizeof(int32_t));
				g_targetSpeed = (g_targetSpeed * 665) / 90;
				UartPrintf("Direction: %d\r\n",g_motorControlState.direction);
				UartPrintf("Speed: %d\r\n",g_targetSpeed);
			}
		}
		else
		{
			BrakeMotors();
			g_motorControlState.direction = 3;
		}

//		tx_mutex_get(&g_emergencyMutex, TX_WAIT_FOREVER);
//		if(g_emergencyBrake && g_motorControlState.direction == FORWARD)
//		{
//			tx_mutex_put(&g_emergencyMutex);
//			tx_thread_sleep(10);
//			continue ;
//		}
//		tx_mutex_put(&g_emergencyMutex);

		if (g_motorControlState.direction == FORWARD || g_motorControlState.direction == BACKWARD)
		{
			//UpdateMotorControl();
			if (g_motorControlState.direction == FORWARD)
				MoveMotors(g_targetSpeed, true);
			else
				MoveMotors(g_targetSpeed, false);
		}

		
		tx_thread_sleep(100);
	}
}
