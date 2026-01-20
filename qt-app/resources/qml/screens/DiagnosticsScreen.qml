import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    color: AppTheme.colors.surface
    
    // Local state for logging paths and playback speed toggle
    property string lastLogPath: ""
    property int speedIndex: 1 // 0=0.5x, 1=1.0x, 2=2.0x
    
    // ====== MAIN LAYOUT (TOP: Status + MIDDLE: Signals Table + BOTTOM: Controls) ======
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0
        
        // ====== TOP: Connection & System Status Bar ======
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: AppTheme.colors.surfaceElevated
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.medium
                spacing: AppTheme.spacing.small
                
                // Connection status
                ColumnLayout {
                    spacing: 2
                    
                    RowLayout {
                        spacing: AppTheme.spacing.small
                        
                        Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: AppTheme.colors.online  // Green = connected
                        }
                        
                        Text {
                            text: "KUKSA"
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.labelSmall
                            font.weight: Font.Bold
                        }
                    }
                    
                    Text {
                        text: "24 ms"
                        color: AppTheme.colors.textTertiary
                        font.pixelSize: AppTheme.typography.labelSmall
                    }
                }
                
                Rectangle {
                    width: 1
                    Layout.fillHeight: true
                    color: AppTheme.colors.divider
                }
                
                // Frame rate
                ColumnLayout {
                    spacing: 2
                    
                    Text {
                        text: "125 fps"
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                    }
                    
                    Text {
                        text: "Frame Rate"
                        color: AppTheme.colors.textTertiary
                        font.pixelSize: AppTheme.typography.labelSmall
                    }
                }
                
                Rectangle {
                    width: 1
                    Layout.fillHeight: true
                    color: AppTheme.colors.divider
                }
                
                // CPU usage
                ColumnLayout {
                    spacing: 2
                    
                    Text {
                        text: "34%"
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                    }
                    
                    Text {
                        text: "CPU"
                        color: AppTheme.colors.textTertiary
                        font.pixelSize: AppTheme.typography.labelSmall
                    }
                }
                
                Rectangle {
                    width: 1
                    Layout.fillHeight: true
                    color: AppTheme.colors.divider
                }
                
                // Memory usage
                ColumnLayout {
                    spacing: 2
                    
                    Text {
                        text: "256 MB"
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                    }
                    
                    Text {
                        text: "Memory"
                        color: AppTheme.colors.textTertiary
                        font.pixelSize: AppTheme.typography.labelSmall
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // Rendering FPS
                Text {
                    text: "60 fps (QML)"
                    color: AppTheme.colors.textSecondary
                    font.pixelSize: AppTheme.typography.labelSmall
                }
            }
            
            // Divider at bottom
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: AppTheme.colors.divider
            }
        }
        
        // ====== MIDDLE: VSS Signals Table (Scrollable) ======
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: AppTheme.colors.surface
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 0
                spacing: 0
                
                // Table header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    color: AppTheme.colors.surfaceVariant
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: AppTheme.spacing.small
                        spacing: AppTheme.spacing.small
                        
                        Text {
                            text: "Signal"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            font.weight: Font.Bold
                            Layout.preferredWidth: 80
                        }
                        
                        Text {
                            text: "Value"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            font.weight: Font.Bold
                            Layout.preferredWidth: 60
                        }
                        
                        Text {
                            text: "Unit"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            font.weight: Font.Bold
                            Layout.preferredWidth: 40
                        }
                        
                        Text {
                            text: "Updated"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            font.weight: Font.Bold
                            Layout.fillWidth: true
                        }
                    }
                }
                
                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: AppTheme.colors.divider
                }
                
                // Signals list (scrollable)
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: signalsColumn.implicitHeight
                    clip: true
                    
                    ColumnLayout {
                        id: signalsColumn
                        width: parent.width
                        spacing: 0
                        
                        // Signal rows (repeater would loop through real data)
                        // For now, static examples:
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 28
                            color: AppTheme.colors.surface
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: AppTheme.spacing.small
                                spacing: AppTheme.spacing.small
                                
                                Text {
                                    text: "Vehicle.Speed"
                                    color: AppTheme.colors.text
                                    font.pixelSize: AppTheme.typography.bodySmall
                                    Layout.preferredWidth: 80
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    text: vehicleData.speed.toFixed(1)
                                    color: AppTheme.colors.primary
                                    font.pixelSize: AppTheme.typography.bodySmall
                                    font.weight: Font.Bold
                                    Layout.preferredWidth: 60
                                }
                                
                                Text {
                                    text: "m/s"
                                    color: AppTheme.colors.textSecondary
                                    font.pixelSize: AppTheme.typography.labelSmall
                                    Layout.preferredWidth: 40
                                }
                                
                                Text {
                                    text: "now"
                                    color: AppTheme.colors.textTertiary
                                    font.pixelSize: AppTheme.typography.labelSmall
                                    Layout.fillWidth: true
                                }
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 28
                            color: AppTheme.colors.surfaceVariant
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: AppTheme.spacing.small
                                spacing: AppTheme.spacing.small
                                
                                Text {
                                    text: "Vehicle.Battery"
                                    color: AppTheme.colors.text
                                    font.pixelSize: AppTheme.typography.bodySmall
                                    Layout.preferredWidth: 80
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    text: vehicleData.battery
                                    color: AppTheme.colors.text
                                    font.pixelSize: AppTheme.typography.bodySmall
                                    font.weight: Font.Bold
                                    Layout.preferredWidth: 60
                                }
                                
                                Text {
                                    text: "%"
                                    color: AppTheme.colors.textSecondary
                                    font.pixelSize: AppTheme.typography.labelSmall
                                    Layout.preferredWidth: 40
                                }
                                
                                Text {
                                    text: "2s ago"
                                    color: AppTheme.colors.textTertiary
                                    font.pixelSize: AppTheme.typography.labelSmall
                                    Layout.fillWidth: true
                                }
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 28
                            color: AppTheme.colors.surface
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: AppTheme.spacing.small
                                spacing: AppTheme.spacing.small
                                
                                Text {
                                    text: "Vehicle.Temperature"
                                    color: AppTheme.colors.text
                                    font.pixelSize: AppTheme.typography.bodySmall
                                    Layout.preferredWidth: 80
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    text: vehicleData.temperature
                                    color: AppTheme.colors.text
                                    font.pixelSize: AppTheme.typography.bodySmall
                                    font.weight: Font.Bold
                                    Layout.preferredWidth: 60
                                }
                                
                                Text {
                                    text: "°C"
                                    color: AppTheme.colors.textSecondary
                                    font.pixelSize: AppTheme.typography.labelSmall
                                    Layout.preferredWidth: 40
                                }
                                
                                Text {
                                    text: "5s ago"
                                    color: AppTheme.colors.textTertiary
                                    font.pixelSize: AppTheme.typography.labelSmall
                                    Layout.fillWidth: true
                                }
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 28
                            color: AppTheme.colors.surfaceVariant
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: AppTheme.spacing.small
                                spacing: AppTheme.spacing.small
                                
                                Text {
                                    text: "Vehicle.Gear"
                                    color: AppTheme.colors.text
                                    font.pixelSize: AppTheme.typography.bodySmall
                                    Layout.preferredWidth: 80
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    text: vehicleData.gear
                                    color: AppTheme.colors.primary
                                    font.pixelSize: AppTheme.typography.bodySmall
                                    font.weight: Font.Bold
                                    Layout.preferredWidth: 60
                                }
                                
                                Text {
                                    text: "str"
                                    color: AppTheme.colors.textSecondary
                                    font.pixelSize: AppTheme.typography.labelSmall
                                    Layout.preferredWidth: 40
                                }
                                
                                Text {
                                    text: "1s ago"
                                    color: AppTheme.colors.textTertiary
                                    font.pixelSize: AppTheme.typography.labelSmall
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // ====== BOTTOM: Record/Playback Controls ======
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            color: AppTheme.colors.surfaceElevated
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.small
                spacing: AppTheme.spacing.small
                
                // Record button
                Rectangle {
                    id: recordBtn
                    width: 110
                    height: 36
                    radius: AppTheme.radius.small
                    color: canLogger.isRecording ? AppTheme.colors.warning : AppTheme.colors.error
                    
                    Text {
                        text: canLogger.isRecording ? "■ Stop" : "● Record"
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                        anchors.centerIn: parent
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (systemStatus.connectionMode !== "CAN") {
                                notificationManager.showNotification("Recording requires CAN mode", 1, 3000);
                                return;
                            }
                            if (!canLogger.isRecording) {
                                // Generate timestamped path in local logs/ folder
                                const ts = Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm-ss");
                                root.lastLogPath = "logs/can_" + ts + ".bin";
                                const ok = canLogger.startRecording(root.lastLogPath);
                                if (ok) {
                                    notificationManager.showNotification("Recording CAN → " + root.lastLogPath, 0, 2500);
                                } else {
                                    notificationManager.showNotification("Failed to start recording", 2, 3500);
                                }
                            } else {
                                canLogger.stopRecording();
                                notificationManager.showNotification("Recording stopped", 0, 2000);
                            }
                        }
                    }
                }
                
                // Playback button
                Rectangle {
                    id: playbackBtn
                    width: 110
                    height: 36
                    radius: AppTheme.radius.small
                    color: canLogger.isPlayback ? AppTheme.colors.primary : AppTheme.colors.surfaceVariant
                    
                    Text {
                        text: canLogger.isPlayback ? "■ Stop" : "▶ Playback"
                        color: canLogger.isPlayback ? AppTheme.colors.text : AppTheme.colors.textSecondary
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                        anchors.centerIn: parent
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (canLogger.isPlayback) {
                                canLogger.stopPlayback();
                                notificationManager.showNotification("Playback stopped", 0, 2000);
                            } else {
                                if (!root.lastLogPath || root.lastLogPath.length === 0) {
                                    notificationManager.showNotification("No log loaded. Record first.", 1, 3000);
                                    return;
                                }
                                if (canLogger.loadPlayback(root.lastLogPath)) {
                                    canLogger.playPlayback();
                                    notificationManager.showNotification("Playing " + root.lastLogPath, 0, 2500);
                                } else {
                                    notificationManager.showNotification("Failed to load log", 2, 3500);
                                }
                            }
                        }
                    }
                }
                
                // Speed control (for playback)
                Rectangle {
                    id: speedBtn
                    width: 70
                    height: 36
                    radius: AppTheme.radius.small
                    color: AppTheme.colors.surfaceVariant
                    
                    Text {
                        text: speedIndex === 0 ? "0.5x" : (speedIndex === 1 ? "1.0x" : "2.0x")
                        color: AppTheme.colors.textSecondary
                        font.pixelSize: AppTheme.typography.labelSmall
                        anchors.centerIn: parent
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // Cycle 0.5x → 1.0x → 2.0x
                            root.speedIndex = (root.speedIndex + 1) % 3;
                            const speeds = [50, 100, 200];
                            canLogger.setPlaybackSpeed(speeds[root.speedIndex]);
                            notificationManager.showNotification("Speed " + (root.speedIndex === 0 ? "0.5x" : (root.speedIndex === 1 ? "1.0x" : "2.0x")), 0, 1500);
                        }
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // Export button
                Rectangle {
                    width: 80
                    height: 36
                    radius: AppTheme.radius.small
                    color: AppTheme.colors.surfaceVariant
                    
                    Text {
                        text: "⬇ Export"
                        color: AppTheme.colors.textSecondary
                        font.pixelSize: AppTheme.typography.labelSmall
                        anchors.centerIn: parent
                    }
                }
            }
            
            // Divider at top
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
