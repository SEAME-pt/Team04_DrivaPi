# Test Validation Procedure: CAN vs. KUKSA Latency

## 1. Objective

To empirically compare the end-to-end latency and data integrity of:

1. **Legacy Path:** Direct CAN Bus (vcan0) $\rightarrow$ Qt Application.
2. **Modern Path:** CAN Bus (vcan0) $\rightarrow$ KUKSA Provider $\rightarrow$ Databroker $\rightarrow$ Qt Application.


## 2. Prerequisites

* **OS:** Linux (Ubuntu/Debian recommended)
* **Dependencies:** Docker, Python 3, `can-utils`, `c++`
* **Network:** `vcan0` interface must be active.
```bash
sudo modprobe vcan
sudo ip link add dev vcan0 type vcan
sudo ip link set up vcan0

```



---

## 3. Infrastructure Setup (KUKSA Environment)

Before running tests, the middleware stack (Broker + Feeder) must be running.

### 3.1 Start the KUKSA Databroker

Run the databroker in a Docker container exposing port 55555.

```bash
sudo docker run -it -p 55555:55555 --name kuksa-databroker ghcr.io/eclipse/kuksa.val/databroker:latest

```

### 3.2 Configure the CAN Provider

Clone the provider repository and prepare the configuration files to map CAN ID `0x100` to `Vehicle.Speed`.

```bash
# 1. Get the provider code
git clone https://github.com/eclipse-kuksa/kuksa-can-provider.git
cd kuksa-can-provider

# 2. Install dependencies (best inside a venv)
pip3 install -r requirements.txt

# 3. Create the DBC Database (simple.dbc)
echo 'VERSION ""
NS_ :
BS_:
BU_: Receiver
BO_ 256 SpeedMessage: 4 Receiver
 SG_ Speed : 0|32@1+ (3.6,0) [0|0] "km/h" Receiver
SIG_VALTYPE_ 256 Speed : 1;' > simple.dbc

# 4. Create the Mapping Configuration (mapping.json)
# CRITICAL: "interval_ms": 0 forces "Event-Driven" mode (no throttling)
echo '{
    "Vehicle.Speed": {
        "datatype": "float",
        "type": "sensor",
        "description": "Vehicle Speed",
        "dbc2vss": {
            "signal": "Speed",
            "interval_ms": 0,
            "transform": { "math": "x" }
        }
    }
}' > mapping.json

```

### 3.3 Start the CAN Feeder

Connect the `vcan0` interface to the Databroker using the created configs.

```bash
python3 dbcfeeder.py --canport vcan0 --dbcfile simple.dbc --mapping mapping.json

```

---

The "Test Validation Procedure" below has been updated to reflect the specific repository you used (`eclipse-kuksa/kuksa-can-provider`).

**Correction:** The `kuksa-can-provider` repository **is** the Python-based provider (formerly known as `dbc2val` or `dbcfeeder`). It is **not** Rust-based (that's the Databroker). Therefore, your use of `python3 dbcfeeder.py` and `mapping.json` is perfectly correct for this repo.

Here is the finalized document using `c++` for compilation and the correct repo structure.

---

## 4. Test Execution

### 4.1 Preparation: Compile Tools

Compile the C++ test tools using the standard `c++` command.

```bash
c++ latency_sender.cpp -o latency_sender
c++ latency_analyzer.cpp -o latency_analyzer

```

### 4.2 Test Case A: Direct CAN (Baseline)

Run the application in "Direct CAN" mode to capture baseline performance.

1. **Start Receiver (Background):**
```bash
# Directs output to latency_received_can_1000.txt
./myqtapp > ../../docs/data_transfer/KUKSA/latency/latency_received_can_1000.txt 2>&1 &

```


2. **Start Sender:**
```bash
# Generates 1000 CAN frames on vcan0 and redirects output to latency_sent_can.txt
./latency_sender > latency_sent_can.txt
```


### 4.3 Test Case B: KUKSA Databroker (Target)

Run the application in "KUKSA Client" mode (`-k or -kuksa` flag) to validate the new architecture.

1. **Start Receiver (Background):**
```bash
# Directs output to latency_received_kuksa_1000.txt
./myqtapp -k > ../../docs/data_transfer/KUKSA/latency/latency_received_kuksa_1000.txt 2>&1 &

```


2. **Start Sender:**
```bash
# Generates 1000 CAN frames (Feeder -> Broker -> App)and redirects output to latency_sent_kuksa.txt
./latency_sender > latency_sent_kuksa.txt

```

---

## 5. Validation & Analysis

Run the custom analyzer to correlate timestamps and generate CSV reports.

### 5.1 Run Analysis

```bash
# Analyze Baseline (Direct CAN)
./latency_analyzer latency_sent_can.txt latency_received_can_1000.txt

# Analyze Target (KUKSA)
./latency_analyzer latency_sent_kuksa.txt latency_received_kuksa_1000.txt

```

### 5.2 Verify Output Metrics

Inspect the generated CSV files to confirm the fix.

```bash
# Check Baseline
cat latency_received_can_1000.txt_analise.csv

# Check KUKSA 
cat latency_received_kuksa_1000.txt_analise.csv

```

---

## 6. Pass/Fail Criteria

The test is considered **PASSED** if:
1. The average latency for the KUKSA path is below **16 ms**.
2. No packet loss is observed (100% of sent messages are received).

Note: You might see negative latencies due to clock synchronization issues; these should be minimal and not affect the overall average significantly.

---

