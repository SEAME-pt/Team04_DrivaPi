import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    color: AppTheme.colors.surface
    
    // ====== SCROLLABLE SETTINGS LIST ======
    Flickable {
        anchors.fill: parent
        contentHeight: settingsColumn.implicitHeight
        clip: true
        
        ColumnLayout {
            id: settingsColumn
            width: parent.width
            spacing: 0
            
            // ====== SECTION 1: Connection ======
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: AppTheme.colors.surfaceVariant
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: AppTheme.spacing.medium
                    spacing: AppTheme.spacing.medium
                    
                    Image {
                        source: "qrc:/icons/hardware/network.svg"
                        sourceSize.width: 20
                        sourceSize.height: 20
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.xxSmall
                        
                        Text {
                            text: "Connection Mode"
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.labelLarge
                            font.weight: Font.Bold
                        }
                    
                        RowLayout {
                            spacing: AppTheme.spacing.medium
                            
                            Rectangle {
                                width: 60
                                height: 32
                                radius: AppTheme.radius.small
                                color: AppTheme.colors.primary
                                
                                Text {
                                    text: "CAN"
                                    color: AppTheme.colors.text
                                    font.pixelSize: AppTheme.typography.labelSmall
                                    anchors.centerIn: parent
                                }
                            }
                            
                            Rectangle {
                                width: 70
                                height: 32
                                radius: AppTheme.radius.small
                                color: AppTheme.colors.surfaceElevated
                                
                                Text {
                                    text: "KUKSA"
                                    color: AppTheme.colors.textSecondary
                                    font.pixelSize: AppTheme.typography.labelSmall
                                    anchors.centerIn: parent
                                }
                            }
                        }
                    }
                }
            }
            
            Rectangle { Layout.fillWidth: true; height: 1; color: AppTheme.colors.divider }
            
            // ====== SECTION 2: Display ======
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: AppTheme.colors.surface
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: AppTheme.spacing.medium
                    spacing: AppTheme.spacing.medium
                    
                    Image {
                        source: "qrc:/icons/settings/display.svg"
                        sourceSize.width: 20
                        sourceSize.height: 20
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.xxSmall
                        
                        Text {
                            text: "Display Mode"
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.labelLarge
                            font.weight: Font.Bold
                        }
                    
                        RowLayout {
                            spacing: AppTheme.spacing.medium
                            
                            Rectangle {
                                width: 80
                                height: 32
                                radius: AppTheme.radius.small
                                color: AppTheme.colors.surfaceElevated
                                
                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    
                                    Image {
                                        source: "qrc:/icons/settings/theme-dark.svg"
                                        sourceSize.width: 14
                                        sourceSize.height: 14
                                    }
                                    
                                    Text {
                                        text: "Dark"
                                        color: AppTheme.colors.text
                                        font.pixelSize: AppTheme.typography.labelSmall
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 80
                                height: 32
                                radius: AppTheme.radius.small
                                color: AppTheme.colors.surfaceVariant
                                
                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    
                                    Image {
                                        source: "qrc:/icons/settings/theme-light.svg"
                                        sourceSize.width: 14
                                        sourceSize.height: 14
                                    }
                                    
                                    Text {
                                        text: "Light"
                                        color: AppTheme.colors.textSecondary
                                        font.pixelSize: AppTheme.typography.labelSmall
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Rectangle { Layout.fillWidth: true; height: 1; color: AppTheme.colors.divider }
            
            // ====== SECTION 3: Audio ======
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: AppTheme.colors.surfaceVariant
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: AppTheme.spacing.medium
                    spacing: AppTheme.spacing.medium
                    
                    Image {
                        source: "qrc:/icons/controls/volume-high.svg"
                        sourceSize.width: 20
                        sourceSize.height: 20
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.small
                        
                        Text {
                            text: "Audio Volume"
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.labelLarge
                            font.weight: Font.Bold
                        }
                        
                        RowLayout {
                            spacing: AppTheme.spacing.small
                            
                            Image {
                                source: "qrc:/icons/controls/volume-mute.svg"
                                sourceSize.width: 16
                                sourceSize.height: 16
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 4
                                radius: 2
                                color: AppTheme.colors.surfaceElevated
                                
                                Rectangle {
                                    width: parent.width * 0.6
                                    height: parent.height
                                    radius: 2
                                    color: AppTheme.colors.primary
                                }
                            }
                            
                            Image {
                                source: "qrc:/icons/controls/volume-high.svg"
                                sourceSize.width: 16
                                sourceSize.height: 16
                            }
                        }
                    }
                }
            }
            
            Rectangle { Layout.fillWidth: true; height: 1; color: AppTheme.colors.divider }
            
            // ====== SECTION 4: Connectivity ======
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                color: AppTheme.colors.surface
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: AppTheme.spacing.medium
                    spacing: AppTheme.spacing.medium
                    
                    Image {
                        source: "qrc:/icons/settings/wifi.svg"
                        sourceSize.width: 20
                        sourceSize.height: 20
                        Layout.alignment: Qt.AlignTop
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.small
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: AppTheme.spacing.small
                            
                            Text {
                                text: "WiFi"
                                color: AppTheme.colors.text
                                font.pixelSize: AppTheme.typography.labelLarge
                                font.weight: Font.Bold
                                Layout.fillWidth: true
                            }
                            
                            Image {
                                source: "qrc:/icons/settings/toggle-on.svg"
                                sourceSize.width: 40
                                sourceSize.height: 20
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: AppTheme.spacing.small
                            
                            Image {
                                source: "qrc:/icons/settings/bluetooth.svg"
                                sourceSize.width: 16
                                sourceSize.height: 16
                            }
                            
                            Text {
                                text: "Bluetooth"
                                color: AppTheme.colors.text
                                font.pixelSize: AppTheme.typography.labelLarge
                                font.weight: Font.Bold
                                Layout.fillWidth: true
                            }
                            
                            Image {
                                source: "qrc:/icons/settings/toggle-off.svg"
                                sourceSize.width: 40
                                sourceSize.height: 20
                            }
                        }
                    }
                }
            }
            
            Rectangle { Layout.fillWidth: true; height: 1; color: AppTheme.colors.divider }
            
            // ====== SECTION 5: Developer ======
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: AppTheme.colors.surfaceVariant
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: AppTheme.spacing.medium
                    spacing: AppTheme.spacing.xxSmall
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "Debug Mode"
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.labelLarge
                            font.weight: Font.Bold
                            Layout.fillWidth: true
                        }
                        
                        Rectangle {
                            width: 50
                            height: 28
                            radius: 14
                            color: AppTheme.colors.surfaceElevated
                            
                            Rectangle {
                                width: 24
                                height: 24
                                radius: 12
                                color: AppTheme.colors.textTertiary
                                anchors.verticalCenter: parent.verticalCenter
                                x: 2
                            }
                        }
                    }
                    
                    Text {
                        text: "Enable verbose logging and diagnostics"
                        color: AppTheme.colors.textSecondary
                        font.pixelSize: AppTheme.typography.labelSmall
                    }
                }
            }
            
            Rectangle { Layout.fillWidth: true; height: 1; color: AppTheme.colors.divider }
            
            // ====== SECTION 6: About ======
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                color: AppTheme.colors.surfaceVariant
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: AppTheme.spacing.medium
                    spacing: AppTheme.spacing.small
                    
                    Text {
                        text: "About DrivaPi HMI"
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.labelLarge
                        font.weight: Font.Bold
                    }
                    
                    ColumnLayout {
                        spacing: AppTheme.spacing.xxSmall
                        
                        RowLayout {
                            spacing: AppTheme.spacing.medium
                            
                            Text {
                                text: "Version:"
                                color: AppTheme.colors.textSecondary
                                font.pixelSize: AppTheme.typography.bodySmall
                            }
                            
                            Text {
                                text: "1.0.0-beta"
                                color: AppTheme.colors.primary
                                font.pixelSize: AppTheme.typography.bodySmall
                                font.weight: Font.Bold
                            }
                        }
                        
                        RowLayout {
                            spacing: AppTheme.spacing.medium
                            
                            Text {
                                text: "Build Date:"
                                color: AppTheme.colors.textSecondary
                                font.pixelSize: AppTheme.typography.bodySmall
                            }
                            
                            Text {
                                text: "2026-01-20"
                                color: AppTheme.colors.text
                                font.pixelSize: AppTheme.typography.bodySmall
                            }
                        }
                        
                        Text {
                            text: "ISO 26262 Compliant • Automotive Grade"
                            color: AppTheme.colors.textTertiary
                            font.pixelSize: AppTheme.typography.labelSmall
                        }
                    }
                }
            }
            
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: AppTheme.spacing.large
            }
        }
    }
}
