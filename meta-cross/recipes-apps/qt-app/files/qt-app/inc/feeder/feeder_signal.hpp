#pragma once

#include <atomic>
#include <vector>
#include <unistd.h>

namespace feeder {

/**
 * @brief Global stop flag set by signal handlers
 * @note Thread-safe atomic; read-checked in main loop
 */
extern std::atomic<bool> g_stop_requested;

/**
 * @brief Install signal handlers for graceful shutdown (SIGINT, SIGTERM, SIGCHLD)
 * @note Call once during startup
 */
void InstallSignalHandlers();

/**
 * @brief Register a child process PID for managed shutdown
 * @param pid Process ID to track
 * @note Safe to call from signal handlers (uses no locking)
 */
void RegisterChildPid(pid_t pid);

/**
 * @brief Gracefully terminate all registered child processes
 * @note Call during shutdown; uses SIGTERM then SIGKILL with timeout
 */
void KillRegisteredChildren();

} // namespace feeder
