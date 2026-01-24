# C Codebase Standardization & Naming Convention

## 1. Core Philosophy

The goal of this standard is **Visual Distinction** with **one official policy**. Pure C/C++ follows the rules below; Qt code has a mandatory Qt-style exception (not optional, required by the framework).

* **Files:** Compatibility (`snake_case`)
* **Types & Functions:** Proper Nouns (`PascalCase`)
* **Variables:** Instances (`snake_case`)
* **Constants:** Screaming (`UPPER_SNAKE_CASE`)

---

## 2. File Organization

File names must be lowercase to ensure cross-platform compatibility (Windows/Linux/CI/CD pipelines).

* **Format:** `snake_case` (lowercase with underscores)
* **Extension:** `.c` for source, `.h` for headers. Header files relative to a source file should have the same name, only the extension would differ.
* **Rule:** The filename should match the "Module Name" used in function prefixes.

| Item | Format | Example |
| --- | --- | --- |
| Source File | `snake_case` | `motor_controller.c` |
| Header File | `snake_case` | `motor_controller.h` |

---

## 3. Data Types (Structs, Enums, Typedefs)

Types represent the "blueprint" of data. They use `PascalCase` to look like proper nouns. This allows you to easily distinguish a Type from an instance of that type.

* **Format:** `PascalCase`
* **Rule:** Do not use `_t` suffixes (this is a POSIX convention). The capitalization is enough distinction.

```c
// Good
typedef struct {
    float x;
    float y;
} Vector2D;

// Good
typedef enum {
    STATE_IDLE,
    STATE_RUNNING,
    STATE_ERROR
} SystemState;

// Usage is clean and readable:
Vector2D position;
SystemState currentState;

```

---

## 4. Functions

Functions represent "Actions." Because C does not have namespaces, **Function names must include the Module Prefix**.

* **Format:** `PascalCase`
* **Pattern:** `Module + Verb + Subject` (or `Module + Action`)
* **Prefix:** Must match the filename (or logical module).
* **Type:** Must be in lowercase, like `void`,`int`,`char`, etc. (unless specified otherwise in libs).
* **Exceptions:** When defining a function with a **specific/complicated** name, such as including the specific chip name `PCA9685` in the related `InitDevice()` function, you should separate the specific name with an underscore `_` and keep the rest in `PascalCase`, like so: `PCA9685_InitDevice`.

| Scope | Format | Pattern | Example |
| --- | --- | --- | --- |
| **Public API** | `PascalCase` | `ModuleAction` | `AudioInit()`, `MotorSetSpeed()` |
| **Private (Static)** | `PascalCase` | `_Action` | `_CalculateChecksum()` (underscore implies private) |

```c
// Good Definition
void UartTransmitByte(uint8_t data) { ... }
void PCA9685_InitDevice() { ... }

// Good Usage
if (UartIsOpen()) {
    UartTransmitByte(0xFF);
}

// Bad Definition
VOID UARTTx(uint8_t d) { ... } // 'VOID' should be 'void' to improve readability | UART can't be in CAPS because of case conflicts with the next word.

// Bad Usage
if (UartOp()) { // In this case, we can't immediately know what 'Op' means
    UartTx(0xFF); // And here, 'Tx' is transmit, but what are we transmitting?
}
```

---

## 5. Variables

Variables represent "Data" and "Instances". They use `snake_case` to visually sit "lower" than Types and Functions.

* **Format:** `snake_case`
* **Pattern:** Lowercase, short and concise, offering immediate information about what it does. Descriptive `snake_case` with possibility to add unit information like `length_cm`. Try to not have more than one underscore `_`, although up to two underscores is acceptable, like: `is_first_run`.
* **Pointer naming:** Do not use `p_var` or Hungarian notation (`pPtr`). The type is usually visible.
* **Exceptions:** If defining the type of value for the variable, like speed in mps, or time in ms, use `speed_mps` or `time_ms`. The unit of measurement should be separated by the underscore `_` and should occupy the rightmost part of the variable's name.

```c
// Function arguments and local variables
void DisplaySetBrightness(int brightness_level) {
    int max_level = 255;

    if (brightness_level > max_level) {
        brightness_level = max_level;
    }
}

// Don't do this:
void DisplaySetBrightness(int brightnessLevel) {
	int n = 1; // In this case, 'n' should be called 'number', or 'num', at the very least.
	char name_of_display_type // Here, 'name_of_display_type' can simply be switched to 'display_name' to simplify and de-clutter the code.
}
```

### 5.1 Global Variables

Global variables are dangerous. If they must exist, they need a prefix to distinguish them from local variables to prevent shadowing bugs.

* **Format:** `g_camelCase`

```c
int g_systemTickCount = 0;

```

---

## 6. Constants & Macros

