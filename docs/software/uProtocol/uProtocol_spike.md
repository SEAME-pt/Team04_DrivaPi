
Investigate Eclipse uProtocol as the transport layer. Can it replace our custom CAN parsing? Can it run on the STM32 (ThreadX/Bare metal)?

Context: Why is the spike needed?
The automotive industry is currently navigating a profound architectural inflection point, transitioning from the traditional, signal-based paradigm that has dominated for three decades toward the Software-Defined Vehicle (SDV). This transition necessitates a re-evaluation of fundamental communication layers, moving away from static, proprietary signal definitions toward standardized, service-oriented architectures (SOA).

Objective:
The primary objective of this investigation was to determine if uProtocol could effectively replace custom Controller Area Network (CAN) parsing logic, thereby decoupling application software from hardware topology. The study followed a strict one-day timebox to review the up-spec core specifications, assess the up-cpp software development kit (SDK) for embedded compatibility (specifically looking for Zenoh and MQTT bindings), prototype a compilation for the STM32 toolchain, and estimate the resulting Resource Access Memory (RAM) and Flash memory footprints.


What is uProtocol?
uProtocol is a lightweight protocol for communication between embedded systems. It provides a simple way to serialize and deserialize data structures for transmission over various transport layers, such as CAN, UART, or TCP/IP.

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
