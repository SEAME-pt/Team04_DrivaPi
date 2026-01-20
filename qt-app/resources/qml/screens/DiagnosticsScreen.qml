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
                    title: "🖥️ Raspberry Pi 5"
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
                    title: "⚡ STM32U585 MCU"
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
                    title: "🔧 Servo Motors"
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
                    title: "📡 Sensors & Peripherals"
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
                    title: "🔗 Communication"
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
                    title: "💾 Storage & Logs"
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
