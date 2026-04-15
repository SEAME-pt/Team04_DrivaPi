#!/usr/bin/env bash
set -euo pipefail

MODULE_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$MODULE_DIR/../../.." && pwd)"
BUILD_DIR="$MODULE_DIR/build"
OUT_C="$ROOT_DIR/firmware/Core/Src/ultrasonic_module_image.c"

mkdir -p "$BUILD_DIR"
rm -f "$BUILD_DIR"/*

CC=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy
NM=arm-none-eabi-nm

THREADX_BASE="$ROOT_DIR/firmware/Middlewares/ST/threadx"

INCLUDES=(
  -I"$ROOT_DIR/firmware/Core/Inc"
  -I"$THREADX_BASE/common/inc"
  -I"$THREADX_BASE/common_modules/inc"
  -I"$THREADX_BASE/ports/cortex_m33/gnu/inc"
  -I"$THREADX_BASE/ports_module/cortex_m33/gnu/inc"
)

CFLAGS=(
  -mcpu=cortex-m33
  -mthumb
  -mfpu=fpv5-sp-d16
  -mfloat-abi=hard
  -O2
  -g0
  -ffunction-sections
  -fdata-sections
  -fno-exceptions
  -fno-unwind-tables
  -fno-asynchronous-unwind-tables
  -fPIC
  -msingle-pic-base
  -mpic-register=r9
  -mno-pic-data-is-text-relative
  -DTXM_MODULE
)

ASFLAGS=(
  -mcpu=cortex-m33
  -mthumb
  -mfpu=fpv5-sp-d16
  -mfloat-abi=hard
  -x assembler-with-cpp
)

MODULE_SRCS=(
  "$MODULE_DIR/ultrasonic_module.c"
  "$THREADX_BASE/common_modules/module_lib/src/txm_module_application_request.c"
  "$THREADX_BASE/common_modules/module_lib/src/txm_module_callback_request_thread_entry.c"
  "$THREADX_BASE/common_modules/module_lib/src/txm_queue_receive.c"
  "$THREADX_BASE/common_modules/module_lib/src/txm_thread_resume.c"
  "$THREADX_BASE/common_modules/module_lib/src/txm_thread_sleep.c"
  "$THREADX_BASE/common_modules/module_lib/src/txm_module_thread_system_suspend.c"
  "$THREADX_BASE/ports_module/cortex_m33/gnu/module_lib/src/txm_module_thread_shell_entry.c"
)

for src in "${MODULE_SRCS[@]}"; do
  obj="$BUILD_DIR/$(basename "${src%.*}").o"
  "$CC" "${CFLAGS[@]}" "${INCLUDES[@]}" -c "$src" -o "$obj"
done

"$CC" "${ASFLAGS[@]}" "${INCLUDES[@]}" -c "$MODULE_DIR/gcc_setup.s" -o "$BUILD_DIR/gcc_setup.o"
"$CC" "${ASFLAGS[@]}" "${INCLUDES[@]}" -c "$MODULE_DIR/txm_module_preamble.S" -o "$BUILD_DIR/txm_module_preamble.o"

"$CC" -nostdlib -Wl,--gc-sections -Wl,-Map,"$BUILD_DIR/ultrasonic_module.map" \
  -T"$MODULE_DIR/ultrasonic_module.ld" \
  -o "$BUILD_DIR/ultrasonic_module.elf" \
  "$BUILD_DIR"/*.o

"$NM" "$BUILD_DIR/ultrasonic_module.elf" > "$BUILD_DIR/ultrasonic_module.nm"
"$OBJCOPY" -O binary "$BUILD_DIR/ultrasonic_module.elf" "$BUILD_DIR/ultrasonic_module.bin"

python3 - <<'PY' "$BUILD_DIR/ultrasonic_module.bin" "$OUT_C"
import pathlib
import sys

bin_path = pathlib.Path(sys.argv[1])
out_path = pathlib.Path(sys.argv[2])
raw = bin_path.read_bytes()

lines = []
lines.append('#include "ultrasonic_module_image.h"')
lines.append('')
lines.append('__attribute__((aligned(32)))')
lines.append('const UCHAR g_ultrasonic_module_image[] = {')
for i, b in enumerate(raw):
    if i % 12 == 0:
        lines.append('    ')
    lines[-1] += f'0x{b:02X}u,'
lines.append('};')
lines.append('')
lines.append(f'const ULONG g_ultrasonic_module_image_size = {len(raw)}u;')
out_path.write_text('\n'.join(lines) + '\n', encoding='ascii')
PY

echo "Built ultrasonic module image: $OUT_C"
