# V2P Emergency Vehicle System: Latency Testing Documentation

## 1. Overview

This document outlines the methodology and implementation used to measure the end-to-end communication latency between an STM32-based Emergency Vehicle node and a Pedestrian Mobile Application. The evaluation measures the **Round Trip Time (RTT)** of MQTT messages transmitted over a local Wi-Fi network to assess the responsiveness of the Vehicle-to-Pedestrian (V2P) alert system.

---

## 2. Testing Methodology

To accurately measure communication latency, a **Round Trip Time (RTT) Ping-Pong test** is performed:

1. The **STM32 (Vehicle Node)** records the current RTOS system tick and publishes a `ping` message containing this timestamp to the MQTT broker.
2. The **Mobile Application (Pedestrian Node)** subscribes to the `latency/ping` topic. Upon receiving the message, it immediately extracts the timestamp from the payload and republishes the same payload to the `latency/pong` topic.
3. The **STM32** receives the `pong` message, records the current system tick, and computes the difference between the reception time and the original transmission time. This difference represents the RTT in milliseconds.

---

## 3. STM32 Implementation (Vehicle Node)

The STM32 acts as the initiator of the latency test. The key components involved in the latency measurement are the transmission loop, the MQTT yield function, and the receive callback.

### 3.1 Sending the Ping

Within the main thread, the STM32 publishes a ping message every second. Before transmission, it records the current RTOS system tick (`tx_time_get()`) and sends it as a string payload.

```c
// Payload generation
uint32_t start_time = tx_time_get();
sprintf(payload, "%lu", start_time);

// Publishing to latency/ping
int rc = MQTTPublish(&client, "latency/ping", &msg);
```

### 3.2 Yielding the Thread

After publishing, the application must yield execution so that the MQTT client and underlying network stack can process incoming packets. The `safe_mqtt_yield()` function is protected by a mutex to ensure thread-safe access to the Wi-Fi API while waiting for the corresponding Pong response.

```c
// Yield for 100 ms to process incoming MQTT packets
rc = safe_mqtt_yield(&client, 100);
```

### 3.3 Pong Callback and RTT Calculation

When the Mobile Application responds, the MQTT client invokes `latency_pong_callback()`. The callback records the reception time (`stop_time`), extracts the original transmission timestamp from the payload, computes the RTT, converts it to milliseconds, and outputs the result through UART for later analysis.

```c
void latency_pong_callback(MessageData* data)
{
    uint32_t stop_time = tx_time_get();

    // Extract original start time from payload
    char payload[64] = {0};
    int len = (data->message->payloadlen > 63) ? 63 : data->message->payloadlen;
    memcpy(payload, data->message->payload, len);
    uint32_t start_time = (uint32_t)strtoul(payload, NULL, 10);

    if (start_time > 0 && stop_time >= start_time)
    {
        uint32_t delta_ticks = stop_time - start_time;

        // Convert RTOS ticks to milliseconds
        uint32_t rtt_ms = (delta_ticks * 1000) / TX_TIMER_TICKS_PER_SECOND;

        // Output RTT value over UART
        UartPrintf("%lu", rtt_ms);
    }
}
```

---

## 4. Mobile Application Implementation (Pedestrian Node)

The React Native mobile application uses the `paho-mqtt` library. During the latency test, its role is intentionally minimal, acting as an MQTT echo server to reduce processing overhead on the mobile device.

Within the `client.onMessageArrived` callback, the application checks whether the received message belongs to the `latency/ping` topic. If so, it immediately republishes the same payload to the `latency/pong` topic without modification.

```javascript
client.onMessageArrived = (message) => {
    const topic = message.destinationName;
    const payload = message.payloadString;

    // Round Trip Time (RTT) logic
    if (topic === 'latency/ping') {

        // Create the Pong response using the original timestamp
        const pongMessage = new Message(payload);
        pongMessage.destinationName = 'latency/pong';

        // Send the response back to the broker
        client.send(pongMessage);
    }

    // Emergency UI logic omitted for brevity
};
```

---

## 5. Data Collection

To perform statistical analysis, 100 RTT measurements are collected from the STM32 UART output and stored in a text file for subsequent processing.

The following command is executed on the host machine:

```bash
minicom -b 115200 -D /dev/ttyACM0 | head -100 > latency_output
```

---

# 6. Results and Statistical Analysis

### Measured RTT Statistics

- **Total Samples:** 100
- **Average RTT (Mean):** 139.80 ms
- **Minimum RTT:** 10 ms
- **Maximum RTT:** 800 ms
- **Variance:** 21,741.96 ms²
- **Standard Deviation:** 147.45 ms
- **Average Network Jitter:** 148.08 ms

## Analysis

### Packet Delivery

All 100 transmitted packets were successfully received and recorded, resulting in a **100% packet delivery rate** and **0% packet loss**. This indicates that the communication channel is reliable in terms of successful message delivery, although its timing performance is highly variable.

### Latency Distribution

The measured RTT values exhibit significant latency spikes. Although the minimum observed RTT is only **10 ms**, demonstrating that the system is capable of fast communication under favorable conditions, the maximum RTT reaches **800 ms**. Furthermore, **14 out of the 100 samples (14%)** experienced delays of **300 ms or greater**, substantially increasing the overall average RTT to **139.80 ms**.

### Jitter

The communication exhibits considerable timing instability. The measured variance (**21,741.96 ms²**) and standard deviation (**147.45 ms**) indicate a wide spread in RTT values, while the average network jitter of **148.08 ms** shows that consecutive packet delays fluctuate significantly. These results suggest that, although message delivery is reliable, the timing consistency of the Wi-Fi network is poor, leading to unpredictable communication delays.