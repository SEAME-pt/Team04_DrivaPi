#!/usr/bin/env bash
# set -euo pipefail

# Cross-compilation and packaging script for AGL (Automotive Grade Linux)
# Adapted from the native Raspberry Pi build script.

# This script assumes you have the AGL SDK installed at /opt/agl-sdk/
# and that this script is run from a compatible host machine (e.g., x86_64 Linux).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
BINARY_NAME="myqtapp"
AGL_ENV_SETUP_SCRIPT="/opt/agl-sdk/20.0.1-aarch64/environment-setup-aarch64-agl-linux"

# echo "1) Sourcing AGL SDK environment"
# if [ ! -f "${AGL_ENV_SETUP_SCRIPT}" ]; then
#   echo "ERROR: AGL environment setup script not found at ${AGL_ENV_SETUP_SCRIPT}"
#   echo "Please ensure the AGL SDK is installed correctly."
#   exit 1
# fi
# # The sourced script will set up all necessary environment variables for cross-compilation
# # (e.g., CC, CXX, CMAKE_TOOLCHAIN_FILE, SDKTARGETSYSROOT)
source "${AGL_ENV_SETUP_SCRIPT}"


echo "2) Configure & build for AGL"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# With the environment sourced, CMake will automatically use the AGL toolchain
# and find the Qt6 libraries within the SDK's sysroot.
cmake ..
make -j$(nproc)
# cmake --build . --parallel

# The SDKTARGETSYSROOT variable is set by the AGL environment script.
# It points to the root filesystem of the target system.
if [ -z "${SDKTARGETSYSROOT:-}" ]; then
    echo "ERROR: SDKTARGETSYSROOT is not set. The AGL environment script may have failed."
    exit 1
fi
echo "Using target sysroot: ${SDKTARGETSYSROOT}"
# 
# echo "3) Locate system Qt files within the AGL SDK"
# # Find libQt6Core location within the sysroot
# QT_LIB_FILE="$(find "${SDKTARGETSYSROOT}" -type f -name 'libQt6Core.so*' -print -quit 2>/dev/null || true)"
# if [ -z "${QT_LIB_FILE}" ]; then
#   echo "ERROR: libQt6Core.so not found within the SDK sysroot (${SDKTARGETSYSROOT})."
#   exit 1
# fi
# QT_LIB_DIR="$(dirname "${QT_LIB_FILE}")"
# QT_PREFIX_GUESS="$(dirname "${QT_LIB_DIR}")"
# echo "Detected SDK QT_LIB_DIR=${QT_LIB_DIR}"
# echo "Guessed SDK QT_PREFIX=${QT_PREFIX_GUESS}"
# 
# # Detect qml dir within the sysroot
# QT_QML_DIR="$(find "${QT_PREFIX_GUESS}" -type d -name qml -print -quit 2>/dev/null || true)"
# if [ -z "${QT_QML_DIR}" ]; then
#   # Fallback search in the sysroot's /usr directory
#   QT_QML_DIR="$(find "${SDKTARGETSYSROOT}/usr" -type d -name qml -path '*qt*' -print -quit 2>/dev/null || true)"
# fi
# echo "Detected SDK QT_QML_DIR=${QT_QML_DIR:-<none>}"
# 
# # Detect plugins dir within the sysroot
# QT_PLUGINS_DIR="$(find "${QT_PREFIX_GUESS}" -type d -name plugins -print -quit 2>/dev/null || true)"
# if [ -z "${QT_PLUGINS_DIR}" ]; then
#     # Fallback search in the sysroot's /usr directory
#     QT_PLUGINS_DIR="$(find "${SDKTARGETSYSROOT}/usr" -type d -name plugins -path '*qt*' -print -quit 2>/dev/null || true)"
# fi
# echo "Detected SDK QT_PLUGINS_DIR=${QT_PLUGINS_DIR:-<none>}"
# 
# 
# echo "4) Create package folder"
# rm -rf "${PKG_DIR}"
# mkdir -p "${PKG_DIR}/lib" "${PKG_DIR}/qml" "${PKG_DIR}/plugins"
# 
# # Copy built binary
# if [ ! -f "${BUILD_DIR}/${BINARY_NAME}" ]; then
#   echo "ERROR: built binary ${BINARY_NAME} not found in ${BUILD_DIR}"
#   exit 1
# fi
# cp "${BUILD_DIR}/${BINARY_NAME}" "${PKG_DIR}/"
# 
# 
# echo "5) Copy Qt runtime libraries (libQt6*.so*)"
# if [ -n "${QT_LIB_DIR}" ] && [ -d "${QT_LIB_DIR}" ]; then
#   cp -av "${QT_LIB_DIR}"/libQt6*.so* "${PKG_DIR}/lib/"
# else
#   echo "Warning: Qt lib dir not found in SDK; runtime may fail."
# fi
# 
# echo "6) Copy QML modules and plugins"
# if [ -n "${QT_QML_DIR}" ] && [ -d "${QT_QML_DIR}" ]; then
#   rsync -a --delete "${QT_QML_DIR}/" "${PKG_DIR}/qml/"
# else
#   echo "Warning: QML directory not found in SDK; copy QML modules manually if needed."
# fi
# 
# if [ -n "${QT_PLUGINS_DIR}" ] && [ -d "${QT_PLUGINS_DIR}" ]; then
#   rsync -a --delete "${QT_PLUGINS_DIR}/" "${PKG_DIR}/plugins/"
# else
#   echo "Warning: plugins directory not found in SDK; UI platform plugin may be missing."
# fi
# 
# 
# echo "7) Fix binary rpath so it loads libs from ./lib"
# BINARY_PATH="${PKG_DIR}/${BINARY_NAME}"
# if command -v patchelf >/dev/null 2>&1; then
#   patchelf --set-rpath '$ORIGIN/lib' "${BINARY_PATH}"
#   echo "Patchelf set RUNPATH -> $ORIGIN/lib"
# else
#   echo "patchelf not found on host; package will require LD_LIBRARY_PATH to be set on the target"
# fi
# 
# echo
# echo "Cross-compilation complete."
# echo "Package created at: ${PKG_DIR}"
# echo
# echo "To run the packaged app on the AGL target:"
# echo "1. Copy the entire '${PKG_DIR}' directory to the target device."
# echo "2. On the target, navigate into the directory:"
# echo "   cd $(basename "${PKG_DIR}")"
# echo "3. Make the binary executable:"
# echo "   chmod +x ${BINARY_NAME}"
# echo "4. Run the application:"
# echo "   ./${BINARY_NAME}"
# echo
# echo "If it fails with missing libs (and patchelf wasn't used), try:"
# echo "  export LD_LIBRARY_PATH=\`pwd\`/lib:\$LD_LIBRARY_PATH"
# echo "  export QML2_IMPORT_PATH=\`pwd\`/qml"
# echo "  export QT_PLUGIN_PATH=\`pwd\`/plugins:\`pwd\`/lib"
# echo "  ./${BINARY_NAME}"
