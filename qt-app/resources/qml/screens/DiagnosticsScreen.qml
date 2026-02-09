import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: AppTheme.spacing.medium

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: AppTheme.colors.surfaceElevated

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: AppTheme.spacing.large
                anchors.rightMargin: AppTheme.spacing.large

                Text {
                    text: "Diagnostics"
                    font.pixelSize: AppTheme.typography.headlineSmall
                    font.weight: Font.Bold
                    color: AppTheme.colors.text
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: Qt.formatDateTime(new Date(), "hh:mm:ss")
                    font.pixelSize: AppTheme.typography.labelMedium
                    color: AppTheme.colors.textSecondary
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: AppTheme.colors.background

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.large
                spacing: AppTheme.spacing.large

                // Battery
                Rectangle {
                    Layout.fillWidth: true
                    radius: 16
                    color: AppTheme.colors.surfaceElevated
                    border.width: 1
                    border.color: AppTheme.colors.outline

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: AppTheme.spacing.large
                        spacing: AppTheme.spacing.medium

                        Text {
                            text: "STM32 Battery"
                            font.pixelSize: AppTheme.typography.titleMedium
                            font.weight: Font.DemiBold
                            color: AppTheme.colors.text
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: AppTheme.spacing.large

                            Text {
                                text: "SOC:"
                                color: AppTheme.colors.textSecondary
                                font.pixelSize: AppTheme.typography.bodyMedium
                            }
                            Text {
                                text: (vehicleData.stm32Battery ?? 0) + " %"
                                color: AppTheme.colors.text
                                font.pixelSize: AppTheme.typography.bodyLarge
                                font.weight: Font.Bold
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Voltage:"
                                color: AppTheme.colors.textSecondary
                                font.pixelSize: AppTheme.typography.bodyMedium
                            }
                            Text {
                                text: Number(vehicleData.stm32BatteryVoltage ?? 0).toFixed(2) + " V"
                                color: AppTheme.colors.text
                                font.pixelSize: AppTheme.typography.bodyLarge
                                font.weight: Font.Bold
                            }
                        }
                    }
                }

                // STM32 internal sensors
                Rectangle {
                    Layout.fillWidth: true
                    radius: 16
                    color: AppTheme.colors.surfaceElevated
                    border.width: 1
                    border.color: AppTheme.colors.outline

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: AppTheme.spacing.large
                        spacing: AppTheme.spacing.medium

                        Text {
                            text: "STM32 Internal Sensors"
                            font.pixelSize: AppTheme.typography.titleMedium
                            font.weight: Font.DemiBold
                            color: AppTheme.colors.text
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: AppTheme.spacing.large

                            Text {
                                text: "Temp:"
                                color: AppTheme.colors.textSecondary
                                font.pixelSize: AppTheme.typography.bodyMedium
                            }
                            Text {
                                text: Number(vehicleData.stm32Temperature ?? 0).toFixed(1) + " °C"
                                color: AppTheme.colors.text
                                font.pixelSize: AppTheme.typography.bodyLarge
                                font.weight: Font.Bold
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Humidity:"
                                color: AppTheme.colors.textSecondary
                                font.pixelSize: AppTheme.typography.bodyMedium
                            }
                            Text {
                                text: Number(vehicleData.stm32Humidity ?? 0).toFixed(1) + " %"
                                color: AppTheme.colors.text
                                font.pixelSize: AppTheme.typography.bodyLarge
                                font.weight: Font.Bold
                            }
                        }
                    }
                }

                // Gear
                Rectangle {
                    Layout.fillWidth: true
                    radius: 16
                    color: AppTheme.colors.surfaceElevated
                    border.width: 1
                    border.color: AppTheme.colors.outline

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: AppTheme.spacing.large

                        Text {
                            text: "Current Gear:"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.bodyMedium
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: vehicleData.gear ?? "N"
                            color: AppTheme.colors.text
                            font.pixelSize: 28
                            font.weight: Font.Black
                        }
                    }
                }
            }
        }
    }
}
