## Organizing & Optimizing Qt

---

The Qt application is the user interface for our KUKSA system, allowing users to interact with the CAN feeder and visualize data. To ensure that the application is efficient, maintainable, and scalable, we need to organize our codebase effectively and optimize performance.


This file will quantify the steps taken to organize and optimize the Qt application, including code structure, resource management, and performance enhancements.

Additionally, it will disclose exactly what was changed and where, providing a clear roadmap of the improvements made to the Qt application. This will help in understanding the rationale behind main changes and how it contributed to the overall functionality and user experience of the application.


---


### KUKSA mTLS Upgrade

**Problem:** The original implementation of the KUKSA CAN feeder did not support mutual TLS (mTLS), sending/receiving such data over a network, with no encryption, is a considerable security risk.


mTLS essential for secure communication between the client and server.
The upgrade involved implementing mTLS to ensure that both parties authenticate each other, enhancing security. A guide to changes is avaiable [here](tls_implementation.md).



### _ClusterScreen.qml_ UI Thread Optimization

**Problem:** The UI thread was handling most of the calculations, reducing performance. As per the Qt best practices, it should only be responsible for rendering and user interactions, while heavy computations should be offloaded to the C++ backend.


Removed `odometerUpdateTimer` physics engine and the antipattern `Connections` block from `ClusterScreen.qml`.
Replaced procedural JavaScript polling with native C++ declarative bindings.



### _main.cpp_ Switch

```
while (!feeder::g_stopRequested.load()) {
    can_frame frame;
[...]
switch (can_id) {
case can::ID_SPEED:
handlers::HandleSpeed(frame, publisher);
break;
case can::ID_STM32_BATTERY:
handlers::HandleStm32Battery(frame, publisher);
break;
case can::ID_RPI_BATTERY:
handlers::HandleRpiBattery(frame, publisher);
break;
case can::ID_GEAR:
handlers::HandleGear(frame, publisher);
break;
case can::ID_ENV:
handlers::HandleEnv(frame, publisher);
break;
```

**Problem:** Lines 62 through 80 are forcing the Pi 5's CPU to linearly evaluate every incoming CAN frame against five different conditions.
Also, the code anticipates Extended CAN frames (29-bit IDs via CAN_EFF_FLAG). If an extended frame comes in, its ID could be massive (up to 536 million) and segfault the app.

