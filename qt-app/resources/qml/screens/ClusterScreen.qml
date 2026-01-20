import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    color: AppTheme.colors.surface
    
    // ====== MAIN LAYOUT (3 COLUMNS) ======
    RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0
        
        // ====== LEFT COLUMN: Navigation/Trip Info ======
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.22
            color: AppTheme.colors.surface
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.medium
                spacing: AppTheme.spacing.small
                
                // Distance to turn
                ColumnLayout {
                    spacing: AppTheme.spacing.xxSmall
                    Layout.fillWidth: true
                    
                    Text {
                        text: "500m"
                        color: AppTheme.colors.primary
                        font.pixelSize: AppTheme.typography.headlineLarge
                        font.weight: Font.Bold
                    }
                    
                    Text {
                        text: "Next Turn"
                        color: AppTheme.colors.textSecondary
                        font.pixelSize: AppTheme.typography.labelSmall
                    }
                }
                
                Item { Layout.fillHeight: true }
                
                // Trip Distance
                ColumnLayout {
                    spacing: AppTheme.spacing.xxSmall
                    Layout.fillWidth: true
                    
                    Text {
                        text: "Trip: 568 km"
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.bodySmall
                    }
                    
                    // Simple progress bar
                    Rectangle {
                        Layout.fillWidth: true
                        height: 3
                        radius: AppTheme.radius.small
                        color: AppTheme.colors.surfaceVariant
                        
                        Rectangle {
                            width: parent.width * 0.65
                            height: parent.height
                            radius: AppTheme.radius.small
                            color: AppTheme.colors.primary
                        }
                    }
                }
            }
        }
        
        // ====== CENTER COLUMN: Large Speed Display ======
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: AppTheme.colors.surface
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 0
                spacing: 0
                
                // ====== TOP: Mode + Status ======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: AppTheme.colors.surfaceVariant
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: AppTheme.spacing.small
                        spacing: AppTheme.spacing.medium
                        
                        // Mode badge (ECO, NORMAL, SPORT)
                        Rectangle {
                            width: 50
                            height: 24
                            radius: AppTheme.radius.small
                            color: AppTheme.colors.primaryDark
                            
                            Text {
                                text: "ECO"
                                color: AppTheme.colors.text
                                font.pixelSize: AppTheme.typography.labelSmall
                                font.weight: Font.Bold
                                anchors.centerIn: parent
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Gear display
                        Text {
                            text: vehicleData.gear
                            color: AppTheme.colors.primary
                            font.pixelSize: 16
                            font.weight: Font.Bold
                        }
                    }
                }
                
                // ====== MIDDLE: Speed Gauge (Center) ======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: AppTheme.colors.surface
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: AppTheme.spacing.small
                        
                        // Speed number (huge)
                        Text {
                            text: Math.round(vehicleData.speed * 3.6).toString() // m/s to km/h
                            color: AppTheme.colors.text
                            font.pixelSize: 80
                            font.weight: Font.Bold
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        // Unit
                        Text {
                            text: "km/h"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.bodyMedium
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
                
                // ====== BOTTOM: Metrics Grid ======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: AppTheme.colors.surfaceVariant
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: AppTheme.spacing.small
                        spacing: AppTheme.spacing.small
                        
                        // Energy consumption
                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignCenter
                            
                            Text {
                                text: vehicleData.energy.toFixed(0) + "%"
                                color: AppTheme.colors.primary
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "Energy"
                                color: AppTheme.colors.textTertiary
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                        
                        Rectangle {
                            Layout.fillHeight: true
                            width: 1
                            color: AppTheme.colors.divider
                        }
                        
                        // Temperature
                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignCenter
                            
                            RowLayout {
                                spacing: 4
                                Layout.alignment: Qt.AlignHCenter
                                
                                Image {
                                    source: "qrc:/icons/hardware/temperature.svg"
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                }
                                
                                Text {
                                    text: vehicleData.temperature + "°C"
                                    color: vehicleData.temperature > 80 ? AppTheme.colors.warning : AppTheme.colors.text
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                }
                            }
                            
                            Text {
                                text: "Temp"
                                color: AppTheme.colors.textTertiary
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                        
                        Rectangle {
                            Layout.fillHeight: true
                            width: 1
                            color: AppTheme.colors.divider
                        }
                        
                        // Battery
                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignCenter
                            
                            RowLayout {
                                spacing: 4
                                Layout.alignment: Qt.AlignHCenter
                                
                                Image {
                                    source: "qrc:/icons/hardware/battery.svg"
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                }
                                
                                Text {
                                    text: vehicleData.battery + "%"
                                    color: vehicleData.battery < 20 ? AppTheme.colors.error : AppTheme.colors.text
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                }
                            }
                            
                            Text {
                                text: "Battery"
                                color: AppTheme.colors.textTertiary
                                font.pixelSize: 10
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
        
        // ====== RIGHT COLUMN: Media/Info ======
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.22
            color: AppTheme.colors.surface
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.medium
                spacing: AppTheme.spacing.small
                
                // Media/info area
                ColumnLayout {
                    spacing: AppTheme.spacing.xxSmall
                    Layout.fillWidth: true
                    
                    Text {
                        text: "Playing"
                        color: AppTheme.colors.textSecondary
                        font.pixelSize: AppTheme.typography.labelSmall
                    }
                    
                    Text {
                        text: "Send Me Your..."
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.bodySmall
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    
                    Text {
                        text: "OneRepublic"
                        color: AppTheme.colors.textSecondary
                        font.pixelSize: AppTheme.typography.labelSmall
                    }
                }
                
                Item { Layout.fillHeight: true }
                
                // Odometer
                ColumnLayout {
                    spacing: AppTheme.spacing.xxSmall
                    Layout.fillWidth: true
                    
                    Text {
                        text: "ODO"
                        color: AppTheme.colors.textSecondary
                        font.pixelSize: AppTheme.typography.labelSmall
                    }
                    
                    Text {
                        text: vehicleData.distance.toString() + " km"
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.bodyMedium
                        font.bold: true
                    }
                }
            }
        }
    }
}
