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

## 2. Qt6 Application CMake Configuration

To correctly configure a Qt project for cross-compilation with the AGL SDK, you need to add several settings to your project's `CMakeLists.txt` file. The following settings are based on using Qt6, which corresponds to the `qtbase` package installed in the AGL image.

### 2.1. CMake Settings

Add the following to your `CMakeLists.txt`:

```cmake
# Directly specifies the location of the host-native tools (like moc, rcc)
# within the SDK's host sysroot. This helps CMake find the right tools for code generation.
set(QT_HOST_PATH "/opt/agl-sdk/20.0.1-aarch64/sysroots/x86_64-aglsdk-linux/usr/bin/qt5")

# Enables automatic invocation of the Qt Meta-Object Compiler, Resource Compiler,
# and UI compiler, which is mandatory for C++/QML integration and resource handling.
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Explicitly lists all required Qt components (e.g., QuickControls2) to force CMake
# to locate them in the SDK's toolchain and sysroot.
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)

# Link against the found libraries.
target_link_libraries(your_target_name PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2)
```

### 2.2. Explanation of CMake Settings

-   **`set(QT_HOST_PATH "...")`**
    -   **Purpose**: Specifies the location of host-native Qt tools (like `moc`, `rcc`, `uic`) required during the build.
    -   **Why it's needed**: This can help prevent configuration failures where CMake cannot find the host tools for code generation.
    -   **Action**: Replace `...` with the actual path to the host tools in your installed SDK. You can typically find this by looking for the `qt6` directory within the `sysroots/x86_64-aglsdk-linux/usr/bin/` directory of your SDK. For example: `/opt/agl-sdk/20.0.1-aarch64/sysroots/x86_64-aglsdk-linux/usr/bin/qt6`.

-   **`CMAKE_AUTOMOC, CMAKE_AUTORCC, CMAKE_AUTOUIC`**
    -   **Purpose**: Enables the automatic invocation of the Meta-Object Compiler (`moc`), Resource Compiler (`rcc`), and User Interface Compiler (`uic`).
    -   **Why it's needed**: This is mandatory for handling Qt's signal and slot mechanism, `.qrc` resource files, and `.ui` files, especially in a cross-compilation environment.

-   **`find_package(Qt6 REQUIRED COMPONENTS ...)`**
    -   **Purpose**: Explicitly lists all required Qt6 components for your project.
    -   **Why it's needed**: This forces CMake to locate and configure the necessary toolchain files for each Qt module you use. It helps prevent "target not found" errors during the build.
    -   **Action**: Replace the component list with the Qt6 modules your application depends on (e.g., `Core`, `Gui`, `Widgets`, `Qml`, `Quick`).

-   **RPATH Handling**: When cross-compiling, it is important to prevent the build system from embedding host-specific library paths (RPATH) into the final binary. The AGL SDK's CMake toolchain file typically handles this automatically. If you encounter runtime errors on the target about missing libraries in host-specific paths (like `/opt/agl-sdk/...`), you may need to explicitly disable RPATH generation in your `CMakeLists.txt` by setting `set(CMAKE_SKIP_INSTALL_RPATH ON)`.
