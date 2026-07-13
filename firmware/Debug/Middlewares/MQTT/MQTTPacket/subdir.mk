################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Middlewares/MQTT/MQTTPacket/MQTTConnectClient.c \
../Middlewares/MQTT/MQTTPacket/MQTTConnectServer.c \
../Middlewares/MQTT/MQTTPacket/MQTTDeserializePublish.c \
../Middlewares/MQTT/MQTTPacket/MQTTFormat.c \
../Middlewares/MQTT/MQTTPacket/MQTTPacket.c \
../Middlewares/MQTT/MQTTPacket/MQTTSerializePublish.c \
../Middlewares/MQTT/MQTTPacket/MQTTSubscribeClient.c \
../Middlewares/MQTT/MQTTPacket/MQTTSubscribeServer.c \
../Middlewares/MQTT/MQTTPacket/MQTTUnsubscribeClient.c \
../Middlewares/MQTT/MQTTPacket/MQTTUnsubscribeServer.c 

OBJS += \
./Middlewares/MQTT/MQTTPacket/MQTTConnectClient.o \
./Middlewares/MQTT/MQTTPacket/MQTTConnectServer.o \
./Middlewares/MQTT/MQTTPacket/MQTTDeserializePublish.o \
./Middlewares/MQTT/MQTTPacket/MQTTFormat.o \
./Middlewares/MQTT/MQTTPacket/MQTTPacket.o \
./Middlewares/MQTT/MQTTPacket/MQTTSerializePublish.o \
./Middlewares/MQTT/MQTTPacket/MQTTSubscribeClient.o \
./Middlewares/MQTT/MQTTPacket/MQTTSubscribeServer.o \
./Middlewares/MQTT/MQTTPacket/MQTTUnsubscribeClient.o \
./Middlewares/MQTT/MQTTPacket/MQTTUnsubscribeServer.o 

C_DEPS += \
./Middlewares/MQTT/MQTTPacket/MQTTConnectClient.d \
./Middlewares/MQTT/MQTTPacket/MQTTConnectServer.d \
./Middlewares/MQTT/MQTTPacket/MQTTDeserializePublish.d \
./Middlewares/MQTT/MQTTPacket/MQTTFormat.d \
./Middlewares/MQTT/MQTTPacket/MQTTPacket.d \
./Middlewares/MQTT/MQTTPacket/MQTTSerializePublish.d \
./Middlewares/MQTT/MQTTPacket/MQTTSubscribeClient.d \
./Middlewares/MQTT/MQTTPacket/MQTTSubscribeServer.d \
./Middlewares/MQTT/MQTTPacket/MQTTUnsubscribeClient.d \
./Middlewares/MQTT/MQTTPacket/MQTTUnsubscribeServer.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/MQTT/MQTTPacket/%.o Middlewares/MQTT/MQTTPacket/%.su Middlewares/MQTT/MQTTPacket/%.cyclo: ../Middlewares/MQTT/MQTTPacket/%.c Middlewares/MQTT/MQTTPacket/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m33 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32U585xx -DTX_INCLUDE_USER_DEFINE_FILE -DTX_SINGLE_MODE_NON_SECURE=1 -c -I../Core/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc -I../Drivers/STM32U5xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32U5xx/Include -I../Drivers/CMSIS/Include -I../AZURE_RTOS/App -I../Middlewares/ST/threadx/common/inc -I../Middlewares/ST/threadx/ports/cortex_m33/gnu/inc -I../Middlewares/MQTT/MQTTClient -I../Middlewares/MQTT/MQTTPacket -I../Middlewares/MX_WIFI/core -I../Middlewares/MX_WIFI/io_pattern -I../Middlewares/MX_WIFI -I../Core/Inc/MX_WIFI -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Middlewares-2f-MQTT-2f-MQTTPacket

clean-Middlewares-2f-MQTT-2f-MQTTPacket:
	-$(RM) ./Middlewares/MQTT/MQTTPacket/MQTTConnectClient.cyclo ./Middlewares/MQTT/MQTTPacket/MQTTConnectClient.d ./Middlewares/MQTT/MQTTPacket/MQTTConnectClient.o ./Middlewares/MQTT/MQTTPacket/MQTTConnectClient.su ./Middlewares/MQTT/MQTTPacket/MQTTConnectServer.cyclo ./Middlewares/MQTT/MQTTPacket/MQTTConnectServer.d ./Middlewares/MQTT/MQTTPacket/MQTTConnectServer.o ./Middlewares/MQTT/MQTTPacket/MQTTConnectServer.su ./Middlewares/MQTT/MQTTPacket/MQTTDeserializePublish.cyclo ./Middlewares/MQTT/MQTTPacket/MQTTDeserializePublish.d ./Middlewares/MQTT/MQTTPacket/MQTTDeserializePublish.o ./Middlewares/MQTT/MQTTPacket/MQTTDeserializePublish.su ./Middlewares/MQTT/MQTTPacket/MQTTFormat.cyclo ./Middlewares/MQTT/MQTTPacket/MQTTFormat.d ./Middlewares/MQTT/MQTTPacket/MQTTFormat.o ./Middlewares/MQTT/MQTTPacket/MQTTFormat.su ./Middlewares/MQTT/MQTTPacket/MQTTPacket.cyclo ./Middlewares/MQTT/MQTTPacket/MQTTPacket.d ./Middlewares/MQTT/MQTTPacket/MQTTPacket.o ./Middlewares/MQTT/MQTTPacket/MQTTPacket.su ./Middlewares/MQTT/MQTTPacket/MQTTSerializePublish.cyclo ./Middlewares/MQTT/MQTTPacket/MQTTSerializePublish.d ./Middlewares/MQTT/MQTTPacket/MQTTSerializePublish.o ./Middlewares/MQTT/MQTTPacket/MQTTSerializePublish.su ./Middlewares/MQTT/MQTTPacket/MQTTSubscribeClient.cyclo ./Middlewares/MQTT/MQTTPacket/MQTTSubscribeClient.d ./Middlewares/MQTT/MQTTPacket/MQTTSubscribeClient.o ./Middlewares/MQTT/MQTTPacket/MQTTSubscribeClient.su ./Middlewares/MQTT/MQTTPacket/MQTTSubscribeServer.cyclo ./Middlewares/MQTT/MQTTPacket/MQTTSubscribeServer.d ./Middlewares/MQTT/MQTTPacket/MQTTSubscribeServer.o ./Middlewares/MQTT/MQTTPacket/MQTTSubscribeServer.su ./Middlewares/MQTT/MQTTPacket/MQTTUnsubscribeClient.cyclo ./Middlewares/MQTT/MQTTPacket/MQTTUnsubscribeClient.d ./Middlewares/MQTT/MQTTPacket/MQTTUnsubscribeClient.o ./Middlewares/MQTT/MQTTPacket/MQTTUnsubscribeClient.su ./Middlewares/MQTT/MQTTPacket/MQTTUnsubscribeServer.cyclo ./Middlewares/MQTT/MQTTPacket/MQTTUnsubscribeServer.d ./Middlewares/MQTT/MQTTPacket/MQTTUnsubscribeServer.o ./Middlewares/MQTT/MQTTPacket/MQTTUnsubscribeServer.su

.PHONY: clean-Middlewares-2f-MQTT-2f-MQTTPacket

