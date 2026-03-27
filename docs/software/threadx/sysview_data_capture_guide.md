# SystemView Capture Guide

This guide explains, in a simple way:
- What OpenOCD is
- What SystemView is
- What `sysview_data_generate.sh` does
- How to run the script
- How to see the recorded data


## What is OpenOCD?

OpenOCD means **Open On-Chip Debugger**.

It is a tool that lets your computer talk to a microcontroller through a debug probe (like ST-Link). With OpenOCD you can:
- connect to the target
- reset / halt / resume the CPU
- read memory from RAM/flash

In this project, OpenOCD is used to read SystemView trace bytes from RAM.


## What is SystemView?

SEGGER SystemView is a timeline/profiling tool for embedded systems.

It records RTOS and application events such as:
- task switches
- interrupts
- timing and execution behavior

Internally, events are written into an RTT buffer in RAM. This script dumps that buffer after runtime so you can inspect it later.


## What `firmware/sysview_data_generate.sh` script does

The script:
1. Finds the RTT control block address (`_SEGGER_RTT`) from `Debug/firmware.map`.
2. Creates a temporary OpenOCD config script.
3. Connects to the STM32 target.
4. Optionally resets the board (depending on argument 3).
5. Waits for a capture window (argument 2, in ms).
6. Halts the CPU and reads the SEGGER RTT buffer for SystemView (up-channel 1).
7. Handles both cases:
   - data is contiguous
   - data wrapped around in a ring buffer
8. Saves the result as an `.SVDat` file.


## How to run the script

From the `firmware/` folder:

```bash
./sysview_data_generate.sh [output_file] [capture_ms] [reset_target]
```

Examples:

```bash
# Default output name, 5s capture, no reset
./sysview_data_generate.sh

# Custom file, 8s capture, reset before capture
./sysview_data_generate.sh my_trace.SVDat 8000 1
```

Arguments:
- `output_file` (optional): output `.SVDat` file name
- `capture_ms` (optional): capture duration in milliseconds (default `5000`)
- `reset_target` (optional): `1` to reset before capture, `0` otherwise (default `0`)


## How to view the recorded data

1. Open SEGGER SystemView on your computer.
2. Click **File -> Open**.
3. Select the generated `.SVDat` file.
4. Inspect timeline/events (tasks, ISRs, timing).

If the script says `No output file created`, check:
- board and ST-Link connection
- OpenOCD availability
- `Debug/firmware.map` exists (build first)
- `_SEGGER_RTT` symbol is present in the map file
