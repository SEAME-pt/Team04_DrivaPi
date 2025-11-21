# Setting Up Qt Creator for AGL Cross-Compilation with CMake and Qt6

This document provides a step-by-step guide to configure the Qt Creator IDE for cross-compiling **Qt6 applications using CMake** for an Automotive Grade Linux (AGL) image running on a Raspberry Pi 5.

This guide focuses on configuring the Qt Creator IDE. For instructions on how to build an AGL image and the required SDK with Qt6, please refer to `Qt_AGL_Cross_Compilation.md`.

## Prerequisites

-   **Qt Creator Installed**: A functional version of Qt Creator on your host machine.
-   **AGL Cross-SDK Installed**: The AGL cross-sdk is installed on your host system. For this guide, we will assume it is located in `/opt/agl-sdk/`.
-   **SDK Environment Sourced**: You have opened a terminal and sourced the environment setup script provided by your AGL SDK. This script exports critical environment variables (e.g., `$CC`, `$CXX`, `$SDKTARGETSYSROOT`, and `$CMAKE_TOOLCHAIN_FILE`) that Qt Creator needs. The exact path depends on your SDK version. **It is recommended to launch Qt Creator from this terminal** to ensure it inherits the environment.
    ```bash
    # Example for an aarch64 target (Raspberry Pi 5)
    source /opt/agl-sdk/20.0.1-aarch64/environment-setup-aarch64-agl-linux
    qtcreator &
    ```
-   **Target Device IP**: The IP address of your Raspberry Pi 5 running AGL.
-   **SSH Access**: Secure Shell access to the target device is confirmed and working.

## Step 1: Configure Compilers (C and C++)

First, point Qt Creator to the cross-compilers provided by the AGL SDK. After sourcing the SDK environment script, the paths to the compilers are available in the `$CC` and `$CXX` environment variables.

1.  Navigate to **Tools > Options > Kits > Compilers**.
2.  Click **Add**, select **GCC**, and then choose **C**.
3.  Configure the C compiler:
    -   **Name**: Give it a clear name (e.g., `AGL RPi5 GCC C`).
    -   **Compiler Path**: Enter the full path to the C cross-compiler. You can find this by running `echo $CC` in your sourced terminal.
    -   *Example Path*: `/opt/agl-sdk/20.0.1-aarch64/sysroots/x86_64-aglsdk-linux/usr/bin/aarch64-agl-linux/aarch64-agl-linux-gcc`
4.  Click **Apply**.
5.  Click **Add**, select **GCC**, and then choose **C++**.
6.  Configure the C++ compiler:
    -   **Name**: Give it a clear name (e.g., `AGL RPi5 GCC C++`).
    -   **Compiler Path**: Enter the full path to the C++ cross-compiler (`echo $CXX`).
    -   *Example Path*: `/opt/agl-sdk/20.0.1-aarch64/sysroots/x86_64-aglsdk-linux/usr/bin/aarch64-agl-linux/aarch64-agl-linux-g++`
7.  Click **Apply**.

## Step 2: Configure the Debugger

Add the cross-platform GDB debugger from the SDK. The path is available in the `$GDB` environment variable.

1.  Navigate to **Tools > Options > Kits > Debuggers**.
2.  Click **Add**.
3.  Configure the debugger:
    -   **Name**: Give it a clear name (e.g., `AGL RPi5 GDB`).
    -   **Path**: Enter the full path to the GDB debugger from the SDK (`echo $GDB`).
    -   *Example Path*: `/opt/agl-sdk/20.0.1-aarch64/sysroots/x86_64-aglsdk-linux/usr/bin/aarch64-agl-linux/aarch64-agl-linux-gdb`
4.  Click **Apply**.

## Step 3: Configure the Device (Target Connection)

Set up the SSH connection to your target device for deployment and debugging.

1.  Navigate to **Tools > Options > Devices**.
2.  Click **Add...** and select **Generic Linux Device**.
3.  Click **Start Wizard**.
4.  Configure the device connection:
    -   **Device Name**: Give it a clear name (e.g., `AGL RPi5`).
    -   **Host Name**: Enter the IP address of your target board.
    -   **Authentication**: Select `Password` or `Key` based on your device's SSH setup.
    -   **Username**: Enter the login username (e.g., `root`).
5.  Click **Next** and then **Finish**.
6.  Click the **Test** button to verify the connection. You should see a "Device test successful" message.
7.  Click **OK**.

## Step 4: Create the Cross-Compilation Kit

Finally, create a "Kit" that bundles all the previous components together. This configuration is for a **CMake-based Qt6 project**.

1.  Navigate to **Tools > Options > Kits**.
2.  Click **Add**.
3.  Configure the kit:
    -   **Name**: Give it a descriptive name (e.g., `AGL RPi5 CMake Qt6`).
    -   **Device type**: Select `Generic Linux Device`.
    -   **Device**: Select the device you configured in Step 3 (e.g., `AGL RPi5`).
    -   **Sysroot**: **This is a critical step.** Set this to the target's sysroot directory within your SDK. The path is available in the `$SDKTARGETSYSROOT` environment variable.
        -   *Example Path*: `/opt/agl-sdk/20.0.1-aarch64/sysroots/aarch64-agl-linux`
    -   **Compiler C**: Select the C compiler from Step 1 (e.g., `AGL RPi5 GCC C`).
    -   **Compiler C++**: Select the C++ compiler from Step 1 (e.g., `AGL RPi5 GCC C++`).
    -   **Debugger**: Select the debugger from Step 2 (e.g., `AGL RPi5 GDB`).
    -   **Qt version**: For CMake projects, this is not strictly required for building, but it is highly recommended for the code editor to provide correct auto-completion and syntax highlighting. If you have a host installation of Qt6, you can select it here. Otherwise, leave it as `None`. The actual Qt libraries used for compilation will be determined by the CMake toolchain file.
    -   **CMake Toolchain**: **This is the most important setting for CMake.**
        -   Set this to the CMake toolchain file provided by the AGL SDK. If you launched Qt Creator from the sourced environment script, it may be pre-filled. Otherwise, find the path by running `echo $CMAKE_TOOLCHAIN_FILE` in your terminal.
        -   *Example Path*: `/opt/agl-sdk/20.0.1-aarch64/sysroots/x86_64-aglsdk-linux/usr/share/oecore-sdk/toolchain-helpers.cmake`. **Note:** The exact path can vary; always verify it with `echo $CMAKE_TOOLCHAIN_FILE`.
4.  Click **OK** to save all changes.

## Step 5: Configure your CMake Project

With the kit configured, you can now open your Qt6 CMake project.

1.  Open your `CMakeLists.txt` file in Qt Creator.
2.  When prompted to configure the project, select your newly created kit (e.g., `AGL RPi5 CMake Qt6`).
3.  Ensure your `CMakeLists.txt` is correctly set up to find the Qt6 packages. The AGL toolchain file will instruct CMake to locate the libraries and headers within the SDK's sysroot.

A minimal configuration in your `CMakeLists.txt` should include:
```cmake
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

You can now build, deploy, and debug your application directly on the target device using the configured kit.