# TraceX

## Overview

TraceX is a graphical debugging and analysis tool developed by Microsoft for Azure RTOS ThreadX. It provides real-time visualization of thread execution, context switches, interrupt handling, and system events. The tool allows developers to monitor thread behavior, identify performance bottlenecks, and debug multi-threaded applications by displaying a timeline view of all system activities.

## How to Use

TraceX captures trace data from a running ThreadX application and displays it in a graphical interface. The basic workflow involves:

1. Instrument your ThreadX application with trace recording macros
2. Run the application and collect trace logs
3. Import the trace file into TraceX
4. Analyze the thread timeline, performance metrics, and system events

## Decision: Not Using TraceX

**We have decided NOT to use TraceX** for this project because:

- **Windows Store Only**: TraceX is exclusively available through the Windows Store and is not supported on Linux
- **Development Environment**: Our development environment is Linux-based, and switching between operating systems for debugging tools would create unnecessary friction and reduce development efficiency
- **Cross-Platform Mismatch**: The overhead of switching between OS environments does not justify the benefits of this tool

Instead, we have chosen **Segger SystemView** for ThreadX application analysis and debugging on our Linux development platform.
