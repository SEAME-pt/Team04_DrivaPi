################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Middlewares/MQTT/MQTTClient/MQTTClient.c \
../Middlewares/MQTT/MQTTClient/MQTT_STM32.c 

OBJS += \
./Middlewares/MQTT/MQTTClient/MQTTClient.o \
./Middlewares/MQTT/MQTTClient/MQTT_STM32.o 

C_DEPS += \
./Middlewares/MQTT/MQTTClient/MQTTClient.d \
./Middlewares/MQTT/MQTTClient/MQTT_STM32.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/MQTT/MQTTClient/%.o Middlewares/MQTT/MQTTClient/%.su Middlewares/MQTT/MQTTClient/%.cyclo: ../Middlewares/MQTT/MQTTClient/%.c Middlewares/MQTT/MQTTClient/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m33 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32U585xx -DTX_INCLUDE_USER_DEFINE_FILE -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Drivers/CMSIS/Include -I../AZURE_RTOS/App -I../Middlewares/ST/threadx/common/inc -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/MQTT/MQTTClient" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/MQTT/MQTTPacket" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/Mx_WIFI/core" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/Mx_WIFI/io_pattern" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Core/Inc/Mx_WIFI" -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage   -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Middlewares-2f-MQTT-2f-MQTTClient

clean-Middlewares-2f-MQTT-2f-MQTTClient:
	-$(RM) ./Middlewares/MQTT/MQTTClient/MQTTClient.cyclo ./Middlewares/MQTT/MQTTClient/MQTTClient.d ./Middlewares/MQTT/MQTTClient/MQTTClient.o ./Middlewares/MQTT/MQTTClient/MQTTClient.su ./Middlewares/MQTT/MQTTClient/MQTT_STM32.cyclo ./Middlewares/MQTT/MQTTClient/MQTT_STM32.d ./Middlewares/MQTT/MQTTClient/MQTT_STM32.o ./Middlewares/MQTT/MQTTClient/MQTT_STM32.su

.PHONY: clean-Middlewares-2f-MQTT-2f-MQTTClient

