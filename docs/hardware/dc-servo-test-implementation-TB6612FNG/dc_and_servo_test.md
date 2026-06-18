# DC and Servo Test with TB6612FNG

This sketch is a simple Arduino test for the TB6612FNG H-bridge. It drives two DC motors forward and backward while also moving a servo through different angles.

## What the code shows

- The TB6612FNG can control both DC motors correctly.
- The servo also works with the same test setup.
- The motor bridge responds properly to direction and speed commands.
- The test proves the H-bridge is suitable for the car's motor control stage.

## Why it is useful

This test confirms that the TB6612FNG works with the car's motors and servo before.
It also shows that the same control behavior can be implemented later on the STM32 instead of the Arduino.

## Future use

The Arduino code can be used as a reference for the STM32 firmware implementation, especially for:

- motor direction control
- PWM speed control
- servo position control
- basic validation of the motor bridge wiring

---
