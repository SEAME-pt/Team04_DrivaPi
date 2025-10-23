# Project Structure

```
seame-hmi/
│
├── 📁 src/                          # Source Code
│   ├── 📁 core/                     # Core application logic
│   │   ├── main.cpp                 # Application entry point
│   │   └── vehicledata.cpp          # Vehicle data model
│   └── 📁 ui/                       # UI-specific code (future)
│
├── 📁 include/                      # Header Files
│   └── vehicledata.h                # Vehicle data header
│
├── 📁 resources/                    # Application Resources
│   ├── 📁 qml/                      # QML files
│   │   └── main.qml                 # Main QML interface
│   ├── 📁 assets/                   # Images and graphics
│   │   ├── 📁 roadSigns/            # Road sign assets
│   │   ├── Car.svg
│   │   ├── InstrumentClusterBase.svg
│   │   └── ... (225 files)
│   ├── 📁 icons/                    # Application icons
│   └── resources.qrc                # Qt resource file
│
├── 📁 scripts/                      # Build & Utility Scripts
│   ├── 📁 build/                    # Build scripts
│   │   ├── build.sh                 # Main build script
│   │   ├── clean.sh                 # Clean build artifacts
│   │   └── run.sh                   # Run application
│   ├── 📁 deploy/                   # Deployment scripts
│   │   ├── docker-build.sh          # Build Docker image
│   │   └── docker-run.sh            # Run Docker container
│   └── 📁 utils/                    # Utility scripts
│
├── 📁 docker/                       # Docker Configuration
│   ├── 📁 production/               # Production build
│   │   └── Dockerfile               # Production Dockerfile
│   ├── 📁 development/              # Development build
│   ├── docker-compose.yml           # Docker Compose config
│   └── .dockerignore                # Docker ignore file
│
├── 📁 docs/                         # Documentation
│   ├── 📁 architecture/             # Architecture docs
│   │   └── README.md
│   ├── 📁 api/                      # API documentation
│   ├── 📁 user-guide/               # User guides
│   └── BUILD.md                     # Build instructions
│
├── 📁 tests/                        # Tests
│   ├── 📁 unit/                     # Unit tests
│   └── 📁 integration/              # Integration tests
│
├── 📁 build/                        # Build Output (generated)
│   ├── 📁 bin/                      # Compiled binaries
│   ├── 📁 obj/                      # Object files
│   ├── 📁 moc/                      # Qt MOC files
│   └── 📁 rcc/                      # Qt RCC files
│
├── seame-hmi.pro                    # Qt project file
├── quick-start.sh                   # Quick start script
├── README.md                        # Project README
├── .gitignore                       # Git ignore file
└── PROJECT_STRUCTURE.md             # This file
```

## Key Directories

### 📂 src/
Contains all C++ source code organized by functionality.

### 📂 include/
Public header files for the project.

### 📂 resources/
All non-code resources (QML, images, assets).

### 📂 scripts/
Automation scripts for building, testing, and deployment.

### 📂 docker/
Docker configuration for containerized builds and deployment.

### 📂 docs/
Project documentation organized by topic.

### 📂 tests/
Automated tests for the project.
