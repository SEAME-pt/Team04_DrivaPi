################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Middlewares/MX_WIFI/mx_wifi.c \
../Middlewares/MX_WIFI/wifi_startup.c 

OBJS += \
./Middlewares/MX_WIFI/mx_wifi.o \
./Middlewares/MX_WIFI/wifi_startup.o 

C_DEPS += \
./Middlewares/MX_WIFI/mx_wifi.d \
./Middlewares/MX_WIFI/wifi_startup.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/MX_WIFI/%.o Middlewares/MX_WIFI/%.su Middlewares/MX_WIFI/%.cyclo: ../Middlewares/MX_WIFI/%.c Middlewares/MX_WIFI/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m33 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32U585xx -DTX_INCLUDE_USER_DEFINE_FILE -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Drivers/CMSIS/Include -I../AZURE_RTOS/App -I../Middlewares/ST/threadx/common/inc -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -I../Middlewares/MQTT/MQTTClient -I../Middlewares/MQTT/MQTTPacket -I../Middlewares/MX_WIFI/core -I../Middlewares/MX_WIFI/io_pattern -I../Middlewares/MX_WIFI -I../Core/Inc/MX_WIFI -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage  -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Middlewares-2f-MX_WIFI

clean-Middlewares-2f-MX_WIFI:
	-$(RM) ./Middlewares/MX_WIFI/mx_wifi.cyclo ./Middlewares/MX_WIFI/mx_wifi.d ./Middlewares/MX_WIFI/mx_wifi.o ./Middlewares/MX_WIFI/mx_wifi.su ./Middlewares/MX_WIFI/wifi_startup.cyclo ./Middlewares/MX_WIFI/wifi_startup.d ./Middlewares/MX_WIFI/wifi_startup.o ./Middlewares/MX_WIFI/wifi_startup.su

.PHONY: clean-Middlewares-2f-MX_WIFI

