################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Middlewares/MX_WIFI/core/checksumutils.c \
../Middlewares/MX_WIFI/core/mx_address.c \
../Middlewares/MX_WIFI/core/mx_rtos_abs.c \
../Middlewares/MX_WIFI/core/mx_wifi_hci.c \
../Middlewares/MX_WIFI/core/mx_wifi_ipc.c \
../Middlewares/MX_WIFI/core/mx_wifi_slip.c 

OBJS += \
./Middlewares/MX_WIFI/core/checksumutils.o \
./Middlewares/MX_WIFI/core/mx_address.o \
./Middlewares/MX_WIFI/core/mx_rtos_abs.o \
./Middlewares/MX_WIFI/core/mx_wifi_hci.o \
./Middlewares/MX_WIFI/core/mx_wifi_ipc.o \
./Middlewares/MX_WIFI/core/mx_wifi_slip.o 

C_DEPS += \
./Middlewares/MX_WIFI/core/checksumutils.d \
./Middlewares/MX_WIFI/core/mx_address.d \
./Middlewares/MX_WIFI/core/mx_rtos_abs.d \
./Middlewares/MX_WIFI/core/mx_wifi_hci.d \
./Middlewares/MX_WIFI/core/mx_wifi_ipc.d \
./Middlewares/MX_WIFI/core/mx_wifi_slip.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/MX_WIFI/core/%.o Middlewares/MX_WIFI/core/%.su Middlewares/MX_WIFI/core/%.cyclo: ../Middlewares/MX_WIFI/core/%.c Middlewares/MX_WIFI/core/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m33 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32U585xx -DTX_INCLUDE_USER_DEFINE_FILE -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Drivers/CMSIS/Include -I../AZURE_RTOS/App -I../Middlewares/ST/threadx/common/inc -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -I../Middlewares/MQTT/MQTTClient -I../Middlewares/MQTT/MQTTPacket -I../Middlewares/MX_WIFI/core -I../Middlewares/MX_WIFI/io_pattern -I../Middlewares/MX_WIFI -I../Core/Inc/MX_WIFI -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage  -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Middlewares-2f-MX_WIFI-2f-core

clean-Middlewares-2f-MX_WIFI-2f-core:
	-$(RM) ./Middlewares/MX_WIFI/core/checksumutils.cyclo ./Middlewares/MX_WIFI/core/checksumutils.d ./Middlewares/MX_WIFI/core/checksumutils.o ./Middlewares/MX_WIFI/core/checksumutils.su ./Middlewares/MX_WIFI/core/mx_address.cyclo ./Middlewares/MX_WIFI/core/mx_address.d ./Middlewares/MX_WIFI/core/mx_address.o ./Middlewares/MX_WIFI/core/mx_address.su ./Middlewares/MX_WIFI/core/mx_rtos_abs.cyclo ./Middlewares/MX_WIFI/core/mx_rtos_abs.d ./Middlewares/MX_WIFI/core/mx_rtos_abs.o ./Middlewares/MX_WIFI/core/mx_rtos_abs.su ./Middlewares/MX_WIFI/core/mx_wifi_hci.cyclo ./Middlewares/MX_WIFI/core/mx_wifi_hci.d ./Middlewares/MX_WIFI/core/mx_wifi_hci.o ./Middlewares/MX_WIFI/core/mx_wifi_hci.su ./Middlewares/MX_WIFI/core/mx_wifi_ipc.cyclo ./Middlewares/MX_WIFI/core/mx_wifi_ipc.d ./Middlewares/MX_WIFI/core/mx_wifi_ipc.o ./Middlewares/MX_WIFI/core/mx_wifi_ipc.su ./Middlewares/MX_WIFI/core/mx_wifi_slip.cyclo ./Middlewares/MX_WIFI/core/mx_wifi_slip.d ./Middlewares/MX_WIFI/core/mx_wifi_slip.o ./Middlewares/MX_WIFI/core/mx_wifi_slip.su

.PHONY: clean-Middlewares-2f-MX_WIFI-2f-core

