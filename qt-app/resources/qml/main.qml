import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import "screens"
import "components"
import "theme"

ApplicationWindow {
    id: root
    visible: true
    width: 1280
    height: 400
    title: qsTr("DrivaPi HMI - Multi-Screen Infotainment")
    color: AppTheme.colors.surface
    
    // Keep a sensible minimum for 1280x400 while allowing resize for testing
    minimumWidth: 1280
    minimumHeight: 400
    
    // ====== KEYBOARD SHORTCUTS ======
    Shortcut {
        sequence: "Ctrl+Q"
        context: Qt.ApplicationShortcut
        onActivated: Qt.quit()
    }
    
    Shortcut {
        sequence: "Ctrl+D"
        context: Qt.ApplicationShortcut
        onActivated: {
            // Toggle debug/diagnostics (placeholder for future)
            console.log("[HMI] Debug shortcut triggered");
        }
    }
    
    // ====== MAIN LAYOUT ======
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // ====== CONTENT AREA (SwipeView with 5 screens) ======
        SwipeView {
            id: swipeView
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex
            clip: true
            
            // Interactive swiping between screens
            interactive: true
            
            // Smooth transition animation
            transitions: Transition {
                NumberAnimation {
                    property: "contentX"
                    duration: AppTheme.animation.normal
                    easing.type: Easing.InOutQuad
                }
            }
            
            // Screen 1: Cluster (Driving Display)
            ClusterScreen {
                id: clusterScreen
            }
            
            // Screen 2: Navigation
            NavigationScreen {
                id: navigationScreen
            }
            
            // Screen 3: Media Player
            MediaScreen {
                id: mediaScreen
            }
            
            // Screen 4: Diagnostics
            DiagnosticsScreen {
                id: diagnosticsScreen
            }
            
            // Screen 5: Settings
            SettingsScreen {
                id: settingsScreen
            }
        }
        
        // ====== BOTTOM NAVIGATION TAB BAR ======
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            currentIndex: swipeView.currentIndex
            position: TabBar.Footer
            
            // Styling
            background: Rectangle {
                color: AppTheme.colors.surfaceElevated
                border.color: AppTheme.colors.divider
                border.width: 1
            }
            
            // Tab buttons
            TabButton {
                text: "Cluster"
                font.pixelSize: AppTheme.typography.labelMedium
                font.weight: Font.Medium
                width: implicitWidth
                
                background: Rectangle {
                    color: tabBar.currentIndex === 0 
                        ? AppTheme.colors.primary 
                        : "transparent"
                    border.width: 0
                    
                    // Smooth color transition
                    Behavior on color {
                        ColorAnimation {
                            duration: AppTheme.animation.normal
                        }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    color: tabBar.currentIndex === 0 
                        ? AppTheme.colors.text 
                        : AppTheme.colors.textSecondary
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    
                    // Smooth text color transition
                    Behavior on color {
                        ColorAnimation {
                            duration: AppTheme.animation.normal
                        }
                    }
                }
            }
            
            TabButton {
                text: "Navigation"
                font.pixelSize: AppTheme.typography.labelMedium
                font.weight: Font.Medium
                width: implicitWidth
                
                background: Rectangle {
                    color: tabBar.currentIndex === 1 
                        ? AppTheme.colors.primary 
                        : "transparent"
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: AppTheme.animation.normal
                        }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    color: tabBar.currentIndex === 1 
                        ? AppTheme.colors.text 
                        : AppTheme.colors.textSecondary
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: AppTheme.animation.normal
                        }
                    }
                }
            }
            
            TabButton {
                text: "Media"
                font.pixelSize: AppTheme.typography.labelMedium
                font.weight: Font.Medium
                width: implicitWidth
                
                background: Rectangle {
                    color: tabBar.currentIndex === 2 
                        ? AppTheme.colors.primary 
                        : "transparent"
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: AppTheme.animation.normal
                        }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    color: tabBar.currentIndex === 2 
                        ? AppTheme.colors.text 
                        : AppTheme.colors.textSecondary
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: AppTheme.animation.normal
                        }
                    }
                }
            }
            
            TabButton {
                text: "Diagnostics"
                font.pixelSize: AppTheme.typography.labelMedium
                font.weight: Font.Medium
                width: implicitWidth
                
                background: Rectangle {
                    color: tabBar.currentIndex === 3 
                        ? AppTheme.colors.primary 
                        : "transparent"
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: AppTheme.animation.normal
                        }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    color: tabBar.currentIndex === 3 
                        ? AppTheme.colors.text 
                        : AppTheme.colors.textSecondary
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: AppTheme.animation.normal
                        }
                    }
                }
            }
            
            TabButton {
                text: "Settings"
                font.pixelSize: AppTheme.typography.labelMedium
                font.weight: Font.Medium
                width: implicitWidth
                
                background: Rectangle {
                    color: tabBar.currentIndex === 4 
                        ? AppTheme.colors.primary 
                        : "transparent"
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: AppTheme.animation.normal
                        }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    color: tabBar.currentIndex === 4 
                        ? AppTheme.colors.text 
                        : AppTheme.colors.textSecondary
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    
                    Behavior on color {
                        ColorAnimation {
                            duration: AppTheme.animation.normal
                        }
                    }
                }
            }
        }
    }
    
    // ====== STATUS BAR OVERLAY (TOP) ======
    Rectangle {
        id: statusBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 48
        color: AppTheme.colors.surfaceElevated
        border.color: AppTheme.colors.divider
        border.width: 1
        z: 100
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: AppTheme.spacing.small
            spacing: AppTheme.spacing.small
            
            // Time (left)
            Text {
                text: Qt.formatDateTime(new Date(), "hh:mm:ss")
                color: AppTheme.colors.text
                font.pixelSize: AppTheme.typography.bodySmall
                
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: parent.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
                }
            }
            
            Item { Layout.fillWidth: true }
            
            // Connection Status (right)
            RowLayout {
                spacing: AppTheme.spacing.small
                
                // Status indicator
                Rectangle {
                    width: 12
                    height: 12
                    radius: width / 2
                    color: systemStatus.connectionState === "connected" 
                        ? AppTheme.colors.online 
                        : systemStatus.connectionState === "connecting"
                        ? AppTheme.colors.warning
                        : AppTheme.colors.offline
                }
                
                Text {
                    text: systemStatus.connectionMode + " - " + systemStatus.frameRate + " fps"
                    color: AppTheme.colors.text
                    font.pixelSize: AppTheme.typography.bodySmall
                }
            }
        }
    }
    
    // ====== NOTIFICATION TOAST CONTAINER (TOP-CENTER) ======
    Rectangle {
        id: notificationContainer
        anchors.top: statusBar.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: AppTheme.spacing.medium
        width: 320
        height: childrenRect.height
        color: "transparent"
        z: 200
        
        Column {
            width: parent.width
            spacing: AppTheme.spacing.small
            
            // Dynamically create toasts from notificationManager.notifications
            Repeater {
                model: notificationManager.notifications
                
                Rectangle {
                    width: notificationContainer.width
                    height: 52
                    radius: AppTheme.radius.medium
                    
                    // Color based on alert level
                    color: {
                        switch (modelData.level) {
                        case 0: return AppTheme.colors.info        // Info
                        case 1: return AppTheme.colors.warning     // Warning
                        case 2: return AppTheme.colors.error       // Critical
                        default: return AppTheme.colors.info
                        }
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: AppTheme.spacing.medium
                        spacing: AppTheme.spacing.medium
                        
                        Text {
                            text: modelData.message
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.bodyMedium
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                    }
                    
                    // Fade out animation
                    NumberAnimation on opacity {
                        from: 1.0
                        to: 1.0
                        duration: 0
                    }
                }
            }
        }
    }
}
