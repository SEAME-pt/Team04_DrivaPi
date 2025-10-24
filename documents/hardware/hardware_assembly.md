
## Hardware Documentation - DrivaPi Project (Team04)
### 1. Overview
This document describes the hardware components and their interconnection in the DrivaPi project, an autonomous vehicle based on the PiRacer platform and Raspberry Pi 5. The architecture includes a main computer (Raspberry Pi), an expansion board for low-level control , sensors, actuators, a secondary microcontroller (STM32) , and communication interfaces such as CAN bus.

### 2. Bill of Materials (BOM)
The following diagram lists the main components identified in the SEA_ME WORKBOARD.pdf:

### 3. Component Description

Raspberry Pi 5: The brain of the system, responsible for high-level processing, computer vision, graphical user interface (GUI), and overall orchestration.


Expansion Board : The central board of the PiRacer platform providing regulated power, control for the DC motors and steering servo, and interfacing with the Raspberry Pi. Features an ON/OFF switch and 6 pins: 5V, 5V, 3V3, GND, SDA, SCL.


DC Motors & Servo: Responsible for vehicle locomotion (motors) and steering (servo).


18650 Batteries : Provide the main power to the system via the Expansion Board at 12.6V (using 3 of them).


Pi Camera: Connected to the Raspberry Pi via the CSI interface, used for computer vision.


Waveshare 7.9" LCD : Touch display connected to the Raspberry Pi via HDMI  for the user interface.


STM32U585AI : High-performance microcontroller, potentially used for real-time control tasks, low-level sensor reading, or interfacing with the CAN bus. Connected to a CAN-BUS transceiver module and to the motors and servo.


SSD HAT : Allows connecting an M.2 NVMe SSD to the Raspberry Pi 5 for fast, high-capacity storage, also connecting via GPIO pins for power and control (e.g., I2C ).


CAN-BUS (FD) Board: Interface for communication on the CAN (Controller Area Network), an automotive industry standard. We used two: one connected to the STM32 Microcontrller, and the other directly to the Rasp, both connected to each other via CAN-BUS.


LM393 Speed Sensor: Optical sensor used to measure wheel rotation speed, providing essential feedback for motion control.

### 4. Connectivity Diagram (Based on Image)

#### Raspberry Pi 5:

Connects via DSI (ribbon cable) to the Waveshare 7.9" LCD.

Connects via CSI (ribbon cable) to the Pi Camera.

Connects via GPIO (I2C Pins: SCL , SDA , 3V3) to the SSD HAT.

Connects via GPIO (Power Pins: 5V , Ground) to the SSD HAT.

Connects via GPIO (5V, 5V, 3V3, GND, SDA, SCL) to the Expansion Board.

Connects (likely via USB, not explicit) to the CAN-BUS Transceiver module.

---
|CAN Module | Raspberry Pi|
|-------|----------|
|INT 22 | (GPIO 25)|
|SCK 23 | (SCK)    |
|SI 19  | (MOSI)   |
|S0 21  | (MISO)   |
|CS 24  | (CE0)    |
|GND 6  | (GND)    |
|VCC 1  | (3.3V)   |
---


Connects (likely via USB or UART, not explicit) to the STM32U585AI Microcontroller.


#### Expansion Board:

Receives power from the 18650 Batteries  (12.6V connector ).

Controls the two DC Motors .

Controls the Waveshare Servo .

Connects to the Raspberry Pi 5  via GPIO.

Potentially provides power or control to the Waveshare 7.9" LCD  (unidentified line).


#### SSD HAT:

Mounted on the Raspberry Pi 5 .

Receives I2C and Power  from the Raspberry Pi 5.

Provides an M.2 M Key slot for SSD.


#### STM32U585AI Microcontroller:

Connects to the CAN-BUS (FD) Board  (interface unspecified).

Connects to the Raspberry Pi 5  (interface unspecified).


#### CAN-BUS (FD) Board:

Connects to the STM32U585AI Microcontroller .

Connects to the Raspberry Pi 5 .


#### LM393 Speed Sensor:

Connection is not explicit in the main diagram. Typically would connect to GPIO pins on the Raspberry Pi 5 or STM32U585AI for pulse counting.

### 5. Power Subsystem
Primary power comes from the 3x 18650 battery pack , presumably providing 12.6V to the Expansion Board.

The Expansion Board is responsible for powering the DC Motors and Servo , and likely provides regulated power (e.g., 5V) to the Raspberry Pi 5.

The Raspberry Pi 5 in turn provides 5V and 3.3V power to peripherals like the SSD HAT , Pi Camera , and potentially the LCD  (though the LCD might have separate power or receive it via the Expansion Board).

The STM32 Microcontroller and CAN-BUS Board  require their own power supplies (e.g., 5V or 3.3V), which could come from the Raspberry Pi, Expansion Board, or their own regulators. The diagram does not detail these specific power connections.

There is a main ON/OFF switch on the Expansion Board.

### 6. Notes and Assumptions
The exact communication interfaces between RPi5 <-> STM32, RPi5 <-> CAN Board, and STM32 <-> CAN Board are not specified in the diagram (USB, UART, or SPI/I2C are assumed).

The exact connection of the LM393 Speed Sensor is not depicted.

How the LCD receives power is not fully clear (could be via RPi5, Expansion Board, or both/separate).

It is assumed the Expansion Board contains the necessary drivers for the DC motors and servo.
