################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Middlewares/Mx_WIFI/io_pattern/mx_wifi_spi.c 

OBJS += \
./Middlewares/Mx_WIFI/io_pattern/mx_wifi_spi.o 

C_DEPS += \
./Middlewares/Mx_WIFI/io_pattern/mx_wifi_spi.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/Mx_WIFI/io_pattern/%.o Middlewares/Mx_WIFI/io_pattern/%.su Middlewares/Mx_WIFI/io_pattern/%.cyclo: ../Middlewares/Mx_WIFI/io_pattern/%.c Middlewares/Mx_WIFI/io_pattern/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m33 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32U585xx -DTX_INCLUDE_USER_DEFINE_FILE -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Drivers/CMSIS/Include -I../AZURE_RTOS/App -I../Middlewares/ST/threadx/common/inc -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/MQTT/MQTTClient" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/MQTT/MQTTPacket" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/Mx_WIFI/core" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/Mx_WIFI/io_pattern" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Core/Inc/Mx_WIFI" -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Middlewares-2f-Mx_WIFI-2f-io_pattern

clean-Middlewares-2f-Mx_WIFI-2f-io_pattern:
	-$(RM) ./Middlewares/Mx_WIFI/io_pattern/mx_wifi_spi.cyclo ./Middlewares/Mx_WIFI/io_pattern/mx_wifi_spi.d ./Middlewares/Mx_WIFI/io_pattern/mx_wifi_spi.o ./Middlewares/Mx_WIFI/io_pattern/mx_wifi_spi.su

.PHONY: clean-Middlewares-2f-Mx_WIFI-2f-io_pattern

