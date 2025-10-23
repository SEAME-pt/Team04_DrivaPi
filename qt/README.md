# SEA:ME HMI Dashboard

Qt-based HMI Dashboard for Automotive Grade Linux (AGL).

## 📁 Project Structure

```
qt/
├── src/                       # Source code
│   └── core/                 # Core application logic
│       ├── main.cpp         # Application entry point
│       └── vehicledata.cpp  # Vehicle data implementation
├── include/                  # Header files
│   └── vehicledata.h        # Vehicle data class
├── resources/                # Resources
│   ├── qml/                 # QML files
│   │   └── main.qml        # Main UI
│   ├── assets/              # Images, icons, SVG
│   │   ├── images/
│   │   ├── icons/
│   │   └── svg/
│   └── resources.qrc        # Qt resource file
├── scripts/                  # Build and utility scripts
│   ├── build/               # Build scripts
│   │   ├── build.sh        # Build the project
│   │   ├── run.sh          # Run the application
│   │   └── clean.sh        # Clean build files
│   ├── deploy/              # Deployment scripts
│   │   ├── docker-build.sh # Build Docker image
│   │   └── docker-run.sh   # Run in Docker
│   └── utils/               # Utility scripts
│       └── fix-qml.sh      # QML property fix script
├── docker/                   # Docker configuration
│   └── production/
│       └── Dockerfile       # Production Dockerfile
├── docs/                     # Documentation
│   ├── BUILD.md            # Build instructions
│   ├── ARCHITECTURE.md     # System architecture
│   └── API.md              # API documentation
├── tests/                    # Unit tests (future)
├── build/                    # Build output (generated)
├── qt-hmi.pro               # Qt project file
├── quick-start.sh           # Interactive quick start menu
├── PROJECT_STRUCTURE.md     # Detailed structure
└── README.md                # This file
```

## 🚀 Quick Start

### Option 1: Interactive Menu (Recommended)

```bash
./quick-start.sh
```

### Option 2: Build and Run Manually

```bash
# Build
./scripts/build/build.sh

# Run
./scripts/build/run.sh

# Clean (if needed)
./scripts/build/clean.sh
```

### Option 3: Docker Build

```bash
# Build Docker image
./scripts/deploy/docker-build.sh

# Run in Docker
./scripts/deploy/docker-run.sh
```

## 📋 Requirements

### Local Development
- **Qt 6.x** (Qt Quick, Qt QML)
- **C++17 or higher**
- **QMake** (comes with Qt)
- **macOS, Linux, or Windows**

### Installation (macOS)

```bash
# Install Qt via Homebrew
brew install qt

# Verify installation
qmake --version
```

### Installation (Linux)

```bash
# Ubuntu/Debian
sudo apt-get install qt6-base-dev qt6-declarative-dev

# Fedora
sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel

# Arch Linux
sudo pacman -S qt6-base qt6-declarative
```

## 🎯 Features

- ✅ **Real-time Vehicle Data** - Speed, battery, energy, temperature
- ✅ **Interactive Simulation** - Adjustable speed (1x-5x)
- ✅ **Gear Selection** - P, R, N, D with visual feedback
- ✅ **Modern UI** - Clean, automotive-grade design
- ✅ **Responsive Layout** - 1280x400 dashboard display
- ✅ **Qt Property Binding** - Reactive data updates
- ✅ **Docker Support** - Cross-platform containerized builds

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│            QML Frontend (UI)                │
│  - main.qml                                 │
│  - Speedometer, Battery, Gear Display      │
└──────────────┬──────────────────────────────┘
               │ Qt Property Binding
┌──────────────▼──────────────────────────────┐
│         C++ Backend (Logic)                 │
│  - VehicleData class                        │
│  - Simulation engine                        │
│  - Data management                          │
└─────────────────────────────────────────────┘
```

## 🛠️ Development Commands

```bash
# Build and Run
./scripts/build/build.sh      # Build project
./scripts/build/run.sh        # Run application
./scripts/build/clean.sh      # Clean build files

# Docker
./scripts/deploy/docker-build.sh    # Build Docker image
./scripts/deploy/docker-run.sh      # Run in container

# Utilities
./scripts/utils/fix-qml.sh    # Fix QML property calls
tree -L 3 -I 'build|*.o'      # View structure
```

## 🐳 Docker Support

### Build for Different Platforms

```bash
# x86_64 (Intel/AMD)
docker build -f docker/production/Dockerfile -t seame-hmi:x64 .

# ARM64 (Raspberry Pi, AGL)
docker build --platform linux/arm64 -f docker/production/Dockerfile -t seame-hmi:arm64 .
```

### Deploy to AGL/Raspberry Pi

```bash
# Build for ARM64
docker build --platform linux/arm64 -f docker/production/Dockerfile -t seame-hmi:arm64 .

# Extract binary
docker create --name temp seame-hmi:arm64
docker cp temp:/app/SEA_ME_HMI_Dashboard ./SEA_ME_HMI_Dashboard_arm64
docker rm temp

# Copy to device
scp SEA_ME_HMI_Dashboard_arm64 pi@raspberrypi:/home/pi/
ssh pi@raspberrypi './SEA_ME_HMI_Dashboard_arm64'
```

## 🔧 Adding New Features

1. **C++ Backend**: Modify `VehicleData` class
   ```cpp
   // include/vehicledata.h
   Q_PROPERTY(int newProperty READ newProperty NOTIFY newPropertyChanged)
   Q_INVOKABLE void newMethod();
   ```

2. **QML Frontend**: Use the property
   ```qml
   // resources/qml/main.qml
   Text { text: vehicleData.newProperty }
   ```

3. **Rebuild**
   ```bash
   ./scripts/build/clean.sh && ./scripts/build/build.sh
   ```

## 🐛 Troubleshooting

### Build Issues

```bash
# Clean rebuild
./scripts/build/clean.sh
./scripts/build/build.sh

# Check Qt
qmake --version
qmake -query
```

### Runtime Issues

```bash
# Debug output
QT_LOGGING_RULES="*.debug=true" ./scripts/build/run.sh

# QML trace
QML_IMPORT_TRACE=1 ./scripts/build/run.sh
```

## 📊 Project Status

| Component | Status |
|-----------|--------|
| Project Structure | ✅ Complete |
| C++ Backend | ✅ Working |
| QML Frontend | ✅ Working |
| Build System | ✅ Working |
| Scripts | ✅ Complete |
| Docker | ✅ Ready |
| Documentation | ✅ Complete |

## 📖 Documentation

- [Project Structure](PROJECT_STRUCTURE.md) - Detailed structure
- [Build Guide](docs/BUILD.md) - Build instructions
- [Architecture](docs/ARCHITECTURE.md) - System design
- [API Documentation](docs/API.md) - VehicleData API

## 👥 Team

**SEA:ME Project** - Software Engineering in Automotive and Mobility Ecosystems

## 📄 License

MIT License

---

**Ready to start?** → `./quick-start.sh` 🚀
