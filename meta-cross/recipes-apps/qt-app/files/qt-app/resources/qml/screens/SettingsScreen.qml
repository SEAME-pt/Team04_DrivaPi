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

                        RowLayout {
                            spacing: AppTheme.spacing.small
                            
                            Image {
                                source: "qrc:/icons/controls/volume-low.svg"
                                sourceSize.width: 16
                                sourceSize.height: 16
                            }
                            
                            Text {
                                text: "Night mode volume"
                                color: AppTheme.colors.textSecondary
                                font.pixelSize: AppTheme.typography.labelSmall
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
            
            // ====== SECTION 6: Brightness Control ======
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                color: AppTheme.colors.surface
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: AppTheme.spacing.medium
                    spacing: AppTheme.spacing.small
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.medium
                        
                        Image {
                            source: "qrc:/icons/settings/brightness.svg"
                            sourceSize.width: 20
                            sourceSize.height: 20
                        }
                        
                        Text {
                            text: "Screen Brightness"
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.labelLarge
                            font.weight: Font.Bold
                            Layout.fillWidth: true
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.small
                        
                        Image {
                            source: "qrc:/icons/settings/brightness-low.svg"
                            sourceSize.width: 16
                            sourceSize.height: 16
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            height: 4
                            radius: 2
                            color: AppTheme.colors.surfaceElevated
                            
                            Rectangle {
                                width: parent.width * 0.75
                                height: parent.height
                                radius: 2
                                color: AppTheme.colors.warning
                            }
                        }
                        
                        Image {
                            source: "qrc:/icons/settings/brightness-high.svg"
                            sourceSize.width: 16
                            sourceSize.height: 16
                        }
                    }
                }
            }
            
            Rectangle { Layout.fillWidth: true; height: 1; color: AppTheme.colors.divider }
            
            // ====== SECTION 7: Language & Localization ======
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: AppTheme.colors.surfaceVariant
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: AppTheme.spacing.medium
                    spacing: AppTheme.spacing.medium
                    
                    Image {
                        source: "qrc:/icons/settings/language.svg"
                        sourceSize.width: 20
                        sourceSize.height: 20
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.xxSmall
                        
                        Text {
                            text: "Language"
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
                                color: AppTheme.colors.primary
                                
                                Text {
                                    text: "English"
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
                                    text: "Español"
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
            
            // ====== SECTION 8: Theme Selection ======
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: AppTheme.colors.surface
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: AppTheme.spacing.medium
                    spacing: AppTheme.spacing.medium
                    
                    Image {
                        source: "qrc:/icons/settings/theme-auto.svg"
                        sourceSize.width: 20
                        sourceSize.height: 20
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.xxSmall
                        
                        Text {
                            text: "Theme"
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.labelLarge
                            font.weight: Font.Bold
                        }
                        
                        RowLayout {
                            spacing: AppTheme.spacing.medium
                            
                            Rectangle {
                                width: 70
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
                                        color: AppTheme.colors.text
                                        font.pixelSize: AppTheme.typography.labelSmall
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 70
                                height: 32
                                radius: AppTheme.radius.small
                                color: AppTheme.colors.primary
                                
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
                                width: 70
                                height: 32
                                radius: AppTheme.radius.small
                                color: AppTheme.colors.surfaceVariant
                                
                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    
                                    Image {
                                        source: "qrc:/icons/settings/theme-auto.svg"
                                        sourceSize.width: 14
                                        sourceSize.height: 14
                                    }
                                    
                                    Text {
                                        text: "Auto"
                                        color: AppTheme.colors.text
                                        font.pixelSize: AppTheme.typography.labelSmall
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Rectangle { Layout.fillWidth: true; height: 1; color: AppTheme.colors.divider }
            
            // ====== SECTION 9: Input Devices ======
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                color: AppTheme.colors.surfaceVariant
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: AppTheme.spacing.medium
                    spacing: AppTheme.spacing.small
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.medium
                        
                        Image {
                            source: "qrc:/icons/settings/keyboard.svg"
                            sourceSize.width: 20
                            sourceSize.height: 20
                        }
                        
                        Text {
                            text: "Input Devices"
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.labelLarge
                            font.weight: Font.Bold
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.small
                        
                        Rectangle {
                            width: 30
                            height: 30
                            color: AppTheme.colors.primary
                            radius: AppTheme.radius.small
                            
                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/settings/keyboard.svg"
                                sourceSize.width: 16
                                sourceSize.height: 16
                            }
                        }
                        
                        Text {
                            text: "Keyboard Enabled"
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.bodySmall
                            Layout.fillWidth: true
                        }
                        
                        Image {
                            source: "qrc:/icons/settings/toggle-on.svg"
                            sourceSize.width: 36
                            sourceSize.height: 18
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.small
                        
                        Rectangle {
                            width: 30
                            height: 30
                            color: AppTheme.colors.surfaceElevated
                            radius: AppTheme.radius.small
                            
                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/settings/usb.svg"
                                sourceSize.width: 16
                                sourceSize.height: 16
                            }
                        }
                        
                        Text {
                            text: "USB Mode: Mass Storage"
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.bodySmall
                            Layout.fillWidth: true
                        }
                        
                        Image {
                            source: "qrc:/icons/settings/toggle-off.svg"
                            sourceSize.width: 36
                            sourceSize.height: 18
                        }
                    }
                }
            }
            
            Rectangle { Layout.fillWidth: true; height: 1; color: AppTheme.colors.divider }
            
            // ====== SECTION 10: Audio & Peripherals ======
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                color: AppTheme.colors.surface
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: AppTheme.spacing.medium
                    spacing: AppTheme.spacing.small
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.medium
                        
                        Image {
                            source: "qrc:/icons/settings/aux.svg"
                            sourceSize.width: 20
                            sourceSize.height: 20
                        }
                        
                        Text {
                            text: "Audio & Peripherals"
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.labelLarge
                            font.weight: Font.Bold
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.small
                        
                        Rectangle {
                            width: 30
                            height: 30
                            color: AppTheme.colors.surfaceElevated
                            radius: AppTheme.radius.small
                            
                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/settings/aux.svg"
                                sourceSize.width: 16
                                sourceSize.height: 16
                            }
                        }
                        
                        Text {
                            text: "AUX Input"
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.bodySmall
                            Layout.fillWidth: true
                        }
                        
                        Image {
                            source: "qrc:/icons/settings/toggle-on.svg"
                            sourceSize.width: 36
                            sourceSize.height: 18
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.small
                        
                        Rectangle {
                            width: 30
                            height: 30
                            color: AppTheme.colors.surfaceElevated
                            radius: AppTheme.radius.small
                            
                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/settings/bluetooth-off.svg"
                                sourceSize.width: 16
                                sourceSize.height: 16
                            }
                        }
                        
                        Text {
                            text: "Bluetooth Audio"
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.bodySmall
                            Layout.fillWidth: true
                        }
                        
                        Image {
                            source: "qrc:/icons/settings/toggle-off.svg"
                            sourceSize.width: 36
                            sourceSize.height: 18
                        }
                    }
                }
            }
            
            Rectangle { Layout.fillWidth: true; height: 1; color: AppTheme.colors.divider }
            
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
