# Repository Structure and Naming Conventions

This document defines the naming conventions and structure rules for the Team04_DrivaPi repository.

## Directory Naming

### Acronym Directories
Directories that represent acronyms should be in **ALL CAPS**.

**Examples:**
- `TSF/` - Technical Safety Framework
- `CAN/` - Controller Area Network

### Multi-word Directories
Regular directories with multiple words should use **kebab-case** (lowercase with hyphens).

**Examples:**
- `qt-app/`
- `data-transfer/`
- `speed-sensor/`
- `motor-servo/`

### Single-word Directories
Single-word directories should be **lowercase**.

**Examples:**
- `docs/`
- `scripts/`
- `tests/`
- `rust/`
- `archive/`

## File Naming

### C/C++ and  Rust Files
C/C++ (`.c`, `.cpp`, `.h`, `hpp`) and Rust (`.rs`) files should use **snake_case**.

**Examples:**
- `test_speed_sensor.c`
- `speed_sensor.h`
- `dc_motor_functions.h`
- `pca9685_testable.c`
- `can_latency_send_test.c`
- `main.rs`

### QML Component Files
QML component files (`.qml`) **MUST** use **PascalCase** (starting with an uppercase letter). This is a **strict requirement** of the QML engine - files starting with lowercase letters are not registered as instantiable types.

**Examples:**
- `BatteryIndicator.qml` ✅ (works - creates `BatteryIndicator` type)
- `EnergyDisplay.qml` ✅ (works - creates `EnergyDisplay` type)
- `GearSelector.qml` ✅ (works - creates `GearSelector` type)
- `battery_indicator.qml` ❌ (fails - not recognized as a type)

**Why this matters:**
The QML engine only recognizes files beginning with uppercase letters as component types. Lowercase-starting files are ignored for type registration, causing "X is not a type" errors at runtime.

**Qt Documentation Reference:**
> "The type name has the following requirements:
> - It must be comprised of alphanumeric characters or underscores.
> - **It must begin with an uppercase letter.**"

See: [Qt QML Type Naming](https://doc.qt.io/qt-6/qtqml-documents-definetypes.html#naming-custom-qml-object-types)

### Markdown Documentation
Markdown files should use **snake_case**.

**Examples:**
- `project_guidelines.md`
- `branch_guidelines.md`
- `issue_template.md`
- `genAI_justification.md` (acronym preserved in camelCase)

### Template Files
Template files should clearly indicate they are templates using the `_template` suffix.

**Examples:**
- `epic_template.md`
- `issue_template.md`
- `sub_issue_template.md`

## Special Cases

### Language-Specific Conventions
While the repository follows kebab-case for directories, language-specific naming follows their respective conventions:
- **C/C++/Rust projects**: Use snake_case for all files

### GitHub Directories
GitHub-specific directories follow GitHub conventions:
- `.github/`
- `.github/workflows/`
- `.github/ISSUE_TEMPLATE/`

### Configuration Files
Configuration files follow their ecosystem conventions:
- `README.md` (uppercase)
- `Gemfile` (capitalized)
- `CODE_OF_CONDUCT.md` (uppercase)

### Systemd Service Files
Systemd `.service` files use **kebab-case** (hyphens), following the systemd/freedesktop ecosystem convention. This is intentional and **not** a violation of the snake_case rule.

Systemd identifies and references units by their filename (e.g. via `After=`, `Wants=`, `systemctl enable`). Renaming to snake_case would change the unit name visible to the OS and could break service dependencies.

**Examples:**
- `pipewire-system.service` ✅
- `wireplumber-system.service` ✅
- `drivapi-dashboard.service` ✅

### Yocto Recipe Files
Yocto `.bb` recipe files use **snake_case**, consistent with the project convention.

**Exception:** `.bbappend` files **must** match the upstream recipe name they extend (Bitbake file-based matching). Renaming a `.bbappend` causes it to be silently ignored by the build system.

**Examples:**
- `qt_app_git.bb` ✅ (snake_case, with explicit `PN` override if needed)
- `gstreamer1.0-plugins-good_%.bbappend` ✅ (must match upstream name — not a convention violation)

## Summary Table

| Type | Convention | Example |
|------|-----------|---------|
| Acronym directories | ALL CAPS | `TSF/`, `CAN/` |
| Multi-word directories | kebab-case | `qt-app/`, `motor-servo/` |
| Single-word directories | lowercase | `docs/`, `scripts/`, `rust/` |
| C files | snake_case | `speed_sensor.c`, `test_speed_sensor.c` |
| Rust files | snake_case | `main.rs` |
| C++ files | snake_case | `can_reader.cpp`, `vehicle_data.cpp` |
| QML components | **PascalCase** (mandatory) | `BatteryIndicator.qml`, `EnergyDisplay.qml` |
| Markdown files | snake_case | `project_guidelines.md` |
| Template files | snake_case + `_template` | `issue_template.md` |
| Yocto `.bb` files | snake_case | `qt_app_git.bb`, `drivapi_audio_1.0.bb` |
| Yocto `.bbappend` files | match upstream recipe name | `gstreamer1.0-plugins-good_%.bbappend` |
| Systemd `.service` files | kebab-case (ecosystem convention) | `pipewire-system.service` |

## Guidelines

1. **Be consistent**: Follow these conventions for all new files and directories
2. **Acronyms**: Keep acronyms in CAPS for directories, preserve meaning in files
3. **Readability**: Prioritize clarity over brevity
4. **C/C++ and Rust**: Always use snake_case for files (primary languages in this project)
5. **QML Components**: **MUST** use PascalCase - this is enforced by the QML engine, not a preference
6. **Don't rename existing files**: Only apply these rules to new additions unless refactoring

## Questions?

If you're unsure about naming something, refer to existing similar files/directories or ask the team during standup.
