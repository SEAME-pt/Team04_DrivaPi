# Piracer SEA:ME HMI Dashboard - Build System Documentation

## Prerequisites

### Install Qt
```bash
# Install Qt 6 via Homebrew
brew install qt@6

# Add to PATH
echo 'export PATH="/opt/homebrew/opt/qt@6/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify installation
qmake --version
```

## Quick Start

### First Time Setup
```bash
# 1. Clone or navigate to project
cd /Users/melaniereis/SEA:ME/seame-automotive-journey/qt/Qt-HMI-Display-UI-main

# 2. Make scripts executable
chmod +x build.sh clean.sh run.sh rebuild.sh

# 3. Build the project
./build.sh

# 4. Run the application
./run.sh
```

## Build Scripts

### 📦 Build the Project
```bash
./build.sh
```

**Performs:**
- ✅ Checks for required tools (qmake, make)
- 🧹 Cleans previous build artifacts
- 📁 Creates build directory structure
- ⚙️ Generates Makefile from PiracerSeaMe.pro
- 🔨 Compiles the project (uses all CPU cores)
- 📊 Shows build information

### 🧹 Clean Build Artifacts
```bash
./clean.sh
```

**Removes:**
- `build/` directory and all contents
- `.qmake.stash`
- `Makefile`
- All generated files (`*.o`, `moc_*`, `qrc_*`, `ui_*`)
- `.DS_Store` files (macOS)

### ▶️ Run the Application
```bash
./run.sh
```

Launches the compiled SEA:ME HMI Dashboard application.

### 🔄 Rebuild Everything
```bash
./rebuild.sh
```

Performs: clean → build → optional run

## Directory Structure

```
Qt-HMI-Display-UI-main/
├── build/                          # Build output (generated)
│   ├── bin/                       # Compiled application
│   │   └── SEA_ME_HMI_Dashboard.app
│   ├── obj/                       # Object files
│   ├── moc/                       # Meta-Object Compiler files
│   ├── rcc/                       # Resource Compiler files
│   └── ui/                        # UI files
├── assets/                         # Application resources
│   ├── InstrumentClusterBase.svg
│   ├── Car.svg
│   ├── roadSigns/
│   └── ... (other assets)
├── main.cpp                        # Application entry point
├── vehicledata.h                   # Vehicle data model header
├── vehicledata.cpp                 # Vehicle data model implementation
├── main.qml                        # Main UI definition
├── qml.qrc                         # Qt resources file
├── PiracerSeaMe.pro               # Qt project file ⭐
├── build.sh                        # Build script
├── clean.sh                        # Clean script
├── run.sh                          # Run script
├── rebuild.sh                      # Rebuild script
├── .gitignore                      # Git ignore rules
└── BUILD.md                        # This file
```

## Manual Build (Advanced)

If you prefer manual control:

```bash
# Clean
rm -rf build .qmake.stash Makefile

# Create build directories
mkdir -p build/{obj,moc,rcc,ui,bin}

# Generate Makefile
qmake PiracerSeaMe.pro

# Build (use all CPU cores)
make -j$(sysctl -n hw.ncpu)

# Run
./build/bin/SEA_ME_HMI_Dashboard.app/Contents/MacOS/SEA_ME_HMI_Dashboard
```

## Qt Creator Integration

### Using Qt Creator IDE

1. **Install Qt Creator:**
   ```bash
   brew install --cask qt-creator
   ```

2. **Open Project:**
   - Launch Qt Creator
   - `File` → `Open File or Project`
   - Select `PiracerSeaMe.pro`

3. **Configure:**
   - Select your Qt Kit (Qt 6.x for macOS)
   - Choose build configuration (Debug/Release)

4. **Build & Run:**
   - Press `⌘+B` to build
   - Press `⌘+R` to run
   - Or click the green play button ▶️

## Build Configurations

### Debug Build (Default)
```bash
qmake CONFIG+=debug PiracerSeaMe.pro
make
```

**Features:**
- Debug symbols included
- No optimizations
- Easier debugging
- Larger binary size

### Release Build
```bash
qmake CONFIG+=release PiracerSeaMe.pro
make
```

**Features:**
- Optimized code
- No debug symbols
- Smaller binary size
- Better performance

## Application Features

The HMI Dashboard includes:

### ✅ Functional Features
- 🚗 Real-time speed display (0-240 km/h)
- ⚡ Energy consumption monitoring
- 🔋 Battery level indicator
- 📏 Trip distance counter
- ⚙️ Gear selector (P/R/N/D)
- 🌡️ Temperature display
- 🔄 Simulation mode
- 🎮 Interactive controls

### 🎨 UI Elements
- Tesla-style minimalist design
- Smooth animations
- Glow effects
- Responsive indicators
- Dark theme

## Troubleshooting

### qmake not found
```bash
# Check if Qt is installed
brew list | grep qt

# Install if missing
brew install qt@6

# Add to PATH
echo 'export PATH="/opt/homebrew/opt/qt@6/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify
which qmake
```

### Build fails with "Unknown module: core5compat"
The project automatically detects if `core5compat` is available. Update Qt if needed:
```bash
brew upgrade qt@6
```

### Permission denied on scripts
```bash
chmod +x build.sh clean.sh run.sh rebuild.sh
```

### Application doesn't start
```bash
# Check if build was successful
ls -la build/bin/SEA_ME_HMI_Dashboard.app

# Check executable
file build/bin/SEA_ME_HMI_Dashboard.app/Contents/MacOS/SEA_ME_HMI_Dashboard

# Run directly
./build/bin/SEA_ME_HMI_Dashboard.app/Contents/MacOS/SEA_ME_HMI_Dashboard
```

### Qt version mismatch
```bash
# Check installed Qt version
qmake --version

# Check project requirements
grep "QT +=" PiracerSeaMe.pro
```

## Performance Tips

- **Parallel Compilation**: Build script uses all CPU cores (`-j$(sysctl -n hw.ncpu)`)
- **Incremental Builds**: Only modified files recompile after first build
- **Clean Build**: Use `./rebuild.sh` if experiencing issues
- **Release Mode**: Use release build for better performance

## Development Workflow

### Typical Development Cycle

1. **Make changes** to `.cpp`, `.h`, or `.qml` files
2. **Build**: `./build.sh` (incremental)
3. **Test**: `./run.sh`
4. **Debug**: Use Qt Creator or console output
5. **Repeat**

### Full Rebuild (When Needed)
```bash
./rebuild.sh
```

**When to use:**
- After changing `.pro` file
- After updating Qt version
- When experiencing strange build issues
- Before committing to version control

## Project Configuration

### PiracerSeaMe.pro Settings

```pro
TARGET = SEA_ME_HMI_Dashboard    # Application name
VERSION = 1.0.0                   # Version number
QT += quick qml gui               # Qt modules
CONFIG += c++17                   # C++ standard
BUILD_DIR = build                 # Build output directory
```

### Key Directories

- **OBJECTS_DIR**: `build/obj` - Compiled object files
- **MOC_DIR**: `build/moc` - Meta-object compiler output
- **RCC_DIR**: `build/rcc` - Resource compiler output
- **UI_DIR**: `build/ui` - UI compiler output
- **DESTDIR**: `build/bin` - Final application bundle

## Support

For issues or questions:
- Check this documentation
- Review Qt documentation: https://doc.qt.io/
- Check SEA:ME project wiki

## License

Part of the SEA:ME Automotive Journey project.

---

**Author:** Melanie Reis
**Project:** Piracer SEA:ME
**Last Updated:** October 2024
