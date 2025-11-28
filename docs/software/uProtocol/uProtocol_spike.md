Investigate Eclipse uProtocol as the transport layer. Can it replace our custom CAN parsing? Can it run on the STM32 (ThreadX/Bare metal)?


What is uProtocol?
uProtocol is a lightweight protocol for communication between embedded systems. It provides a simple way to serialize and deserialize data structures for transmission over various transport layers, such as CAN, UART, or TCP/IP


outra opção:

zenoh pico:
O Zenoh-Pico é a implementação "bare-metal" do protocolo Zenoh. Ao contrário da implementação completa em Rust (zenoh), que assume um sistema operativo com gestão de memória avançada e threads complexas, o Zenoh-Pico foi desenhado para correr em loops infinitos simples ou com RTOS minimalistas (como FreeRTOS ou ThreadX).

