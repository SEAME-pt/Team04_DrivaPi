# Architecture Documentation

## Overview

SEA:ME HMI Dashboard follows a clean architecture pattern:

### Layers

1. **UI Layer** (QML)
   - Declarative UI
   - Data binding
   - Visual components

2. **Core Layer** (C++)
   - Business logic
   - Data models
   - Qt integration

3. **Resources**
   - Assets
   - Styling
   - Configuration

## Component Diagram

```
┌─────────────────────────────────────┐
│         QML UI Layer                │
│  (main.qml, components)             │
└───────────┬─────────────────────────┘
            │ Q_PROPERTY / Signals
┌───────────▼─────────────────────────┐
│      C++ Core Layer                 │
│  (VehicleData, Controllers)         │
└───────────┬─────────────────────────┘
            │
┌───────────▼─────────────────────────┐
│      Qt Framework                   │
└─────────────────────────────────────┘
```

## Data Flow

1. User interaction in QML
2. Signal emitted to C++ backend
3. Backend processes logic
4. Property changed signals
5. QML UI updates automatically
