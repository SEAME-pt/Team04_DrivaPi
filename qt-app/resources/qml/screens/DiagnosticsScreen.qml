import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: AppTheme.spacing.medium

        // ====== HEADER ======
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: AppTheme.colors.surfaceElevated

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: AppTheme.spacing.large
                anchors.rightMargin: AppTheme.spacing.large

                Text {
                    text: "System Diagnostics"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    color: "#e6f0ff"
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    id: systemTime
                    text: Qt.formatDateTime(new Date(), "hh:mm:ss")
                    font.pixelSize: 12
                    color: "#93a6bf"

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

                // ====== RASPBERRY PI 5 (Real Health Data) ======
                ComponentCard {
                    title: "Raspberry Pi 5"
                    titleIcon: "qrc:/icons/hardware/cpu.svg"
                    statusText: piHealthReader.isOnline ? "Online" : "Offline"
                    statusColor: piHealthReader.isOnline ? "#00ff00" : "#ff0000"
                    metrics: [
                        {
                            label: "CPU Temp",
                            value: piHealthReader.cpuTemp.toFixed(1) + "°C",
                            warning: piHealthReader.cpuTemp > 70
                        },
                        {
                            label: "CPU Freq",
                            value: piHealthReader.cpuFreq + " MHz",
                            warning: false
                        },
                        {
                            label: "Memory",
                            value: piHealthReader.memoryPercent + "%",
                            warning: piHealthReader.memoryPercent > 85
                        },
                        {
                            label: "Disk",
                            value: piHealthReader.diskPercent + "%",
                            warning: piHealthReader.diskPercent > 90
                        },
                        {
                            label: "IP Address",
                            value: piHealthReader.ipAddress,
                            warning: false
                        },
                        {
                            label: "Uptime",
                            value: piHealthReader.uptime,
                            warning: false
                        }
                    ]
                }

                // ====== STM32 BATTERY & VOLTAGE (CAN 0x200) ======
                ComponentCard {
                    title: "STM32 Power Monitor"
                    titleIcon: "qrc:/icons/hardware/battery.svg"
                    statusText: vehicleData.stm32Battery > 20 ? "Healthy" : "Low"
                    statusColor: vehicleData.stm32Battery > 20 ? "#00ff00" : "#ff6600"
                    metrics: [
                        {
                            label: "Battery",
                            value: vehicleData.stm32Battery + "%",
                            warning: vehicleData.stm32Battery < 20
                        },
                        {
                            label: "Voltage",
                            value: (vehicleData.stm32BatteryVoltage || 0).toFixed(2) + " V",
                            warning: (vehicleData.stm32BatteryVoltage || 0) < 11.0 || (vehicleData.stm32BatteryVoltage || 0) > 13.0
                        },
                        {
                            label: "Source",
                            value: "CAN 0x200",
                            warning: false
                        },
                        {
                            label: "Format",
                            value: "5 bytes (1% + 4×V)",
                            warning: false
                        }
                    ]
                }

                // ====== STM32 ENVIRONMENT (CAN 0x400) ======
                ComponentCard {
                    title: "STM32 Environmental"
                    titleIcon: "qrc:/icons/hardware/sensor.svg"
                    statusText: "Online"
                    statusColor: "#00ff00"
                    metrics: [
                        {
                            label: "Temperature",
                            value: (vehicleData.stm32Temperature || 0).toFixed(1) + "°C",
                            warning: (vehicleData.stm32Temperature || 0) > 60
                        },
                        {
                            label: "Humidity",
                            value: (vehicleData.stm32Humidity || 0).toFixed(1) + "%",
                            warning: (vehicleData.stm32Humidity || 0) > 85
                        },
                        {
                            label: "Source",
                            value: "CAN 0x400",
                            warning: false
                        },
                        {
                            label: "Format",
                            value: "8 bytes (4×T + 4×H)",
                            warning: false
                        }
                    ]
                }

                Item {
                    Layout.preferredHeight: AppTheme.spacing.medium
                }
            }
        }
    }

    // ====== REUSABLE COMPONENT CARD ======
    component ComponentCard: Rectangle {
        property string title: ""
        property string titleIcon: ""
        property string statusText: ""
        property color statusColor: "#00ff00"
        property var metrics: []

        Layout.fillWidth: true
        Layout.leftMargin: AppTheme.spacing.medium
        Layout.rightMargin: AppTheme.spacing.medium
        Layout.topMargin: AppTheme.spacing.small
        Layout.preferredHeight: cardContent.height + 24

        color: AppTheme.colors.surfaceElevated
        radius: AppTheme.radius.medium
        border.width: 1
        border.color: AppTheme.colors.divider

        ColumnLayout {
            id: cardContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 8

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Image {
                    source: titleIcon
                    sourceSize.width: 20
                    sourceSize.height: 20
                    visible: titleIcon !== ""
                }

                Text {
                    text: title
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    color: "#e6f0ff"
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: statusColor
                }

                Text {
                    text: statusText
                    font.pixelSize: 12
                    color: "#93a6bf"
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: AppTheme.colors.divider
            }

            // Metrics
            Flow {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: metrics

                    Item {
                        width: 240
                        height: 24

                        RowLayout {
                            anchors.fill: parent
                            spacing: 4

                            Text {
                                text: modelData.label + ":"
                                font.pixelSize: 11
                                color: "#93a6bf"
                                width: 80
                            }

                            Text {
                                text: modelData.value
                                font.pixelSize: 11
                                color: modelData.warning ? "#ff6600" : "#e6f0ff"
                                font.weight: Font.Medium
                            }
                        }
                    }
                }
            }
        }
    }
}
