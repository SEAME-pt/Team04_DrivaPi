# Spike: USB PS4 Dongle on B-U585I-IOT02A (STM32U5)

## Goal
Verify whether the B-U585I-IOT02A (STM32U585) can act as a USB Host to enumerate a PS4 BT dongle and parse HID reports, and compare USB vs BLE as alternatives.

## Dependencies / Blockers
- STM32U5 USB Host capability (hardware & drivers)
- USBX Host HID middleware available in STM32CubeU5
- Physical access to the PS4 dongle
- VBUS/power behavior of the B-U585I-IOT02A board (TCPP03-M20 protection)

## Tasks
1. Enable USB Host on STM32U585 board.
2. Build and run USBX HID Host example.
3. Plug in PS4 dongle; capture enumeration and VBUS logs.
4. Decode HID reports (buttons, sticks, triggers).
5. Investigate BLE alternative (STM32WBA or external BLE module).
6. Document pros/cons of USB vs BLE.

## Acceptance Criteria (AC)
- USB Host recognizes the PS4 dongle (enumeration success).
- HID reports are parsed successfully and mapped to inputs.
- Remote commands from dongle appear in firmware logs/state.
- Spike document explains final feasibility and recommended path.

## Definition of Done (DoD)
- Spike documentation saved to /docs/spikes/remote_usb_ble.md
- Enumeration logs and HID report descriptors included
- Test steps and validation notes present
- Findings reviewed by team

## How to validate / Test steps
1. Flash USBX HID Host example to the board.
2. Connect a low-power HID device (keyboard/mouse) first; verify enumeration.
3. Connect PS4 dongle; capture USB enumeration and VBUS (voltage/current) behavior.
4. Log HID descriptor and sample reports; implement a parser and validate mapping.
5. If VBUS OCP occurs, document behavior and measured values.
6. Repeat with BLE alternative if USB fails.

## Findings (theory & expected risks)
- The STM32U5 (U585) supports USB FS Host and STM32CubeU5 includes USB Host drivers and USBX HID middleware — so software capability exists.
- Community reports indicate the B-U585I-IOT02A may trigger VBUS over-current protection (TCPP03-M20) when some USB devices draw current; this can cut VBUS and prevent enumeration.
- A missing/reduced VBUS capacitance or PD-protection behavior can cause host power to be cut even for modest-power dongles.
- If VBUS is cut, the board will not enumerate the dongle without hardware change (caps or PD circuit modification) or an external powered USB hub.

## Pros / Cons (USB vs BLE)
- USB (Host + HID)
  - Pros: Standard HID descriptors; direct parsing of HID reports; existing USBX HID middleware.
  - Cons: VBUS/power-protection risk on B-U585I-IOT02A; potential hardware mods needed; limited by physical cable/port.
- BLE (STM32WBA / external BLE)
  - Pros: Lower risk re: VBUS; wireless; flexible pairing; common for controllers.
  - Cons: Requires BLE stack/firmware; may need separate module or different MCU; different parsing/flow.

## Recommendation
- Perform a short spike: test with a low-power HID device, then test the PS4 dongle while monitoring VBUS. Use an external powered USB hub as a mitigation if direct dongle fails.
- Parallel-evaluate BLE (STM32WBA or external module) if USB proves unreliable.

## Conclusion (team decision)
- Technically feasible but risky on B-U585I-IOT02A due to VBUS/over‑current behavior. Treat USB dongle approach as a prototype/spike only.
- Final decision: do not choose the USB-dongle option as the primary integration path. Rationale: the project will receive commands over CAN from the Raspberry Pi AI in the future; designing firmware now to consume the same command format (instead of heavily investing in a USB-host dongle path) saves development time and better prepares the system for the planned CAN-based command flow.