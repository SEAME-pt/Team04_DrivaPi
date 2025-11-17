# Threadx Architecture

This project uses a small real-time, thread-based architecture to control vehicle speed and steering and to exchange data over CAN.

## High-level components
- Threads: each control or communication task runs in its own RTOS thread.
- Queues: used for inter-thread commands (CAN RX → control threads).
- Semaphores / Event Flags: signal new data or commands.
- Mutexes: protect shared state (e.g., sensor values).
- Timers: drive periodic tasks (example: sensor read every 10 ms).

## Threads and responsibilities
1. CAN Receive Thread
   - Waits for incoming CAN messages.
   - Parses message types (e.g., CMD_SPEED → speed control, CMD_STEERING → steering control).
   - Enqueues parsed commands to the appropriate control queue.

2. Speed Control Thread
   - Waits on its command queue.
   - Runs control loop (PWM / PID) to update motor output.

3. Steering Control Thread
   - Waits on its command queue.
   - Updates servo or steering motor driver.

4. Sensor Thread
   - Reads speed sensors (encoder / Hall).
   - Computes velocity and stores it in a mutex-protected shared variable.

5. CAN Transmit Thread
   - Periodically sends sensor/speed/state data over CAN.

6. Supervisor Thread (optional)
   - Safety monitoring, watchdog feeding, diagnostics, fault handling.

## Priorities (lower value = higher priority)
- CAN Receive: 3
- CAN Transmit: 4
- Speed Control: 5
- Steering Control: 6
- Sensor Thread: 7
- Supervisor (optional): 8

## Implementation notes / considerations
- Keep queues bounded and handle overflow deterministically.
- Use priority inheritance on mutexes to reduce priority inversion risks.
- Time-critical control loops should use deterministic timers and avoid blocking on long operations.
- Watchdog and supervisor should detect and recover from stuck threads or missed deadlines.
