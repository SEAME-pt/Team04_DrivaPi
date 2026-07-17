#ifndef __SOFT_I2C_H
#define __SOFT_I2C_H

#include "main.h"

#define SDA_PORT        GPIOB
#define SDA_PIN         GPIO_PIN_6 // SDA = D6 = PB6
#define SCL_PORT        GPIOE
#define SCL_PIN         GPIO_PIN_0 // SCL = D5 = PE0

void 	  Soft_I2C_Init(void);
void    Soft_I2C_Start(void);
void    Soft_I2C_Stop(void);
uint8_t Soft_I2C_WriteByte(uint8_t byte);
uint8_t Soft_I2C_ReadByte(uint8_t ack);

#endif /* __SOFT_I2C_H */
