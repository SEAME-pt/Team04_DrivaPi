import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root
    
    // ====== MAIN LAYOUT ======
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // ====== HEADER ======
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: AppTheme.colors.surfaceElevated
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: AppTheme.spacing.large
                anchors.rightMargin: AppTheme.spacing.large
                spacing: AppTheme.spacing.medium
                
                Text {
                    text: "System Diagnostics"
                    font.pixelSize: AppTheme.typography.headlineSmall
                    font.weight: Font.Bold
                    color: AppTheme.colors.text
                }
                
                Item { Layout.fillWidth: true }
                
                // System time
                Text {
                    id: systemTime
                    text: Qt.formatDateTime(new Date(), "hh:mm:ss")
                    font.pixelSize: AppTheme.typography.labelMedium
                    color: AppTheme.colors.textSecondary
                    
                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: systemTime.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
                    }
                }
            }
        }
        
        // ====== SCROLLABLE CONTENT ======
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: diagnosticsContent.height
            clip: true
            
            ColumnLayout {
                id: diagnosticsContent
                width: parent.width
                spacing: AppTheme.spacing.small
                
                // ====== RASPBERRY PI 5 ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/cpu.svg"
                    title: "Raspberry Pi 5"
                    status: "Operational"
                    statusColor: AppTheme.colors.online
                    metrics: [
                        {label: "CPU Temp", value: (systemStatus.cpuUsage || 0) + "°C", warning: (systemStatus.cpuUsage || 0) > 70},
                        {label: "CPU Usage", value: (systemStatus.cpuUsage || 0) + "%", warning: (systemStatus.cpuUsage || 0) > 80},
                        {label: "Memory", value: (systemStatus.memoryUsage || 0) + "%", warning: (systemStatus.memoryUsage || 0) > 85},
                        {label: "Voltage", value: "5.1 V", warning: false},
                        {label: "Throttled", value: "No", warning: false},
                        {label: "Uptime", value: "2h 34m", warning: false}
                    ]
                }
                
                // ====== STM32 MICROCONTROLLER ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/mcu.svg"
                    title: "STM32U585 MCU"
                    status: "Connected"
                    statusColor: AppTheme.colors.online
                    metrics: [
                        {label: "Firmware", value: "v1.2.0", warning: false},
                        {label: "UART Status", value: "Active", warning: false},
                        {label: "Sensor Data", value: "125 Hz", warning: false},
                        {label: "Last Update", value: "< 1s", warning: false},
                        {label: "Errors", value: "0", warning: false},
                        {label: "Buffer", value: "24%", warning: false}
                    ]
                }
                
                // ====== SERVO MOTORS ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/servo.svg"
                    title: "Servo Motors"
                    status: "Active"
                    statusColor: AppTheme.colors.online
                    metrics: [
                        {label: "Steering", value: "Connected", warning: false},
                        {label: "Position", value: (vehicleData.gear || "N") === "D" ? "Center" : "Neutral", warning: false},
                        {label: "Throttle", value: "Connected", warning: false},
                        {label: "Position", value: (vehicleData.speed || 0) > 0 ? Math.round((vehicleData.speed || 0) / 2) + "%" : "0%", warning: false},
                        {label: "Response", value: "< 50ms", warning: false},
                        {label: "Errors", value: "0", warning: false}
                    ]
                }
                
                // ====== SENSORS ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/sensor.svg"
                    title: "Sensors & Peripherals"
                    status: "Online"
                    statusColor: AppTheme.colors.online
                    metrics: [
                        {label: "IMU (MPU6050)", value: "Active", warning: false},
                        {label: "GPS Module", value: "Fix 12 sats", warning: false},
                        {label: "Camera", value: "1080p@30fps", warning: false},
                        {label: "Ultrasonic", value: "4 sensors OK", warning: false},
                        {label: "Battery Mon.", value: (vehicleData.battery || 0) + "%", warning: (vehicleData.battery || 0) < 20},
                        {label: "Temperature", value: (vehicleData.temperature || 0) + "°C", warning: (vehicleData.temperature || 0) > 80}
                    ]
                }
                
                // ====== COMMUNICATION BUSES ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/network.svg"
                    title: "Communication"
                    status: (systemStatus.connectionState || "disconnected") === "connected" ? "Active" : "Degraded"
                    statusColor: (systemStatus.connectionState || "disconnected") === "connected" ? AppTheme.colors.online : AppTheme.colors.warning
                    metrics: [
                        {label: "CAN Bus", value: "500 kbps", warning: false},
                        {label: "I2C", value: "400 kHz", warning: false},
                        {label: "UART", value: "115200 baud", warning: false},
                        {label: "KUKSA", value: systemStatus.connectionState || "unknown", warning: (systemStatus.connectionState || "disconnected") !== "connected"},
                        {label: "Latency", value: ((systemStatus.latency || 0).toFixed(0)) + " ms", warning: (systemStatus.latency || 0) > 100},
                        {label: "Frame Rate", value: (systemStatus.frameRate || 0) + " Hz", warning: (systemStatus.frameRate || 0) < 10}
                    ]
                }
                
                // ====== STORAGE ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/sd-card.svg"
                    title: "Storage & Logs"
                    status: "Healthy"
                    statusColor: AppTheme.colors.online
                    metrics: [
                        {label: "SD Card", value: "238 GB free", warning: false},
                        {label: "Usage", value: "18%", warning: false},
                        {label: "Log Files", value: "142 MB", warning: false},
                        {label: "Write Speed", value: "45 MB/s", warning: false},
                        {label: "Health", value: "Good", warning: false},
                        {label: "Temp", value: "42°C", warning: false}
                    ]
                }
                
                // ====== POWER MANAGEMENT ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/power-plug.svg"
                    title: "Power Management"
                    status: "Nominal"
                    statusColor: AppTheme.colors.online
                    metrics: [
                        {label: "Input", value: "12V 5A", warning: false},
                        {label: "Main Rail", value: "12.1V", warning: false},
                        {label: "5V Rail", value: "5.05V", warning: false},
                        {label: "3.3V Rail", value: "3.31V", warning: false},
                        {label: "Current Draw", value: "8.2A", warning: false},
                        {label: "Power Usage", value: "98.4W", warning: false}
                    ]
                }
                
                // ====== COOLING SYSTEM ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/fan.svg"
                    title: "Thermal Management"
                    status: "Operating"
                    statusColor: AppTheme.colors.online
                    metrics: [
                        {label: "CPU Temp", value: (systemStatus.cpuUsage || 0) + "°C", warning: (systemStatus.cpuUsage || 0) > 70},
                        {label: "Ambient", value: "22°C", warning: false},
                        {label: "MCU Temp", value: "28°C", warning: false},
                        {label: "Battery Temp", value: "25°C", warning: false},
                        {label: "Fan Speed", value: "1850 RPM", warning: false},
                        {label: "Heatsink", value: "Optimal", warning: false}
                    ]
                }
                
                // ====== STORAGE ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/storage.svg"
                    title: "Storage & Logs"
                    status: "Healthy"
                    statusColor: AppTheme.colors.online
                    metrics: [
                        {label: "SD Card", value: "238 GB free", warning: false},
                        {label: "Usage", value: "18%", warning: false},
                        {label: "Log Files", value: "142 MB", warning: false},
                        {label: "Write Speed", value: "45 MB/s", warning: false},
                        {label: "Health", value: "Good", warning: false},
                        {label: "Temp", value: "42°C", warning: false}
                    ]
                }
                
                // ====== GPS & LOCATION ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/gps.svg"
                    title: "GPS Module"
                    status: (systemStatus.gpsStatus || "Seeking") === "Fix" ? "Fixed" : "Seeking"
                    statusColor: (systemStatus.gpsStatus || "Seeking") === "Fix" ? AppTheme.colors.online : AppTheme.colors.warning
                    metrics: [
                        {label: "Status", value: systemStatus.gpsStatus || "Seeking", warning: false},
                        {label: "Satellites", value: "12/15", warning: false},
                        {label: "Latitude", value: "37.7749°N", warning: false},
                        {label: "Longitude", value: "122.4194°W", warning: false},
                        {label: "Altitude", value: "52 m", warning: false},
                        {label: "Accuracy", value: "±2.5m", warning: false}
                    ]
                }
                
                // ====== INERTIAL MEASUREMENT ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/imu.svg"
                    title: "IMU Accelerometer"
                    status: "Calibrated"
                    statusColor: AppTheme.colors.online
                    metrics: [
                        {label: "Device", value: "MPU6050", warning: false},
                        {label: "Accel X", value: "0.02 g", warning: false},
                        {label: "Accel Y", value: "0.01 g", warning: false},
                        {label: "Accel Z", value: "1.00 g", warning: false},
                        {label: "Gyro X", value: "0.5 °/s", warning: false},
                        {label: "Sampling", value: "200 Hz", warning: false}
                    ]
                }
                
                // ====== ETHERNET & CONNECTIVITY ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/ethernet.svg"
                    title: "Ethernet Interface"
                    status: "Connected"
                    statusColor: AppTheme.colors.online
                    metrics: [
                        {label: "Link Speed", value: "1000 Mbps", warning: false},
                        {label: "IP Address", value: "192.168.1.50", warning: false},
                        {label: "Gateway", value: "192.168.1.1", warning: false},
                        {label: "Packets RX", value: "245,891", warning: false},
                        {label: "Packets TX", value: "198,342", warning: false},
                        {label: "Errors", value: "0", warning: false}
                    ]
                }
                
                // ====== CAMERA INTERFACE ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/camera.svg"
                    title: "Camera Module"
                    status: "Streaming"
                    statusColor: AppTheme.colors.online
                    metrics: [
                        {label: "Resolution", value: "1920x1080", warning: false},
                        {label: "Frame Rate", value: "30 FPS", warning: false},
                        {label: "Format", value: "H.264", warning: false},
                        {label: "Bitrate", value: "2.5 Mbps", warning: false},
                        {label: "Focus", value: "Auto", warning: false},
                        {label: "Exposure", value: "Auto", warning: false}
                    ]
                }
                
                // ====== ULTRASONIC SENSORS ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/ultrasonic.svg"
                    title: "Ultrasonic Sensors"
                    status: "All Active"
                    statusColor: AppTheme.colors.online
                    metrics: [
                        {label: "Front-Left", value: "45 cm", warning: false},
                        {label: "Front-Right", value: "52 cm", warning: false},
                        {label: "Rear-Left", value: "65 cm", warning: false},
                        {label: "Rear-Right", value: "71 cm", warning: false},
                        {label: "Update Rate", value: "20 Hz", warning: false},
                        {label: "Response Time", value: "< 60 ms", warning: false}
                    ]
                }
                
                // ====== VOLTAGE MONITORING ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/voltage.svg"
                    title: "Voltage Monitoring"
                    status: "Stable"
                    statusColor: AppTheme.colors.online
                    metrics: [
                        {label: "Main Supply", value: "12.0V", warning: false},
                        {label: "5V Rail", value: "5.05V", warning: false},
                        {label: "3.3V Rail", value: "3.31V", warning: false},
                        {label: "Battery", value: (vehicleData.battery || 0) + "%", warning: (vehicleData.battery || 0) < 20},
                        {label: "Ripple", value: "< 50mV", warning: false},
                        {label: "Load", value: "65%", warning: false}
                    ]
                }
                
                // ====== TEMPERATURE SENSORS ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/temperature.svg"
                    title: "Temperature Sensors"
                    status: "Normal"
                    statusColor: AppTheme.colors.online
                    metrics: [
                        {label: "CPU", value: (systemStatus.cpuUsage || 0) + "°C", warning: (systemStatus.cpuUsage || 0) > 70},
                        {label: "Ambient", value: "22°C", warning: false},
                        {label: "MCU", value: "28°C", warning: false},
                        {label: "Battery", value: (vehicleData.temperature || 0) + "°C", warning: (vehicleData.temperature || 0) > 80},
                        {label: "Motor", value: "35°C", warning: false},
                        {label: "Throttle", value: "Normal", warning: false}
                    ]
                }
                
                // ====== MEMORY SUBSYSTEM ======
                ComponentCard {
                    titleIcon: "qrc:/icons/hardware/ram.svg"
                    title: "Memory Subsystem"
                    status: "Healthy"
                    statusColor: AppTheme.colors.online
                    metrics: [
                        {label: "Total RAM", value: "8 GB", warning: false},
                        {label: "Used", value: (systemStatus.memoryUsage || 0) + "%", warning: (systemStatus.memoryUsage || 0) > 85},
                        {label: "Available", value: (100 - (systemStatus.memoryUsage || 0)) + "%", warning: false},
                        {label: "Buffers", value: "512 MB", warning: false},
                        {label: "Cache", value: "1.2 GB", warning: false},
                        {label: "Swap", value: "256 MB", warning: false}
                    ]
                }
                
                // Bottom spacing
                Item {
                    Layout.preferredHeight: AppTheme.spacing.medium
                }
            }
        }
    }
    
    // ====== COMPONENT CARD (Reusable) ======
    component ComponentCard: Rectangle {
        property string title: ""
        property string titleIcon: ""
        property string status: ""
        property color statusColor: AppTheme.colors.online
        property var metrics: []
        
        Layout.fillWidth: true
        Layout.leftMargin: AppTheme.spacing.medium
        Layout.rightMargin: AppTheme.spacing.medium
        Layout.topMargin: AppTheme.spacing.small
        Layout.preferredHeight: cardContent.height + AppTheme.spacing.medium * 2
        
        color: AppTheme.colors.surfaceElevated
        radius: AppTheme.radius.medium
        border.width: 1
        border.color: AppTheme.colors.divider
        
        ColumnLayout {
            id: cardContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: AppTheme.spacing.medium
            spacing: AppTheme.spacing.small
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: AppTheme.spacing.small
                
                Image {
                    source: titleIcon
                    sourceSize.width: 20
                    sourceSize.height: 20
                    visible: titleIcon !== ""
                    Layout.alignment: Qt.AlignVCenter
                }
                
                Text {
                    text: title
                    font.pixelSize: AppTheme.typography.labelLarge
                    font.weight: Font.Bold
                    color: AppTheme.colors.text
                }
                
                Item { Layout.fillWidth: true }
                
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: statusColor
                }
                
                Text {
                    text: status
                    font.pixelSize: AppTheme.typography.labelSmall
                    color: AppTheme.colors.textSecondary
                }
            }
            
            // Divider
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: AppTheme.colors.divider
            }
            
            // Metrics Flow (auto-wrapping 3 columns)
            Flow {
                Layout.fillWidth: true
                spacing: AppTheme.spacing.small
                
                Repeater {
                    model: metrics
                    
                    Item {
                        width: 240
                        height: 24
                        
                        RowLayout {
                            id: metricRow
                            anchors.fill: parent
                            spacing: AppTheme.spacing.xsmall
                            
                            Text {
                                text: modelData.label + ":"
                                font.pixelSize: AppTheme.typography.labelSmall || 12
                                color: AppTheme.colors.textSecondary
                                width: 70
                            }
                            
                            Text {
                                text: modelData.value
                                font.pixelSize: AppTheme.typography.labelSmall || 12
                                color: modelData.warning ? AppTheme.colors.warning : AppTheme.colors.text
                                font.weight: Font.Medium
                            }
                        }
                    }
                }
            }
        }
    }
}
