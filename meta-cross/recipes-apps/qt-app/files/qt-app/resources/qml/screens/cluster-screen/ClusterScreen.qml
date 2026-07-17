import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes // Fornece o LinearGradient correto para os Shapes
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

	property bool demoEmergencyAlert: false
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

				// =========================================================
				// ROAD CONTAINER: Geometria Vetorial Sem Efeitos Pesados
				// =========================================================
				Item {
					id: roadContainer
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.bottom: parent.bottom
					anchors.bottomMargin: -10 * root.sy
					width: 1200 * root.sx
					height: 380 * root.sy
					z: 1

					// Cores dinâmicas para perfeito contraste em Dark/Light mode (Estilo BMW)
					property color themeLaneColor: AppTheme.isDark ? "#00D2FF" : "#0055CC"
					property color themeLaneFill: AppTheme.isDark ? Qt.rgba(0.0, 0.82, 1.0, 0.12) : Qt.rgba(0.0, 0.33, 0.8, 0.08) // Mais subtil no claro

					// Captura dos dados KUKSA do Stanley
					property real currentLateralOffset: (root.vehicleDataAvailable && vehicleData.laneOffset !== undefined) ? (vehicleData.laneOffset * -1.5 * root.sx) : 0
					property real currentCurveOffset: (root.vehicleDataAvailable && vehicleData.laneHeading !== undefined) ? (vehicleData.laneHeading * -400 * root.sx) : 0

					// A animação garante a fluidez a 60 FPS
					Behavior on currentLateralOffset { NumberAnimation { duration: 150; easing.type: Easing.OutSine } }
					Behavior on currentCurveOffset { NumberAnimation { duration: 150; easing.type: Easing.OutSine } }

					// Bloqueios matemáticos (Clamp) para a "Zona Rosa"
					property real horizonXShift: Math.max(-40 * root.sx, Math.min(40 * root.sx, (currentCurveOffset * 0.1) + (currentLateralOffset * 0.1)))
					property real horizonY: roadContainer.height * 0.65
					property real curveBellyShift: (currentCurveOffset * 0.8) + (currentLateralOffset * 0.6)

					Image {
						source: "qrc:/assets/cluster/floor-grid.svg"
						anchors.fill: parent
						// A opacidade precisa de ser muito baixa no modo claro para não criar "sombras pretas" estranhas
						opacity: AppTheme.isDark ? 0.35 : 0.08
						transform: Rotation {
							origin.x: roadContainer.width / 2; origin.y: roadContainer.height
							angle: (roadContainer.currentCurveOffset / 20)
						}
					}

					// Linhas convergentes 3D usando Shapes Nativas
					Shape {
						anchors.fill: parent

						// 1. "Tapete" Virtual
						ShapePath {
							strokeWidth: 0
							fillGradient: LinearGradient {
								y1: 0; y2: roadContainer.height
								GradientStop { position: 0.0; color: "transparent" }
								GradientStop { position: 0.8; color: roadContainer.themeLaneFill }
								GradientStop { position: 1.0; color: "transparent" }
							}

							startX: (roadContainer.width / 2) - (500 * root.sx)
							startY: roadContainer.height

							PathQuad {
								x: (roadContainer.width / 2) - (80 * root.sx) + roadContainer.horizonXShift
								y: roadContainer.horizonY
								controlX: (roadContainer.width / 2) - (200 * root.sx) + roadContainer.curveBellyShift
								controlY: roadContainer.height * 0.8
							}
							PathLine {
								x: (roadContainer.width / 2) + (80 * root.sx) + roadContainer.horizonXShift
								y: roadContainer.horizonY
							}
							PathQuad {
								x: (roadContainer.width / 2) + (500 * root.sx)
								y: roadContainer.height
								controlX: (roadContainer.width / 2) + (200 * root.sx) + roadContainer.curveBellyShift
								controlY: roadContainer.height * 0.8
							}
							PathLine {
								x: (roadContainer.width / 2) - (500 * root.sx)
								y: roadContainer.height
							}
						}

						// 2. Linha Lateral Esquerda (BMW Cyan / Deep Blue)
						ShapePath {
							strokeWidth: 8 * root.s
							strokeColor: roadContainer.themeLaneColor
							fillColor: "transparent"
							capStyle: ShapePath.RoundCap

							startX: (roadContainer.width / 2) - (500 * root.sx)
							startY: roadContainer.height

							PathQuad {
								x: (roadContainer.width / 2) - (80 * root.sx) + roadContainer.horizonXShift
								y: roadContainer.horizonY
								controlX: (roadContainer.width / 2) - (200 * root.sx) + roadContainer.curveBellyShift
								controlY: roadContainer.height * 0.8
							}
						}

						// 3. Linha Lateral Direita (BMW Cyan / Deep Blue)
						ShapePath {
							strokeWidth: 8 * root.s
							strokeColor: roadContainer.themeLaneColor
							fillColor: "transparent"
							capStyle: ShapePath.RoundCap

							startX: (roadContainer.width / 2) + (500 * root.sx)
							startY: roadContainer.height

							PathQuad {
								x: (roadContainer.width / 2) + (80 * root.sx) + roadContainer.horizonXShift
								y: roadContainer.horizonY
								controlX: (roadContainer.width / 2) + (200 * root.sx) + roadContainer.curveBellyShift
								controlY: roadContainer.height * 0.8
							}
						}
					}
				}
				// =========================================================

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

								// =========================================================
								// INDICADOR DE LIMITE DE VELOCIDADE (Mantido e Assegurado)
								// =========================================================
								SpeedLimitIndicator {
									Layout.preferredWidth: 105 * root.s
									Layout.preferredHeight: 105 * root.s
									Layout.alignment: Qt.AlignVCenter
									z: 1

									visible: root.speedLimitActive
									opacity: root.speedLimitActive ? 1.0 : 0.0

									vehicleDataAvailable: root.vehicleDataAvailable
									speedLimitValue: root.speedLimitValue
									s: root.s

									Behavior on opacity {
										NumberAnimation {
											duration: 180
											easing.type: Easing.OutQuad
										}
									}
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
				showTextAlert("PULL OVER - EMERGENCY", 2);
				return;
			}

			if (priorityLevel === 1) {
				showTextAlert("EMERGENCY VEHICLE AHEAD", 1);
				return;
			}

			clearAlert();
			emergencyTimeoutTimer.stop();
		}

		function onTrafficSignChanged(classId) {
			console.log("[ClusterScreen] Traffic Sign/Obstacle ID:", classId);

			// 0 = Clear.
			if (classId === 0) {
				return;
			}

			// O indicador de velocidade continua a ser despoletado aqui corretamente
			if (classId === 1) {
				showSpeedLimit(50);
				return;
			}
			if (classId === 2) {
				showSpeedLimit(80);
				return;
			}

			// Outros sinais...
			if (classId === 3) {
				showAdasSign("gate-sign.png", 1, "GATE AHEAD");
				return;
			}
			if (classId === 4) {
				showAdasSign("crosswalk-sign.png", 1, "CROSSWALK AHEAD");
				return;
			}
			if (classId === 5) {
				showAdasSign("stop-sign.png", 2, "STOP SIGN");
				return;
			}
			if (classId === 6) {
				showAdasSign("yield-sign.svg", 1, "YIELD SIGN");
				return;
			}
			if (classId === 7) {
				showAdasSign("obstacle-sign.png", 2, "CAR AHEAD");
				return;
			}
			if (classId === 8) {
				showAdasSign("danger-sign.png", 1, "DANGER SIGN");
				return;
			}
			if (classId === 9) {
				showAdasSign("obstacle-sign.png", 2, "OBSTACLE AHEAD");
				return;
			}
			if (classId === 10) {
				showAdasSign("traffic-light-green.svg", 1, "GREEN LIGHT");
				return;
			}
			if (classId === 11) {
				showAdasSign("traffic-light-off.svg", 1, "TRAFFIC LIGHT OFF");
				return;
			}
			if (classId === 12) {
				showAdasSign("traffic-light-red.svg", 2, "RED LIGHT");
				return;
			}
			if (classId === 13) {
				showAdasSign("traffic-light-yellow.svg", 1, "YELLOW LIGHT");
				return;
			}
		}
	}

	function adasSign(fileName) {
		return Qt.resolvedUrl("../../../assets/adas-signs/" + fileName);
	}

	function showAdasSign(fileName, priorityLevel, message) {
		root.emergencyIconSource = adasSign(fileName);
		root.emergencyMessage = message || "";
		root.emergencyPriorityLevel = priorityLevel;
		root.emergencyPriorityActive = true;

		console.log("[ClusterScreen] ADAS SIGN ALERT:",
					fileName,
					root.emergencyIconSource,
					"priority=",
					priorityLevel,
					"message=",
					root.emergencyMessage);

		emergencyTimeoutTimer.restart();
	}

	function showSpeedLimit(limitValue) {
		root.speedLimitValue = limitValue;
		root.speedLimitActive = true;

		console.log("[ClusterScreen] SPEED LIMIT ALERT:", limitValue);

		speedLimitTimeoutTimer.restart();
	}

	function showTextAlert(message, priorityLevel) {
		root.emergencyIconSource = "";
		root.emergencyMessage = message;
		root.emergencyPriorityLevel = priorityLevel;
		root.emergencyPriorityActive = true;

		console.log("[ClusterScreen] TEXT ALERT:",
					message,
					"priority=",
					priorityLevel);

		emergencyTimeoutTimer.restart();
	}

	function clearAlert() {
		root.emergencyIconSource = "";
		root.emergencyMessage = "";
		root.emergencyPriorityLevel = 0;
		root.emergencyPriorityActive = false;
	}

	Timer {
		id: emergencyTimeoutTimer
		interval: 3000
		running: false
		repeat: false
		onTriggered: {
			console.log("[ClusterScreen] ADAS / V2X Alert Auto-Cleared (Timeout)");
			clearAlert();
		}
	}

	Timer {
		id: speedLimitTimeoutTimer
		interval: 3000
		running: false
		repeat: false
		onTriggered: {
			console.log("[ClusterScreen] Speed limit auto-cleared");
			root.speedLimitActive = false;
			root.speedLimitValue = 0;
		}
	}

	// ==========================================================
	// V2X EMERGENCY OVERLAY
	// ==========================================================
	EmergencyAlert {
		id: adasEmergencyAlert
		z: 2000
		s: root.s
		isActive: root.vehicleDataAvailable ? vehicleData.emergencyPriorityActive : false
		priorityLevel: root.vehicleDataAvailable ? vehicleData.emergencyPriorityLevel : 0
		alertMessage: root.vehicleDataAvailable ? vehicleData.emergencyMessage : ""
		iconSource: root.vehicleDataAvailable ? vehicleData.emergencyIconSource : ""
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
