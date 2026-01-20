import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    color: AppTheme.colors.surface
    
    // ====== MAIN LAYOUT (LEFT: Album Art + RIGHT: Controls) ======
    RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0
        
        // ====== LEFT: Album Art Area ======
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.35
            color: AppTheme.colors.surfaceVariant
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.medium
                spacing: AppTheme.spacing.medium
                
                // Album art placeholder
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: AppTheme.radius.medium
                    color: AppTheme.colors.surfaceElevated
                    
                    Text {
                        text: "🎵"
                        font.pixelSize: 64
                        anchors.centerIn: parent
                    }
                }
            }
        }
        
        // ====== RIGHT: Track Info + Controls ======
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: AppTheme.colors.surface
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.large
                spacing: AppTheme.spacing.medium
                
                // ====== TRACK INFO ======
                ColumnLayout {
                    spacing: AppTheme.spacing.small
                    Layout.fillWidth: true
                    
                    // Song title
                    Text {
                        text: "Send Me Your Love"
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.headlineSmall
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }
                    
                    // Artist name
                    Text {
                        text: "OneRepublic"
                        color: AppTheme.colors.textSecondary
                        font.pixelSize: AppTheme.typography.bodyMedium
                    }
                    
                    // Album name
                    Text {
                        text: "Dreaming Out Loud"
                        color: AppTheme.colors.textTertiary
                        font.pixelSize: AppTheme.typography.bodySmall
                    }
                }
                
                // ====== TIME SLIDER ======
                ColumnLayout {
                    spacing: AppTheme.spacing.small
                    Layout.fillWidth: true
                    
                    // Progress bar
                    Rectangle {
                        Layout.fillWidth: true
                        height: 4
                        radius: 2
                        color: AppTheme.colors.surfaceVariant
                        
                        Rectangle {
                            width: parent.width * 0.45
                            height: parent.height
                            radius: 2
                            color: AppTheme.colors.primary
                        }
                    }
                    
                    // Time display
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.small
                        
                        Text {
                            text: "2:15"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: "4:50"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                        }
                    }
                }
                
                Item { Layout.fillHeight: true }
                
                // ====== PLAYBACK CONTROLS ======
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    spacing: AppTheme.spacing.medium
                    
                    // Previous
                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: AppTheme.radius.small
                        color: AppTheme.colors.surfaceVariant
                        
                        Image {
                            source: "qrc:/icons/controls/previous.svg"
                            width: 24
                            height: 24
                            sourceSize: Qt.size(24, 24)
                            anchors.centerIn: parent
                        }
                    }
                    
                    // Play/Pause (large)
                    Rectangle {
                        id: playPauseBtn
                        Layout.preferredWidth: 64
                        Layout.preferredHeight: 64
                        radius: AppTheme.radius.medium
                        color: AppTheme.colors.primary
                        
                        property bool isPlaying: true
                        
                        Image {
                            source: playPauseBtn.isPlaying ? "qrc:/icons/controls/pause.svg" : "qrc:/icons/controls/play.svg"
                            width: 32
                            height: 32
                            sourceSize: Qt.size(32, 32)
                            anchors.centerIn: parent
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: playPauseBtn.isPlaying = !playPauseBtn.isPlaying
                        }
                    }
                    
                    // Next
                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: AppTheme.radius.small
                        color: AppTheme.colors.surfaceVariant
                        
                        Image {
                            source: "qrc:/icons/controls/next.svg"
                            width: 24
                            height: 24
                            sourceSize: Qt.size(24, 24)
                            anchors.centerIn: parent
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    // Shuffle
                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: AppTheme.radius.small
                        color: AppTheme.colors.surfaceVariant
                        
                        Image {
                            source: "qrc:/icons/controls/shuffle.svg"
                            width: 20
                            height: 20
                            sourceSize: Qt.size(20, 20)
                            anchors.centerIn: parent
                        }
                    }
                    
                    // Repeat
                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: AppTheme.radius.small
                        color: AppTheme.colors.surfaceVariant
                        
                        Image {
                            source: "qrc:/icons/controls/repeat.svg"
                            width: 20
                            height: 20
                            sourceSize: Qt.size(20, 20)
                            anchors.centerIn: parent
                        }
                    }
                }
                
                // ====== VOLUME CONTROL ======
                ColumnLayout {
                    spacing: AppTheme.spacing.small
                    Layout.fillWidth: true
                    
                    Text {
                        text: "Volume"
                        color: AppTheme.colors.textSecondary
                        font.pixelSize: AppTheme.typography.labelSmall
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.small
                        
                        Image {
                            source: "qrc:/icons/controls/volume-mute.svg"
                            width: 20
                            height: 20
                            sourceSize: Qt.size(20, 20)
                        }
                        
                        // Volume slider
                        Rectangle {
                            Layout.fillWidth: true
                            height: 4
                            radius: 2
                            color: AppTheme.colors.surfaceVariant
                            
                            Rectangle {
                                width: parent.width * 0.75
                                height: parent.height
                                radius: 2
                                color: AppTheme.colors.primary
                            }
                        }
                        
                        Image {
                            source: "qrc:/icons/controls/volume-high.svg"
                            width: 20
                            height: 20
                            sourceSize: Qt.size(20, 20)
                        }
                    }
                }
            }
        }
    }
}
