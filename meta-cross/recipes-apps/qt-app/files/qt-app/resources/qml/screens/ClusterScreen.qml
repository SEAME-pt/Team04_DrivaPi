import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../components"
import "../theme"

Rectangle {
    id: root

    property real motionPhase: 0

    // Speed used by motion simulation (supports reverse if negative)
    readonly property real motionSpeedKmh: currentSpeed
    readonly property real motionSpeedAbs: Math.abs(motionSpeedKmh)
    readonly property real motionDir: {
        // Reverse animation if gear is "R"
        if (currentGear === "R") return -1;
        return 1;
    }

    // REAL-WORLD CALIBRATION: 4 m/s = 14.4 km/h = full intensity
    readonly property real realMaxSpeedKmh: 14.4
    readonly property real motionIntensity: clamp(motionSpeedAbs / realMaxSpeedKmh, 0, 1)

    function wrap01(t) {
        t = t % 1;
        return t < 0 ? (t + 1) : t;
    }

    // ISO 26262 Fail-Safe: Null/Invalid Data Handling
    property bool vehicleDataAvailable: vehicleData !== null && vehicleData !== undefined

    // Demo / fallback (replace with your real signal if you have it)
    // ISO 26262 ASIL requirement: Valid fallback for critical safety display
    property int speedLimitValue: vehicleDataAvailable && vehicleData.speedLimit ? Math.round(vehicleData.speedLimit) : 120
    property real currentSpeed: vehicleDataAvailable && vehicleData.speed ? vehicleData.speed : 0
    property int currentBattery: vehicleDataAvailable && vehicleData.battery !== undefined ? vehicleData.battery : 0
    property int stm32Battery: vehicleDataAvailable && vehicleData.stm32Battery !== undefined ? vehicleData.stm32Battery : 0
    property int rpiBattery: vehicleDataAvailable && vehicleData.rpiBattery !== undefined ? vehicleData.rpiBattery : 0
    property string currentGear: vehicleDataAvailable && vehicleData.gear ? vehicleData.gear : "P"
    property real tripDistance: vehicleDataAvailable && vehicleData.trip ? vehicleData.trip : 568
    property real powerOutput: vehicleDataAvailable && vehicleData.power ? vehicleData.power : 98

    // ====== Odometer State ======
    property real odometerDistance: 0
    property real accumulatedDistance: 0
    property real lastTimestamp: 0
    property bool showOdometerReset: false

    // Initialize odometer with vehicleData value
    Component.onCompleted: {
        if (vehicleDataAvailable && vehicleData.odo > 0) {
            odometerDistance = vehicleData.odo;
            console.log("[ClusterScreen] Initialized odometer from vehicleData:", odometerDistance, "km");
        }
    }

    // Listen for changes in vehicleData.odo (sync with backend changes)
    Connections {
        target: vehicleData
        enabled: vehicleDataAvailable
        function onOdometerChanged() {
            // If backend updates odometer, sync it
            if (vehicleData.odo > odometerDistance) {
                odometerDistance = vehicleData.odo;
                console.log("[ClusterScreen] Odometer synced from backend:", odometerDistance, "km");
            }
        }
        function onStm32BatteryChanged() {
            // Update dual battery display
            console.log("[ClusterScreen] STM32 Battery changed to:", vehicleData.stm32Battery, "%");
        }
        function onRpiBatteryChanged() {
            // Update dual battery display
            console.log("[ClusterScreen] RPi Battery changed to:", vehicleData.rpiBattery, "%");
        }
    }

    Timer {
        id: odometerUpdateTimer
        interval: 100  // Update every 100ms
        running: true
        repeat: true

        onTriggered: {
            if (!vehicleDataAvailable)
                return;

            var currentTime = new Date().getTime();
            if (lastTimestamp === 0) {
                lastTimestamp = currentTime;
                return;
            }

            // Calculate elapsed time in seconds
            var elapsedSeconds = (currentTime - lastTimestamp) / 1000;
            lastTimestamp = currentTime;

            // Speed is already in km/h from currentSpeed property
            var speedKmh = currentSpeed;
            var timeHours = elapsedSeconds / 3600;  // Convert seconds to hours
            var distanceTraveled = speedKmh * timeHours;  // Distance in km

            // Accumulate distance
            accumulatedDistance += distanceTraveled;

            // Update odometer when threshold reached
            if (accumulatedDistance >= 0.01 && speedKmh > 0.5) {  // 10 meters
                odometerDistance += accumulatedDistance;
                accumulatedDistance = 0;  // Reset accumulator
            }
        }
    }

    // Reset odometer function
    function resetOdometer() {
        odometerDistance = 0;
        accumulatedDistance = 0;
        // Update backend too
        if (vehicleDataAvailable) {
            vehicleData.setOdometer(0);
        }
        showOdometerReset = true;
        resetOdometerTimer.start();
        console.log("[ClusterScreen] Odometer reset to 0 km");
    }

    Timer {
        id: resetOdometerTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: showOdometerReset = false
    }

    // ====== END Odometer Logic ======
    // Design Constants (ISO 26262 Instrument Cluster Compliance)
    // ============================================================
    // Font Sizes (consolidated for WCAG AA accessibility)
    property int fontSizeXL: 132         // Primary speed display
    property int fontSizeLarge: 44       // Speed limit indicator
    property int fontSizeMedium: 22      // Bottom bar, labels
    property int fontSizeSmall: 18       // Secondary information
    property int fontSizeXSmall: 13      // Tertiary information

    // Speed limit indicator glow sizes (pixels)
    property int speedLimitOuterGlow: 128
    property int speedLimitMidGlow: 116
    property int speedLimitInnerGlow: 110
    property int speedLimitMainCircle: 102
    property int speedLimitBorderWidth: 9

    // Road rendering parameters
    property real roadWidthFactor: 0.85
    property real roadHeightFactor: 3.5
    property real roadBaseOffset: -0.8
    property real horizonMarginRatio: 0.15

    // Responsive scaling (1200x480 reference)
    property real refW: 1200
    property real refH: 480
    property real sx: width / refW
    property real sy: height / refH
    property real s: Math.min(sx, sy)

    function clamp(v, a, b) {
        return Math.max(a, Math.min(v, b));
    }

    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: AppTheme.colors.surfaceVariant
        }
        GradientStop {
            position: 0.5
            color: AppTheme.colors.surface
        }
        GradientStop {
            position: 1.0
            color: AppTheme.colors.surfaceVariant
        }
    }

    // ==========================================================
    // BACKGROUND LAYER (Glows + Road)
    // ==========================================================
    Item {
        id: backgroundLayer
        anchors.fill: parent
        z: 0

        // --- Top Glow Layer ---
        Image {
            source: "qrc:/assets/oie_kUl6AfLcsUwE.png"
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 36 * 2.5 * root.s
            opacity: AppTheme.isDark ? 0.95 : 0.3
            z: 1

			layer.enabled: true
			layer.effect: ColorOverlay {
				// When light mode is active, we color the asset white or light blue
				// to contrast against the light gray surface.
				color: AppTheme.isDark ? "transparent" : AppTheme.surfaceVariant

				Behavior on color { ColorAnimation { duration: AppTheme.animation.normal } }
			}
        }

        // --- Center Left Glow Layer ---
        Image {
			source: "qrc:/assets/left-dashboard.png"
			anchors.verticalCenter: parent.verticalCenter
			anchors.left: parent.left
			anchors.horizontalCenterOffset: parent.width * 0.225
			width: parent.width * 0.45
			height: parent.height * 0.60
			opacity: AppTheme.isDark ? 0.95 : 0.5
			z: 1

			layer.enabled: true
			layer.effect: ColorOverlay {
				// When light mode is active, we color the asset white or light blue
				// to contrast against the light gray surface.
				color: AppTheme.isDark ? "transparent" : AppTheme.surfaceVariant

				Behavior on color { ColorAnimation { duration: AppTheme.animation.normal } }
			}
		}

        // --- Center Right Glow Layer ---
        Image {
            source: "qrc:/assets/right-dashboard.png"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.horizontalCenterOffset: -parent.width * 0.225
            width: parent.width * 0.45
            height: parent.height * 0.60
            opacity: AppTheme.isDark ? 0.95 : 0.3
            z: 1

			layer.enabled: true
			layer.effect: ColorOverlay {
				// When light mode is active, we color the asset white or light blue
				// to contrast against the light gray surface.
				color: AppTheme.isDark ? "transparent" : AppTheme.surfaceVariant

				Behavior on color { ColorAnimation { duration: AppTheme.animation.normal } }
			}
        }

        // --- Bottom Glow Layer ---
        Image {
            source: "qrc:/assets/oie_OeB7IAtTvDtn.png"
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            width: parent.width * 0.95
            height: 36 * 3.5 * root.s
            opacity: AppTheme.isDark ? 0.95 : 0.3
            z: 1

			layer.enabled: true
			layer.effect: ColorOverlay {
				// When light mode is active, we color the asset white or light blue
				// to contrast against the light gray surface.
				color: AppTheme.isDark ? "transparent" : AppTheme.surfaceVariant

				Behavior on color { ColorAnimation { duration: AppTheme.animation.normal } }
			}
        }

        // ==========================================================
        // ROAD LAYER (road.png is the only lane source)
        // ==========================================================
        Item {
            id: roadLayer
            anchors.fill: parent

            Item {
                id: roadWindow
                z: 0
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                anchors.topMargin: root.clamp(parent.height * root.horizonMarginRatio, 64 * root.sy, 130 * root.sy)
                clip: true

                property real roadW: width * root.roadWidthFactor
                property real roadH: height * root.roadHeightFactor
                property real baseY: -height * Math.abs(root.roadBaseOffset)

                Image {
                    id: roadImg1
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: roadWindow.roadW
                    height: roadWindow.roadH
                    y: roadWindow.baseY
                    source: "qrc:/assets/road.png"
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    opacity: 0.95
                }

                Image {
                    id: roadImg2
                    visible: false
                    source: "qrc:/assets/road.png"
                }

                // ===== Horizon integration: blur + fade (top only) =====
                // Simplified horizon blend without MultiEffect
                Item {
                    id: horizonBlend
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: roadWindow.anchors.topMargin + 180 * root.sy
                    clip: true
                    z: 4

                    // Blurred road image (using opacity/scale for subtle effect)
                    Image {
                        x: roadImg1.x
                        y: roadImg1.y
                        width: roadImg1.width
                        height: roadImg1.height
                        source: roadImg1.source
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        opacity: 0.15
                        scale: 1.05  // Slightly enlarged for blur effect
                    }

                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            GradientStop {
                                position: 0.00
                                color: AppTheme.alpha(AppTheme.colors.surface, 1.0)
                            }
                            GradientStop {
                                position: 0.35
                                color: AppTheme.alpha(AppTheme.colors.surface, 0.8)
                            }
                            GradientStop {
                                position: 0.70
                                color: AppTheme.alpha(AppTheme.colors.surface, 0.88)
                            }
                            GradientStop {
                                position: 1.00
                                color: AppTheme.alpha(AppTheme.colors.surface, 0.0)
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            GradientStop {
                                position: 0.00
                                color: AppTheme.alpha(AppTheme.colors.surface, 1.0)
                            }
                            GradientStop {
                                position: 0.55
                                color: AppTheme.alpha(AppTheme.colors.surface, 0.56)
                            }
                            GradientStop {
                                position: 1.00
                                color: AppTheme.alpha(AppTheme.colors.surface, 0.0)
                            }
                        }
                        opacity: 0.55
                    }
                }

                // ===== Center dashed lane line =====
                Item {
                    id: laneLines
                    width: roadWindow.roadW
                    x: (parent.width - width) / 2
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    z: 3
                    visible: true
                    clip: true

                    readonly property real startY: roadWindow.anchors.topMargin + 120 * root.sy
                    readonly property int dashCount: 12
                    readonly property real dashBaseH: 26 * root.sy
                    readonly property real travel: (height - startY) + dashBaseH * 2

                    function dashY(i) {
                        return startY - dashBaseH + root.wrap01(root.motionPhase + (i / dashCount)) * travel;
                    }
                    function tForY(y) {
                        return root.clamp((y - startY + dashBaseH) / travel, 0, 1);
                    }
                    function dashW(y) {
                        var t = tForY(y);
                        return (2.0 + 8.0 * t) * root.s;
                    }
                    function dashH(y) {
                        var t = tForY(y);
                        return dashBaseH * (0.30 + 0.70 * t);
                    }
                    function dashOpacity(y) {
                        var t = tForY(y);
                        var baseOpacity = 0.12 + 0.18 * root.motionIntensity;
                        return baseOpacity * Math.pow(t, 1.35);
                    }

                    Repeater {
                        model: laneLines.dashCount
                        Rectangle {
                            property real yy: laneLines.dashY(index)
                            y: yy
                            width: laneLines.dashW(yy)
                            height: laneLines.dashH(yy)
                            x: (parent.width - width) / 2
                            radius: width / 2
                            color: AppTheme.colors.primary
                            opacity: laneLines.dashOpacity(yy)
                        }
                    }
                }

                // ===== Two faint "flow lines" =====
                Item {
                    id: laneFlow
                    width: roadWindow.roadW * 0.45
                    x: (parent.width - width) / 2
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    z: 3
                    visible: true
                    clip: true

                    readonly property real startY: roadWindow.anchors.topMargin + 140 * root.sy
                    readonly property int streakCount: 8
                    readonly property real baseLen: 80 * root.sy
                    readonly property real travel: (height - startY) + baseLen * 2

                    function yFor(i) {
                        return startY - baseLen + root.wrap01(root.motionPhase + (i / streakCount)) * travel;
                    }
                    function tForY(y) {
                        return root.clamp((y - startY + baseLen) / travel, 0, 1);
                    }
                    function xOffset(t) {
                        return (8 + 20 * t) * root.s;
                    }

                    Repeater {
                        model: laneFlow.streakCount
                        Item {
                            property real yy: laneFlow.yFor(index)
                            readonly property real t: laneFlow.tForY(yy)

                            y: yy
                            width: parent.width
                            height: laneFlow.baseLen * (0.4 + 0.8 * t) * (0.6 + 0.6 * root.motionIntensity)

                            readonly property real a: (0.15 + 0.25 * root.motionIntensity) * Math.pow(t, 1.2)
                            readonly property real w: (2.0 + 4.0 * t) * root.s

                            Rectangle {
                                x: (parent.width / 2) - laneFlow.xOffset(parent.t) - (parent.w / 2)
                                width: parent.w
                                height: parent.height
                                radius: width / 2
                                color: AppTheme.colors.primary
                                opacity: parent.a
                            }

                            Rectangle {
                                x: (parent.width / 2) + laneFlow.xOffset(parent.t) - (parent.w / 2)
                                width: parent.w
                                height: parent.height
                                radius: width / 2
                                color: AppTheme.colors.primary
                                opacity: parent.a
                            }
                        }
                    }
                }

                // --- Motion Shadows (3 bands) ---
                Item {
                    id: motionShadows
                    anchors.fill: parent
                    z: 2

                    readonly property real bandH: Math.max(40 * root.sy, parent.height * 0.22)
                    readonly property real travel: parent.height + bandH * 2

                    function bandY(offset) {
                        return -bandH + root.wrap01(root.motionPhase + offset) * travel;
                    }

                    Rectangle {
                        width: roadWindow.roadW * 0.98
                        height: motionShadows.bandH
                        x: (parent.width - width) / 2
                        y: motionShadows.bandY(0.00)
                        radius: 22 * root.s
                        opacity: 0.08 + 0.18 * root.motionIntensity
                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: AppTheme.alpha(AppTheme.colors.text, 0.0)
                            }
                            GradientStop {
                                position: 0.5
                                color: AppTheme.colors.text
                            }
                            GradientStop {
                                position: 1.0
                                color: AppTheme.alpha(AppTheme.colors.text, 0.0)
                            }
                        }
                    }

                    Rectangle {
                        width: roadWindow.roadW * 0.95
                        height: motionShadows.bandH * 0.85
                        x: (parent.width - width) / 2
                        y: motionShadows.bandY(0.33)
                        radius: 22 * root.s
                        opacity: 0.06 + 0.14 * root.motionIntensity
                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: AppTheme.alpha(AppTheme.colors.text, 0.0)
                            }
                            GradientStop {
                                position: 0.5
                                color: AppTheme.colors.text
                            }
                            GradientStop {
                                position: 1.0
                                color: AppTheme.alpha(AppTheme.colors.text, 0.0)
                            }
                        }
                    }

                    Rectangle {
                        width: roadWindow.roadW * 0.92
                        height: motionShadows.bandH * 0.75
                        x: (parent.width - width) / 2
                        y: motionShadows.bandY(0.66)
                        radius: 22 * root.s
                        opacity: 0.05 + 0.10 * root.motionIntensity
                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: AppTheme.alpha(AppTheme.colors.text, 0.0)
                            }
                            GradientStop {
                                position: 0.5
                                color: AppTheme.colors.text
                            }
                            GradientStop {
                                position: 1.0
                                color: AppTheme.alpha(AppTheme.colors.text, 0.0)
                            }
                        }
                    }
                }

                // ===== FOG GRADIENT OVERLAYS =====
                // Fog cap: subtle horizon fade
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom  // extend to full height
                    z: 5
                    gradient: Gradient {
                        GradientStop {
                            position: 0.00
                            color: AppTheme.alpha(AppTheme.colors.surface, 1.0)
                        }
                        GradientStop {
                            position: 0.20
                            color: AppTheme.alpha(AppTheme.colors.surface, 0.88)
                        }
                        GradientStop {
                            position: 0.50
                            color: AppTheme.alpha(AppTheme.colors.surface, 0.25)
                        }
                        GradientStop {
                            position: 1.00
                            color: AppTheme.alpha(AppTheme.colors.surface, 0.0)
                        }
                    }
                    opacity: 0.65
                }

                // ADAS calming band behind the ADAS box
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.62
                    height: parent.height * 0.22
                    y: parent.height * 0.46
                    radius: 32 * root.s
                    z: 6
					visible: false
                    color: AppTheme.colors.surfaceVariant
                    opacity: 0.40
                }

                // Soft global fade (full height, smooth transition)
                Rectangle {
                    anchors.fill: parent
                    z: 7
                    gradient: Gradient {
                        GradientStop {
                            position: 0.00
                            color: AppTheme.alpha(AppTheme.colors.surface, 1.0)
                        }
                        GradientStop {
                            position: 0.30
                            color: AppTheme.alpha(AppTheme.colors.surface, 0.75)
                        }
                        GradientStop {
                            position: 0.70
                            color: AppTheme.alpha(AppTheme.colors.surface, 0.18)
                        }
                        GradientStop {
                            position: 1.00
                            color: AppTheme.alpha(AppTheme.colors.surface, 0.0)
                        }
                    }
                    opacity: 0.50
                }

                Rectangle {
                    anchors.fill: parent
                    z: 8
                    color: AppTheme.colors.text
                    opacity: 0.02
                }

                Rectangle {
                    anchors.fill: parent
                    z: 9
                    color: AppTheme.colors.primary
                    opacity: 0.003
                }

                // Top protection matches roadWindow topMargin
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: roadWindow.anchors.topMargin
                    color: AppTheme.colors.surfaceVariant
                    opacity: 1.0
                    z: 10
                }
            }
        }
    }

    Item {
        id: uiLayer
        anchors.fill: parent
        z: 10

        ColumnLayout {
            anchors.fill: parent
            spacing: 2
            z: 10

            ClusterTopBar {
                id: topBar
                Layout.fillWidth: true
                z: 20
                currentGear: root.currentGear
                batteryLevel: root.currentBattery
                onBatteryClicked: batteryPopup.open()
            }

            Item {
                id: contentArea
                Layout.fillWidth: true
                Layout.fillHeight: true

                Timer {
                    id: motionTimer
                    interval: 16
                    running: true
                    repeat: true
                    onTriggered: {
                        if (root.motionSpeedAbs < 0.5)
                            return;

                        var normalizedSpeed = root.clamp(root.motionSpeedAbs / root.realMaxSpeedKmh, 0, 1);
                        var step = (interval / 1000.0) * normalizedSpeed * 2.0;
                        root.motionPhase = root.wrap01(root.motionPhase + root.motionDir * step);
                    }
                }

                // Background grid and glow
                Image {
                    source: "qrc:/assets/cluster_floor_grid.svg"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 26 * root.sy
                    sourceSize.width: 1200
                    opacity: AppTheme.isDark ? 0.55 : 0.15
                    z: 1
                }

                Image {
                    source: "qrc:/assets/cluster_car_glow.svg"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 74 * root.sy
                    sourceSize.width: 900
                    opacity: AppTheme.isDark ? 0.9 : 0.4
                    z: 2
                }

                // ==========================================================
                // MAIN LAYOUT
                // ==========================================================
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 52 * root.s
                    spacing: 46 * root.s
                    z: 30

                    // LEFT: Speed
                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 400 * root.s

                        ColumnLayout {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -18 * root.sy
                            spacing: 6 * root.s

                            Text {
                                // Dynamically convert speed based on the selected setting
                                text: {
                                    if (!root.vehicleDataAvailable)
                                        return "--";
                                    let speedVal = root.currentSpeed; // Base is km/h

                                    if (settingsManager.speedUnit === "m/s") {
                                        speedVal = speedVal / 3.6;
                                    } else if (settingsManager.speedUnit === "mph") {
                                        speedVal = speedVal * 0.621371;
                                    }

                                    return Math.round(speedVal).toString();
                                }
                                color: root.vehicleDataAvailable ? AppTheme.colors.text : AppTheme.colors.textSecondary
                                font.pixelSize: root.fontSizeXL * root.s
                                font.weight: Font.ExtraBold
                                Layout.alignment: Qt.AlignHCenter
                                style: root.vehicleDataAvailable && AppTheme.isDark ? Text.Outline : Text.Normal
                                styleColor: AppTheme.colors.primary
                            }

                            Text {
                                // Bind directly to the settings manager instead of hardcoding "km/h"
                                text: settingsManager.speedUnit
                                color: AppTheme.colors.textSecondary
                                font.pixelSize: 22 * root.s
                                font.weight: Font.DemiBold
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // CENTER: Speed + ADAS (OEM position)
                    Item {
                        z: 40
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // ISO 26266 ADAS / Warnings Area (ASIL-Compliant Display)
                        Rectangle {
                            id: adasZone
                            width: 560 * root.s
                            height: 175 * root.s
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 74 * root.sy
                            radius: 28 * root.s
                            color: "transparent"
   							border.width: 0

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 16 * root.s
                                spacing: 14 * root.s

                                // Speed Limit Indicator (ISO 26262 Safety-Critical Element)
                                Item {
                                    Layout.preferredWidth: 120 * root.s
                                    Layout.preferredHeight: 120 * root.s
                                    Layout.alignment: Qt.AlignVCenter
                                    z: 1  // Bring forward for maximum visibility

                                    // Outer glow layer (enhanced visibility - ISO 26262 ASIL-B)
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: root.speedLimitOuterGlow * root.s
                                        height: root.speedLimitOuterGlow * root.s
                                        radius: (root.speedLimitOuterGlow * root.s) / 2
                                        color: root.vehicleDataAvailable ? "#d81f2a" : AppTheme.colors.textSecondary
                                        opacity: 0.15
                                    }

                                    // Mid-tone glow (depth effect)
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: root.speedLimitMidGlow * root.s
                                        height: root.speedLimitMidGlow * root.s
                                        radius: (root.speedLimitMidGlow * root.s) / 2
                                        color: root.vehicleDataAvailable ? "#d81f2a" : AppTheme.colors.textSecondary
                                        opacity: 0.08
                                    }

                                    // Background glow (low opacity - fail-safe indicator)
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: root.speedLimitInnerGlow * root.s
                                        height: root.speedLimitInnerGlow * root.s
                                        radius: (root.speedLimitInnerGlow * root.s) / 2
                                        color: root.vehicleDataAvailable ? "#d81f2a" : AppTheme.colors.textSecondary
                                        opacity: 0.12
                                    }

                                    // Main speed limit circle
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: root.speedLimitMainCircle * root.s
                                        height: root.speedLimitMainCircle * root.s
                                        radius: (root.speedLimitMainCircle * root.s) / 2
                                        color: root.vehicleDataAvailable ? AppTheme.colors.surfaceElevated : AppTheme.colors.surfaceVariant
                                        border.color: root.vehicleDataAvailable ? "#d81f2a" : AppTheme.colors.border
                                        border.width: root.speedLimitBorderWidth * root.s
                                    }

                                    // Speed limit value
                                    Text {
                                        anchors.centerIn: parent
                                        text: root.vehicleDataAvailable ? root.speedLimitValue.toString() : "--"
                                        color: root.vehicleDataAvailable ? AppTheme.colors.text : AppTheme.colors.textSecondary
                                        font.pixelSize: root.fontSizeLarge * root.s
                                        font.weight: Font.ExtraBold
                                    }
                                }

                                // Flexible spacer for centered layout
                                Item {
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Image {
                            id: carImg
                            source: "qrc:/assets/car.png"
                            sourceSize.width: 150 * root.s
                            sourceSize.height: 150 * root.s
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: -50 * root.sy
                            opacity: 1.0

                            // Subtler motion (still direction-aware)
                            transform: [
                                Translate {
                                    y: Math.sin(root.motionPhase * 6.28318530718 * 2.0) * (1.2 * root.sy) * root.motionIntensity
                                },
                                Rotation {
                                    origin.x: carImg.width / 2
                                    origin.y: carImg.height / 2
                                    angle: Math.sin(root.motionPhase * 6.28318530718) * (0.35 * root.motionIntensity) * root.motionDir
                                }
                            ]
                        }
                    }

                    // ====== RIGHT: Swipe (Media / Weather / Navigation) ======
                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 400 * root.s

                        Column {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: -10 * root.sy
                            spacing: 6 * root.s

                            SwipeView {
                                id: rightSwipe
                                width: 280 * root.s
                                height: 170 * root.s
                                interactive: true
                                clip: true

                                // --- Page 1: Media ---
                                Item {
                                    width: rightSwipe.width
                                    height: rightSwipe.height

                                    Column {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: AppTheme.spacing.small

                                        Rectangle {
                                            id: albumArtBox
                                            width: 102 * root.s
                                            height: width
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            radius: AppTheme.radius.medium
                                            color: AppTheme.colors.surfaceElevated
                                            clip: true

                                            Image {
                                                id: albumArtImg
                                                anchors.fill: parent
                                                source: musicPlayerController.albumArtUrl
                                                fillMode: Image.PreserveAspectCrop
                                                smooth: true
                                                asynchronous: true
                                                visible: musicPlayerController.albumArtUrl.length > 0
                                            }

                                            Rectangle {
                                                anchors.fill: parent
                                                color: AppTheme.colors.surface
                                                opacity: 0.18
                                            }

                                            Rectangle {
                                                anchors.fill: parent
                                                gradient: Gradient {
                                                    GradientStop {
                                                        position: 0.0
                                                        color: AppTheme.alpha(AppTheme.colors.surfaceElevated, 0.4)
                                                    }
                                                    GradientStop {
                                                        position: 0.5
                                                        color: AppTheme.alpha(AppTheme.colors.surface, 0.0)
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: AppTheme.alpha(AppTheme.colors.surface, 0.5)
                                                    }
                                                }
                                                opacity: 0.25
                                            }

                                            Rectangle {
                                                anchors.fill: parent
                                                visible: musicPlayerController.albumArtUrl.length === 0
                                                gradient: Gradient {
                                                    GradientStop {
                                                        position: 0.0
                                                        color: getAlbumColor(musicPlayerController.currentTrackIndex)
                                                    }
                                                    GradientStop {
                                                        position: 1.0
                                                        color: Qt.darker(getAlbumColor(musicPlayerController.currentTrackIndex), 1.5)
                                                    }
                                                }
                                            }

                                            Image {
                                                source: "qrc:/icons/common/music-note.svg"
                                                width: 64 * root.s
                                                height: 64 * root.s
                                                anchors.centerIn: parent
                                                visible: musicPlayerController.albumArtUrl.length === 0
                                            }
                                        }

                                        Text {
                                            width: parent.width
                                            text: musicPlayerController.trackTitle.length > 0 ? musicPlayerController.trackTitle : "No Music"
                                            color: AppTheme.colors.text
                                            font.pixelSize: root.fontSizeSmall * root.s
                                            font.weight: Font.Bold
                                            elide: Text.ElideRight
                                            horizontalAlignment: Text.AlignHCenter
                                        }

                                        Text {
                                            width: parent.width
                                            text: musicPlayerController.artistName.length > 0 ? musicPlayerController.artistName : "Local Music"
                                            color: AppTheme.colors.textSecondary
                                            font.pixelSize: root.fontSizeXSmall * root.s
                                            elide: Text.ElideRight
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }

                                // --- Page 2: Weather (placeholder) ---
                                Item {
                                    width: rightSwipe.width
                                    height: rightSwipe.height

                                    WeatherMini {
                                        anchors.centerIn: parent
                                        width: rightSwipe.width
                                        height: rightSwipe.height
                                        weatherData: weatherScreen?.weatherDataModel
                                    }
                                }

                                // --- Page 3: Navigation (placeholder) ---
                                Item {
                                    width: rightSwipe.width
                                    height: rightSwipe.height

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 6 * root.s

                                        Image {
                                            source: "qrc:/icons/common/arrow-right.svg"
                                            width: 42 * root.s
                                            height: 42 * root.s
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        Text {
                                            text: "Next Turn"
                                            color: AppTheme.colors.text
                                            font.pixelSize: root.fontSizeSmall * root.s
                                            font.weight: Font.Bold
                                            horizontalAlignment: Text.AlignHCenter
                                        }

                                        Text {
                                            text: "— m  •  —"
                                            color: AppTheme.colors.textSecondary
                                            font.pixelSize: root.fontSizeXSmall * root.s
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }
                            }

                            PageIndicator {
                                count: rightSwipe.count
                                currentIndex: rightSwipe.currentIndex
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }

            // Bottom bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52 * root.sy
                Layout.leftMargin: 40 * root.s
                Layout.rightMargin: 40 * root.s
                Layout.bottomMargin: 6 * root.sy

                color: AppTheme.alpha(AppTheme.colors.surfaceVariant, 0.9)
                border.color: AppTheme.colors.border
                border.width: 1
                radius: 4 * root.s

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14 * root.s
                    spacing: 60 * root.s

                    // Trip distance (left)
                    Text {
                        // ISO 26262: Null-safe trip distance display
                        text: "Trip A " + Math.round(root.tripDistance) + "km"
                        color: root.vehicleDataAvailable ? AppTheme.colors.textSecondary : AppTheme.colors.textTertiary
                        font.pixelSize: root.fontSizeMedium * root.s
                        font.weight: Font.Medium
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Power output indicator (center)
                    RowLayout {
                        spacing: 10 * root.s
                        Layout.alignment: Qt.AlignHCenter

                        // Unit label
                        Text {
                            text: "kw"
                            color: root.vehicleDataAvailable ? AppTheme.colors.textSecondary : AppTheme.colors.textTertiary
                            font.pixelSize: root.fontSizeMedium * root.s
                        }

                        // Power bar (ISO 26262: Fail-safe visualization)
                        Rectangle {
                            width: 110 * root.s
                            height: 5 * root.s
                            radius: 2.5 * root.s
                            color: root.vehicleDataAvailable ? AppTheme.colors.surface : AppTheme.colors.divider
                            Rectangle {
                                width: root.vehicleDataAvailable ? parent.width * (root.powerOutput / 100) : parent.width * 0.5
                                height: parent.height
                                radius: parent.radius
                                color: root.vehicleDataAvailable ? AppTheme.colors.primary : AppTheme.colors.textTertiary
                            }
                        }

                        // Power value
                        Text {
                            text: root.vehicleDataAvailable ? Math.round(root.powerOutput) : "--"
                            color: root.vehicleDataAvailable ? AppTheme.colors.primary : AppTheme.colors.textTertiary
                            font.pixelSize: root.fontSizeMedium * root.s
                            font.weight: Font.Bold
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Odometer distance (right) with reset button
                    RowLayout {
                        spacing: AppTheme.spacing.small
                        Layout.alignment: Qt.AlignRight

                        Text {
                            // Convert trip distance based on settings
                            text: {
                                if (!root.vehicleDataAvailable)
                                    return "Trip A --";
                                let dist = root.tripDistance; // Base is km

                                if (settingsManager.distanceUnit === "mi" || settingsManager.distanceUnit === "miles") {
                                    dist = dist * 0.621371;
                                }

                                return "Trip A " + Math.round(dist) + " " + settingsManager.distanceUnit;
                            }
                            color: root.vehicleDataAvailable ? AppTheme.colors.textSecondary : AppTheme.colors.textTertiary
                            font.pixelSize: root.fontSizeMedium * root.s
                            font.weight: Font.Medium
                        }

                        // Reset button
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 4
                            color: odometerResetMouseArea.containsMouse ? AppTheme.colors.primary : "transparent"
                            border.color: AppTheme.colors.primary
                            border.width: 1
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                text: "↻"
                                color: odometerResetMouseArea.containsMouse ? AppTheme.colors.surfaceElevated : AppTheme.colors.primary
                                font.pixelSize: 18
                                font.weight: Font.Bold
                            }

                            MouseArea {
                                id: odometerResetMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.resetOdometer()
                            }
                        }
                    }
                }
            }
        }
    }

    // Battery Status Popup
    BatteryPopup {
        id: batteryPopup
        anchors.fill: parent
        stm32BatteryLevel: root.stm32Battery
        rpiBatteryLevel: root.rpiBattery
        z: 1000
    }

    function getAlbumColor(index) {
        var colors = ["#FF6B35", "#004E89", "#1AE5BE"];
        return colors[index % colors.length];
    }
}
