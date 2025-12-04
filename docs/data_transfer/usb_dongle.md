# Spike: USB PS4 Dongle on B-U585I-IOT02A (STM32U5)

## Goal
Verify whether the B-U585I-IOT02A (STM32U585) can act as a USB Host to enumerate a PS4 BT dongle and parse HID reports.

## Findings (theory & expected risks)
- USB FS Host (UM2839 — B‑U585I‑IOT02A User Manual §7.5.1, §7.5.2)
- The STM32U5 (U585) supports USB FS Host, and STM32CubeU5 includes USB Host drivers and USBX HID middleware — so software capability exists.
- From the manual we read: "It is possible to support the Host mode by mounting the 16 MHz HSE clock X1 and setting the SB4 and SB5 solder bridges OFF. In this configuration, be aware that the U27 VL53L5CXV0GC/1 Time-of-Flight sensor does not work anymore." This means that some physical modifications are required to enable Host mode.
- Community reports (from the ST community) indicate the B‑U585I‑IOT02A may trigger VBUS over‑current protection (TCPP03‑M20) when some USB devices draw current. This can cut VBUS and prevent enumeration. The STM32 manual states: "To protect B‑U585I‑IOT02A from USB overvoltage, a PPS‑compliant USB Type‑C® port protection is used, the TCPP03‑M20 IC‑compliant with IEC6100‑4‑2 level 4."
- A missing or reduced VBUS capacitance or PD protection behavior can cause host power to be cut even for modest‑power dongles.

## Pros / Cons (USB vs BLE)
- USB (Host + HID)
  - Pros: Standard HID descriptors; direct parsing of HID reports; existing USBX HID middleware.
  - Cons: VBUS / power‑protection risk on B‑U585I‑IOT02A; potential hardware modifications needed; limited by the physical cable/port.

## Conclusion (team decision)
- Technically feasible but risky on B‑U585I‑IOT02A due to VBUS / over‑current behavior. Treat the USB‑dongle approach as a prototype/spike only.
- Final decision: we did not choose the USB‑dongle option as the primary integration path. Rationale: the project will receive commands over CAN from the Raspberry Pi AI in the future. Designing firmware now to consume the same command format (instead of heavily investing in a USB‑host dongle path) saves development time and better prepares the system for the planned CAN‑based command flow.