################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_UPPER_SRCS += \
../Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/tx_initialize_low_level.S 

OBJS += \
./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/tx_initialize_low_level.o 

S_UPPER_DEPS += \
./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/tx_initialize_low_level.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/%.o: ../Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/%.S Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/subdir.mk
	arm-none-eabi-gcc -mcpu=cortex-m33 -g3 -DDEBUG -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../AZURE_RTOS/App -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Middlewares/ST/threadx/common/inc -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -I../Drivers/CMSIS/Include -x assembler-with-cpp -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@" "$<"

clean: clean-Middlewares-2f-ST-2f-threadx-2f-ports_module-2f-cortex_m33-2f-ac6-2f-example_build

clean-Middlewares-2f-ST-2f-threadx-2f-ports_module-2f-cortex_m33-2f-ac6-2f-example_build:
	-$(RM) ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/tx_initialize_low_level.d ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/tx_initialize_low_level.o

.PHONY: clean-Middlewares-2f-ST-2f-threadx-2f-ports_module-2f-cortex_m33-2f-ac6-2f-example_build

