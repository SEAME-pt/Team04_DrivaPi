# Setting Up Qt Creator for AGL Cross-Compilation

This document provides a step-by-step guide to configure the Qt Creator IDE for cross-compiling applications for an Automotive Grade Linux (AGL) image running on a Raspberry Pi 5.

This guide focuses on configuring the Qt Creator IDE. For instructions on how to build an AGL image and the required SDK, please refer to `Qt_AGL_Cross_Compilation.md` and `AGL_Cross_Compilation.md`.

## Prerequisites

-   **Qt Creator Installed**: A functional version of Qt Creator on your host machine.
-   **AGL Cross-SDK Installed**: The AGL cross-sdk is installed on your host system. For this guide, we will assume it is located in `/opt/agl-sdk/`.
-   **SDK Environment Sourced**: You have opened a terminal and sourced the environment setup script provided by your AGL SDK. The exact path depends on your SDK version.
    ```bash
    # Example for an aarch64 target (Raspberry Pi 5)
    source /opt/agl-sdk/20.0.1-aarch64/environment-setup-aarch64-agl-linux
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

## Step 2: Configure the Qt Version (qmake)

Next, tell Qt Creator where to find the `qmake` executable for the target. This `qmake` is part of the SDK's host sysroot, not the target's.

1.  Navigate to **Tools > Options > Kits > Qt Versions**.
2.  Click **Add...**.
3.  Select the `qmake` binary located in the SDK's host sysroot.
    -   *Example Path*: `/opt/agl-sdk/20.0.1-aarch64/sysroots/x86_64-aglsdk-linux/usr/bin/qt5/qmake`
4.  Qt Creator should automatically detect the version. Give it a descriptive name (e.g., `Qt 5.15.2 (AGL RPi5)`).
5.  Click **Apply**.

## Step 3: Configure the Debugger

Add the cross-platform GDB debugger from the SDK. The path is available in the `$GDB` environment variable.

1.  Navigate to **Tools > Options > Kits > Debuggers**.
2.  Click **Add**.
3.  Configure the debugger:
    -   **Name**: Give it a clear name (e.g., `AGL RPi5 GDB`).
    -   **Path**: Enter the full path to the GDB debugger from the SDK (`echo $GDB`).
    -   *Example Path*: `/opt/agl-sdk/20.0.1-aarch64/sysroots/x86_64-aglsdk-linux/usr/bin/aarch64-agl-linux/aarch64-agl-linux-gdb`
4.  Click **Apply**.

## Step 4: Configure the Device (Target Connection)

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

## Step 5: Create the Cross-Compilation Kit

Finally, create a "Kit" that bundles all the previous components together.

1.  Navigate to **Tools > Options > Kits**.
2.  Click **Add**.
3.  Configure the kit:
    -   **Name**: Give it a descriptive name (e.g., `AGL RPi5 Cross-Compile`).
    -   **Device type**: Select `Generic Linux Device`.
    -   **Device**: Select the device you configured in Step 4 (e.g., `AGL RPi5`).
    -   **Sysroot**: **This is a critical step.** Set this to the target's sysroot directory within your SDK. The path is available in the `$SDKTARGETSYSROOT` environment variable.
        -   *Example Path*: `/opt/agl-sdk/20.0.1-aarch64/sysroots/aarch64-agl-linux`
    -   **Compiler C**: Select the C compiler from Step 1 (e.g., `AGL RPi5 GCC C`).
    -   **Compiler C++**: Select the C++ compiler from Step 1 (e.g., `AGL RPi5 GCC C++`).
    -   **Debugger**: Select the debugger from Step 3 (e.g., `AGL RPi5 GDB`).
    -   **Qt version**: Select the Qt version from Step 2 (e.g., `Qt 5.15.2 (AGL RPi5)`).
    -   **Qt mkspec**: Leave this empty if sysroot is set correctly.
4.  Click **OK** to save all changes.

You can now select the new kit when creating or configuring a project to build, deploy, and debug your application directly on the target device.
