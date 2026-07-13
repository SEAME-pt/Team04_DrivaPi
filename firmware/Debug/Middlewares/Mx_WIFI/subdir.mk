################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Middlewares/Mx_WIFI/mx_wifi.c \
../Middlewares/Mx_WIFI/wifi_startup.c 

OBJS += \
./Middlewares/Mx_WIFI/mx_wifi.o \
./Middlewares/Mx_WIFI/wifi_startup.o 

C_DEPS += \
./Middlewares/Mx_WIFI/mx_wifi.d \
./Middlewares/Mx_WIFI/wifi_startup.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/Mx_WIFI/%.o Middlewares/Mx_WIFI/%.su Middlewares/Mx_WIFI/%.cyclo: ../Middlewares/Mx_WIFI/%.c Middlewares/Mx_WIFI/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m33 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32U585xx -DTX_INCLUDE_USER_DEFINE_FILE -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Drivers/CMSIS/Include -I../AZURE_RTOS/App -I../Middlewares/ST/threadx/common/inc -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/MQTT/MQTTClient" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/MQTT/MQTTPacket" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/Mx_WIFI/core" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/Mx_WIFI/io_pattern" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Core/Inc/Mx_WIFI" -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage   -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Middlewares-2f-Mx_WIFI

clean-Middlewares-2f-Mx_WIFI:
	-$(RM) ./Middlewares/Mx_WIFI/mx_wifi.cyclo ./Middlewares/Mx_WIFI/mx_wifi.d ./Middlewares/Mx_WIFI/mx_wifi.o ./Middlewares/Mx_WIFI/mx_wifi.su ./Middlewares/Mx_WIFI/wifi_startup.cyclo ./Middlewares/Mx_WIFI/wifi_startup.d ./Middlewares/Mx_WIFI/wifi_startup.o ./Middlewares/Mx_WIFI/wifi_startup.su

.PHONY: clean-Middlewares-2f-Mx_WIFI

