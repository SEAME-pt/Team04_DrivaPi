################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_absolute_load.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_application_request.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_callback_request.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_event_flags_notify_trampoline.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_file_load.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_in_place_load.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_initialize.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_internal_load.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_kernel_dispatch.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_maximum_module_priority_set.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_memory_load.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_allocate.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_deallocate.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pointer_get.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pointer_get_extended.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pool_create.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_properties_get.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_queue_notify_trampoline.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_semaphore_notify_trampoline.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_start.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_stop.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_create.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_notify_trampoline.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_reset.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_timer_notify_trampoline.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_unload.c \
../Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_util.c 

OBJS += \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_absolute_load.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_application_request.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_callback_request.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_event_flags_notify_trampoline.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_file_load.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_in_place_load.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_initialize.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_internal_load.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_kernel_dispatch.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_maximum_module_priority_set.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_memory_load.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_allocate.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_deallocate.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pointer_get.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pointer_get_extended.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pool_create.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_properties_get.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_queue_notify_trampoline.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_semaphore_notify_trampoline.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_start.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_stop.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_create.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_notify_trampoline.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_reset.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_timer_notify_trampoline.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_unload.o \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_util.o 

C_DEPS += \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_absolute_load.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_application_request.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_callback_request.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_event_flags_notify_trampoline.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_file_load.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_in_place_load.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_initialize.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_internal_load.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_kernel_dispatch.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_maximum_module_priority_set.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_memory_load.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_allocate.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_deallocate.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pointer_get.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pointer_get_extended.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pool_create.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_properties_get.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_queue_notify_trampoline.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_semaphore_notify_trampoline.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_start.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_stop.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_create.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_notify_trampoline.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_reset.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_timer_notify_trampoline.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_unload.d \
./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_util.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/ST/threadx/common_modules/module_manager/src/%.o Middlewares/ST/threadx/common_modules/module_manager/src/%.su Middlewares/ST/threadx/common_modules/module_manager/src/%.cyclo: ../Middlewares/ST/threadx/common_modules/module_manager/src/%.c Middlewares/ST/threadx/common_modules/module_manager/src/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m33 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32U585xx -DTX_INCLUDE_USER_DEFINE_FILE -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../Middlewares/ST/threadx/common_modules/inc/ -I../Middlewares/ST/threadx/common_modules/module_manager/inc -I../Middlewares/ST/threadx/ports_module/cortex_m33/gnu/inc -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Drivers/CMSIS/Include -I../AZURE_RTOS/App -I../Middlewares/ST/threadx/common/inc -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Middlewares-2f-ST-2f-threadx-2f-common_modules-2f-module_manager-2f-src

clean-Middlewares-2f-ST-2f-threadx-2f-common_modules-2f-module_manager-2f-src:
	-$(RM) ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_absolute_load.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_absolute_load.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_absolute_load.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_absolute_load.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_application_request.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_application_request.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_application_request.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_application_request.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_callback_request.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_callback_request.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_callback_request.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_callback_request.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_event_flags_notify_trampoline.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_event_flags_notify_trampoline.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_event_flags_notify_trampoline.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_event_flags_notify_trampoline.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_file_load.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_file_load.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_file_load.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_file_load.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_in_place_load.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_in_place_load.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_in_place_load.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_in_place_load.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_initialize.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_initialize.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_initialize.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_initialize.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_internal_load.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_internal_load.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_internal_load.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_internal_load.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_kernel_dispatch.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_kernel_dispatch.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_kernel_dispatch.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_kernel_dispatch.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_maximum_module_priority_set.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_maximum_module_priority_set.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_maximum_module_priority_set.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_maximum_module_priority_set.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_memory_load.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_memory_load.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_memory_load.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_memory_load.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_allocate.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_allocate.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_allocate.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_allocate.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_deallocate.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_deallocate.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_deallocate.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_deallocate.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pointer_get.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pointer_get.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pointer_get.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pointer_get.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pointer_get_extended.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pointer_get_extended.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pointer_get_extended.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pointer_get_extended.su
	-$(RM) ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pool_create.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pool_create.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pool_create.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_object_pool_create.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_properties_get.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_properties_get.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_properties_get.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_properties_get.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_queue_notify_trampoline.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_queue_notify_trampoline.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_queue_notify_trampoline.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_queue_notify_trampoline.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_semaphore_notify_trampoline.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_semaphore_notify_trampoline.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_semaphore_notify_trampoline.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_semaphore_notify_trampoline.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_start.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_start.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_start.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_start.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_stop.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_stop.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_stop.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_stop.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_create.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_create.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_create.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_create.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_notify_trampoline.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_notify_trampoline.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_notify_trampoline.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_notify_trampoline.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_reset.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_reset.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_reset.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_thread_reset.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_timer_notify_trampoline.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_timer_notify_trampoline.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_timer_notify_trampoline.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_timer_notify_trampoline.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_unload.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_unload.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_unload.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_unload.su ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_util.cyclo ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_util.d ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_util.o ./Middlewares/ST/threadx/common_modules/module_manager/src/txm_module_manager_util.su

.PHONY: clean-Middlewares-2f-ST-2f-threadx-2f-common_modules-2f-module_manager-2f-src

