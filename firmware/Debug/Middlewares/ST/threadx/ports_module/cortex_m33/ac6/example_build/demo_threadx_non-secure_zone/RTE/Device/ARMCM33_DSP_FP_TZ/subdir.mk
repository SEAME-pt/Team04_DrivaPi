################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/startup_ARMCM33.c \
../Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/system_ARMCM33.c 

OBJS += \
./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/startup_ARMCM33.o \
./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/system_ARMCM33.o 

C_DEPS += \
./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/startup_ARMCM33.d \
./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/system_ARMCM33.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/%.o Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/%.su Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/%.cyclo: ../Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/%.c Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m33 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32U585xx -DTX_INCLUDE_USER_DEFINE_FILE -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../Middlewares/ST/threadx/common_modules/inc/ -I../Middlewares/ST/threadx/ports_module/cortex_m33/iar/inc -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Drivers/CMSIS/Include -I../AZURE_RTOS/App -I../Middlewares/ST/threadx/common/inc -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Middlewares-2f-ST-2f-threadx-2f-ports_module-2f-cortex_m33-2f-ac6-2f-example_build-2f-demo_threadx_non-2d-secure_zone-2f-RTE-2f-Device-2f-ARMCM33_DSP_FP_TZ

clean-Middlewares-2f-ST-2f-threadx-2f-ports_module-2f-cortex_m33-2f-ac6-2f-example_build-2f-demo_threadx_non-2d-secure_zone-2f-RTE-2f-Device-2f-ARMCM33_DSP_FP_TZ:
	-$(RM) ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/startup_ARMCM33.cyclo ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/startup_ARMCM33.d ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/startup_ARMCM33.o ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/startup_ARMCM33.su ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/system_ARMCM33.cyclo ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/system_ARMCM33.d ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/system_ARMCM33.o ./Middlewares/ST/threadx/ports_module/cortex_m33/ac6/example_build/demo_threadx_non-secure_zone/RTE/Device/ARMCM33_DSP_FP_TZ/system_ARMCM33.su

.PHONY: clean-Middlewares-2f-ST-2f-threadx-2f-ports_module-2f-cortex_m33-2f-ac6-2f-example_build-2f-demo_threadx_non-2d-secure_zone-2f-RTE-2f-Device-2f-ARMCM33_DSP_FP_TZ

