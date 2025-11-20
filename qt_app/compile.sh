#!/usr/bin/env bash
set -euo pipefail

# Simple native build + package script for Raspberry Pi
# Run on the Pi: sudo bash build_on_pi.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/myqtapp-build"
PKG_DIR="${SCRIPT_DIR}/myqtapp-package"
BINARY_NAME="myqtapp"

echo "1) Install build tools & Qt dev packages (may prompt)"
apt update
DEPS=(build-essential cmake pkg-config git patchelf)
# add common Qt6 dev packages; some may not exist depending on distro
DEPS+=(qt6-base-dev qt6-declarative-dev qt6-tools-dev)
apt install -y "${DEPS[@]}" || true

echo "2) Configure & build"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"
QT_CMAKE_DIR="$(find /usr/lib -type d -name "cmake" -path "*Qt6*" -print -quit 2>/dev/null)"

if [ -n "$QT_CMAKE_DIR" ]; then
  QT_PREFIX_PATH="$(dirname "$QT_CMAKE_DIR")"
  echo "Detected CMAKE_PREFIX_PATH=$QT_PREFIX_PATH"
  CMAKE_PREFIX_PATH_ARG="-DCMAKE_PREFIX_PATH=${QT_PREFIX_PATH}"
else
  echo "Warning: Could not auto-detect Qt6 CMake path; you may need to set -DCMAKE_PREFIX_PATH manually."
  CMAKE_PREFIX_PATH_ARG=""
fi

cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . --parallel

echo "3) Locate system Qt files (qml, libs, plugins)"
# find libQt6Core location
QT_LIB_FILE="$(find /usr -type f -name 'libQt6Core.so*' -print -quit 2>/dev/null || true)"
if [ -z "${QT_LIB_FILE}" ]; then
  echo "ERROR: libQt6Core.so not found under /usr. If Qt is installed in a custom location, set QT_PREFIX and re-run."
  exit 1
fi
QT_LIB_DIR="$(dirname "${QT_LIB_FILE}")"
QT_PREFIX="$(dirname "${QT_LIB_DIR}")"
echo "Detected QT_LIB_DIR=${QT_LIB_DIR}"
echo "Detected QT_PREFIX=${QT_PREFIX}"

# detect qml dir (common locations)
QT_QML_DIR="$(find "${QT_PREFIX}" -type d -name qml -print -quit 2>/dev/null || true)"
if [ -z "${QT_QML_DIR}" ]; then
  QT_QML_DIR="$(find /usr -type d -name qml -path '*qt*' -print -quit 2>/dev/null || true)"
fi
echo "Detected QT_QML_DIR=${QT_QML_DIR:-<none>}"

# plugins dir candidates
if [ -d "${QT_PREFIX}/plugins" ]; then
  QT_PLUGINS_DIR="${QT_PREFIX}/plugins"
elif [ -d "${QT_PREFIX}/lib/plugins" ]; then
  QT_PLUGINS_DIR="${QT_PREFIX}/lib/plugins"
else
  QT_PLUGINS_DIR="$(find /usr -type d -name plugins -path '*qt*' -print -quit 2>/dev/null || true)"
fi
echo "Detected QT_PLUGINS_DIR=${QT_PLUGINS_DIR:-<none>}"

echo "4) Create package folder"
rm -rf "${PKG_DIR}"
mkdir -p "${PKG_DIR}/lib" "${PKG_DIR}/qml" "${PKG_DIR}/plugins" "${PKG_DIR}/lib/fonts"

# copy built binary
if [ ! -f "${BUILD_DIR}/${BINARY_NAME}" ]; then
  # try Release subdir
  if [ -f "${BUILD_DIR}/Release/${BINARY_NAME}" ]; then
    cp "${BUILD_DIR}/Release/${BINARY_NAME}" "${PKG_DIR}/"
  else
    echo "ERROR: built binary ${BINARY_NAME} not found in ${BUILD_DIR}"
    exit 1
  fi
