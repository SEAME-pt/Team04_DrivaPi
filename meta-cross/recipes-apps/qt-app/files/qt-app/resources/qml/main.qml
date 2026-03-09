import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "screens/cluster-screen"
import "screens/media-screen"
import "screens/weather-screen"
import "screens/navigation-screen"
import "screens/diagnostics-screen"
import "screens/settings-screen"
import "theme"

ApplicationWindow {
    id: root
    visible: true
    width: 1280
    height: 400
    title: qsTr("DrivaPi HMI - Multi-Screen Infotainment")
    color: AppTheme.colors.surface

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
    property bool edgeHovered: false

    // ====== DYNAMIC THEME CONTROLLER ======
    function evaluateTheme() {
        if (!settingsManager)
            return;

        if (settingsManager.theme === "Light") {
            AppTheme.isDark = false;
        } else if (settingsManager.theme === "Dark") {
            AppTheme.isDark = true;
        } else {
            // "Auto" Mode: Switches to Dark Mode between 18:00 (6 PM) and 07:00 (7 AM)
            var hour = new Date().getHours();
            AppTheme.isDark = (hour >= 18 || hour < 7);
        }
    }

    Connections {
        target: settingsManager
        function onThemeChanged() {
            evaluateTheme();
        }
    }

    Timer {
        interval: 60000
        running: settingsManager !== null && settingsManager.theme === "Auto"
        repeat: true
        onTriggered: evaluateTheme()
    }

    Component.onCompleted: {
        evaluateTheme();
    }

    Timer {
        id: splashTimer
        interval: 2500
        running: true
        repeat: false
        onTriggered: showSplashScreen = false
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
                scale: 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutCubic
                    }
                }
                opacity: 1.0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
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

            // Toggle Button
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
                        color: AppTheme.colors.surfaceElevated
                    }
                    GradientStop {
                        position: 1.0
                        color: AppTheme.colors.surfaceVariant
                    }
                }

                border.color: rightPanelVisible ? AppTheme.colors.primary : AppTheme.colors.border
                border.width: 1

                // Glow Ring
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -8
                    radius: parent.radius + 4
                    color: "transparent"
                    border.color: AppTheme.colors.primary
                    border.width: 1
                    opacity: rightPanelVisible ? 0.4 : 0
                    z: -1
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }

                // Grid icon
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Repeater {
                        model: 3
                        Rectangle {
                            width: 20
                            height: 2
                            radius: 1
                            color: rightPanelVisible ? AppTheme.colors.primary : AppTheme.colors.textSecondary
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

            // Edge detection for auto-reveal
            MouseArea {
                id: edgeDetector
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 5
                z: 199
                hoverEnabled: true
                onEntered: edgeHoverTimer.start()
                onExited: {
                    edgeHoverTimer.stop();
                    edgeHovered = false;
                }
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

            // Tap-to-reveal on cluster
            MouseArea {
                anchors.fill: clusterScreen
                z: 1
                propagateComposedEvents: true
                readonly property real topDeadZone: clusterScreen.height * 0.14
                property int tapCount: 0
                property double lastTapTime: 0
                onPressed: mouse => {
                    if (mouse.y <= topDeadZone || mouse.y >= (clusterScreen.height - topDeadZone))
                        mouse.accepted = false;
                }
                onClicked: mouse => {
                    var currentTime = Date.now();
                    if (currentTime - lastTapTime < 400) {
                        tapCount++;
                        if (tapCount >= 2) {
                            rightPanelVisible = !rightPanelVisible;
                            tapCount = 0;
                        }
                    } else
                        tapCount = 1;
                    lastTapTime = currentTime;
                }
            }
        }

        // ====== RIGHT SIDE: SWIPEABLE CONTENT ======
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

            SwipeView {
                id: swipeView
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0
                z: 50
                clip: true
                onCurrentIndexChanged: verticalTabBar.currentIndex = currentIndex
                Behavior on currentIndex {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }

                NavigationScreen {
                    id: navigationScreen
                }
                MediaScreen {
                    id: mediaScreen
                }
                WeatherScreen {
                    id: weatherScreen
                }
                SettingsScreen {
                    id: settingsScreen
                }
                DiagnosticsScreen {
                    id: diagnosticsScreen
                }
            }

            // Vertical Tab Bar
            Item {
                id: verticalTabBar
                Layout.preferredWidth: 72
                Layout.fillHeight: true
                z: 40
                property int currentIndex: 0
                onCurrentIndexChanged: swipeView.currentIndex = currentIndex

                Rectangle {
                    anchors.fill: parent
                    color: AppTheme.colors.surfaceVariant
                }
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: AppTheme.colors.divider
                    border.width: 1
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8
                    topPadding: 12

                    TabIconButton {
                        isActive: verticalTabBar.currentIndex === 0
                        iconSource: "qrc:/icons/common/nav-mode.svg"
                        onClicked: verticalTabBar.currentIndex = 0
                    }
                    TabIconButton {
                        isActive: verticalTabBar.currentIndex === 1
                        iconSource: "qrc:/icons/common/media-mode.svg"
                        onClicked: verticalTabBar.currentIndex = 1
                    }
                    TabIconButton {
                        isActive: verticalTabBar.currentIndex === 2
                        iconSource: "qrc:/icons/weather/sun.svg"
                        onClicked: verticalTabBar.currentIndex = 2
                    }
                    TabIconButton {
                        isActive: verticalTabBar.currentIndex === 3
                        iconSource: "qrc:/icons/settings/gear.svg"
                        onClicked: verticalTabBar.currentIndex = 3
                    }
                    TabIconButton {
                        isActive: verticalTabBar.currentIndex === 4
                        iconSource: "qrc:/icons/hardware/sensor.svg"
                        onClicked: verticalTabBar.currentIndex = 4
                    }
                }
            }
        }
    }

    // ====== WELCOME SPLASH SCREEN ======
    Rectangle {
        id: splashScreen
        anchors.fill: parent
        z: 300  // Above everything
        visible: opacity > 0
        opacity: showSplashScreen ? 1 : 0
        color: AppTheme.colors.surface

        Behavior on opacity {
            NumberAnimation {
                duration: 800
                easing.type: Easing.InOutQuad
            }
        }

        // Gradient background with subtle depth
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.darker(AppTheme.colors.surface, 1.3)
                }
                GradientStop {
                    position: 1.0
                    color: AppTheme.colors.surface
                }
            }
        }

        // Subtle ambient glow effect (center)
        Rectangle {
            anchors.centerIn: parent
            width: 400
            height: 400
            radius: 200
            color: AppTheme.colors.primary
            opacity: 0.05
        }

        // Main logo container with glow
        Item {
            anchors.centerIn: parent
            width: 280
            height: 280

            // Outer glow layer (pulsing)
            Rectangle {
                anchors.centerIn: parent
                width: 200
                height: 200
                radius: 100
                color: "transparent"
                border.color: AppTheme.colors.primary
                border.width: 1
                opacity: 0.2

                SequentialAnimation on opacity {
                    running: showSplashScreen
                    PauseAnimation {
                        duration: 400
                    }
                    SequentialAnimation {
                        loops: Animation.Infinite
                        NumberAnimation {
                            from: 0.2
                            to: 0.6
                            duration: 1500
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            from: 0.6
                            to: 0.2
                            duration: 1500
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            // Middle ring
            Rectangle {
                anchors.centerIn: parent
                width: 160
                height: 160
                radius: 80
                color: "transparent"
                border.color: AppTheme.colors.primary
                border.width: 1.5
                opacity: 0

                SequentialAnimation on opacity {
                    running: showSplashScreen
                    PauseAnimation {
                        duration: 300
                    }
                    NumberAnimation {
                        to: 0.8
                        duration: 500
                        easing.type: Easing.OutQuad
                    }
                }
            }

            // Inner logo "D"
            Text {
                anchors.centerIn: parent
                text: "D"
                font.pixelSize: 110
                font.weight: Font.Bold
                color: AppTheme.colors.primary
                opacity: 0

                SequentialAnimation on opacity {
                    running: showSplashScreen
                    PauseAnimation {
                        duration: 600
                    }
                    NumberAnimation {
                        to: 1
                        duration: 400
                        easing.type: Easing.OutQuad
                    }
                }

                scale: 0.5
                SequentialAnimation on scale {
                    running: showSplashScreen
                    PauseAnimation {
                        duration: 600
                    }
                    NumberAnimation {
                        to: 1.0
                        duration: 600
                        easing.type: Easing.OutElastic
                    }
                }
            }

            // Animated arc/dash indicator
            Canvas {
                id: loadingArc
                anchors.fill: parent

                property real progress: 0
                onProgressChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    var centerX = width / 2;
                    var centerY = height / 2;
                    var radius = 90;
                    var lineWidth = 2;

                    ctx.strokeStyle = Qt.rgba(AppTheme.colors.primary.r, AppTheme.colors.primary.g, AppTheme.colors.primary.b, 0.6);
                    ctx.lineWidth = lineWidth;
                    ctx.lineCap = "round";

                    var startAngle = -Math.PI / 2;
                    var endAngle = startAngle + (progress * 2 * Math.PI);

                    ctx.beginPath();
                    ctx.arc(centerX, centerY, radius, startAngle, endAngle, false);
                    ctx.stroke();
                }

                SequentialAnimation {
                    running: showSplashScreen
                    PauseAnimation {
                        duration: 500
                    }
                    SequentialAnimation {
                        loops: Animation.Infinite
                        NumberAnimation {
                            target: loadingArc
                            property: "progress"
                            from: 0
                            to: 1
                            duration: 2000
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            text: "SYSTEM INITIALIZING..."
            color: AppTheme.colors.textSecondary
            font.pixelSize: 10
            font.letterSpacing: 2
            font.weight: Font.DemiBold
            opacity: 0.7
        }
    }

    // ====== CUSTOM TAB ICON COMPONENT ======
    component TabIconButton: Rectangle {
        id: tabButton
        required property bool isActive
        required property string iconSource
        property bool isHovered: false
        signal clicked

        width: 56
        height: 56
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"
        radius: 12

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: tabButton.isActive ? AppTheme.colors.primary : (tabButton.isHovered ? AppTheme.colors.surfaceElevated : "transparent")
            opacity: tabButton.isActive ? 1.0 : (tabButton.isHovered ? 0.5 : 0.0)
            border.color: tabButton.isActive ? AppTheme.colors.primary : AppTheme.colors.border
            border.width: (tabButton.isActive || tabButton.isHovered) ? 1 : 0
        }

        Image {
            id: iconImage
            anchors.centerIn: parent
            width: 26
            height: 26
            source: tabButton.iconSource
            fillMode: Image.PreserveAspectFit
            opacity: isActive ? 1.0 : 0.6
            layer.enabled: true
            layer.effect: ColorOverlay {
                color: tabButton.isActive ? "#FFFFFF" : AppTheme.colors.text
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
        Behavior on scale {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutCubic
            }
        }
    }

    // ====== BRIGHTNESS OVERLAY ======
    Rectangle {
        anchors.fill: parent
        z: 10000
        color: "black"
        opacity: settingsManager ? 0.5 - Math.max(0.1, settingsManager.screenBrightness) : 0
        enabled: false
    }
}
