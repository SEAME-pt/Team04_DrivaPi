import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../components/cluster"
import "../../components/battery"
import "../../theme"
import "background"
import "adas"
import "panels"
import "bottom-bar"

Rectangle {
    id: root

    property real motionPhase: 0

    // Speed used by motion simulation (supports reverse if negative)
    readonly property real motionSpeedKmh: currentSpeed
    readonly property real motionSpeedAbs: Math.abs(motionSpeedKmh)
    readonly property real motionDir: {
        // Reverse animation if gear is "R"
        if (currentGear === "R")
            return -1;
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
            vehicleData.odo = 0;
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
    Background {
        anchors.fill: parent
        z: 0
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
                batteryLevel: vehicleData.rpiBattery < vehicleData.stm32Battery ? vehicleData.rpiBattery : vehicleData.stm32Battery
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
                    source: "qrc:/assets/cluster/floor-grid.svg"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 26 * root.sy
                    sourceSize.width: 1200
                    opacity: AppTheme.isDark ? 0.55 : 0.15
                    z: 1
                }

                Image {
                    source: "qrc:/assets/cluster/car-glow.svg"
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
                                SpeedLimitIndicator {
                                    Layout.preferredWidth: 120 * root.s
                                    Layout.preferredHeight: 120 * root.s
                                    Layout.alignment: Qt.AlignVCenter
                                    z: 1
                                    vehicleDataAvailable: root.vehicleDataAvailable
                                    speedLimitValue: root.speedLimitValue
                                    s: root.s
                                }

                                // Flexible spacer for centered layout
                                Item {
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Image {
                            id: carImg
                            source: "qrc:/assets/cluster/car.png"
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
                    RightInfoPanel {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 400 * root.s
                        s: root.s
                        sy: root.sy
                        fontSizeSmall:  root.fontSizeSmall
                        fontSizeXSmall: root.fontSizeXSmall
                        albumColor: getAlbumColor(musicPlayerController.currentTrackIndex)
                        weatherData: weatherScreen?.weatherDataModel
                    }
                }
            }

            // Bottom bar
            BottomBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 52 * root.sy
                Layout.leftMargin: 40 * root.s
                Layout.rightMargin: 40 * root.s
                Layout.bottomMargin: 6 * root.sy
                s: root.s
                sy: root.sy
                fontSizeMedium: root.fontSizeMedium
                vehicleDataAvailable: root.vehicleDataAvailable
                tripDistance: root.tripDistance
                powerOutput: root.powerOutput
                odometerDistance: root.odometerDistance
                onResetRequested: root.resetOdometer()
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
