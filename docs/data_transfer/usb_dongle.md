# Spike: USB PS4 Dongle on B-U585I-IOT02A (STM32U5)

## Goal
Evaluate whether the STM32U585 (B-U585I-IOT02A) can act as a USB Host to enumerate a PS4 USB/Bluetooth dongle and process HID reports.

## Findings
### 1. USB Host Capability

- The STM32U585 supports USB FS Host mode.
- USBX HID Host middleware is available in STM32CubeU5.
- Host mode requires hardware modifications:
  - Mount the external 16 MHz HSE
  - Set solder bridges SB4/SB5 OFF
  - This disables the VL53L5 ToF sensor

### 2. VBUS / Power-Protection Limitations

- The TCPP03-M20 USB-C protection IC may shut down VBUS due to false over-current or over-voltage events.
- ST Community reports show issues even with low-power devices (<150 mA peak).
- This can prevent USB enumeration and makes Host mode unreliable without further hardware changes.

### 3. HID Parsing

USB enumeration and HID access are technically possible.
PS4 dongles use vendor-specific HID reports, so custom parsing and polling logic is required.
Effort is non-trivial.

## Conclusion

USB-dongle integration is feasible but hardware-risky on the B-U585I-IOT02A because of VBUS protection behavior and mandatory board modifications.

## Decision

We will not use the USB-dongle path as the primary integration method.

The final architecture will receive commands over CAN from the Raspberry Pi AI module. Implementing the CAN-based command format now avoids unnecessary firmware refactoring and aligns the system with the long-term design. The USB dongle will remain connected to the Raspberry Pi, as before.