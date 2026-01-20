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
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: AppTheme.spacing.medium
                    spacing: AppTheme.spacing.xxSmall
                    
                    Text {
                        text: "Connection Mode"
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.labelLarge
                        font.weight: Font.Bold
                    }
                    
                    RowLayout {
                        spacing: AppTheme.spacing.medium
                        
                        // CAN button
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
                        
                        // KUKSA button
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
            
            // ====== DIVIDER ======
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: AppTheme.colors.divider
            }
            
            // ====== SECTION 2: Display ======
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: AppTheme.colors.surface
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: AppTheme.spacing.medium
                    spacing: AppTheme.spacing.xxSmall
                    
                    Text {
                        text: "Display Mode"
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.labelLarge
                        font.weight: Font.Bold
                    }
                    
                    RowLayout {
                        spacing: AppTheme.spacing.medium
                        
                        // Dark mode button
                        Rectangle {
                            width: 60
                            height: 32
                            radius: AppTheme.radius.small
                            color: AppTheme.colors.surfaceElevated
                            
                            Text {
                                text: "🌙 Dark"
                                color: AppTheme.colors.text
                                font.pixelSize: AppTheme.typography.labelSmall
                                anchors.centerIn: parent
                            }
                        }
                        
                        // Light mode button
                        Rectangle {
                            width: 60
                            height: 32
                            radius: AppTheme.radius.small
                            color: AppTheme.colors.surfaceVariant
                            
                            Text {
                                text: "☀️ Light"
                                color: AppTheme.colors.textSecondary
                                font.pixelSize: AppTheme.typography.labelSmall
                                anchors.centerIn: parent
                            }
                        }
                    }
                }
            }
            
            // ====== DIVIDER ======
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: AppTheme.colors.divider
            }
            
            // ====== SECTION 3: Audio ======
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: AppTheme.colors.surfaceVariant
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: AppTheme.spacing.medium
                    spacing: AppTheme.spacing.small
                    
                    Text {
                        text: "Audio Volume"
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.labelLarge
                        font.weight: Font.Bold
                    }
                    
                    RowLayout {
                        spacing: AppTheme.spacing.small
                        
                        Text {
                            text: "🔇"
                            font.pixelSize: 14
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
                        
                        Text {
                            text: "🔊"
                            font.pixelSize: 14
                        }
                    }
                }
            }
            
            // ====== DIVIDER ======
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: AppTheme.colors.divider
            }
            
            // ====== SECTION 4: Developer ======
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: AppTheme.colors.surface
                
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
                        
                        // Toggle switch
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
            
            // ====== DIVIDER ======
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: AppTheme.colors.divider
            }
            
            // ====== SECTION 5: About ======
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
            
            // ====== SPACING AT BOTTOM ======
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: AppTheme.spacing.large
            }
        }
    }
}
