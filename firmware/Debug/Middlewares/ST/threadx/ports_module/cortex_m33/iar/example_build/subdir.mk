################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/tx_initialize_low_level.s \
../Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/txm_module_preamble.s 

C_SRCS += \
../Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/sample_threadx_module.c \
../Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/sample_threadx_module_manager.c 

OBJS += \
./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/sample_threadx_module.o \
./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/sample_threadx_module_manager.o \
./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/tx_initialize_low_level.o \
./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/txm_module_preamble.o 

S_DEPS += \
./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/tx_initialize_low_level.d \
./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/txm_module_preamble.d 

C_DEPS += \
./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/sample_threadx_module.d \
./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/sample_threadx_module_manager.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/%.o Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/%.su Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/%.cyclo: ../Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/%.c Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m33 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32U585xx -DTX_INCLUDE_USER_DEFINE_FILE -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../Middlewares/ST/threadx/common_modules/inc/ -I../Middlewares/ST/threadx/ports_module/cortex_m33/iar/inc -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Drivers/CMSIS/Include -I../AZURE_RTOS/App -I../Middlewares/ST/threadx/common/inc -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@"
Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/%.o: ../Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/%.s Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/subdir.mk
	arm-none-eabi-gcc -mcpu=cortex-m33 -g3 -DDEBUG -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../AZURE_RTOS/App -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Middlewares/ST/threadx/common/inc -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -I../Drivers/CMSIS/Include -x assembler-with-cpp -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@" "$<"

clean: clean-Middlewares-2f-ST-2f-threadx-2f-ports_module-2f-cortex_m33-2f-iar-2f-example_build

clean-Middlewares-2f-ST-2f-threadx-2f-ports_module-2f-cortex_m33-2f-iar-2f-example_build:
	-$(RM) ./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/sample_threadx_module.cyclo ./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/sample_threadx_module.d ./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/sample_threadx_module.o ./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/sample_threadx_module.su ./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/sample_threadx_module_manager.cyclo ./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/sample_threadx_module_manager.d ./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/sample_threadx_module_manager.o ./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/sample_threadx_module_manager.su ./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/tx_initialize_low_level.d ./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/tx_initialize_low_level.o ./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/txm_module_preamble.d ./Middlewares/ST/threadx/ports_module/cortex_m33/iar/example_build/txm_module_preamble.o

.PHONY: clean-Middlewares-2f-ST-2f-threadx-2f-ports_module-2f-cortex_m33-2f-iar-2f-example_build

