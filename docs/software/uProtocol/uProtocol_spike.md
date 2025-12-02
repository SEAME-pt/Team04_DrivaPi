
Investigate Eclipse uProtocol as the transport layer. Can it replace our custom CAN parsing? Can it run on the STM32 (ThreadX/Bare metal)?

Context: Why is the spike needed?
The automotive industry is currently navigating a profound architectural inflection point, transitioning from the traditional, signal-based paradigm that has dominated for three decades toward the Software-Defined Vehicle (SDV). This transition necessitates a re-evaluation of fundamental communication layers, moving away from static, proprietary signal definitions toward standardized, service-oriented architectures (SOA).

Objective:
The primary objective of this investigation was to determine if uProtocol could effectively replace custom Controller Area Network (CAN) parsing logic, thereby decoupling application software from hardware topology. The study followed a strict one-day timebox to review the up-spec core specifications, assess the up-cpp software development kit (SDK) for embedded compatibility (specifically looking for Zenoh and MQTT bindings), prototype a compilation for the STM32 toolchain, and estimate the resulting Resource Access Memory (RAM) and Flash memory footprints.

The Shift from Signal to Service
To understand the gravity of the decision between uProtocol and legacy CAN parsing, one must examine the broader evolution of Electronic Control Units (ECUs). The automotive electrical/electronic (E/E) architecture is migrating from a flat, distributed network of domain controllers to a zonal architecture centered around high-performance compute (HPC) units. In this new world, the microcontroller is no longer just a signal processor; it is a service provider.

Pure CAN and Signal Paradigm
For decades, the automotive industry has relied on Pure CAN networks, where ECUs exchange simple, fixed-format data frames identified only by a CAN ID. The protocol does not define the meaning of the data; instead, each signal’s interpretation (e.g., which bit represents a door status) is stored in external .dbc files. This creates strong dependencies between ECUs—any change in how data is packed requires updates across all receivers. While efficient and real-time, this signal-based model provides no semantic context or metadata, limiting flexibility and scalability.

Eclipse uProtocol and SOA
Eclipse uProtocol represents the antithesis of the signal paradigm. Born from the need to standardize communication between the vehicle and the cloud, uProtocol is a Service-Oriented Architecture (SOA) enabler. It abstracts the transport layer, allowing applications to communicate via standardized messages—specifically CloudEvents—regardless of whether the underlying transport is TCP/IP, Zenoh, MQTT, or CAN.

In a uProtocol-enabled system, an ECU does not "broadcast ID 0x123." Instead, it publishes a message to a Uniform Resource Identifier (URI), such as up://vehicle_vin/body_control_module/door/driver_side. The payload is a structured object (often serialized via Protocol Buffers) that describes the event. The receiving application subscribes to this URI, oblivious to the underlying bus topology. This decoupling allows for dynamic routing, where services can move between ECUs without breaking the communication contract, a capability essential for the SDV era.

Another option:

zenoh-pico:
2.1 Architecture of Eclipse Zenoh-Pico
Zenoh-Pico is the "bare-metal" implementation of the Zenoh protocol. Unlike the full Rust implementation (zenoh), which assumes an operating system with advanced memory management and complex threads, Zenoh-Pico is designed to run in simple infinite loops or on minimal RTOSs (such as FreeRTOS or ThreadX).

2.1.1 The Abstract Transport Model
The feature that makes the user's request viable is the abstraction of the transport layer. Zenoh-Pico does not call socket(), bind() or connect() directly in its protocol logic. Instead, it defines an "interface" (a set of function pointers) known as z_transport_ops_t.

This structure defines the atomic operations that the protocol needs:

- send: Send an opaque block of data to a destination.
- recv: Receive data (either by polling or callback).
- get_mtu: Query the maximum transmission size to know when to fragment.

If the user implements these functions using the hardware registers of their microcontroller's CAN controller (for example, an STM32), the core of Zenoh-Pico will not know the difference between running over a fiber Ethernet cable or a copper CAN pair.

2.1.2 Wire Efficiency of the Protocol
Zenoh prides itself on "zero overhead" (or minimal overhead). The protocol specification defines a minimal header of 4 to 5 bytes for data messages.

- Frame Header: ~1–2 bytes.
- Message Header: 1 byte.
- Resource ID: 1+ bytes (with variable-length encoding).

This compactness is critical for CAN. While protocols like HTTP or JSON over MQTT waste hundreds of bytes in text headers, Zenoh is binary and extremely dense, philosophically aligning with CAN's scarce bandwidth.

2.2 The Physical Challenge: Controller Area Network (CAN)
CAN is not just a "slow cable"; it is fundamentally different from Ethernet.

2.2.1 Message-Oriented vs. Byte-Oriented
TCP/IP and Serial are oriented to byte streams. CAN is oriented to atomic frames.

- Classic CAN: Maximum of 8 bytes of payload per frame.
- CAN-FD (Flexible Data-Rate): Maximum of 64 bytes of payload.

Zenoh produces variable-size messages (for example: 20 bytes for a "Hello World").

On a TCP socket, we send 20 bytes and the IP stack handles fragmentation.

On CAN, the hardware rejects any attempt to send 20 bytes in a single frame.

Therefore, implementing Zenoh over CAN requires an intermediate Adaptation Layer that transforms the stream of Zenoh packets into a sequence of CAN frames.
Portanto, a implementação do Zenoh sobre CAN exige uma Camada de Adaptação intermédia que transforme o stream de pacotes Zenoh numa sequência de frames CAN.

2.1 Classic CAN: The Deterministic Constraint
Developed by Bosch in the 1980s and standardized as ISO 11898-1, Classic CAN is a broadcast bus protocol that uses differential signaling to achieve high noise immunity. Its defining characteristic is its non-destructive bitwise arbitration mechanism. When multiple nodes attempt to transmit simultaneously, the node transmitting a dominant bit ('0') overwrites the recessive bit ('1') on the bus. The node transmitting the recessive bit detects this disparity and immediately ceases transmission, switching to receiving mode. This ensures that the message with the highest priority (lowest arbitration ID) always gains access to the bus without any loss of time or data.

While this mechanism guarantees excellent determinism for high-priority messages, it imposes severe limitations on bandwidth and payload.

Bandwidth: The bit rate is uniform throughout the frame, typically capped at 500 kbps in automotive applications to ensure signal propagation across the length of the bus within a single bit time.

Payload: The Data Length Code (DLC) allows for a maximum payload of only 8 bytes.

Efficiency: A standard CAN frame containing 8 bytes of data consists of roughly 111 to 130 bits, depending on the number of stuff bits inserted for synchronization. This results in a protocol overhead of approximately 40% to 50%. The effective throughput (goodput) is often significantly less than 500 kbps.

The 8-byte payload limit is the primary bottleneck for modern applications. It forces any higher-level protocol attempting to send more than a trivial amount of data—such as a security certificate, a serialized object, or even a complex sensor reading—to engage in fragmentation. This fragmentation is typically handled by the ISO-TP protocol, which introduces significant latency and complexity.
