################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Middlewares/Mx_WIFI/core/checksumutils.c \
../Middlewares/Mx_WIFI/core/mx_address.c \
../Middlewares/Mx_WIFI/core/mx_rtos_abs.c \
../Middlewares/Mx_WIFI/core/mx_wifi_hci.c \
../Middlewares/Mx_WIFI/core/mx_wifi_ipc.c \
../Middlewares/Mx_WIFI/core/mx_wifi_slip.c 

OBJS += \
./Middlewares/Mx_WIFI/core/checksumutils.o \
./Middlewares/Mx_WIFI/core/mx_address.o \
./Middlewares/Mx_WIFI/core/mx_rtos_abs.o \
./Middlewares/Mx_WIFI/core/mx_wifi_hci.o \
./Middlewares/Mx_WIFI/core/mx_wifi_ipc.o \
./Middlewares/Mx_WIFI/core/mx_wifi_slip.o 

C_DEPS += \
./Middlewares/Mx_WIFI/core/checksumutils.d \
./Middlewares/Mx_WIFI/core/mx_address.d \
./Middlewares/Mx_WIFI/core/mx_rtos_abs.d \
./Middlewares/Mx_WIFI/core/mx_wifi_hci.d \
./Middlewares/Mx_WIFI/core/mx_wifi_ipc.d \
./Middlewares/Mx_WIFI/core/mx_wifi_slip.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/Mx_WIFI/core/%.o Middlewares/Mx_WIFI/core/%.su Middlewares/Mx_WIFI/core/%.cyclo: ../Middlewares/Mx_WIFI/core/%.c Middlewares/Mx_WIFI/core/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m33 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32U585xx -DTX_INCLUDE_USER_DEFINE_FILE -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Drivers/CMSIS/Include -I../AZURE_RTOS/App -I../Middlewares/ST/threadx/common/inc -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/MQTT/MQTTClient" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/MQTT/MQTTPacket" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/Mx_WIFI/core" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/Mx_WIFI/io_pattern" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Core/Inc/Mx_WIFI" -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Middlewares-2f-Mx_WIFI-2f-core

clean-Middlewares-2f-Mx_WIFI-2f-core:
	-$(RM) ./Middlewares/Mx_WIFI/core/checksumutils.cyclo ./Middlewares/Mx_WIFI/core/checksumutils.d ./Middlewares/Mx_WIFI/core/checksumutils.o ./Middlewares/Mx_WIFI/core/checksumutils.su ./Middlewares/Mx_WIFI/core/mx_address.cyclo ./Middlewares/Mx_WIFI/core/mx_address.d ./Middlewares/Mx_WIFI/core/mx_address.o ./Middlewares/Mx_WIFI/core/mx_address.su ./Middlewares/Mx_WIFI/core/mx_rtos_abs.cyclo ./Middlewares/Mx_WIFI/core/mx_rtos_abs.d ./Middlewares/Mx_WIFI/core/mx_rtos_abs.o ./Middlewares/Mx_WIFI/core/mx_rtos_abs.su ./Middlewares/Mx_WIFI/core/mx_wifi_hci.cyclo ./Middlewares/Mx_WIFI/core/mx_wifi_hci.d ./Middlewares/Mx_WIFI/core/mx_wifi_hci.o ./Middlewares/Mx_WIFI/core/mx_wifi_hci.su ./Middlewares/Mx_WIFI/core/mx_wifi_ipc.cyclo ./Middlewares/Mx_WIFI/core/mx_wifi_ipc.d ./Middlewares/Mx_WIFI/core/mx_wifi_ipc.o ./Middlewares/Mx_WIFI/core/mx_wifi_ipc.su ./Middlewares/Mx_WIFI/core/mx_wifi_slip.cyclo ./Middlewares/Mx_WIFI/core/mx_wifi_slip.d ./Middlewares/Mx_WIFI/core/mx_wifi_slip.o ./Middlewares/Mx_WIFI/core/mx_wifi_slip.su

.PHONY: clean-Middlewares-2f-Mx_WIFI-2f-core

