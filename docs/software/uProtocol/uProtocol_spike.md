
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

2.2 CAN-FD: The Enabler for Modern Middleware
CAN with Flexible Data-Rate (CAN-FD), standardized in ISO 11898-1:2015, was developed to address the bandwidth limitations of Classic CAN while maintaining its arbitration robustness. It introduces two critical enhancements that fundamentally alter the viability of running middleware on the bus:

Dual Bit Rates: CAN-FD splits the frame into two phases. The Arbitration Phase (comprising the ID and Control bits) operates at the standard nominal bit rate (e.g., 500 kbps) to ensure arbitration works correctly across the network topology. However, once the arbitration is won, the protocol switches to the Data Phase, where the bit rate is accelerated significantly—typically to 2 Mbps, and potentially up to 5 Mbps or 8 Mbps depending on the transceiver and physical layer quality.

Expanded Payload: CAN-FD supports data fields of up to 64 bytes, an eight-fold increase over Classic CAN.

2.2.1 Efficiency Analysis: The Crossover Point
The transition to CAN-FD alters the overhead dynamics. A CAN-FD frame includes additional control bits (EDL, BRS, ESI) and a larger Cyclic Redundancy Check (CRC) field (17 or 21 bits) to maintain data integrity with larger payloads. Consequently, for very small payloads (e.g., 1-4 bytes), CAN-FD frames are actually longer in terms of bit count than Classic CAN frames if transmitted at the same speed. However, the acceleration of the data phase more than compensates for this in terms of time on the bus.

For payloads exceeding 8 bytes, CAN-FD is drastically more efficient. In Classic CAN, sending 64 bytes of data requires fragmenting the message into at least 9 separate frames (8 frames of 7 bytes + 1 frame of 8 bytes using ISO-TP), each with its own arbitration ID, CRC, and inter-frame spacing. In CAN-FD, this entire payload fits into a single frame. The "breathing room" provided by the 64-byte payload is the critical enabler for middleware like Zenoh and uProtocol. It allows these protocols to include their necessary headers (which can range from 5 to 30 bytes) while still leaving substantial space for the actual application payload, a feat mathematically impossible on Classic CAN.

2.3 The Maintenance Burden: "DBC Hell"
Despite its efficiency, the "Pure CAN" approach (whether Classic or FD) relies on a static definition of data. The mapping of application signals (e.g., "Engine Speed") to specific bits within a specific CAN frame is defined in a DBC (Database CAN) file. This file acts as the contract between all ECUs on the bus.

Managing these DBC files is a significant engineering challenge in the automotive industry.

Tight Coupling: If a sensor supplier updates their firmware to output a 12-bit pressure value instead of 10-bit, the bit packing of the entire CAN frame shifts. This change requires updating the DBC file and subsequently recompiling and reflashing every other ECU on the bus that consumes that frame.

Version Control: In complex supply chains, managing different versions of DBC files across different vehicle variants and model years creates a logistical nightmare often referred to as "DBC Hell." Merging DBC files from different suppliers can lead to ID conflicts and signal overlaps.

Security: The DBC file is static and often confidential. However, reverse-engineering CAN traffic to reconstruct the DBC is a common attack vector.

This maintenance burden is the primary driver for the shift towards Service-Oriented Architectures (SOA), which abstract the communication contract away from static bit positions.

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

5. Middleware Candidate B: Eclipse uProtocol-Lite
Eclipse uProtocol approaches the problem from a different angle. It focuses on standardization and interoperability, aiming to create a ubiquitous language for the Software Defined Vehicle that is independent of the underlying transport.

5.1 The uProtocol Data Model and CloudEvents
uProtocol enforces a strict, rich message structure based on the CloudEvents specification. Every message is a UMessage containing:

UUri (The Address): A hierarchical address consisting of an Authority (device/domain), an Entity (service/process), and a Resource (specific data topic).

UAttributes (The Metadata): A comprehensive set of metadata including a unique message ID (UUID), message type (Publish, Request, Response), priority, time-to-live (TTL), and data format.

Payload: The actual application data.

This rich metadata is the core value proposition of uProtocol. It allows messages to be self-describing and routed intelligently by generic dispatchers anywhere in the cloud-to-edge continuum.

5.2 Serialization: The Cost of Standards
uProtocol-Lite (up-c) typically employs Protocol Buffers (Protobuf) for serializing the attributes and payload. While Protobuf is efficient compared to JSON or XML, it introduces significant overhead compared to raw bit-packing or Zenoh's optimized VLE.

5.2.1 UUri Serialization Analysis
A UUri is not just a string; it is a structured object. Even in the "micro" form used for embedded systems (where string names are replaced by integer IDs), the Protobuf serialization adds weight:

Tag-Length-Value (TLV): Each field in the UUri (Authority ID, Entity ID, Resource ID) is preceded by a tag.

UAttributes: The UUID alone is 16 bytes (if binary) or 36 bytes (if string). Even compressed, the attributes block—containing source, sink, type, and priority—can easily consume 20 to 40 bytes.

5.2.2 Impact on CAN-FD
On a 64-byte CAN-FD frame, a header overhead of ~30 bytes is substantial. It consumes nearly 50% of the available bandwidth.

Fragmentation Necessity: Because the header consumes so much space, even a modest payload (e.g., 40 bytes of sensor data) will push the total message size beyond 64 bytes. This forces the system to use ISO-TP fragmentation for a much larger percentage of traffic than Zenoh or Pure CAN.

