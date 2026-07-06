# V2P Emergency Vehicle System: Latency Testing Documentation

## 1. Overview
This document outlines the methodology and implementation details for testing the end-to-end communication latency between an STM32-based Emergency Vehicle node and a Pedestrian Mobile Application. The test measures the **Round Trip Time (RTT)** of MQTT messages sent over a local Wi-Fi network to evaluate the responsiveness of the Vehicle-to-Pedestrian (V2P) alert system.

## 2. Testing Methodology
To accurately measure latency, we perform a **Round Trip Time (RTT) Ping-Pong test**:
1. The **STM32 (Vehicle)** records the exact system time and publishes a `ping` message containing this timestamp to the MQTT broker.
2. The **Mobile App (Pedestrian)** subscribes to the `ping` topic. Upon receiving the message, it immediately extracts the timestamp payload and publishes it back to a `pong` topic.
3. The **STM32** receives the `pong` message, checks the current system time, and calculates the difference between the stop time and the start time. This difference is the RTT in milliseconds.

## 3. STM32 Implementation (Vehicle Node)

The STM32 acts as the initiator of the latency test. The critical components for latency measurement are the transmission loop, the network yield function, and the receive callback.

### 3.1 Sending the Ping
In the main thread, the STM32 continuously sends a ping every second. It captures the RTOS system tick (`tx_time_get()`) and sends it as a string payload.

```c
// Payload generation
uint32_t start_time = tx_time_get();
sprintf(payload, "%lu", start_time);

// Publishing to latency/ping
int rc = MQTTPublish(&client, "latency/ping", &msg);
```

### 3.2 Yielding the Thread
After publishing, the system must yield to allow the underlying network stack to receive incoming MQTT packets. The `safe_mqtt_yield` function is wrapped in a Mutex to ensure thread-safe operations over the Wi-Fi API while waiting for the Pong response.

```c
// Yielding for 100ms to process incoming messages
rc = safe_mqtt_yield(&client, 100);
```

### 3.3 The Pong Callback & RTT Calculation
When the Mobile App responds, the MQTT client triggers `latency_pong_callback`. Here, the system records the `stop_time`, parses the `start_time` from the payload, and calculates the RTT. The result is printed via UART for data collection.

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
        // Convert OS ticks to milliseconds
        uint32_t rtt_ms = (delta_ticks * 1000) / TX_TIMER_TICKS_PER_SECOND;
        
        // Output raw ms data to UART
        UartPrintf("%lu", rtt_ms);
    }
}
```

## 4. Mobile App Implementation (Pedestrian Node)

The React Native mobile application uses the `paho-mqtt` library. Its role in the latency test is purely reflective—it acts as an echo server to minimize processing overhead on the mobile side.

Inside the `client.onMessageArrived` event handler, the app checks if the incoming message is on the `latency/ping` topic. If so, it takes the exact payload (the STM32's timestamp) and immediately publishes it back to `latency/pong`.

```javascript
client.onMessageArrived = (message) => {
    const topic = message.destinationName;
    const payload = message.payloadString;

    // Round Trip Time (RTT) Logic
    if (topic === 'latency/ping') {
        // Prepare the response (Pong) with the same timestamp
        const pongMessage = new Message(payload);
        pongMessage.destinationName = 'latency/pong';
        
        // Send back to the broker
        client.send(pongMessage);
    } 
    // ... (Emergency UI trigger logic omitted for brevity)
};
```

## 5. Data Collection Command

To perform statistical analysis on the latency, we capture exactly 100 RTT measurements from the STM32's UART serial output and save them directly to a text file for further mathematical evaluation.

The following command is used on the host machine:

```bash
minicom -b 115200 -D /dev/ttyACM0 | head -100 > rtt_results.txt
```

---

## 6. Conclusions & Statistical Analysis

**Metrics calculated from `serial_output.txt`:**
* **Total Samples:** 100
* **Average Latency (Mean RTT):** 139.80 ms
* **Minimum Latency:** 10 ms
* **Maximum Latency:** 800 ms
* **Jitter (Variance):** 21741.96 ms² *(Standard Deviation: 147.45 ms | Network Jitter: 148.08 ms)*

**Analysis:**
* **Packet Delivery & Loss:** All 100 packets were successfully captured and recorded. This represents a 100% packet delivery rate (0% packet loss), meaning the transmission medium is reliable in terms of data integrity, though highly unstable in timing.
* **Latency Spikes:** The dataset shows severe and unpredictable latency spikes. Although the hardware is capable of a very fast minimum response time of 10 ms, the maximum latency reaches an extreme peak of 800 ms. Out of the 100 collected samples, 14% of the packets (14 samples) suffer from high delays ≥ 300 ms, which pulls the overall average RTT up to 139.80 ms.
* **Emergency Application Suitability:** **No, this latency profile is completely unacceptable for a critical emergency application.** Safety-critical systems require highly predictable, stable, and low-latency communication (typically consistently under 50 ms to 100 ms). 
* **Jitter Impact:** The exceptionally high variance (21741.96 ms²) and an average step-to-step network jitter of 148.08 ms indicate that the arrival time of data is highly unstable. A massive delay like 800 ms could mean the difference between a successful emergency shutdown and a catastrophic system failure. 
* **Recommendations:** Before deploying, you must investigate the root cause of these periodic spikes. Common reasons include:
  1. Microcontroller blocking loops (e.g., using `delay()` instead of non-blocking timers).
  2. Wi-Fi or network congestion if the MQTT broker is remote.
  3. Misconfigured MQTT QoS (Quality of Service) levels causing heavy acknowledgment overhead.
  4. Serial port buffer delays or reading bottlenecks.