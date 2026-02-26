# AI-Generated Code Standards for Team04_DrivaPi

This document defines the coding standards that **AI assistants (GitHub Copilot, AI code generators)** must follow when generating code for the Team04_DrivaPi project.

> **Purpose:** Ensure all AI-generated code adheres to the project's established naming conventions, code style, and architectural patterns.

---

## 🎯 Mandatory Pre-Code-Generation Checklist

Before generating ANY code, AI must:

1. ✅ Read `.github/NAMING_CONVENTIONS.md` for file/directory naming rules
2. ✅ Identify the language/framework (C, C++, Rust, QML, Python)
3. ✅ Review existing similar files in the codebase for patterns
4. ✅ Follow language-specific conventions defined below

---

## 📁 File and Directory Naming (Reference)

**AI must strictly follow** `.github/NAMING_CONVENTIONS.md`:

| Type | Convention | Example |
|------|-----------|---------|
| **C/C++ files** | `snake_case` | `dc_motor.c`, `vehicle_data.cpp` |
| **Rust files** | `snake_case` | `main.rs`, `can_reader.rs` |
| **QML components** | `PascalCase` (mandatory) | `BatteryIndicator.qml`, `SpeedDisplay.qml` |
| **Headers** | `snake_case` | `dc_motor.h`, `vehicle_data.hpp` |
| **Python files** | `snake_case` | `validators.py`, `cli_parser.py` |
| **Directories (multi-word)** | `kebab-case` | `qt-app/`, `speed-sensor/` |
| **Directories (acronym)** | `ALL CAPS` | `TSF/`, `CAN/` |

---

## 🛠️ Language-Specific Coding Standards

### 🔷 C (Firmware - `firmware/Core/`)

#### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| **Functions** | `PascalCase` | `MotorStop()`, `SetMotor()`, `PCA9685_SetPWM()` |
| **Variables (local)** | `snake_case` | `uint16_t pwm_value`, `double speed` |
| **Defines/Macros** | `SCREAMING_SNAKE_CASE` | `#define MOTOR_L_PWM 7`, `#define PCA9685_ADDR_MOTOR 0x60` |
| **Struct names** | `PascalCase` | `struct MotorConfig`, `struct SensorData` |
| **Enums** | `PascalCase` for type, `SCREAMING_SNAKE_CASE` for values | `enum MotorState { MOTOR_STOPPED, MOTOR_RUNNING }` |
| **Global variables** | `snake_case` with `g_` prefix | `g_motor_speed`, `g_sensor_data` |
| **Header guards** | `__FILENAME_H` | `#ifndef __DC_MOTOR_H` |

#### Code Style Rules

```c
// ✅ CORRECT - Follow this pattern
/**
 * @file dc_motor.c
 * @author DrivaPi Team
 * @brief DC motor control functions
 */

#include "dc_motor.h"

#define MAX_SPEED 4095u
#define MIN_SPEED 0u

/**
 * @brief Stops the DC motor by setting PWM to 0
 */
void MotorStop(void)
{
    PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0);
    PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0);
}

/**
 * @brief Moves motor forward at specified speed
 * @param speed Normalized speed value (0.0 - 1.0)
 */
void MotorForward(double speed)
{
    uint16_t pwm_value = (uint16_t)(speed * MAX_SPEED);
    // Implementation...
}
```

**Key Rules:**
- Use Doxygen-style comments (`/** @brief */`)
- Functions use `PascalCase` (established pattern in codebase)
- Constants/macros use `SCREAMING_SNAKE_CASE`
- Local variables use `snake_case`
- Use explicit types (`uint16_t`, `int32_t`, not `int`)
- Include file headers with `@file`, `@author`, `@brief`

---

### 🔷 C++ (Qt Application - `qt-app/`)

#### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| **Classes** | `PascalCase` | `class VehicleData`, `class CanReader` |
| **Methods** | `camelCase` | `setSpeed()`, `getEnergy()`, `checkStaleProperties()` |
| **Member variables** | `camelCase` with `m_` prefix | `m_speed`, `m_battery`, `m_watchdogTimer` |
| **Local variables** | `snake_case` | `float_val`, `byte_array`, `pwm_value` |
| **Constants** | `SCREAMING_SNAKE_CASE` | `const uint32_t SPEED_CAN_ID = 0x100` |
| **Namespaces** | `lowercase` | `namespace drivaui`, `namespace feeder` |
| **Enums** | `PascalCase` for type, values match context | `enum GearState { Park, Drive, Reverse }` |

#### Code Style Rules

```cpp
// ✅ CORRECT - Follow this pattern
/**
 * @file vehicle_data.hpp
 * @brief Vehicle telemetry data model exposed to QML
 * @note Thread-safe property setters for main thread
 */

#ifndef VEHICLEDATA_HPP
#define VEHICLEDATA_HPP

#include <QObject>
#include <QString>

namespace drivaui {

/**
 * @class VehicleData
 * @brief QObject-based vehicle telemetry model for QML
 */
class VehicleData : public QObject
{
    Q_OBJECT

    Q_PROPERTY(double speed READ getSpeed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(int battery READ getBattery WRITE setBattery NOTIFY batteryChanged)

public:
    explicit VehicleData(QObject *parent = nullptr);
    ~VehicleData() override;

    // Getters
    float getSpeed() const;
    int getBattery() const;

    // Setters
    void setSpeed(float mps);
    void setBattery(int battery);

signals:
    void speedChanged();
    void batteryChanged();

private:
    float m_speed;
    int m_battery;
    QTimer* m_watchdogTimer;

    void checkStaleProperties();
};

} // namespace drivaui

#endif // VEHICLEDATA_HPP
```

**Key Rules:**
- Use Doxygen-style comments
- Member variables prefixed with `m_`
- Methods use `camelCase` (Qt convention)
- Classes use `PascalCase`
- Header guards: `#ifndef CLASSNAME_HPP`
- Always use namespaces (`drivaui`, `feeder`)
- Qt signals/slots follow Qt naming (no `on` prefix for custom signals)

---

### 🔷 Rust (`rust/`, `meta-cross/recipes-rust/`)

#### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| **Structs** | `PascalCase` | `struct Vector2f`, `struct GamepadInput` |
| **Functions** | `snake_case` | `fn read_gamepad()`, `fn send_can_message()` |
| **Variables** | `snake_case` | `let pwm_value = 100;`, `let max_speed = 4095.0;` |
| **Constants** | `SCREAMING_SNAKE_CASE` | `const CAN_ID_MOTOR: u16 = 44;` |
| **Enums** | `PascalCase` for type and variants | `enum MotorState { Running, Stopped }` |
| **Modules** | `snake_case` | `mod can_handler;`, `mod motor_control;` |

#### Code Style Rules

```rust
// ✅ CORRECT - Follow this pattern
use std::collections::HashMap;
use socketcan::{CanFrame, CanSocket};

/* CAN Protocol Constants */
const CAN_ID_MOTOR: u16 = 44;
const CAN_ID_SERVO: u16 = 45;
const MAX_MOTOR_SPEED: f64 = 4095.0;

/* Motor Constants */
const MIN_MOTOR_SPEED: f64 = -4095.0;

#[derive(Default, Debug, Clone, Copy)]
pub struct Vector2f {
    x: f64,
    y: f64,
}

#[derive(Default, Debug)]
pub struct GamepadInput {
    analog_stick_left: Vector2f,
    analog_stick_right: Vector2f,
    button_a: bool,
    button_b: bool,
}

impl GamepadInput {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn update_axis(&mut self, axis_id: u8, value: i16) {
        match axis_id {
            0 => self.analog_stick_left.x = normalize_axis(value),
            1 => self.analog_stick_left.y = normalize_axis(value),
            _ => {}
        }
    }
}

fn normalize_axis(value: i16) -> f64 {
    (value as f64) / 32767.0
}
```

