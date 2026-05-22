################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/app_threadx.c \
../Core/Src/can_rx.c \
../Core/Src/can_tx.c \
../Core/Src/dc_motor.c \
../Core/Src/init_devices.c \
../Core/Src/main.c \
../Core/Src/motor_control.c \
../Core/Src/motor_utils.c \
../Core/Src/sensors.c \
../Core/Src/servo_motor.c \
../Core/Src/speed_sensor.c \
../Core/Src/stm32u5xx_hal_msp.c \
../Core/Src/stm32u5xx_it.c \
../Core/Src/supervisor.c \
../Core/Src/syscalls.c \
../Core/Src/sysmem.c \
../Core/Src/system_stm32u5xx.c \
../Core/Src/systemview_threadx_hooks.c \
../Core/Src/thread_init.c \
../Core/Src/ultrasonic.c 

S_UPPER_SRCS += \
../Core/Src/tx_initialize_low_level.S 

OBJS += \
./Core/Src/app_threadx.o \
./Core/Src/can_rx.o \
./Core/Src/can_tx.o \
./Core/Src/dc_motor.o \
./Core/Src/init_devices.o \
./Core/Src/main.o \
./Core/Src/motor_control.o \
./Core/Src/motor_utils.o \
./Core/Src/sensors.o \
./Core/Src/servo_motor.o \
./Core/Src/speed_sensor.o \
./Core/Src/stm32u5xx_hal_msp.o \
./Core/Src/stm32u5xx_it.o \
./Core/Src/supervisor.o \
./Core/Src/syscalls.o \
./Core/Src/sysmem.o \
./Core/Src/system_stm32u5xx.o \
./Core/Src/systemview_threadx_hooks.o \
./Core/Src/thread_init.o \
./Core/Src/tx_initialize_low_level.o \
./Core/Src/ultrasonic.o 

S_UPPER_DEPS += \
./Core/Src/tx_initialize_low_level.d 

C_DEPS += \
./Core/Src/app_threadx.d \
./Core/Src/can_rx.d \
./Core/Src/can_tx.d \
./Core/Src/dc_motor.d \
./Core/Src/init_devices.d \
./Core/Src/main.d \
./Core/Src/motor_control.d \
./Core/Src/motor_utils.d \
./Core/Src/sensors.d \
./Core/Src/servo_motor.d \
./Core/Src/speed_sensor.d \
./Core/Src/stm32u5xx_hal_msp.d \
./Core/Src/stm32u5xx_it.d \
./Core/Src/supervisor.d \
./Core/Src/syscalls.d \
./Core/Src/sysmem.d \
./Core/Src/system_stm32u5xx.d \
./Core/Src/systemview_threadx_hooks.d \
./Core/Src/thread_init.d \
./Core/Src/ultrasonic.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/%.o Core/Src/%.su Core/Src/%: ../Core/Src/%.c Core/Src/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m33 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32U585xx -DTX_INCLUDE_USER_DEFINE_FILE -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Drivers/CMSIS/Include -I../AZURE_RTOS/App -I../Middlewares/ST/threadx/common/inc -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@"
Core/Src/%.o: ../Core/Src/%.S Core/Src/subdir.mk
	arm-none-eabi-gcc -mcpu=cortex-m33 -g3 -DDEBUG -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../AZURE_RTOS/App -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Middlewares/ST/threadx/common/inc -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -I../Drivers/CMSIS/Include -x assembler-with-cpp -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@" "$<"

clean: clean-Core-2f-Src

clean-Core-2f-Src:
	-$(RM) ./Core/Src/app_threadx ./Core/Src/app_threadx.d ./Core/Src/app_threadx.o ./Core/Src/app_threadx.su ./Core/Src/can_rx ./Core/Src/can_rx.d ./Core/Src/can_rx.o ./Core/Src/can_rx.su ./Core/Src/can_tx ./Core/Src/can_tx.d ./Core/Src/can_tx.o ./Core/Src/can_tx.su ./Core/Src/dc_motor ./Core/Src/dc_motor.d ./Core/Src/dc_motor.o ./Core/Src/dc_motor.su ./Core/Src/init_devices ./Core/Src/init_devices.d ./Core/Src/init_devices.o ./Core/Src/init_devices.su ./Core/Src/main ./Core/Src/main.d ./Core/Src/main.o ./Core/Src/main.su ./Core/Src/motor_control ./Core/Src/motor_control.d ./Core/Src/motor_control.o ./Core/Src/motor_control.su ./Core/Src/motor_utils ./Core/Src/motor_utils.d ./Core/Src/motor_utils.o ./Core/Src/motor_utils.su ./Core/Src/sensors ./Core/Src/sensors.d ./Core/Src/sensors.o ./Core/Src/sensors.su ./Core/Src/servo_motor ./Core/Src/servo_motor.d ./Core/Src/servo_motor.o ./Core/Src/servo_motor.su ./Core/Src/speed_sensor ./Core/Src/speed_sensor.d ./Core/Src/speed_sensor.o ./Core/Src/speed_sensor.su ./Core/Src/stm32u5xx_hal_msp ./Core/Src/stm32u5xx_hal_msp.d ./Core/Src/stm32u5xx_hal_msp.o ./Core/Src/stm32u5xx_hal_msp.su ./Core/Src/stm32u5xx_it ./Core/Src/stm32u5xx_it.d ./Core/Src/stm32u5xx_it.o ./Core/Src/stm32u5xx_it.su ./Core/Src/supervisor ./Core/Src/supervisor.d ./Core/Src/supervisor.o ./Core/Src/supervisor.su ./Core/Src/syscalls ./Core/Src/syscalls.d ./Core/Src/syscalls.o ./Core/Src/syscalls.su ./Core/Src/sysmem ./Core/Src/sysmem.d ./Core/Src/sysmem.o ./Core/Src/sysmem.su ./Core/Src/system_stm32u5xx ./Core/Src/system_stm32u5xx.d ./Core/Src/system_stm32u5xx.o ./Core/Src/system_stm32u5xx.su ./Core/Src/systemview_threadx_hooks ./Core/Src/systemview_threadx_hooks.d ./Core/Src/systemview_threadx_hooks.o ./Core/Src/systemview_threadx_hooks.su ./Core/Src/thread_init ./Core/Src/thread_init.d ./Core/Src/thread_init.o ./Core/Src/thread_init.su ./Core/Src/tx_initialize_low_level.d ./Core/Src/tx_initialize_low_level.o ./Core/Src/ultrasonic ./Core/Src/ultrasonic.d ./Core/Src/ultrasonic.o ./Core/Src/ultrasonic.su

.PHONY: clean-Core-2f-Src