Preprocessor definitions must be visually jarring to warn the developer that they are not variables.

* **Format:** `UPPER_SNAKE_CASE`
* **Rule:** If a variable is `const` but not a macro, it may use `kPascalCase` (optional) or standard `UPPER_SNAKE_CASE`.

| Type | Format | Example |
| --- | --- | --- |
| #define Macros | `UPPER_SNAKE_CASE` | `MAX_BUFFER_SIZE` |
| Enum Values | `UPPER_SNAKE_CASE` | `COLOR_RED`, `COLOR_BLUE` (Scoped to Enum name if possible) |
| Const Variables | `kPascalCase` | `kDefaultTimeout` |

---

## 7. Migration & Renaming Cheat Sheet

When renaming your legacy code, follow these patterns to ensure consistency:

| Concept | Old / Legacy Style | **New Standard** | Why? |
| --- | --- | --- | --- |
| **Clarity** | `init()` | `LcdInit()` | Avoids collisions; explicit dependency. |
| **Units** | `delay(100)` | `TimerDelayMs(100)` | Prevents unit errors (seconds vs ms). |
| **Booleans** | `int flag` | `bool isValid` | `is`, `has`, or `should` prefix clarifies logic. |
| **Iterators** | `ii`, `idx` | `i`, `index` | Standard convention. |
| **Collision** | `data` | `packetPayload` | `data` is too generic. Be specific. |

---

### Example: Before vs. After

**Before (Legacy Mix)**

```c
/* serial.c */
#define buff_size 128

typedef struct {
    int BaudRate;
    bool IsOpen;
} serial_config_t;

serial_config_t cfg;

void init_serial() {
    cfg.baud = 9600;
}

int send(char * p) {
    // ...
}

```

**After (Standardized)**

```c
/* serial_driver.c */
#define SERIAL_BUFFER_SIZE 128

typedef struct {
	int baud;
    int is_open;
} SerialConfig;

SerialConfig g_serialConfig;

void SerialInit(void) {
    g_serialConfig.baud = 9600;
}

int SerialSendString(char* payload) {
    // ...
}

```

---

## 8. C++ / Qt Framework (Mandatory Qt Exception)

This standard is primarily designed for **C / pure C++**. **Qt code MUST follow Qt style** (camelCase + `m_`), because Qt tooling and community conventions depend on it. This is not an alternative policy—Qt style is mandatory for Qt files.

### 8.1 Qt Classes and Methods

Qt framework follows its own established conventions. **Qt-related code should follow Qt style**:

* **Qt Class Methods:** `camelCase` (Qt standard convention)
* **Qt Signals/Slots:** `camelCase`
* **Qt Member Variables:** `m_camelCase` (single convention; Qt uses `m_` prefix)
* **Qt Class Names:** `PascalCase` (matches our convention)

**Example (Qt Code):**
```cpp
// inc/vehicle_data.hpp - Qt Class
class VehicleData : public QObject {
    Q_OBJECT
public:
    float getSpeed() const;      // Qt style: camelCase
    void setSpeed(float value);  // Qt style: camelCase
    
signals:
    void speedReceived(float speed);  // Qt style: camelCase
    
private:
    float m_speed;               // Qt style: m_ prefix
    QTimer* m_watchdogTimer;     // Qt style: m_ + camelCase
};
```

### 8.2 Pure C++ Modules (Non-Qt)

For **pure C++ code that doesn't use Qt** (e.g., the feeder module), apply the C conventions with C++ adaptations:

* **Free Functions:** `PascalCase` (class/namespace provides scope)
* **Namespaces:** `snake_case` (lowercase)
* **Class Methods:** `PascalCase`
* **Member Variables:** `snake_case` with optional trailing underscore `variable_name_`
* **Local Variables:** `snake_case`

**Example (Pure C++ Code):**
```cpp
// src/feeder/can_decode.hpp - Pure C++
namespace can_decode {

inline uint8_t U8(const uint8_t* data) {
    return data[0];
}

inline float FloatLe(const uint8_t* data) {
    float result;
    std::memcpy(&result, data, sizeof(float));
    return result;
}

} // namespace can_decode

// src/feeder/publisher.hpp - Pure C++ Class
namespace kuksa {

class Publisher {
public:
    bool PublishFloat(const std::string& path, float value);
    bool PublishInt32(const std::string& path, int32_t value);
    
private:
    void AttachAuth(grpc::ClientContext& ctx);
    PublisherOptions options_;
    std::unique_ptr<VAL::Stub> stub_;
};

} // namespace kuksa
```

### 8.3 Rationale (Why Qt is an exception, not an option)

* Qt code must match Qt tooling expectations (MOC, signals/slots)
* Qt developers expect camelCase + `m_`; changing it reduces readability
* Pure C/C++ keeps PascalCase actions and snake_case data for clarity

---
