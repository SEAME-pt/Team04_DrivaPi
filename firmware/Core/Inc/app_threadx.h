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
#include <stdint.h>
#include <math.h>
#include "main.h"
#include "pca9685.h"
#include "dc_motor.h"
#include "servo_motor.h"
#include "dc_motor_test.h"
#include "motor_utils.h"
#include "sensors.h"
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
	can_rx_e,
	sensor_hts221_e,
	sensor_battery_e,
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
#define CMD_SPEED           44u
#define CMD_STEERING        45u

/* CAN Message IDs */
#define CAN_ID_BATTERY_DATA        0x200  /* Battery percentage + voltage (512) */
#define CAN_ID_HTS221_DATA         0x400  /* HTS221 Temperature + Humidity (1024) */
#define CAN_ID_RND_GEAR            0x300  /* RND gear state (768) */

/* RND Gear States */
typedef enum {
    GEAR_NEUTRAL = 0,   /* 'N' - Neutral */
    GEAR_REVERSE = 1,   /* 'R' - Reverse */
    GEAR_DRIVE = 2      /* 'D' - Drive */
} RNDGear_t;

/* RND Detection Thresholds */
#define RND_DEADZONE_POSITIVE  0.2f
#define RND_DEADZONE_NEGATIVE  -0.2f

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
VOID	ld1_ThreadEntry(ULONG initial_input);
VOID	DcMotor(ULONG initial_input);
VOID	ServoMotor(ULONG initial_input);
VOID	CanRx(ULONG initial_input);
VOID	CanTx(ULONG initial_input);
VOID	SpeedSensor(ULONG initial_input);
VOID	SensorHTS221Thread(ULONG initial_input);
VOID	SensorBatteryThread(ULONG initial_input);
void	ThreadInit(void);
int		CanSend(t_can_message* msg);
/* USER CODE END EFP */

/* USER CODE BEGIN 1 */
extern thread_t				g_threads[8];
extern TX_QUEUE             g_queueSpeedCmd;
extern TX_QUEUE             g_queueSteerCmd;
extern TX_EVENT_FLAGS_GROUP	g_eventFlags;
extern TX_MUTEX             g_speedDataMutex;
extern float				g_vehicleSpeed;
/* USER CODE END 1 */

#ifdef __cplusplus
}
#endif
#endif /* __APP_THREADX_H */
