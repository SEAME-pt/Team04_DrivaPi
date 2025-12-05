################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Test/dc_motor_test.c 

OBJS += \
./Core/Test/dc_motor_test.o 

C_DEPS += \
./Core/Test/dc_motor_test.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Test/%.o Core/Test/%.su Core/Test/%.cyclo: ../Core/Test/%.c Core/Test/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m33 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32U585xx -DTX_INCLUDE_USER_DEFINE_FILE -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Drivers/CMSIS/Include -I../AZURE_RTOS/App -I../Middlewares/ST/threadx/common/inc -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Core-2f-Test

clean-Core-2f-Test:
	-$(RM) ./Core/Test/dc_motor_test.cyclo ./Core/Test/dc_motor_test.d ./Core/Test/dc_motor_test.o ./Core/Test/dc_motor_test.su

.PHONY: clean-Core-2f-Test

