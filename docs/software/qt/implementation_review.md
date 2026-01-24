# Implementation Review and Improvements

## 1) What We Started With
- **Baseline tool**: `kuksa-can-provider` bridge (DBC + mapping.json) translating CAN → KUKSA over gRPC.
- **Architecture**: STM32 → CAN (ID 0x100, float speed m/s) → kuksa-can-provider container → KUKSA Databroker → Qt UI.
- **Assumptions**: Mapping used `Vehicle.Speed` as m/s; no unit conversion layer; relied on DBC scaling = 1.
- **Security**: Typically run without TLS/JWT; adding creds was non-trivial in the containerized flow.
- **Operational gaps**: Extra container dependency, slower startup on RPi, harder to customize logic (only JSON mapping).
- **Resource/Build Issues**: QML asset casing mismatches; header include casing; proto generation order brittle.
- **Naming**: Mixed Qt-style and ad-hoc names in feeder (pure C++), making readability inconsistent with C conventions.

## 2) Why the Initial Approach Was Not Ideal
- **Standards Compliance**: COVESA VSS defines `Vehicle.Speed` in km/h; kuksa-can-provider mapping sent m/s (scale=1) → databroker/UI values 3.6× too low.
- **Extensibility Limits**: Mapping-only pipeline made custom logic (unit fixes, validation, transformations) awkward; rebuilding container for each change slowed iteration.
- **Security Posture**: TLS/mTLS/JWT were not consistently configured; harder to inject auth in the legacy container workflow.
- **Runtime Footprint**: Extra container process and Python dependencies increased startup and resource use on RPi compared to an in-process C++ feeder.
- **Reliability/Build**: Asset/header casing issues broke builds on case-sensitive filesystems; proto dependency ordering caused fragility.
- **Maintainability**: Mixed naming conventions in feeder reduced clarity; missing documentation of Qt vs pure C++ conventions.
- **User Feedback Path**: UI displayed M/S, masking the unit mismatch and hiding compliance errors.

## 3) What We Implemented (Detailed)
- **Replaced kuksa-can-provider with in-process C++ feeder**
  - Direct SocketCAN → gRPC publisher; removes extra container and Python deps; faster startup on RPi and simpler custom logic.
- **Unit Compliance Fix**
  - Convert CAN payload m/s → km/h in feeder handlers (`speed_kmh = speed_mps * 3.6`).
  - Update VSS metadata (`vss_v6.json`) to `unit: "km/h"`.
  - Reflect conversions in logs, tests, docs, and UI labels (KM/H).
- **Security Hardening**
  - Added TLS/mTLS support via `SslCredentials` for feeder and Qt subscriber.
  - Added JWT bearer metadata injection for authorization.
- **VAL v2 Migration & Stability**
  - Using official `val.proto`/`types.proto`; cleaned proto inputs.
  - Ensured publish/subscribe paths match VSS (`Vehicle.Speed`).
- **Build/Resource Fixes**
  - Corrected QML resource casing and missing assets.
  - Fixed include name casing to match headers on case-sensitive systems.
- **Naming & Documentation**
  - Feeder (pure C++) now uses PascalCase for functions/methods; helper decode functions renamed (`U8`, `FloatLe`, etc.).
  - Added naming convention section clarifying Qt (camelCase, `m_` members) vs pure C++ (PascalCase, snake_case members).
- **Testing Aids**
  - Updated `test_feeder.sh` comments with m/s→km/h examples.
  - README and logs now show km/h outputs alongside original m/s payloads for validation.

### Code References (what changed where)
- **Speed conversion**: CAN float m/s is decoded and converted to km/h before publishing in [qt-app/src/feeder/handlers.cpp](qt-app/src/feeder/handlers.cpp#L14-L30); handler contract documented in [qt-app/src/feeder/handlers.hpp](qt-app/src/feeder/handlers.hpp#L16-L31). Dispatch wiring for CAN ID 0x100 routes here via [qt-app/src/feeder/main.cpp](qt-app/src/feeder/main.cpp#L74-L99).
- **Security flags & broker connection**: CLI now accepts `--tls`, CA/cert/key, and JWT token flags, wiring into publisher options in [qt-app/src/feeder/main.cpp](qt-app/src/feeder/main.cpp#L99-L148). TLS credentials and token metadata are built in [qt-app/src/feeder/publisher.cpp](qt-app/src/feeder/publisher.cpp#L12-L44) with auth header injection in [qt-app/src/feeder/publisher.cpp](qt-app/src/feeder/publisher.cpp#L168-L171); option schema lives in [qt-app/src/feeder/publisher.hpp](qt-app/src/feeder/publisher.hpp#L20-L82).
- **VSS metadata unit**: `Vehicle.Speed` now declares `km/h` in [qt-app/vss_v6.json](qt-app/vss_v6.json) so databroker schema matches the feeder conversion.
- **VAL publish wrappers**: Typed publish helpers stay in [qt-app/src/feeder/publisher.cpp](qt-app/src/feeder/publisher.cpp#L48-L165), reused by handlers to keep CAN→VSS logic minimal.

## 4) Why the New Approach Is Better
- **Standards Alignment**: Publishes km/h per COVESA VSS → correct semantics and interoperability.
- **Operational Accuracy**: UI and databroker show correct speeds (no 3.6× under-reporting).
- **Security Readiness**: TLS/mTLS + JWT reduce risk in production and align with expected broker security.
- **Build Robustness**: Case-sensitive fixes avoid platform-specific build breaks; proto inputs are cleaner.
- **Maintainability & Clarity**: Consistent naming in feeder and documented Qt exceptions reduce cognitive load and onboarding time.
- **Traceability**: Logs now include both km/h and m/s for quick verification during testing.

## 5) Key Improvements and Rationale
- **Unit Conversion in Feeder**: Centralizes SI→VSS boundary; keeps STM32 firmware unchanged while meeting VSS spec.
- **VSS Metadata Update**: Prevents unit mismatch warnings and enforces correct schema in databroker.
- **TLS/mTLS + JWT**: Required for secure deployments; protects data-in-transit and access control.
- **UI Label Change**: Surfaces correct unit to users; prevents misinterpretation of values.
- **Naming Convention Harmonization**: Feeder follows C/PascalCase; Qt code keeps Qt idioms; documented exceptions prevent future drift.

## 6) Current State Snapshot
- **Feeder**: Publishes km/h, secured via TLS/auth, naming aligned.
- **Qt UI**: Displays KM/H; subscribes over TLS/auth when configured.
- **Docs**: Naming convention updated with Qt exceptions; README/test scripts updated for unit conversion.
- **Open Items**: Ensure downstream configs (e.g., any custom vss.json) are refreshed; rebuild on target to confirm includes/paths.
