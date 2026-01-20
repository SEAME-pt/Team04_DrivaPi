import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    color: AppTheme.colors.surface
    
    // ====== MAIN LAYOUT ======
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0
        
        // ====== TOP: Turn Instruction Bar ======
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: AppTheme.colors.surfaceElevated
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.medium
                spacing: AppTheme.spacing.large
                
                // Turn arrow + distance
                ColumnLayout {
                    spacing: AppTheme.spacing.xxSmall
                    
                    Text {
                        text: "↗"  // Turn right arrow (can use SVG icons later)
                        color: AppTheme.colors.primary
                        font.pixelSize: 32
                    }
                    
                    Text {
                        text: "500 m"
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.bodyMedium
                        font.weight: Font.Bold
                    }
                }
                
                // Next instruction
                ColumnLayout {
                    spacing: AppTheme.spacing.xxSmall
                    Layout.fillWidth: true
                    
                    Text {
                        text: "Turn Right"
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.headlineSmall
                        font.weight: Font.Bold
                    }
                    
                    Text {
                        text: "onto Highway 101 North"
                        color: AppTheme.colors.textSecondary
                        font.pixelSize: AppTheme.typography.bodySmall
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // Street name
                Text {
                    text: "Highway 101"
                    color: AppTheme.colors.textTertiary
                    font.pixelSize: AppTheme.typography.labelMedium
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }
            }
            
            // Divider line at bottom
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: AppTheme.colors.divider
            }
        }
        
        // ====== CENTER: Map Area (Placeholder) ======
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: AppTheme.colors.surfaceVariant
            
            // Simple road visualization
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 0
                spacing: 0
                
                // Road background
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: AppTheme.colors.surfaceVariant
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: AppTheme.spacing.large
                        
                        // Road lines animation
                        Row {
                            spacing: 0
                            Layout.alignment: Qt.AlignHCenter
                            
                            Rectangle {
                                width: 60
                                height: 6
                                color: AppTheme.colors.primary
                                radius: 3
                            }
                            
                            Rectangle {
                                width: 20
                                height: 6
                                color: AppTheme.colors.surfaceVariant
                            }
                            
                            Rectangle {
                                width: 60
                                height: 6
                                color: AppTheme.colors.primary
                                radius: 3
                            }
                        }
                        
                        // Car icon (center)
                        Text {
                            text: "🚗"
                            font.pixelSize: 40
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        // Destination info
                        Text {
                            text: "Navigation Map (Placeholder)"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.bodySmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Text {
                            text: "Full map integration coming soon"
                            color: AppTheme.colors.textTertiary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }
        
        // ====== BOTTOM: Navigation Info Bar ======
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: AppTheme.colors.surfaceElevated
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.medium
                spacing: AppTheme.spacing.small
                
                // ETA
                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true
                    
                    Text {
                        text: "14:23"
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.bodyMedium
                        font.weight: Font.Bold
                    }
                    
                    Text {
                        text: "ETA"
                        color: AppTheme.colors.textTertiary
                        font.pixelSize: AppTheme.typography.labelSmall
                    }
                }
                
                Rectangle {
                    Layout.fillHeight: true
                    width: 1
                    color: AppTheme.colors.divider
                }
                
                // Distance to destination
                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true
                    
                    Text {
                        text: "42.5 km"
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.bodyMedium
                        font.weight: Font.Bold
                    }
                    
                    Text {
                        text: "Distance"
                        color: AppTheme.colors.textTertiary
                        font.pixelSize: AppTheme.typography.labelSmall
                    }
                }
                
                Rectangle {
                    Layout.fillHeight: true
                    width: 1
                    color: AppTheme.colors.divider
                }
                
                // Speed limit
                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true
                    
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 4
                        color: AppTheme.colors.error
                        Layout.alignment: Qt.AlignHCenter
                        
                        Text {
                            text: "60"
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.bodyMedium
                            font.weight: Font.Bold
                            anchors.centerIn: parent
                        }
                    }
                    
                    Text {
                        text: "Speed Limit"
                        color: AppTheme.colors.textTertiary
                        font.pixelSize: AppTheme.typography.labelSmall
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
                
                Rectangle {
                    Layout.fillHeight: true
                    width: 1
                    color: AppTheme.colors.divider
                }
                
                // Traffic status
                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true
                    
                    Text {
                        text: "●"
                        color: AppTheme.colors.success
                        font.pixelSize: 16
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "Clear"
                        color: AppTheme.colors.textTertiary
                        font.pixelSize: AppTheme.typography.labelSmall
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            // Divider line at top
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: AppTheme.colors.divider
            }
        }
    }
}
