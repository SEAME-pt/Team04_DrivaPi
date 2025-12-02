
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

3. The Transport Layer Challenge: ISO-TP and Fragmentation
Before evaluating higher-level middleware, it is essential to understand the mechanism used to transport messages that exceed the physical frame limit. In the automotive domain, this is almost exclusively handled by ISO-TP (ISO 15765-2).

3.1 Mechanics of ISO-TP
ISO-TP is a transport protocol defined for diagnostic and data communication over CAN. It handles segmentation, flow control, and reassembly of messages up to 4095 bytes (or larger in newer revisions). When a message payload exceeds the CAN frame capacity (8 bytes for Classic, 64 for FD), ISO-TP engages a multi-frame transmission sequence:

First Frame (FF): The sender transmits a frame containing the first chunk of data and the total length of the message.

Flow Control (FC): The receiver responds with a Flow Control frame. This frame tells the sender two critical parameters:

Block Size (BS): How many consecutive frames can be sent before waiting for another FC.

Separation Time (STmin): The minimum time gap the sender must wait between consecutive frames to avoid overflowing the receiver's buffer.

Consecutive Frames (CF): The sender transmits the remaining data in chunks, adhering to the flow control parameters.

3.2 The Latency and Throughput Penalty
While ISO-TP enables large messages, it introduces significant overhead and latency, primarily due to the Flow Control mechanism.

Round-Trip Delay: After sending the First Frame, the transmitter must stop and wait for the receiver to process the interrupt, parse the header, check its buffers, and transmit the Flow Control frame. On a loaded bus or a slow MCU, this turnaround time can be several milliseconds. During this time, the transmission logic is blocked.

Protocol Overhead: ISO-TP consumes Protocol Control Information (PCI) bytes within the CAN payload. In Classic CAN, a Consecutive Frame carries only 7 bytes of data (1 byte for PCI). This 12.5% overhead on payload capacity further degrades throughput.

Hardware Limitations: While some advanced CAN controllers have hardware support for ISO-TP (handling FC transmission automatically), many embedded implementations rely on software stacks, which are subject to scheduling jitter and interrupt latency.

Implication for Middleware: Middleware frameworks like uProtocol-Lite that rely on heavy serialization formats (like Protobuf) often produce messages that exceed the 64-byte limit of CAN-FD headers. Consequently, they become heavily dependent on ISO-TP. If the ISO-TP implementation is inefficient, the performance of the middleware collapses, regardless of the theoretical bus speed. In contrast, middleware that can fit its protocol units within a single frame (like Zenoh-Pico often can) avoids the ISO-TP penalty entirely.

CUs run for hours, this amortized cost is negligible.

On a 64-byte CAN-FD frame, a 5-byte overhead implies that 59 bytes are available for user payload. This allows Zenoh to carry significant application data (e.g., a batch of 10-12 float sensor readings) in a single, atomic frame, completely bypassing the need for ISO-TP fragmentation for many use cases.

4.3 Fragmentation and Batching
Zenoh implements its own fragmentation layer. If a message exceeds the interface MTU, Zenoh splits it. Crucially, Zenoh's fragmentation is designed to work end-to-end across the routing fabric, whereas ISO-TP is strictly point-to-point.

Batching: Zenoh-Pico supports automatic and manual batching. This is a powerful feature for CAN. Multiple small updates (e.g., "Door Locked," "Window Up," "Mirror Folded") can be aggregated into a single CAN-FD frame. This shared overhead model drastically improves bus utilization compared to sending three separate frames.

Optimization: Recent updates to Zenoh-Pico have optimized the handling of large payloads by removing byte-by-byte serialization in favor of zero-copy buffer operations, resulting in massive throughput improvements for fragmented messages.

4.4 Performance Characteristics
Benchmarks on embedded platforms (ESP32, STM32) demonstrate Zenoh-Pico's high performance:

Throughput: It can process over 2.5 million messages per second for small payloads on capable hardware. On CAN-FD, the bottleneck will invariably be the bus bandwidth (2-5 Mbps), not the Zenoh stack processing.

Latency: End-to-end latency over fast links is reported as low as 15-45 microseconds. More importantly, the introduction of Peer-to-Peer Unicast has reduced latency by up to 70% compared to routed client modes, making it suitable for direct ECU-to-ECU communication.

Memory Footprint: Zenoh-Pico is highly configurable. A minimal build can fit in less than 15KB of Flash, with RAM usage tunable via configuration parameters like BATCH_UNICAST_SIZE and FRAG_MAX_SIZE.

