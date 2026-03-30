################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Middlewares/ST/threadx/common_modules/module_manager/utilities/module_binary_to_c_array.c \
../Middlewares/ST/threadx/common_modules/module_manager/utilities/module_to_binary.c \
../Middlewares/ST/threadx/common_modules/module_manager/utilities/module_to_c_array.c 

OBJS += \
./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_binary_to_c_array.o \
./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_to_binary.o \
./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_to_c_array.o 

C_DEPS += \
./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_binary_to_c_array.d \
./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_to_binary.d \
./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_to_c_array.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/ST/threadx/common_modules/module_manager/utilities/%.o Middlewares/ST/threadx/common_modules/module_manager/utilities/%.su Middlewares/ST/threadx/common_modules/module_manager/utilities/%.cyclo: ../Middlewares/ST/threadx/common_modules/module_manager/utilities/%.c Middlewares/ST/threadx/common_modules/module_manager/utilities/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m33 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32U585xx -DTX_INCLUDE_USER_DEFINE_FILE -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../Middlewares/ST/threadx/common_modules/inc/ -I../Middlewares/ST/threadx/common_modules/module_manager/inc -I../Middlewares/ST/threadx/ports_module/cortex_m33/gnu/inc -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Drivers/CMSIS/Include -I../AZURE_RTOS/App -I../Middlewares/ST/threadx/common/inc -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Middlewares-2f-ST-2f-threadx-2f-common_modules-2f-module_manager-2f-utilities

clean-Middlewares-2f-ST-2f-threadx-2f-common_modules-2f-module_manager-2f-utilities:
	-$(RM) ./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_binary_to_c_array.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_binary_to_c_array.d ./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_binary_to_c_array.o ./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_binary_to_c_array.su ./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_to_binary.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_to_binary.d ./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_to_binary.o ./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_to_binary.su ./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_to_c_array.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_to_c_array.d ./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_to_c_array.o ./Middlewares/ST/threadx/common_modules/module_manager/utilities/module_to_c_array.su

.PHONY: clean-Middlewares-2f-ST-2f-threadx-2f-common_modules-2f-module_manager-2f-utilities

