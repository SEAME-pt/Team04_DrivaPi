################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_module_thread_shell_entry.c \
../Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_thread_secure_stack_allocate.c \
../Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_thread_secure_stack_free.c 

S_UPPER_SRCS += \
../Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_module_initialize.S 

OBJS += \
./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_module_initialize.o \
./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_module_thread_shell_entry.o \
./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_thread_secure_stack_allocate.o \
./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_thread_secure_stack_free.o 

S_UPPER_DEPS += \
./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_module_initialize.d 

C_DEPS += \
./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_module_thread_shell_entry.d \
./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_thread_secure_stack_allocate.d \
./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_thread_secure_stack_free.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/%.o: ../Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/%.S Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/subdir.mk
	arm-none-eabi-gcc -mcpu=cortex-m33 -g3 -DDEBUG -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../AZURE_RTOS/App -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Middlewares/ST/threadx/common/inc -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -I../Drivers/CMSIS/Include -x assembler-with-cpp -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@" "$<"
Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/%.o Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/%.su Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/%.cyclo: ../Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/%.c Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m33 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32U585xx -DTX_INCLUDE_USER_DEFINE_FILE -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../Middlewares/ST/threadx/common_modules/inc/ -I../Middlewares/ST/threadx/ports_module/cortex_m33/iar/inc -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Drivers/CMSIS/Include -I../AZURE_RTOS/App -I../Middlewares/ST/threadx/common/inc -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Middlewares-2f-ST-2f-threadx-2f-ports_module-2f-cortex_m33-2f-ac6-2f-module_lib-2f-src

clean-Middlewares-2f-ST-2f-threadx-2f-ports_module-2f-cortex_m33-2f-ac6-2f-module_lib-2f-src:
	-$(RM) ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_module_initialize.d ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_module_initialize.o ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_module_thread_shell_entry.cyclo ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_module_thread_shell_entry.d ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_module_thread_shell_entry.o ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_module_thread_shell_entry.su ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_thread_secure_stack_allocate.cyclo ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_thread_secure_stack_allocate.d ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_thread_secure_stack_allocate.o ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_thread_secure_stack_allocate.su ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_thread_secure_stack_free.cyclo ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_thread_secure_stack_free.d ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_thread_secure_stack_free.o ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/module_lib/src/txm_thread_secure_stack_free.su

.PHONY: clean-Middlewares-2f-ST-2f-threadx-2f-ports_module-2f-cortex_m33-2f-ac6-2f-module_lib-2f-src

