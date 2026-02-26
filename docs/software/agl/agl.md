# Project Resume: Automotive Grade Linux (AGL) Custom Image Build
**Target: Raspberry Pi 5 - Trout Release**

## I. Executive Summary

This report summarizes the successful build and configuration of a custom Automotive Grade Linux (AGL) distribution image based on the Trout (v20.0.1) branch.
The process leveraged the Yocto Project/OpenEmbedded framework to cross-compile the complete software stack for the Raspberry Pi 5 architecture (aarch64).
The resultant image incorporates minimal features.

---

## II. Build Methodology and Environment

The core methodology is based on the AGL and Yocto Project workflow, ensuring a reproducible and standardized build.

### A. Host System Prerequisites

The build was executed on a Linux host (Ubuntu 20.04) meeting the Yocto Project's minimum requirements for a large distribution:

* **Disk Space:** Minimum 100 GB free disk space for source, build artifacts, and downloads (sstate-cache).
* **RAM:** 16 GB or greater to optimize parallel compilation performance (BB_NUMBER_THREADS, PARALLEL_MAKE).
* **Packages:** Standard Yocto dependencies (git, python3, wget, tar, curl, repo).

### B. Source Acquisition and Branch Synchronization

The AGL source code was retrieved using the `repo` tool, specifying the stable Trout branch, which aligns with Yocto Kirkstone/Langdale.

* **Repository Initialization:** The build environment was initialized, pointing to the Trout manifest: `repo init -b <branch name> -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo`
* **Source Synchronization:** All necessary meta-layers (including poky, meta-agl, and critical hardware layers like meta-raspberrypi were synchronized locally: `repo sync`

---

## III. Configuration for Raspberry Pi 5

The build required explicit configuration to target the Raspberry Pi 5 hardware and enable the specified feature sets.

### A. Environment and Machine Setup

The `aglsetup.sh` script automated the creation of the build directory, incorporating all required AGL layers and the specific hardware support layer (meta-raspberrypi).
The machine type and target features were defined at this step:

```bash
source meta-agl/scripts/aglsetup.sh -m raspberrypi5 agl-all-features agl-devel

### B. Kernel Configuration and Real-Time Considerations

The AGL build for Raspberry Pi 5 currently does not include PREEMPT_RT (Preemptible Real-Time Kernel) patches. This decision was primarily due to two main factors:

*   **Kernel Version Incompatibility:** At the time of development, PREEMPT_RT patches were not readily available or stable for the specific kernel version utilized in the Raspberry Pi 5 AGL build. Integrating unsupported patches could lead to system instability and complex debugging challenges.
*   **Lack of Yocto/meta-raspberrypi Support:** The Yocto Project's `meta-raspberrypi` layer, which provides board-specific configurations for the Raspberry Pi, did not offer official or stable support for PREEMPT_RT on the Raspberry Pi 5. Developing and maintaining custom real-time kernel configurations within the Yocto framework for an unsupported platform would introduce significant overhead and deviate from the project's scope.

Therefore, to ensure system stability, maintainability, and to adhere to the existing Yocto ecosystem support for Raspberry Pi 5, PREEMPT_RT was intentionally excluded from this custom AGL image. Integration of real-time capabilities would require dedicated effort to align with kernel and Yocto support advancements for the Raspberry Pi 5. As a pragmatic alternative, threading mechanisms within the AGL application layer are being utilized to manage concurrent tasks and simulate real-time behavior where possible.