Double Serialization: Often, the payload itself is a serialized Protobuf message. This means the ECU burns CPU cycles serializing the payload, then burns more cycles serializing the uProtocol envelope around it.

5.3 Static Allocation and "Lite" Constraints
The embedded C implementation of uProtocol (up-c) relies on NanoPB, a Protobuf library designed for microcontrollers. NanoPB avoids dynamic heap allocation (malloc) by generating C structs with fixed maximum sizes. This is a critical feature for complying with automotive safety standards (ISO 26262), which generally discourage or forbid dynamic allocation in runtime safety paths.

However, defining these fixed sizes can be challenging. Because Protobuf supports optional and repeated fields, the generated structs must be sized for the worst-case scenario, potentially wasting significant RAM compared to the tightly packed buffers of Zenoh or raw CAN.

5.4 The Transport Agnostic Layer (uP-L1)
uProtocol is designed to run over other transports. This architectural layering offers flexibility but introduces complexity.

uProtocol over Zenoh: It is possible to run uProtocol on top of Zenoh. In this case, the UMessage is the payload of the Zenoh message. While this provides the routing benefits of Zenoh, it incurs a "double tax" on overhead: the Zenoh header plus the uProtocol header.

uProtocol over CAN (Native): To run uProtocol directly on CAN, an adapter layer is required. This adapter must map the UUri to CAN IDs (potentially using extended 29-bit IDs) and handle the serialization/deserialization and ISO-TP fragmentation.


6. Comparative Analysis and Synthesis
This section synthesizes the technical data into direct comparisons across critical engineering metrics: Wire Overhead, Latency, Complexity, and Resource Usage.

6.1 Wire Overhead and Bus Utilization (The "Goodput" Metric)
Goodput is defined here as the ratio of useful application payload to the total bits transmitted on the wire.

Metric,Pure CAN-FD,Zenoh-Pico (on CAN-FD),uProtocol-Lite (on CAN-FD)
Header Size,~6 bytes (ID + Control + CRC equiv.),~5 bytes (Steady State),~25 - 40 bytes (Protobuf UAttributes)
Addressing,Flat 29-bit ID,Mapped Integer ID,Hierarchical UUri (Authority/Entity/Resource)
Max Payload,64 bytes,64 bytes (minus header),64 bytes (minus header)
Effective Payload,64 bytes (~100%),~59 bytes (~92%),~24-40 bytes (~40-60%)
Fragmentation,ISO-TP (Manual),Built-in / ISO-TP,ISO-TP (Required Frequently)

Analysis: uProtocol's rich metadata comes at a steep price on CAN-FD. Consuming 40-60% of the frame for headers significantly reduces the effective bandwidth. Zenoh-Pico strikes a highly effective balance, providing modern pub/sub addressing with an overhead that is almost negligible on a 64-byte frame. Pure CAN-FD remains the efficiency king but lacks the semantic richness.

6.2 Latency and Real-Time Determinism
Pure CAN-FD: The gold standard for determinism. Latency is purely a function of frame length and wire speed. A high-priority frame has immediate access. There is zero software processing overhead beyond the driver.

Zenoh-Pico: Adds a thin layer of software processing. The library must traverse its internal routing tables and serialize the header. However, benchmark reports indicate internal latencies of < 10 µs for unicast. On a CAN bus where a frame takes ~200-300 µs to transmit, this CPU overhead is minor. The minimal header size ensures that messages fit in single frames, maintaining determinism.

uProtocol-Lite: Introduces significant latency variance.

Serialization Latency: Protobuf encoding with NanoPB is efficient but still requires iterating over fields and copying data, consuming CPU cycles.

Fragmentation Latency: The high overhead increases the probability of needing ISO-TP. Once ISO-TP is engaged, latency effectively triples (at minimum) due to the FF -> FC -> CF round-trip requirement. If the receiver is slow to send the Flow Control frame, the latency can spike by milliseconds.

Conclusion: For hard real-time control loops (e.g., 100Hz motor control), Pure CAN-FD is the only safe choice. Zenoh-Pico is a viable contender for soft real-time applications (e.g., body control). uProtocol-Lite is best suited for non-time-critical event processing.

6.3 Complexity and Integration Workflow
The "DBC" Workflow (Pure CAN): Highly rigid. Requires sharing and merging large text files. Conflicts are common. Changing a signal is a global event. Secure communication requires add-ons like AUTOSAR SecOC, which adds further complexity.

The "Late Binding" Workflow (Zenoh): Decoupled. Publishers and Subscribers do not need to know about each other at compile time. New nodes can be added to the network to "sniff" data without reconfiguring the transmitter. The dynamic mapping of resources to IDs solves the rigidity of the DBC model.

The "Service Mesh" Workflow (uProtocol): Standardized. It abstracts the network entirely. Developers code against a generated API (publish(UUri)). This reduces application complexity but increases system complexity. The reliance on .proto files provides a strong contract, but managing these schemas across an organization is a governance challenge similar to DBCs, albeit more modern.

6.4 Resource Footprint (CPU/RAM/Flash)
Pure CAN: Negligible.

Zenoh-Pico: Highly optimized. Code size can be stripped down to < 20 KB. RAM usage is static and tunable via macros like BATCH_UNICAST_SIZE. It is designed explicitly to fit on devices where a full DDS stack would be impossible.

uProtocol-Lite: Heavier. The Protobuf generated code, combined with the logic for CloudEvent building and the underlying transport adapter, likely results in a larger footprint than Zenoh. The CPU load for serialization is also higher.
