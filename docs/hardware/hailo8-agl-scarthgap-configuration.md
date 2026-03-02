# Hailo-8 Configuration for AGL Trout Scarthgap
---

## Overview

This document describes the steps to integrate and configure the Hailo-8 AI accelerator with the Automotive Grade Linux (AGL) Trout distribution using the Scarthgap release. The Hailo-8 provides hardware-accelerated AI inference capabilities for edge computing applications.

---

## Prerequisites

- AGL Trout Scarthgap build environment configured
- Yocto/BitBake build system set up
- Access to Hailo meta-layer repository
- Target hardware with Hailo-8 PCIe module installed

---

## Configuration Steps

### 1. Fetch meta-hailo Layer

Clone the meta-hailo layer using the `hailo8-scarthgap` branch:

```bash
cd <yocto-workspace>/external
git clone <meta-hailo-repo-url> -b hailo8-scarthgap
```

### 2. Add Required Layers to Build Configuration

Add the following layers to your `bblayers.conf`:

```bash
bitbake-layers add-layer ../sources/meta-hailo/meta-accelerator
bitbake-layers add-layer ../sources/meta-hailo/meta-libhailort
```

Or manually edit `conf/bblayers.conf`:

```conf
BBLAYERS += " \
    ${BSPDIR}/sources/meta-hailo/meta-accelerator \
    ${BSPDIR}/sources/meta-hailo/meta-libhailort \
"
```

### 3. Build Hailo Packages

Build the required Hailo components using BitBake:

```bash
# Build the HailoRT library (core runtime)
bitbake libhailort

# Build the Hailo firmware package
bitbake hailo-firmware

# Build the Hailo PCIe driver
bitbake hailo-pci
```

These packages will be included in your AGL image.

### 4. Deploy to Target System

After building your AGL image with the Hailo packages, boot the target system and install the runtime components using DNF (Dandified YUM):

```bash
# On the target AGL system
dnf install libhailort hailo-pci hailortcli
```

**Package Descriptions:**
- **libhailort**: HailoRT shared libraries for AI model inference
- **hailo-pci**: PCIe kernel driver for Hailo-8 hardware
- **hailortcli**: Command-line tools for Hailo device management and testing

### 5. Verify Installation

Check that the Hailo-8 device is detected:

```bash
# Check if kernel module is loaded
lsmod | grep hailo

# Check PCIe device
lspci | grep Hailo

# Verify HailoRT CLI functionality
hailortcli fw-control identify
```

---

## Package Overview

| Package | Description | Type |
|---------|-------------|------|
| `libhailort` | HailoRT runtime library for model inference | Library |
| `hailo-firmware` | Firmware binaries for Hailo-8 accelerator | Firmware |
| `hailo-pci` | PCIe kernel driver for Hailo-8 hardware | Kernel Module |
| `hailortcli` | Command-line interface for device management | CLI Tool |

---

## Troubleshooting

### Driver Not Loading

If the `hailo-pci` module fails to load:

```bash
# Check kernel logs
dmesg | grep -i hailo

# Manually load the module
sudo modprobe hailo_pci
```

### PCIe Device Not Detected

- Verify Hailo-8 is properly seated in PCIe slot
- Check BIOS/UEFI settings for PCIe configuration
- Ensure PCIe slot is enabled and has sufficient power

### HailoRT CLI Errors

If `hailortcli` commands fail:

```bash
# Check device permissions
ls -l /dev/hailo*

# Verify library dependencies
ldd $(which hailortcli)
```
---

## References

- [Hailo-8 Documentation](https://hailo.ai/developer-zone/)
- [meta-hailo Layer Repository](https://github.com/hailo-ai/meta-hailo)

---
