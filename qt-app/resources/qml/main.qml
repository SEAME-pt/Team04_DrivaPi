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

    // ====== STATE MANAGEMENT ======
    property bool rightPanelVisible: true  // Toggle for right content panel

    // ====== CONNECTION STATE MONITORING ======
    Connections {
        target: systemStatus

        function onConnectionStateChanged() {
            var state = systemStatus.connectionState;
            var mode = systemStatus.connectionMode;

            if (state === "connected") {
                notificationManager.showNotification("✓ " + mode + " Connected", 0, 2000);
            } else if (state === "disconnected") {
                notificationManager.showNotification("✗ " + mode + " Disconnected", 2, 3000);
            } else if (state === "connecting") {
                notificationManager.showNotification("○ Connecting to " + mode + "...", 0, 2000);
            }
        }
    }

    // ====== MAIN LAYOUT ======
    RowLayout {
        anchors.fill: parent
        z: 1
        spacing: 0

        // ====== LEFT SIDE: PERSISTENT INSTRUMENT CLUSTER ======
        // Cluster should maintain its aspect ratio (1200:480 = 2.5:1)
        Item {
            id: clusterContainer
            Layout.fillHeight: true
            // When right panel is visible, give cluster its proper aspect ratio width
            Layout.preferredWidth: rightPanelVisible ? height * 2.5 : parent.width
            Layout.minimumWidth: height * 2.5  // Minimum width to maintain aspect ratio
            Layout.maximumWidth: rightPanelVisible ? height * 2.5 : parent.width
            z: 100

            // Clip to container bounds
            clip: true

            ClusterScreen {
                id: clusterScreen
                anchors.fill: parent

                // Force the cluster to scale to fit the container while maintaining aspect ratio
                width: parent.width
                height: parent.height
            }

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.InOutCubic
                }
            }

            // Minimal edge tab/handle
            Rectangle {
                id: toggleTab
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 280
                z: 200

                // Rounded corners (pill shape)
                radius: 12
                color: "#1a2a3a"

                // Subtle border
                border.color: Qt.rgba(0.3, 0.6, 1.0, 0.3)
                border.width: 1

                // Content column
                Column {
                    anchors.centerIn: parent
                    spacing: 16

                    // Three dots indicator
                    Repeater {
                        model: 3
                        Rectangle {
                            width: 4
                            height: 4
                            radius: 2
                            color: "#4fb3d9"
                            opacity: 0.9
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    Item {
                        height: 8
                    }  // Spacer

                    // Chevron indicator
                    Text {
                        text: rightPanelVisible ? "›" : "‹"
                        font.pixelSize: 28
                        font.weight: Font.Bold
                        color: "#4fb3d9"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                // Touch area (extended for easier tapping)
                MouseArea {
                    anchors.fill: parent
                    anchors.leftMargin: -20
                    anchors.topMargin: -20
                    anchors.bottomMargin: -20
                    onClicked: {
                        rightPanelVisible = !rightPanelVisible;
                    }

                    // Visual feedback
                    onPressed: toggleTab.opacity = 0.7
                    onReleased: toggleTab.opacity = 1.0
                    onCanceled: toggleTab.opacity = 1.0
                }

                // Smooth opacity transition
                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }
        }

        // ====== RIGHT SIDE: SWIPEABLE CONTENT + TABBAR ======
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 0
            spacing: 0
            visible: opacity > 0
            opacity: rightPanelVisible ? 1 : 0

            // Smooth fade animation
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            // Slide animation using transform
            transform: Translate {
                x: rightPanelVisible ? 0 : 400
                Behavior on x {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutCubic
                    }
                }
            }

            // ====== SWIPEABLE CONTENT SCREENS ======
            SwipeView {
                id: swipeView
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: tabBar.currentIndex
                z: 50   // Below cluster, above tab bar
                clip: true

                // Navigation screens
                NavigationScreen {
                    id: navigationScreen
                }
                MediaScreen {
                    id: mediaScreen
                }
                DiagnosticsScreen {
                    id: diagnosticsScreen
                }
                SettingsScreen {
                    id: settingsScreen
                }
                WeatherScreen {
                    id: weatherScreen
                }
                UtilitiesScreen {
                    id: utilitiesScreen
                }
            }

            // ====== TABBAR (only for right side) ======
            TabBar {
                id: tabBar
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                currentIndex: swipeView.currentIndex
                position: TabBar.Footer
                z: 40
                onCurrentIndexChanged: swipeView.currentIndex = currentIndex

                // Styling
                background: Rectangle {
                    color: AppTheme.colors.surfaceElevated
                    border.color: AppTheme.colors.divider
                    border.width: 1
                }

                // Tab buttons (6 total)
                TabButton {
                    text: "Navigation"
                    font.pixelSize: AppTheme.typography.labelMedium
                    font.weight: Font.Medium
                    width: implicitWidth
                    icon.source: tabBar.currentIndex === 0 ? "qrc:/icons/common/nav-mode-active.svg" : "qrc:/icons/common/nav-mode.svg"
                    icon.width: 20
                    icon.height: 20

                    background: Rectangle {
                        color: tabBar.currentIndex === 0 ? AppTheme.colors.primary : "transparent"
                        Behavior on color {
                            ColorAnimation {
                                duration: AppTheme.animation.normal
                            }
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: tabBar.currentIndex === 0 ? AppTheme.colors.text : AppTheme.colors.textSecondary
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
                    icon.source: tabBar.currentIndex === 1 ? "qrc:/icons/common/media-mode-active.svg" : "qrc:/icons/common/media-mode.svg"
                    icon.width: 20
                    icon.height: 20

                    background: Rectangle {
                        color: tabBar.currentIndex === 1 ? AppTheme.colors.primary : "transparent"
                        Behavior on color {
                            ColorAnimation {
                                duration: AppTheme.animation.normal
                            }
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: tabBar.currentIndex === 1 ? AppTheme.colors.text : AppTheme.colors.textSecondary
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
                    icon.source: "qrc:/icons/hardware/sensor.svg"
                    icon.width: 20
                    icon.height: 20

                    background: Rectangle {
                        color: tabBar.currentIndex === 2 ? AppTheme.colors.primary : "transparent"
                        Behavior on color {
                            ColorAnimation {
                                duration: AppTheme.animation.normal
                            }
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: tabBar.currentIndex === 2 ? AppTheme.colors.text : AppTheme.colors.textSecondary
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
                    icon.source: "qrc:/icons/settings/brightness.svg"
                    icon.width: 20
                    icon.height: 20

                    background: Rectangle {
                        color: tabBar.currentIndex === 3 ? AppTheme.colors.primary : "transparent"
                        Behavior on color {
                            ColorAnimation {
                                duration: AppTheme.animation.normal
                            }
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: tabBar.currentIndex === 3 ? AppTheme.colors.text : AppTheme.colors.textSecondary
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
                    text: "Weather"
                    font.pixelSize: AppTheme.typography.labelMedium
                    font.weight: Font.Medium
                    width: implicitWidth
                    icon.source: "qrc:/icons/weather/sun.svg"
                    icon.width: 20
                    icon.height: 20

                    background: Rectangle {
                        color: tabBar.currentIndex === 4 ? AppTheme.colors.primary : "transparent"
                        Behavior on color {
                            ColorAnimation {
                                duration: AppTheme.animation.normal
                            }
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: tabBar.currentIndex === 4 ? AppTheme.colors.text : AppTheme.colors.textSecondary
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
                    text: "Utilities"
                    font.pixelSize: AppTheme.typography.labelMedium
                    font.weight: Font.Medium
                    width: implicitWidth
                    icon.source: "qrc:/icons/common/menu.svg"
                    icon.width: 20
                    icon.height: 20

                    background: Rectangle {
                        color: tabBar.currentIndex === 5 ? AppTheme.colors.primary : "transparent"
                        Behavior on color {
                            ColorAnimation {
                                duration: AppTheme.animation.normal
                            }
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: tabBar.currentIndex === 5 ? AppTheme.colors.text : AppTheme.colors.textSecondary
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
    }

    // ====== NOTIFICATION TOAST CONTAINER (TOP-CENTER) ======
    Rectangle {
        id: notificationContainer
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: AppTheme.spacing.medium
        width: 320
        height: childrenRect.height
        color: "transparent"
        z: 200

        Column {
            width: parent.width
            spacing: AppTheme.spacing.small

            Repeater {
                model: notificationManager.notifications

                Rectangle {
                    width: notificationContainer.width
                    height: 52
                    radius: AppTheme.radius.medium

                    color: {
                        switch (modelData.level) {
                        case 0:
                            return AppTheme.colors.info;
                        case 1:
                            return AppTheme.colors.warning;
                        case 2:
                            return AppTheme.colors.error;
                        default:
                            return AppTheme.colors.info;
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
                }
            }
        }
    }
}
