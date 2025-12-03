# Spike: USB PS4 Dongle on B-U585I-IOT02A (STM32U5)

## Goal
Verify whether the B-U585I-IOT02A (STM32U585) can act as a USB Host to enumerate a PS4 BT dongle and parse HID reports, and compare USB vs BLE as alternatives.

## Findings (theory & expected risks)
- The STM32U5 (U585) supports USB FS Host and STM32CubeU5 includes USB Host drivers and USBX HID middleware — so software capability exists.
- Community reports indicate the B-U585I-IOT02A may trigger VBUS over-current protection (TCPP03-M20) when some USB devices draw current, this can cut VBUS and prevent enumeration.
- A missing/reduced VBUS capacitance or PD-protection behavior can cause host power to be cut even for modest-power dongles.
- If VBUS is cut, the board will not enumerate the dongle without hardware change (caps or PD circuit modification) or an external powered USB hub.

## Pros / Cons (USB vs BLE)
- USB (Host + HID)
  - Pros: Standard HID descriptors; direct parsing of HID reports; existing USBX HID middleware.
  - Cons: VBUS/power-protection risk on B-U585I-IOT02A; potential hardware mods needed; limited by physical cable/port.
- BLE (STM32WBA / external BLE)
  - Pros: Lower risk re: VBUS; wireless; flexible pairing; common for controllers.
  - Cons: Requires BLE stack/firmware; may need separate module or different MCU; different parsing/flow.

## Conclusion (team decision)
- Technically feasible but risky on B-U585I-IOT02A due to VBUS/over‑current behavior. Treat USB dongle approach as a prototype/spike only.
- Final decision: do not choose the USB-dongle option as the primary integration path. Rationale: the project will receive commands over CAN from the Raspberry Pi AI in the future. Designing firmware now to consume the same command format (instead of heavily investing in a USB-host dongle path) saves development time and better prepares the system for the planned CAN-based command flow.