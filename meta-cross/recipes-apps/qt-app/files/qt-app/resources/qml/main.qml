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

                scale: 1.0

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

                border.color: rightPanelVisible ? "#00BFFF" : "#1a2535"
                border.width: 1

                // --- portable fake glow (no QtQuick.Effects) ---
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -4
                    radius: parent.radius + 4
                    color: rightPanelVisible ? "#00BFFF" : "#000000"
                    opacity: rightPanelVisible ? 0.18 : 0.10
                    z: -1
                }
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -10
                    radius: parent.radius + 10
                    color: rightPanelVisible ? "#00BFFF" : "#000000"
                    opacity: rightPanelVisible ? 0.07 : 0.05
                    z: -2
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Repeater {
                        model: 3
                        Rectangle {
                            width: 20
                            height: 2
                            radius: 1
                            color: rightPanelVisible ? "#00BFFF" : "#8FA4B8"
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

            // Invisible edge detection area for panel reveal
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

            MouseArea {
                anchors.fill: clusterScreen
                z: 1
                enabled: !rightPanelVisible
                propagateComposedEvents: true

                readonly property real topDeadZone: clusterScreen.height * 0.14
                readonly property real bottomDeadZone: clusterScreen.height * 0.14

                property int tapCount: 0
                property double lastTapTime: 0

                function inDeadZone(y) {
                    return (y <= topDeadZone) || (y >= (clusterScreen.height - bottomDeadZone));
                }

                onPressed: mouse => {
                    if (inDeadZone(mouse.y)) {
                        mouse.accepted = false;
                        return;
                    }
                }

                onClicked: mouse => {
                    if (inDeadZone(mouse.y)) {
                        mouse.accepted = false;
                        return;
                    }

                    var currentTime = Date.now();
                    if (currentTime - lastTapTime < 400) {
                        tapCount++;
                        if (tapCount >= 2) {
                            rightPanelVisible = true;
                            tapCount = 0;
                        }
                    } else {
                        tapCount = 1;
                    }
                    lastTapTime = currentTime;
                }
            }
        }

        // ====== RIGHT SIDE: SWIPEABLE CONTENT + VERTICAL TABBAR ======
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 0
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
                currentIndex: verticalTabBar.currentIndex
                z: 50
                clip: true

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

            Item {
                id: verticalTabBar
                Layout.preferredWidth: 72
                Layout.fillHeight: true
                z: 40

                property int currentIndex: verticalTabBar.currentIndex >= 0 ? verticalTabBar.currentIndex : 0

                Rectangle {
                    anchors.fill: parent
                    color: "#05080e"

                    // portable “depth” (no Effects)
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -8
                        color: "#00BFFF"
                        opacity: 0.035
                        radius: 10
                        z: -2
                    }
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -16
                        color: "#00BFFF"
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
                        anchors.horizontalCenter: parent.horizontalCenter
                        isActive: verticalTabBar.currentIndex === 0
                        iconSource: "qrc:/icons/common/nav-mode.svg"
                        onClicked: verticalTabBar.currentIndex = 0
                    }
                    TabIconButton {
                        width: 56
                        height: 56
                        anchors.horizontalCenter: parent.horizontalCenter
                        isActive: verticalTabBar.currentIndex === 1
                        iconSource: "qrc:/icons/common/media-mode.svg"
                        onClicked: verticalTabBar.currentIndex = 1
                    }
                    TabIconButton {
                        width: 56
                        height: 56
                        anchors.horizontalCenter: parent.horizontalCenter
                        isActive: verticalTabBar.currentIndex === 2
                        iconSource: "qrc:/icons/weather/sun.svg"
                        onClicked: verticalTabBar.currentIndex = 2
                    }
                    TabIconButton {
                        width: 56
                        height: 56
                        anchors.horizontalCenter: parent.horizontalCenter
                        isActive: verticalTabBar.currentIndex === 3
                        iconSource: "qrc:/icons/settings/brightness.svg"
                        onClicked: verticalTabBar.currentIndex = 3
                    }
                    TabIconButton {
                        width: 56
                        height: 56
                        anchors.horizontalCenter: parent.horizontalCenter
                        isActive: verticalTabBar.currentIndex === 4
                        iconSource: "qrc:/icons/hardware/sensor.svg"
                        onClicked: verticalTabBar.currentIndex = 4
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

    // ====== WELCOME SPLASH SCREEN ======
    Rectangle {
        id: splashScreen
        anchors.fill: parent
        z: 300
        visible: opacity > 0
        opacity: showSplashScreen ? 1 : 0
        color: AppTheme.colors.surface

        Behavior on opacity {
            NumberAnimation {
                duration: 800
                easing.type: Easing.InOutQuad
            }
        }

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

        Rectangle {
            anchors.centerIn: parent
            width: 400
            height: 400
            radius: 200
            color: AppTheme.colors.primary
            opacity: 0.05
        }

        Item {
            anchors.centerIn: parent
            width: 280
            height: 280

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
            anchors.top: parent.verticalCenter
            anchors.topMargin: 160
            text: "DRIVAPI"
            font.pixelSize: 24
            font.weight: Font.Light
            font.letterSpacing: 4
            color: AppTheme.colors.primary
            opacity: 0

            SequentialAnimation on opacity {
                running: showSplashScreen
                PauseAnimation {
                    duration: 1200
                }
                NumberAnimation {
                    to: 0.9
                    duration: 500
                    easing.type: Easing.OutQuad
                }
            }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 80
            width: 240
            height: 2
            radius: 1
            color: AppTheme.colors.primary
            opacity: 0.2

            Rectangle {
                height: parent.height
                radius: 1
                color: AppTheme.colors.primary
                width: 0

                SequentialAnimation on width {
                    running: showSplashScreen
                    PauseAnimation {
                        duration: 300
                    }
                    SequentialAnimation {
                        loops: Animation.Infinite
                        NumberAnimation {
                            to: 240
                            duration: 2000
                            easing.type: Easing.InOutCubic
                        }
                        NumberAnimation {
                            to: 0
                            duration: 400
                            easing.type: Easing.InQuad
                        }
                    }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            text: "Initializing..."
            font.pixelSize: 12
            font.weight: Font.Light
            font.letterSpacing: 1
            color: AppTheme.colors.textSecondary
            opacity: 0

            SequentialAnimation on opacity {
                running: showSplashScreen
                PauseAnimation {
                    duration: 1500
                }
                NumberAnimation {
                    to: 0.6
                    duration: 400
                    easing.type: Easing.OutQuad
                }
            }
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

        // background
        Rectangle {
            anchors.fill: parent
            radius: 6
            color: tabButton.isActive ? "#00BFFF" : (tabButton.isHovered ? "#FFFFFF" : "transparent")
            opacity: tabButton.isActive ? 1 : (tabButton.isHovered ? 0.3 : 0.0)
            border.color: tabButton.isActive ? "#00BFFF" : (tabButton.isHovered ? "#8FA4B8" : "transparent")
            border.width: (tabButton.isActive || tabButton.isHovered) ? 1 : 0
        }

        // portable fake glow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -6
            radius: parent.radius + 6
            color: tabButton.isActive ? "#00BFFF" : "#8FA4B8"
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
