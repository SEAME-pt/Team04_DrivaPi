/* USER CODE BEGIN Header */
/**
 ******************************************************************************
* @file    app_threadx.h
* @author  MCD Application Team
* @brief   ThreadX applicative header file
******************************************************************************
	* @attention
*
* Copyright (c) 2025 STMicroelectronics.
* All rights reserved.
*
* This software is licensed under terms that can be found in the LICENSE file
* in the root directory of this software component.
* If no LICENSE file comes with this software, it is provided AS-IS.
*
******************************************************************************
*/
/* USER CODE END Header */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __APP_THREADX_H
#define __APP_THREADX_H
#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "tx_api.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include <string.h>
#include <stdio.h>
#include "main.h"
#include <stdint.h>
/* USER CODE END Includes */

/* Exported types ------------------------------------------------------------*/
/* USER CODE BEGIN ET */
typedef struct thread_s
{
	uint8_t		thread_Stack[1024];
	TX_THREAD 	thread_ptr;
}thread_t;

typedef enum threads_s
{
	supervisor_e,
	dc_motor_e,
	servo_motor_e,
	speed_sensor_e,
	can_tx_e,
	can_rx_e
}	t_e_threads;

typedef struct can_message_s
{
    uint32_t id;	
    uint8_t  data[8];
    uint8_t  len;
} t_can_message;
/* USER CODE END ET */

/* Exported constants --------------------------------------------------------*/
/* USER CODE BEGIN EC */

/* USER CODE END EC */

/* Private defines -----------------------------------------------------------*/

/* USER CODE BEGIN PD */
#define FLAG_CAN_SPEED_CMD	(1 << 0)
#define FLAG_CAN_STEER_CMD	(1 << 1)
#define FLAG_SENSOR_UPDATE	(1 << 2)
#define THREAD_STACK_SIZE	1024
#define QUEUE_SIZE         	10
#define CMD_SPEED           0x101
#define CMD_STEERING        0x102

/* USER CODE END PD */

/* Main thread defines -------------------------------------------------------*/
/* USER CODE BEGIN MTD */

/* USER CODE END MTD */

/* Exported macro ------------------------------------------------------------*/
/* USER CODE BEGIN EM */

/* USER CODE END EM */

/* Exported functions prototypes ---------------------------------------------*/
UINT App_ThreadX_Init(VOID *memory_ptr);
void MX_ThreadX_Init(void);

/* USER CODE BEGIN EFP */
VOID ld1_thread_entry(ULONG initial_input);
VOID dc_motor(ULONG initial_input);
VOID servo_motor(ULONG initial_input);
VOID canRX(ULONG initial_input);
VOID canTX(ULONG initial_input);
VOID speed_sensor(ULONG initial_input);
void thread_init(void);
/* USER CODE END EFP */

/* USER CODE BEGIN 1 */
extern thread_t				threads[6];
extern TX_QUEUE             queue_speed_cmd;
extern TX_QUEUE             queue_steer_cmd;
extern TX_EVENT_FLAGS_GROUP	event_flags;
extern TX_MUTEX             speed_data_mutex;
extern float				g_vehicle_speed;
/* USER CODE END 1 */

#ifdef __cplusplus
}
#endif
#endif /* __APP_THREADX_H */