**Key Rules:**
- Use `/* */` block comments for section headers
- Use `//` for inline comments
- Constants use `SCREAMING_SNAKE_CASE`
- Struct fields use `snake_case`
- Always derive `Debug` for structs
- Use `#[derive(Default)]` when sensible
- Follow Rust naming conventions (not C conventions)

---

### 🔷 QML (Qt Quick - `qt-app/resources/qml/`)

#### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| **QML files** | `PascalCase` (mandatory!) | `BatteryIndicator.qml`, `SpeedDisplay.qml` |
| **IDs** | `camelCase` | `id: speedText`, `id: batteryIcon` |
| **Properties** | `camelCase` | `property int batteryLevel`, `property string gearMode` |
| **Functions** | `camelCase` | `function updateSpeed()`, `function formatValue()` |

#### Code Style Rules

```qml
// ✅ CORRECT - Follow this pattern (BatteryIndicator.qml)
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root

    property int batteryLevel: 100
    property bool isCharging: false

    width: 120
    height: 60

    Rectangle {
        id: batteryBody
        anchors.fill: parent
        color: getBatteryColor()
        radius: 8

        Text {
            id: batteryText
            anchors.centerIn: parent
            text: root.batteryLevel + "%"
            font.pixelSize: 18
            color: "white"
        }
    }

    function getBatteryColor() {
        if (root.batteryLevel > 50) return "green"
        if (root.batteryLevel > 20) return "orange"
        return "red"
    }
}
```

**Key Rules:**
- **File names MUST be PascalCase** (QML engine requirement)
- Root item should have `id: root`
- Properties, IDs, functions use `camelCase`
- Use `anchors` for layout (Qt Quick convention)
- Group properties logically (size, color, position, etc.)

---

### 🔷 Python (`scripts/`, `dotstop/`)

#### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| **Functions** | `snake_case` | `def validate_coverage()`, `def generate_baseline()` |
| **Variables** | `snake_case` | `coverage_data`, `file_path` |
| **Classes** | `PascalCase` | `class CoverageValidator`, `class TrudagExtension` |
| **Constants** | `SCREAMING_SNAKE_CASE` | `MAX_RETRIES = 3`, `DEFAULT_TIMEOUT = 30` |
| **Modules** | `snake_case` | `validators.py`, `coverage_utils.py` |

#### Code Style Rules

```python
# ✅ CORRECT - Follow this pattern
"""
Module for validating LLTC coverage against baseline.

This module provides utilities for parsing coverage reports
and comparing them to expected baseline values.
"""

import sys
import argparse
from pathlib import Path

# Constants
DEFAULT_THRESHOLD = 85.0
MAX_COVERAGE_DIFF = 5.0

class CoverageValidator:
    """Validates test coverage against baseline."""

    def __init__(self, baseline_path: Path):
        """Initialize validator with baseline file path."""
        self.baseline_path = baseline_path
        self.coverage_data = {}

    def validate_coverage(self, current_coverage: float) -> bool:
        """
        Validate current coverage against baseline.

        Args:
            current_coverage: Current coverage percentage (0-100)

        Returns:
            True if coverage meets threshold, False otherwise
        """
        baseline_coverage = self._load_baseline()
        return current_coverage >= baseline_coverage - MAX_COVERAGE_DIFF

    def _load_baseline(self) -> float:
        """Load baseline coverage from file (private method)."""
        # Implementation...
        pass
```

**Key Rules:**
- Use docstrings (triple quotes) for modules, classes, functions
- Type hints for function parameters and returns
- Constants at module level
- Private methods prefixed with `_`
- Follow PEP 8 style guide

---

## 🔒 Header Guards

### C Headers
```c
// Pattern: __FILENAME_H (double underscore prefix)
#ifndef __DC_MOTOR_H
#define __DC_MOTOR_H

// Code...

#endif // __DC_MOTOR_H
```