else
  cp "${BUILD_DIR}/${BINARY_NAME}" "${PKG_DIR}/"
fi

echo "5) Copy Qt runtime libraries (libQt6*.so*)"
# copy all libQt6*.so* from detected lib dir
if [ -n "${QT_LIB_DIR}" ] && [ -d "${QT_LIB_DIR}" ]; then
  (cd "${QT_LIB_DIR}" && cp -av libQt6*.so* "${PKG_DIR}/lib/" 2>/dev/null || true)
else
  echo "Warning: Qt lib dir not found; runtime may fail."
fi

echo "6) Copy QML modules and plugins"
if [ -n "${QT_QML_DIR}" ] && [ -d "${QT_QML_DIR}" ]; then
  rsync -a --delete "${QT_QML_DIR}/" "${PKG_DIR}/qml/"
else
  echo "Warning: QML directory not found; copy QML modules manually if needed."
fi

if [ -n "${QT_PLUGINS_DIR}" ] && [ -d "${QT_PLUGINS_DIR}" ]; then
  rsync -a --delete "${QT_PLUGINS_DIR}/" "${PKG_DIR}/plugins/"
else
  echo "Warning: plugins directory not found; UI platform plugin may be missing."
fi

echo "7) Copy fonts (optional) from system to avoid font warnings"
# try some standard font locations
if [ -d /usr/share/fonts/truetype/dejavu ]; then
  cp -av /usr/share/fonts/truetype/dejavu/* "${PKG_DIR}/lib/fonts/" || true
fi

echo "8) (Optional) copy other needed shared libs referenced by the binary"
# copy libs from ldd that come from /usr/lib or same prefix (skip kernel libc/ld)
BINARY_PATH="${PKG_DIR}/${BINARY_NAME}"
ldd "${BINARY_PATH}" | awk '/=>/ {print $(NF)}' | while read -r lib; do
  [ -z "$lib" ] && continue
  # only copy libs under /usr or under detected qt prefix (avoid copying libc/ld-linux)
  case "$lib" in
    /usr/*|/lib/*|${QT_PREFIX}/*)
      dest="${PKG_DIR}/lib/$(basename "$lib")"
      if [ ! -e "$dest" ]; then
        cp -av --preserve=links "$lib" "${PKG_DIR}/lib/" 2>/dev/null || true
      fi
    ;;
  esac
done

echo "9) Ensure plugin loader libs are present (libQt6Core already copied)."
# ensure plugin loader / qtprivate libs: copy any libQt6* in QT_LIB_DIR not copied yet
if [ -d "${QT_LIB_DIR:-}" ]; then
  for f in "${QT_LIB_DIR}"/libQt6*.so*; do
    [ -e "$f" ] || continue
    cp -av --preserve=links "$f" "${PKG_DIR}/lib/" 2>/dev/null || true
  done
fi

echo "10) Fix binary rpath so it loads libs from ./lib"
if command -v patchelf >/dev/null 2>&1; then
  patchelf --set-rpath '$ORIGIN/lib' "${BINARY_PATH}"
  echo "Patchelf set RUNPATH -> \$ORIGIN/lib"
else
  echo "patchelf not installed; package will require LD_LIBRARY_PATH set to ./lib when running"
fi

echo "Package created at: ${PKG_DIR}"
echo
echo "To run the packaged app:"
echo "  cd ${PKG_DIR}"
echo "  ./$(basename "${BINARY_PATH}")"
echo
echo "If it fails with missing libs, try:"
echo "  export LD_LIBRARY_PATH=\$(pwd)/lib:\$LD_LIBRARY_PATH"
echo "  export QML2_IMPORT_PATH=\$(pwd)/qml"
echo "  export QT_PLUGIN_PATH=\$(pwd)/plugins:\$(pwd)/lib"
echo "  ./$(basename "${BINARY_PATH}")"
