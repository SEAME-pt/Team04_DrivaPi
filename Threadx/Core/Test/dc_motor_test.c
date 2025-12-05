/* Test harness for DC motor (test-only)
 */

#include "app_threadx.h"
#include "main.h"
#include "dc_motor.h"
#include "dc_motor_test.h"
#include <stdio.h>
#include <string.h>

static void UART_Print(const char *s)
{
    HAL_UART_Transmit(&huart1, (uint8_t*)s, strlen(s), HAL_MAX_DELAY);
}

void Motor_Test_High(double speed) {
    char buf[128];
//    snprintf(buf, sizeof(buf), "Motor_Test_High: Starting high-power motor test (speed=%.2f)\r\n", speed);
//    UART_Print(buf);

    UART_Print("-> FORWARD (1.5s)...\r\n");
    Motor_Forward(speed);
    tx_thread_sleep(150);
    tx_thread_sleep(30);

    UART_Print("-> BACKWARD (1.5s)...\r\n");
    Motor_Backward(speed);
    tx_thread_sleep(150);
    Motor_Stop();
    tx_thread_sleep(30);

    UART_Print("-> LEFT (1.2s)...\r\n");
    Motor_Left(speed);
    tx_thread_sleep(120);
    Motor_Stop();
    tx_thread_sleep(30);

    UART_Print("-> RIGHT (1.2s)...\r\n");
    Motor_Right(speed);
    tx_thread_sleep(120);
    Motor_Stop();

    UART_Print("Motor_Test_High: complete\r\n");
}
