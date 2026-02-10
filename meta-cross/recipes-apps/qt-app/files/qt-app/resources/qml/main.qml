// File: resources/qml/main.qml
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

    // ---- Theme fallback (works even if AppTheme singleton is missing on Yocto) ----
    QtObject {
        id: theme

        property var colors: (typeof AppTheme !== "undefined" && AppTheme.colors) ? AppTheme.colors : ({
                primary: "#00BFFF",
                surface: "#05080e",
                text: "#e6f0ff",
                textSecondary: "#8FA4B8",
                info: "#1a4d5c",
                warning: "#ffb020",
                error: "#ff4444"
            })

        property var spacing: (typeof AppTheme !== "undefined" && AppTheme.spacing) ? AppTheme.spacing : ({
                small: 6,
                medium: 12,
                large: 16
            })

        property var radius: (typeof AppTheme !== "undefined" && AppTheme.radius) ? AppTheme.radius : ({
                medium: 10
            })

        property var typography: (typeof AppTheme !== "undefined" && AppTheme.typography) ? AppTheme.typography : ({
                bodyMedium: 14
            })
    }

    color: theme.colors.surface
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
        onActivated: console.log("[HMI] Debug shortcut triggered")
    }

    // ====== STATE MANAGEMENT ======
    property bool rightPanelVisible: false
    property bool showSplashScreen: true

    Timer {
        id: splashTimer
        interval: 2500
        running: true
        repeat: false
        onTriggered: showSplashScreen = false
    }

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
        Item {
            id: clusterContainer
            Layout.fillHeight: true
            Layout.preferredWidth: rightPanelVisible ? height * 2.5 : parent.width
            Layout.minimumWidth: height * 2.5
            Layout.maximumWidth: rightPanelVisible ? height * 2.5 : parent.width
            z: 100
            clip: true

            ClusterScreen {
                id: clusterScreen
                anchors.fill: parent
                width: parent.width
                height: parent.height

                Behavior on width {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutCubic
                    }
                }
                Behavior on height {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutCubic
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.InOutCubic
                }
            }
            Behavior on Layout.minimumWidth {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.InOutCubic
                }
            }
            Behavior on Layout.maximumWidth {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.InOutCubic
                }
            }

            // Elegant minimal toggle button
            Rectangle {
                id: panelToggle
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 30
                anchors.bottomMargin: 50
                width: 48
                height: 48
                radius: 24
                z: 200

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "#0a0f18"
                    }
                    GradientStop {
                        position: 1.0
                        color: "#05080e"
                    }
                }

                border.color: rightPanelVisible ? theme.colors.primary : "#1a2535"
                border.width: 1

                // Fake glow/shadow (no Effects)
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -4
                    radius: parent.radius + 4
                    color: rightPanelVisible ? theme.colors.primary : "#000000"
                    opacity: rightPanelVisible ? 0.18 : 0.10
                    z: -1
                }
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -10
                    radius: parent.radius + 10
                    color: rightPanelVisible ? theme.colors.primary : "#000000"
                    opacity: rightPanelVisible ? 0.07 : 0.05
                    z: -2
                }

                // Grid icon (three horizontal lines)
                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Repeater {
                        model: 3
                        Rectangle {
                            width: 20
                            height: 2
                            radius: 1
                            color: rightPanelVisible ? theme.colors.primary : "#8FA4B8"
                            anchors.horizontalCenter: parent.horizontalCenter

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: rightPanelVisible = !rightPanelVisible
                    onEntered: panelToggle.scale = 1.1
                    onExited: panelToggle.scale = 1.0
                    onPressed: panelToggle.scale = 0.95
                    onReleased: panelToggle.scale = containsMouse ? 1.1 : 1.0
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutBack
                    }
                }
                Behavior on border.color {
                    ColorAnimation {
                        duration: 200
                    }
                }
            }

            // Invisible edge detection area for elegant panel reveal
            MouseArea {
                id: edgeDetector
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 5
                z: 199
                hoverEnabled: true

                onEntered: edgeHoverTimer.start()
                onExited: edgeHoverTimer.stop()

                Timer {
                    id: edgeHoverTimer
                    interval: 300
                    repeat: false
                    onTriggered: {
                        if (edgeDetector.containsMouse && !rightPanelVisible)
                            rightPanelVisible = true;
                    }
                }
            }
        }

        // ====== RIGHT SIDE: SWIPEABLE CONTENT + VERTICAL TABBAR ======
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            visible: opacity > 0
            opacity: rightPanelVisible ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

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
                currentIndex: verticalTabBar.currentIndex
                z: 50
                clip: true

                NavigationScreen {}
                MediaScreen {}
                WeatherScreen {}
                SettingsScreen {}
                DiagnosticsScreen {}
            }

            // ====== VERTICAL TABBAR ======
            Item {
                id: verticalTabBar
                Layout.preferredWidth: 72
                Layout.fillHeight: true
                z: 40

                // NOTE: your original had recursion here; keep simple.
                property int currentIndex: 0

                Rectangle {
                    anchors.fill: parent
                    color: theme.colors.surface

                    // subtle fake glow
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -8
                        color: theme.colors.primary
                        opacity: 0.035
                        radius: 10
                        z: -2
                    }
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -16
                        color: theme.colors.primary
                        opacity: 0.02
                        radius: 14
                        z: -3
                    }
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8
                    topPadding: 12

                    TabIconButton {
                        width: 56
                        height: 56
                        isActive: verticalTabBar.currentIndex === 0
                        iconSource: "qrc:/icons/common/nav-mode.svg"
                        onClicked: verticalTabBar.currentIndex = 0
                    }
                    TabIconButton {
                        width: 56
                        height: 56
                        isActive: verticalTabBar.currentIndex === 1
                        iconSource: "qrc:/icons/common/media-mode.svg"
                        onClicked: verticalTabBar.currentIndex = 1
                    }
                    TabIconButton {
                        width: 56
                        height: 56
                        isActive: verticalTabBar.currentIndex === 2
                        iconSource: "qrc:/icons/weather/sun.svg"
                        onClicked: verticalTabBar.currentIndex = 2
                    }
                    TabIconButton {
                        width: 56
                        height: 56
                        isActive: verticalTabBar.currentIndex === 3
                        iconSource: "qrc:/icons/settings/brightness.svg"
                        onClicked: verticalTabBar.currentIndex = 3
                    }
                    TabIconButton {
                        width: 56
                        height: 56
                        isActive: verticalTabBar.currentIndex === 4
                        iconSource: "qrc:/icons/hardware/sensor.svg"
                        onClicked: verticalTabBar.currentIndex = 4
                    }
                }
            }
        }
    }

    // ====== NOTIFICATION TOAST CONTAINER ======
    Rectangle {
        id: notificationContainer
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: theme.spacing.medium
        width: 320
        height: childrenRect.height
        color: "transparent"
        z: 200

        Column {
            width: parent.width
            spacing: theme.spacing.small

            Repeater {
                model: notificationManager.notifications

                Rectangle {
                    width: notificationContainer.width
                    height: 52
                    radius: theme.radius.medium

                    color: {
                        switch (modelData.level) {
                        case 0:
                            return theme.colors.info;
                        case 1:
                            return theme.colors.warning;
                        case 2:
                            return theme.colors.error;
                        default:
                            return theme.colors.info;
                        }
                    }

                    opacity: 0
                    Component.onCompleted: opacity = 1

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutQuad
                        }
                    }

                    transform: Translate {
                        y: -20
                    }
                    Behavior on transform {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutBack
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: theme.spacing.medium
                        spacing: theme.spacing.medium

                        Text {
                            text: modelData.message
                            color: theme.colors.text
                            font.pixelSize: theme.typography.bodyMedium
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }
        }
    }

    // ====== SIMPLE SAFE SPLASH (no Effects, uses theme fallback) ======
    Rectangle {
        id: splashScreen
        anchors.fill: parent
        z: 300
        visible: opacity > 0
        opacity: showSplashScreen ? 1 : 0
        color: theme.colors.surface

        Behavior on opacity {
            NumberAnimation {
                duration: 800
                easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 360
            height: 360
            radius: 180
            color: theme.colors.primary
            opacity: 0.06
        }

        Text {
            anchors.centerIn: parent
            text: "DRIVAPI"
            font.pixelSize: 28
            font.weight: Font.Light
            font.letterSpacing: 6
            color: theme.colors.primary
            opacity: 0.95
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            anchors.topMargin: 42
            text: "Initializing..."
            font.pixelSize: 12
            font.weight: Font.Light
            letterSpacing: 1
            color: theme.colors.textSecondary
            opacity: 0.8
        }
    }

    // ====== CUSTOM TAB ICON BUTTON COMPONENT ======
    component TabIconButton: Rectangle {
        id: tabButton
        required property bool isActive
        required property string iconSource
        property bool isHovered: false
        signal clicked

        color: "transparent"
        radius: 6

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: tabButton.isActive ? theme.colors.primary : (tabButton.isHovered ? "#FFFFFF" : "transparent")
            opacity: tabButton.isActive ? 1 : (tabButton.isHovered ? 0.3 : 0.0)
            border.color: tabButton.isActive ? theme.colors.primary : (tabButton.isHovered ? "#8FA4B8" : "transparent")
            border.width: (tabButton.isActive || tabButton.isHovered) ? 1 : 0
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -6
            radius: parent.radius + 6
            color: tabButton.isActive ? theme.colors.primary : "#8FA4B8"
            opacity: tabButton.isActive ? 0.16 : (tabButton.isHovered ? 0.07 : 0.0)
            z: -1
            visible: tabButton.isActive || tabButton.isHovered
        }

        Behavior on scale {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutCubic
            }
        }

        Image {
            anchors.centerIn: parent
            width: 24
            height: 24
            source: tabButton.iconSource
            fillMode: Image.PreserveAspectFit
            opacity: isActive ? 0.85 : (tabButton.isHovered ? 0.6 : 0.35)
            mipmap: true

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: {
                tabButton.isHovered = true;
                if (!tabButton.isActive)
                    tabButton.scale = 1.05;
            }
            onExited: {
                tabButton.isHovered = false;
                tabButton.scale = 1.0;
            }
            onPressed: tabButton.scale = 0.92
            onReleased: {
                tabButton.scale = containsMouse ? 1.05 : 1.0;
                tabButton.clicked();
            }
        }

        onIsActiveChanged: scale = 1.0
    }
}