### C++ Headers
```cpp
// Pattern: CLASSNAME_HPP (no underscores)
#ifndef VEHICLEDATA_HPP
#define VEHICLEDATA_HPP

// Code...

#endif // VEHICLEDATA_HPP
```

---

## 📝 Documentation Standards

### All Languages
- **Always include file headers** with:
  - `@file` - filename
  - `@author` - "DrivaPi Team" (or specific author if known)
  - `@brief` - one-line description
  - `@note` - additional important information (optional)

### Doxygen-Style Comments (C/C++)
```c
/**
 * @brief Moves motor forward at specified speed
 * @param speed Normalized speed value (0.0 - 1.0)
 * @return 0 on success, -1 on error
 * @note Speed is clamped to valid range internally
 */
int MotorForward(double speed);
```

### Rust Doc Comments
```rust
/// Moves motor forward at specified speed
///
/// # Arguments
/// * `speed` - Normalized speed value (0.0 - 1.0)
///
/// # Returns
/// * `Ok(())` on success, `Err(MotorError)` on failure
pub fn motor_forward(speed: f64) -> Result<(), MotorError> {
    // Implementation...
}
```

---

## 🚫 Common Anti-Patterns to AVOID

### ❌ Don't Do This

```c
// ❌ Wrong: camelCase in C firmware
void motorStop() { ... }

// ❌ Wrong: lowercase defines
#define max_speed 4095

// ❌ Wrong: Hungarian notation
int nSpeed = 100;
uint32_t dwAddress = 0x60;
```

```cpp
// ❌ Wrong: member variables without m_ prefix
class VehicleData {
    float speed;  // Should be m_speed
    int battery;  // Should be m_battery
};

// ❌ Wrong: PascalCase methods in C++ (not Qt)
void SetSpeed(float speed);  // Should be setSpeed()
```

```rust
// ❌ Wrong: PascalCase functions
fn SendCanMessage() { ... }  // Should be send_can_message()

// ❌ Wrong: camelCase constants
const canIdMotor: u16 = 44;  // Should be CAN_ID_MOTOR
```

```qml
// ❌ CRITICAL: lowercase QML component files
// batteryIndicator.qml - Will NOT work! Must be PascalCase.
```

---

## 🎯 AI Code Generation Workflow

When AI generates code, follow this workflow:

1. **Identify Language** → Determine C, C++, Rust, QML, or Python
2. **Check Naming Rules** → Review `.github/NAMING_CONVENTIONS.md`
3. **Find Similar Files** → Look at existing code in the same directory
4. **Apply Standards** → Use the patterns defined in this document
5. **Generate Code** → Write code following all conventions
6. **Add Documentation** → Include file headers and function docs
7. **Verify Compliance** → Self-check against this document

---

## 📚 References

- **Naming Conventions**: `.github/NAMING_CONVENTIONS.md`
- **Pull Request Template**: `.github/PULL_REQUEST_TEMPLATE.md`
- **Daily Logs**: `.github/instructions/daily-logs.instructions.md`
- **Team Info**: `.github/instructions/team.instructions.md`

---

## ✅ Summary Checklist for AI

Before submitting AI-generated code, verify:

- [ ] File names follow `snake_case` (C/C++/Rust/Python) or `PascalCase` (QML)
- [ ] Functions follow language conventions (C: `PascalCase`, C++: `camelCase`, Rust: `snake_case`)
- [ ] Variables use appropriate casing (`snake_case` in C/Rust, `camelCase` with `m_` in C++)
- [ ] Constants use `SCREAMING_SNAKE_CASE`
- [ ] Header guards follow project patterns (`__FILENAME_H` for C, `CLASSNAME_HPP` for C++)
- [ ] File headers include `@file`, `@author`, `@brief`
- [ ] Functions have Doxygen/docstring documentation
- [ ] Code matches existing patterns in the codebase
- [ ] No anti-patterns from the "Don't Do This" section

---

**Last Updated:** 2026-02-08  
**Maintained By:** DrivaPi Team
