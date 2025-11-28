Investigate Eclipse uProtocol as the transport layer. Can it replace our custom CAN parsing? Can it run on the STM32 (ThreadX/Bare metal)?


What is uProtocol?
uProtocol is a lightweight protocol for communication between embedded systems. It provides a simple way to serialize and deserialize data structures for transmission over various transport layers, such as CAN, UART, or TCP/IP


outra opção:

zenoh pico:
2.1 Arquitetura do Eclipse Zenoh-Pico
O Zenoh-Pico é a implementação "bare-metal" do protocolo Zenoh. Ao contrário da implementação completa em Rust (zenoh), que assume um sistema operativo com gestão de memória avançada e threads complexas, o Zenoh-Pico foi desenhado para correr em loops infinitos simples ou com RTOS minimalistas (como FreeRTOS ou ThreadX).

2.1.1 O Modelo de Transporte Abstrato
A característica que viabiliza o pedido do utilizador é a abstração da camada de transporte. O Zenoh-Pico não chama socket(), bind() ou connect() diretamente na sua lógica de protocolo. Em vez disso, ele define uma "interface" (um conjunto de ponteiros de função) conhecida como z_transport_ops_t.

Esta estrutura define as operações atómicas que o protocolo necessita:

send: Enviar um bloco de dados opaco para um destino.

recv: Receber dados (seja por polling ou callback).

get_mtu: Consultar o tamanho máximo de transmissão para saber quando fragmentar.

Se o utilizador implementar estas funções utilizando os registos de hardware do controlador CAN do seu microcontrolador (por exemplo, um STM32), o núcleo do Zenoh-Pico não saberá a diferença entre estar a correr sobre um cabo Ethernet de fibra ótica ou um par de cobre CAN.

2.1.2 Eficiência do Protocolo no Cabo (Wire Efficiency)
O Zenoh orgulha-se do seu "Zero Overhead" (ou overhead mínimo). A especificação do protocolo define um cabeçalho mínimo de 4 a 5 bytes para mensagens de dados.

Cabeçalho de Frame: ~1-2 bytes.

Cabeçalho de Mensagem: 1 byte.

ID de Recurso: 1+ bytes (com codificação de comprimento variável).

Esta compactação é crítica para o CAN. Enquanto protocolos como HTTP ou JSON sobre MQTT desperdiçam centenas de bytes em cabeçalhos de texto, o Zenoh é binário e extremamente denso, alinhando-se filosoficamente com a escassez de largura de banda do CAN.

2.2 O Desafio Físico: Controller Area Network (CAN)
O CAN não é apenas um "cabo lento"; é um protocolo fundamentalmente diferente do Ethernet.

2.2.1 Orientado a Mensagens vs. Orientado a Bytes
O TCP/IP e o Serial são orientados a streams de bytes. O CAN é orientado a frames atómicos.

Classic CAN: Máximo de 8 bytes de payload por frame.

CAN-FD (Flexible Data-Rate): Máximo de 64 bytes de payload.

O Zenoh gera mensagens de tamanho variável (ex: 20 bytes para um "Hello World").

Num socket TCP, enviamos 20 bytes e a pilha IP trata da fragmentação.

No CAN, o hardware rejeita qualquer tentativa de enviar 20 bytes num só frame.

Portanto, a implementação do Zenoh sobre CAN exige uma Camada de Adaptação intermédia que transforme o stream de pacotes Zenoh numa sequência de frames CAN.
