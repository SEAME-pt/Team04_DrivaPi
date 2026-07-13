################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Middlewares/SystemView/SEGGER_RTT.c \
../Middlewares/SystemView/SEGGER_RTT_Syscalls_GCC.c \
../Middlewares/SystemView/SEGGER_RTT_Syscalls_IAR.c \
../Middlewares/SystemView/SEGGER_RTT_Syscalls_KEIL.c \
../Middlewares/SystemView/SEGGER_RTT_Syscalls_SES.c \
../Middlewares/SystemView/SEGGER_RTT_printf.c \
../Middlewares/SystemView/SEGGER_SYSVIEW.c \
../Middlewares/SystemView/SEGGER_SYSVIEW_Config_ThreadX.c \
../Middlewares/SystemView/SEGGER_SYSVIEW_ThreadX.c 

S_UPPER_SRCS += \
../Middlewares/SystemView/SEGGER_RTT_ASM_ARMv7M.S 

OBJS += \
./Middlewares/SystemView/SEGGER_RTT.o \
./Middlewares/SystemView/SEGGER_RTT_ASM_ARMv7M.o \
./Middlewares/SystemView/SEGGER_RTT_Syscalls_GCC.o \
./Middlewares/SystemView/SEGGER_RTT_Syscalls_IAR.o \
./Middlewares/SystemView/SEGGER_RTT_Syscalls_KEIL.o \
./Middlewares/SystemView/SEGGER_RTT_Syscalls_SES.o \
./Middlewares/SystemView/SEGGER_RTT_printf.o \
./Middlewares/SystemView/SEGGER_SYSVIEW.o \
./Middlewares/SystemView/SEGGER_SYSVIEW_Config_ThreadX.o \
./Middlewares/SystemView/SEGGER_SYSVIEW_ThreadX.o 

S_UPPER_DEPS += \
./Middlewares/SystemView/SEGGER_RTT_ASM_ARMv7M.d 

C_DEPS += \
./Middlewares/SystemView/SEGGER_RTT.d \
./Middlewares/SystemView/SEGGER_RTT_Syscalls_GCC.d \
./Middlewares/SystemView/SEGGER_RTT_Syscalls_IAR.d \
./Middlewares/SystemView/SEGGER_RTT_Syscalls_KEIL.d \
./Middlewares/SystemView/SEGGER_RTT_Syscalls_SES.d \
./Middlewares/SystemView/SEGGER_RTT_printf.d \
./Middlewares/SystemView/SEGGER_SYSVIEW.d \
./Middlewares/SystemView/SEGGER_SYSVIEW_Config_ThreadX.d \
./Middlewares/SystemView/SEGGER_SYSVIEW_ThreadX.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/SystemView/%.o Middlewares/SystemView/%.su Middlewares/SystemView/%.cyclo: ../Middlewares/SystemView/%.c Middlewares/SystemView/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m33 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32U585xx -DTX_INCLUDE_USER_DEFINE_FILE -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Drivers/CMSIS/Include -I../AZURE_RTOS/App -I../Middlewares/ST/threadx/common/inc -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/MQTT/MQTTClient" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/MQTT/MQTTPacket" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/Mx_WIFI/core" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/Mx_WIFI/io_pattern" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Core/Inc/Mx_WIFI" -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage   -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@"
Middlewares/SystemView/%.o: ../Middlewares/SystemView/%.S Middlewares/SystemView/subdir.mk
	arm-none-eabi-gcc -mcpu=cortex-m33 -g3 -DDEBUG -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../AZURE_RTOS/App -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Middlewares/ST/threadx/common/inc -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -I../Drivers/CMSIS/Include -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/MQTT/MQTTClient" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/MQTT/MQTTPacket" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/Mx_WIFI/core" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Middlewares/Mx_WIFI/io_pattern" -I"/home/hugofslopes/seame/Team04_DrivaPi/firmware/Core/Inc/Mx_WIFI" -x assembler-with-cpp -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@" "$<"

clean: clean-Middlewares-2f-SystemView

clean-Middlewares-2f-SystemView:
	-$(RM) ./Middlewares/SystemView/SEGGER_RTT.cyclo ./Middlewares/SystemView/SEGGER_RTT.d ./Middlewares/SystemView/SEGGER_RTT.o ./Middlewares/SystemView/SEGGER_RTT.su ./Middlewares/SystemView/SEGGER_RTT_ASM_ARMv7M.d ./Middlewares/SystemView/SEGGER_RTT_ASM_ARMv7M.o ./Middlewares/SystemView/SEGGER_RTT_Syscalls_GCC.cyclo ./Middlewares/SystemView/SEGGER_RTT_Syscalls_GCC.d ./Middlewares/SystemView/SEGGER_RTT_Syscalls_GCC.o ./Middlewares/SystemView/SEGGER_RTT_Syscalls_GCC.su ./Middlewares/SystemView/SEGGER_RTT_Syscalls_IAR.cyclo ./Middlewares/SystemView/SEGGER_RTT_Syscalls_IAR.d ./Middlewares/SystemView/SEGGER_RTT_Syscalls_IAR.o ./Middlewares/SystemView/SEGGER_RTT_Syscalls_IAR.su ./Middlewares/SystemView/SEGGER_RTT_Syscalls_KEIL.cyclo ./Middlewares/SystemView/SEGGER_RTT_Syscalls_KEIL.d ./Middlewares/SystemView/SEGGER_RTT_Syscalls_KEIL.o ./Middlewares/SystemView/SEGGER_RTT_Syscalls_KEIL.su ./Middlewares/SystemView/SEGGER_RTT_Syscalls_SES.cyclo ./Middlewares/SystemView/SEGGER_RTT_Syscalls_SES.d ./Middlewares/SystemView/SEGGER_RTT_Syscalls_SES.o ./Middlewares/SystemView/SEGGER_RTT_Syscalls_SES.su ./Middlewares/SystemView/SEGGER_RTT_printf.cyclo ./Middlewares/SystemView/SEGGER_RTT_printf.d ./Middlewares/SystemView/SEGGER_RTT_printf.o ./Middlewares/SystemView/SEGGER_RTT_printf.su ./Middlewares/SystemView/SEGGER_SYSVIEW.cyclo ./Middlewares/SystemView/SEGGER_SYSVIEW.d ./Middlewares/SystemView/SEGGER_SYSVIEW.o ./Middlewares/SystemView/SEGGER_SYSVIEW.su ./Middlewares/SystemView/SEGGER_SYSVIEW_Config_ThreadX.cyclo ./Middlewares/SystemView/SEGGER_SYSVIEW_Config_ThreadX.d ./Middlewares/SystemView/SEGGER_SYSVIEW_Config_ThreadX.o ./Middlewares/SystemView/SEGGER_SYSVIEW_Config_ThreadX.su ./Middlewares/SystemView/SEGGER_SYSVIEW_ThreadX.cyclo ./Middlewares/SystemView/SEGGER_SYSVIEW_ThreadX.d ./Middlewares/SystemView/SEGGER_SYSVIEW_ThreadX.o ./Middlewares/SystemView/SEGGER_SYSVIEW_ThreadX.su

.PHONY: clean-Middlewares-2f-SystemView

