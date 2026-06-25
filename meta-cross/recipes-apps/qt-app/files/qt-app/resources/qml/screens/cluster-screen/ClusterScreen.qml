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
        if (currentGear === "R") return -1;
        return 1;
    }

    readonly property real realMaxSpeedKmh: 14.4
    readonly property real motionIntensity: clamp(motionSpeedAbs / realMaxSpeedKmh, 0, 1)

    function wrap01(t) {
        t = t % 1;
        return t < 0 ? (t + 1) : t;
    }

    // ISO 26262 Fail-Safe: Null/Invalid Data Handling
    property bool vehicleDataAvailable: vehicleData !== null && vehicleData !== undefined

    // V2X Emergency State
    property bool emergencyPriorityActive: false
    property int emergencyPriorityLevel: 0
	property string emergencyMessage: ""
    // A flag de demo agora deve estar a false para produção
    property bool demoEmergencyAlert: false

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

    Component.onCompleted: {
        if (vehicleDataAvailable && vehicleData.odo > 0) {
            odometerDistance = vehicleData.odo;
        }
    }

    Timer {
        id: odometerUpdateTimer
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            if (!vehicleDataAvailable) return;
            var currentTime = new Date().getTime();
            if (lastTimestamp === 0) {
                lastTimestamp = currentTime;
                return;
            }
            var elapsedSeconds = (currentTime - lastTimestamp) / 1000;
            lastTimestamp = currentTime;
            var speedKmh = currentSpeed;
            var timeHours = elapsedSeconds / 3600;
            var distanceTraveled = speedKmh * timeHours;

            accumulatedDistance += distanceTraveled;
            if (accumulatedDistance >= 0.01 && speedKmh > 0.5) {
                odometerDistance += accumulatedDistance;
                accumulatedDistance = 0;
            }
        }
    }

    Timer {
        id: resetOdometerTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: showOdometerReset = false
    }

    // Design Constants
    property int fontSizeXL: 132
    property int fontSizeLarge: 44
    property int fontSizeMedium: 22
    property int fontSizeSmall: 18
    property int fontSizeXSmall: 13

    property real roadWidthFactor: 0.85
    property real roadHeightFactor: 3.5
    property real roadBaseOffset: -0.8
    property real horizonMarginRatio: 0.15

    property real refW: 1200
    property real refH: 480
    property real sx: width / refW
    property real sy: height / refH
    property real s: Math.min(sx, sy)

    function clamp(v, a, b) { return Math.max(a, Math.min(v, b)); }

    gradient: Gradient {
        GradientStop { position: 0.0; color: AppTheme.colors.surfaceVariant }
        GradientStop { position: 0.5; color: AppTheme.colors.surface }
        GradientStop { position: 1.0; color: AppTheme.colors.surfaceVariant }
    }

    Background { anchors.fill: parent; z: 0 }

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
                        if (root.motionSpeedAbs < 0.5) return;
                        var normalizedSpeed = root.clamp(root.motionSpeedAbs / root.realMaxSpeedKmh, 0, 1);
                        var step = (interval / 1000.0) * normalizedSpeed * 2.0;
                        root.motionPhase = root.wrap01(root.motionPhase + root.motionDir * step);
                    }
                }

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

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 52 * root.s
                    spacing: 46 * root.s
                    z: 30

                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 400 * root.s

                        ColumnLayout {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -18 * root.sy
                            spacing: 6 * root.s

                            Text {
                                text: {
                                    if (!root.vehicleDataAvailable) return "--";
                                    let speedVal = root.currentSpeed;
                                    if (settingsManager.speedUnit === "m/s") speedVal = speedVal / 3.6;
                                    else if (settingsManager.speedUnit === "mph") speedVal = speedVal * 0.621371;
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
                                text: settingsManager.speedUnit
                                color: AppTheme.colors.textSecondary
                                font.pixelSize: 22 * root.s
                                font.weight: Font.DemiBold
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    Item {
                        z: 40
                        Layout.fillWidth: true
                        Layout.fillHeight: true

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

                                SpeedLimitIndicator {
                                    Layout.preferredWidth: 120 * root.s
                                    Layout.preferredHeight: 120 * root.s
                                    Layout.alignment: Qt.AlignVCenter
                                    z: 1
                                    vehicleDataAvailable: root.vehicleDataAvailable
                                    speedLimitValue: root.speedLimitValue
                                    s: root.s
                                }
                                Item { Layout.fillWidth: true }
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
                            transform: [
                                Translate { y: Math.sin(root.motionPhase * 6.28318530718 * 2.0) * (1.2 * root.sy) * root.motionIntensity },
                                Rotation {
                                    origin.x: carImg.width / 2; origin.y: carImg.height / 2
                                    angle: Math.sin(root.motionPhase * 6.28318530718) * (0.35 * root.motionIntensity) * root.motionDir
                                }
                            ]
                        }
                    }

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
                onResetRequested: {
                    vehicleData.requestOdometerReset();
                    showOdometerReset = true;
                    resetOdometerTimer.start();
                    console.log("[ClusterScreen] Odometer reset to 0 km");
                }

            }
        }
    }

    // ==========================================================
    // BACKEND SIGNAL CONNECTIONS (C++ to QML Bridge)
    // ==========================================================
    Connections {
		target: vehicleData
		enabled: vehicleDataAvailable

		function onEmergencyAlertChanged(priorityLevel) {
			console.log("[ClusterScreen] V2X Emergency Alert Received. Priority:", priorityLevel);

			if (priorityLevel >= 2) {
				root.emergencyMessage = "PULL OVER - EMERGENCY";
				root.emergencyPriorityLevel = 2;
				root.emergencyPriorityActive = true;
				emergencyTimeoutTimer.restart();

			} else if (priorityLevel === 1) {
				root.emergencyMessage = "EMERGENCY VEHICLE AHEAD";
				root.emergencyPriorityLevel = 1;
				root.emergencyPriorityActive = true;
				emergencyTimeoutTimer.restart();

			} else {
				root.emergencyMessage = "";
				root.emergencyPriorityLevel = 0;
				root.emergencyPriorityActive = false;
				emergencyTimeoutTimer.stop();
			}
		}

		function onAdasVisionChanged(classId) {
			console.log("[ClusterScreen] ADAS Vision AI ID:", classId);

			if (classId === 1) {
				root.speedLimitValue = 50;
				root.emergencyMessage = "50 SIGN DETECTED";
				root.emergencyPriorityLevel = 1;
				root.emergencyPriorityActive = true;
				emergencyTimeoutTimer.restart();

			} else if (classId === 2) {
				root.speedLimitValue = 80;
				root.emergencyMessage = "80 SIGN DETECTED";
				root.emergencyPriorityLevel = 1;
				root.emergencyPriorityActive = true;
				emergencyTimeoutTimer.restart();

			} else if (classId === 3) {
				root.emergencyMessage = "GATE AHEAD";
				root.emergencyPriorityLevel = 2;
				root.emergencyPriorityActive = true;
				emergencyTimeoutTimer.restart();

			} else if (classId === 4) {
				root.emergencyMessage = "CROSSWALK AHEAD";
				root.emergencyPriorityLevel = 1;
				root.emergencyPriorityActive = true;
				emergencyTimeoutTimer.restart();

			} else if (classId === 5) {
				root.emergencyMessage = "STOP SIGN DETECTED";
				root.emergencyPriorityLevel = 2;
				root.emergencyPriorityActive = true;
				emergencyTimeoutTimer.restart();

			} else if (classId === 6) {
				root.emergencyMessage = "YIELD SIGN DETECTED";
				root.emergencyPriorityLevel = 1;
				root.emergencyPriorityActive = true;
				emergencyTimeoutTimer.restart();

			} else if (classId === 7) {
				root.emergencyMessage = "CAR AHEAD";
				root.emergencyPriorityLevel = 2;
				root.emergencyPriorityActive = true;
				emergencyTimeoutTimer.restart();

			} else if (classId === 8) {
				root.emergencyMessage = "DANGER SIGN DETECTED";
				root.emergencyPriorityLevel = 1;
				root.emergencyPriorityActive = true;
				emergencyTimeoutTimer.restart();

			} else if (classId === 9) {
				root.emergencyMessage = "OBSTACLE AHEAD";
				root.emergencyPriorityLevel = 2;
				root.emergencyPriorityActive = true;
				emergencyTimeoutTimer.restart();

			} else if (classId === 10) {
				root.emergencyMessage = "GREEN LIGHT";
				root.emergencyPriorityLevel = 1;
				root.emergencyPriorityActive = true;
				emergencyTimeoutTimer.restart();

			} else if (classId === 11) {
				root.emergencyMessage = "TRAFFIC LIGHT OFF";
				root.emergencyPriorityLevel = 1;
				root.emergencyPriorityActive = true;
				emergencyTimeoutTimer.restart();

			} else if (classId === 12) {
				root.emergencyMessage = "RED LIGHT";
				root.emergencyPriorityLevel = 2;
				root.emergencyPriorityActive = true;
				emergencyTimeoutTimer.restart();

			} else if (classId === 13) {
				root.emergencyMessage = "YELLOW LIGHT";
				root.emergencyPriorityLevel = 1;
				root.emergencyPriorityActive = true;
				emergencyTimeoutTimer.restart();
			}

			// Important:
			// Do not clear immediately on classId 0.
			// The model publishes Clear often, and it can hide the alert too fast.
		}
	}

    Timer {
        id: emergencyTimeoutTimer
        interval: 15000
        running: false
        repeat: false
        onTriggered: {
            console.log("[ClusterScreen] V2X Emergency Alert Auto-Cleared (Timeout)");
			root.emergencyMessage = "";
            root.emergencyPriorityLevel = 0;
            root.emergencyPriorityActive = false;
        }
    }

    // ==========================================================
    // V2X EMERGENCY OVERLAY
    // ==========================================================
    EmergencyAlert {
		id: v2xEmergencyAlert
		z: 2000
		s: root.s
		isActive: root.emergencyPriorityActive
		priorityLevel: root.emergencyPriorityLevel
		alertMessage: root.emergencyMessage
	}

	Rectangle {
		id: debugAlwaysVisible
		z: 999999
		visible: true

		width: 500 * root.s
		height: 80 * root.s

		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: 20 * root.s

		color: "red"
		border.color: "white"
		border.width: 4

		Text {
			anchors.centerIn: parent
			text: "DEBUG ALERT VISIBLE"
			color: "white"
			font.pixelSize: 28 * root.s
			font.bold: true
		}
	}
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
