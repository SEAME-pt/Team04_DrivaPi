# AGL Build Documentation

This document provides instructions for setting up the Automotive Grade Linux (AGL) build environment and building an AGL image. The documentation is based on the provided notes and configuration files.

## 1. Setup and Prerequisites

This section describes the initial steps to prepare your host machine and download the AGL source code.

### 1.1. Host System Prerequisites

The build was executed on a Linux host (Ubuntu 20.04) meeting the Yocto Project's minimum requirements for a large distribution:

*   **Disk Space:** Minimum 100 GB free disk space for source, build artifacts, and downloads (sstate-cache).
*   **RAM:** 16 GB or greater to optimize parallel compilation performance (BB_NUMBER_THREADS, PARALLEL_MAKE).
*   **Packages:** Standard Yocto dependencies (git, python3, wget, tar, curl, repo).

### 1.2. Download AGL Source Code

Once you have determined the build host can build an AGL image, you need to download the AGL source files. The AGL source files, which includes the Yocto Project layers, are maintained on the AGL Gerrit server.

The remainder of this section provides steps on how to download the AGL source files:

1.  **Define Your Top-Level Directory**: You can define an environment variable as your top-level AGL workspace folder. Following is an example that defines the `$HOME/workspace_agl` folder using an environment variable named "AGL_TOP":

    ```bash
    export AGL_TOP=$HOME/AGL
    echo 'export AGL_TOP=$HOME/AGL' >> $HOME/.bashrc
    mkdir -p $AGL_TOP
    ```

2.  **Download the `repo` Tool and Set Permissions**: AGL Uses the `repo` tool for managing repositories. Use the following commands to download the tool and then set its permissions to allow for execution:

    ```bash
    mkdir -p $HOME/bin
    export PATH=$HOME/bin:$PATH
    echo 'export PATH=$HOME/bin:$PATH' >> $HOME/.bashrc
    curl https://storage.googleapis.com/git-repo-downloads/repo > $HOME/bin/repo
    chmod a+x $HOME/bin/repo
    ```

3.  **Download the AGL Source Files**: Depending on your development goals, you can either download the latest stable AGL release branch, or the "cutting-edge" (i.e. "master" branch) files.

    *   **Stable Release (trout):** Using the latest stable release gives you a solid snapshot of the latest know release. The release is static, tested, and known to work. To download the latest stable release branch, use the following commands:

        ```bash
        cd $AGL_TOP
        mkdir trout
        cd trout
        repo init -b trout -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo
        repo sync
        ```

## 2. Build Configuration (local.conf)

The `local.conf` file is the central point for configuring the AGL build. The following is a summary of the key configurations used in this build, based on the provided `local.conf` and `agl_doc_raw_notes.txt`.

After downloading the sources, you need to initialize the build environment. This is done by sourcing the `aglsetup.sh` script.

```bash
source meta-agl/scripts/aglsetup.sh -m raspberrypi5 agl-all-features agl-devel agl-ic
```

This script will create the `build` directory and the `conf/local.conf` file. The following are the customizations that were made to the `local.conf` file.

### 2.1. Core Configuration

*   **Machine:** The target machine for the build is set to `raspberrypi5`.
    ```
    MACHINE = "raspberrypi5"
    ```
*   **Distribution:** The AGL distribution is used.
    ```
    DISTRO = "poky-agl"
    ```
*   **Download and SState Cache:** To speed up the build process, the download and sstate directories are shared.
    ```
    SSTATE_DIR ?= "${AGL_TOP}/sstate-cache"
    DL_DIR ?= "${AGL_TOP}/downloads"
    ```

### 2.2. Image Features

The following features are included in the build configuration:

*   **`agl-all-features`**: This is a meta-feature that includes a comprehensive set of AGL features for a rich in-vehicle experience.
*   **`agl-devel`**: This feature includes development and debugging tools in the image, which is useful for on-target development.
*   **`agl-ic`**: This feature provides the necessary components for an Instrument Cluster display.

### 2.3. Raspberry Pi 5 Specific Configuration

*   **U-Boot:** The build is configured to use U-Boot for the Raspberry Pi 5.
    ```
    RPI_USE_U_BOOT = "1"
    ```
*   **Overlays:** An extra overlay for a DSI display is added.
    ```
    RPI_EXTRA_OVERLAYS += "vc4-kms-dsi-waveshare-panel"
    ```

## 3. Building the Image

After configuring the `local.conf` file, you can proceed with the build.

To build the AGL image, use the `bitbake` command. The target for this build is `agl-image-minimal-crosssdk`.

```bash
bitbake agl-image-minimal-crosssdk
```

The output of the build will be located in the `tmp/deploy/images/raspberrypi5/` directory.
