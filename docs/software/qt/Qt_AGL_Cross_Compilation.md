# Cross-Compiling Qt Applications for Automotive Grade Linux (AGL)

This guide provides instructions for configuring an Automotive Grade Linux (AGL) build environment to support the cross-compilation of Qt applications. It covers modifications to the AGL image and SDK, as well as the necessary CMake configurations for a Qt project.

**Note:** This document is a continuation of the general AGL setup documentation. It is recommended to familiarize yourself with the other AGL documents first.

## 1. AGL Image and SDK Configuration

To cross-compile Qt applications, you need to ensure that the AGL image and the corresponding SDK contain all the necessary Qt libraries and tools.

### 1.1. Modify `local.conf`

Add the following line to your `conf/local.conf` file. This will include the required Qt modules in your AGL image.

```conf
# Add all necessary Qt modules for a graphical application
IMAGE_INSTALL:append = " qtbase qtbase-dev qtbase-tools qtquick3d qtapplicationmanager qtconnectivity qtdeclarative qtdeviceutilities qtsensors qttools qtwayland kernel_modules"
```

This change ensures that all the Qt libraries, headers, and tools are present in the root filesystem of the target image and within the SDK, which is essential for both compiling and running the application.

### 1.2. Build the Image and SDK

After modifying your configuration, you must rebuild your AGL image and then generate the SDK.

1.  **Build the updated image**: This step incorporates the newly added Qt packages into your AGL image.
    ```bash
    bitbake agl-image-minimal-crosssdk
    ```

2.  **Generate the SDK installer**: This creates a full Software Development Kit (SDK) that includes the cross-compilation toolchain and all the libraries from your image.
    ```bash
    bitbake agl-image-minimal-crosssdk -c populate_sdk
    ```

After the build completes, you will find the SDK installer in `tmp/deploy/sdk/`. Install it on your development machine.

## 2. Qt Application CMake Configuration

To correctly configure a Qt project for cross-compilation with the AGL SDK, you need to add several settings to your project's `CMakeLists.txt` file. Below are the required settings and an explanation for each.

### 2.1. CMake Settings

Add the following to your `CMakeLists.txt`:

```cmake
# Directly specifies the location of the host-native tools (like moc, rcc, qmlcachegen)
# within the SDK's x86_64 sysroot. This bypasses a common SDK configuration failure
# where these tools cannot be found.
set(QT_HOST_PATH "...")

# Prevents CMake from embedding absolute host paths (/opt/agl-sdk/...) into the
# target binary's runtime library path, which causes runtime errors on the target.
set(Qt6_NO_COMPILE_IN_RPATH 1)

# Enables automatic invocation of the Qt Meta-Object Compiler and Resource Compiler,
# which is mandatory for C++/QML integration and resource handling in
# cross-compilation contexts.
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Explicitly lists all required Qt components (e.g., QuickControls2) to force CMake
# to locate and configure their respective toolchain files, preventing "target not
# found" errors.
find_package(Qt6 REQUIRED COMPONENTS ...)
```

### 2.2. Explanation of CMake Settings

-   **`set(QT_HOST_PATH "...")`**
    -   **Purpose**: Specifies the location of host-native Qt tools (like `moc`, `rcc`, `qmlcachegen`) required during the build.
    -   **Why it's needed**: This bypasses a common SDK configuration failure where CMake cannot find the host tools for code generation.
    -   **Action**: Replace `...` with the actual path to the host tools in your installed SDK. For example: `/opt/agl-sdk/VERSION/sysroots/x86_64-pokysdk-linux/usr/bin`.

-   **`set(Qt6_NO_COMPILE_IN_RPATH 1)`**
    -   **Purpose**: Prevents CMake from embedding absolute host paths (e.g., `/opt/agl-sdk/...`) into the target binary's runtime library path (RPATH).
    -   **Why it's needed**: If host paths are embedded in the binary, the application will fail to launch on the target device because it will search for libraries in paths that do not exist on the target.

-   **`set(CMAKE_AUTOMOC ON)` and `set(CMAKE_AUTORCC ON)`**
    -   **Purpose**: Enables the automatic invocation of the Qt Meta-Object Compiler (`moc`) and Resource Compiler (`rcc`).
    -   **Why it's needed**: This is mandatory for handling Qt-specific features like the signal and slot mechanism (C++/QML integration) and for embedding resources (e.g., QML files, images) into the application binary. This is particularly important in a cross-compilation environment.

-   **`find_package(Qt6 REQUIRED COMPONENTS ...)`**
    -   **Purpose**: Explicitly lists all required Qt components for your project.
    -   **Why it's needed**: This forces CMake to locate and configure the necessary toolchain files for each Qt module you use. It helps prevent "target not found" errors during the build.
    -   **Action**: Replace `...` with a list of all Qt6 components your application depends on (e.g., `Quick`, `QuickControls2`, `Svg`).
