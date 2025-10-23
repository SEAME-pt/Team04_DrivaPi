import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.5
import "components"

Window {
    id: root
    visible: true
    width: 1280
    height: 400
    title: qsTr("SEA:ME HMI Dashboard")
    color: "#1a1a1a"

    minimumWidth: width
    maximumWidth: width
    minimumHeight: height
    maximumHeight: height

    // Layout properties
    property int metricOffsetX: 390
    property int metricVOffset: -6

    // Update clock every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            currentTime.text = Qt.formatDateTime(new Date(), "hh:mm");
        }
    }

    Shortcut {
        sequence: "Ctrl+Q"
        context: Qt.ApplicationShortcut
        onActivated: Qt.quit()
    }

    // Background Image
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "qrc:/assets/InstrumentClusterBase.svg"
        fillMode: Image.Stretch
        z: 0
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        z: 1

        Item {
            anchors.fill: parent

            // ============================================
            // TOP BAR
            // ============================================
            Item {
                id: topBar
                width: parent.width
                height: 85
                anchors.top: parent.top

                // Time (far left)
                Text {
                    id: currentTime
                    text: Qt.formatDateTime(new Date(), "hh:mm")
                    font.pixelSize: 16
                    font.family: "SF Pro Display"
                    font.weight: Font.Light
                    color: "#4A4A4A"
                    anchors.left: parent.left
                    anchors.leftMargin: 200
                    anchors.top: parent.top
                    anchors.topMargin: 18
                }

                // Left navigation arrow
                Text {
                    text: "⬅"
                    font.pixelSize: 50
                    color: "#00D66C"
                    anchors.left: parent.left
                    anchors.leftMargin: 270
                    anchors.top: parent.top
                    anchors.topMargin: 8
                }

                // Gear selector (center) - COMPONENT
                GearSelector {
                    id: gearSelector
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 3
                    z: 2

                    currentGear: vehicleData.gear

                    onGearUp: vehicleData.changeGearUp()
                    onGearDown: vehicleData.changeGearDown()
                }

                // Right navigation arrow
                Text {
                    text: "➡"
                    font.pixelSize: 50
                    color: "#00D66C"
                    anchors.right: parent.right
                    anchors.rightMargin: 270
                    anchors.top: parent.top
                    anchors.topMargin: 8
                }

                // Temperature (top right)
                Text {
                    text: Math.round(vehicleData.temperature) + "°C"
                    font.pixelSize: 16
                    font.family: "SF Pro Display"
                    font.weight: Font.Light
                    color: "#4A4A4A"
                    anchors.right: parent.right
                    anchors.rightMargin: 200
                    anchors.top: parent.top
                    anchors.topMargin: 18
                }

                // Speed limit sign
                Image {
                    width: 75
                    height: 75
                    source: "qrc:/assets/roadSigns/Zeichen_274-62.svg.png"
                    anchors.left: parent.left
                    anchors.leftMargin: 40
                    anchors.top: parent.top
                    anchors.topMargin: 5
                }
            }

            // ============================================
            // LEFT - Speed Display - COMPONENT
            // ============================================
            SpeedDisplay {
                id: speedDisplay
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -metricOffsetX
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: metricVOffset

                speed: vehicleData.speed
            }

            // ============================================
            // CENTER - Road View & Car
            // ============================================
            Item {
                id: roadView
                width: 660
                height: 300
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 15
            }

            Image {
                width: 130
                height: 140
                source: "qrc:/assets/Car.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 50
            }

            // ============================================
            // RIGHT - Energy Display - COMPONENT
            // ============================================
            EnergyDisplay {
                id: energyDisplay
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: metricOffsetX
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: metricVOffset

                energy: vehicleData.energy
            }

            // ============================================
            // BOTTOM BAR
            // ============================================
            Item {
                width: parent.width
                height: 85
                anchors.bottom: parent.bottom

                // Battery indicator (left) - COMPONENT
                BatteryIndicator {
                    id: batteryIndicator
                    anchors.left: parent.left
                    anchors.leftMargin: 50
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 28

                    batteryLevel: vehicleData.battery
                }

                // Warning indicators (left-center)
                Row {
                    spacing: 15
                    anchors.left: parent.left
                    anchors.leftMargin: 200
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 28

                    Image {
                        width: 30
                        height: 20
                        opacity: 0.25
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/assets/thirdRightIcon.svg"
                    }

                    Image {
                        width: 30
                        height: 20
                        opacity: 0.25
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/assets/SecondRightIcon.svg"
                    }
                }

                // Distance counter (right-center)
                Row {
                    spacing: 15
                    anchors.right: parent.right
                    anchors.rightMargin: 200
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 28

                    Text {
                        text: Math.round(vehicleData.distance).toString()
                        font.pixelSize: 16
                        font.family: "SF Pro Display"
                        color: "#FFFFFF"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "KMS"
                        font.pixelSize: 16
                        font.family: "SF Pro Display"
                        color: "#8A8A8A"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "↻"
                        font.pixelSize: 18
                        color: "#6A6A6A"
                        anchors.verticalCenter: parent.verticalCenter

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: vehicleData.resetTrip()
                        }
                    }
                }

                // Light & warning indicators (right)
                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 50
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 24
                    spacing: 15

                    Image {
                        width: 30
                        height: 30
                        opacity: 0.25
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/assets/Low_beam_headlights_white.svg"
                    }

                    Image {
                        width: 22
                        height: 22
                        opacity: 0.15
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/assets/warning.svg"
                    }
                }

                // Drive mode indicators (bottom center)
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -2
                    spacing: 80

                    Image {
                        width: 25
                        height: 25
                        opacity: 0.25
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/assets/navigation.svg"
                    }

                    Image {
                        width: 25
                        height: 25
                        opacity: 0.25
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/assets/steering.svg"
                    }

                    Image {
                        width: 40
                        height: 40
                        opacity: 0.25
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/assets/headphones.svg"
                    }
                }
            }

            // ============================================
            // SIMULATION CONTROLS (Top Right) - COMPONENT
            // ============================================
            SimulationControls {
                id: simulationControls
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 15
                z: 100

                isRunning: vehicleData.simulationRunning
                simSpeed: vehicleData.simSpeed

                onStartSimulation: vehicleData.startSimulation()
                onStopSimulation: vehicleData.stopSimulation()
                onIncreaseSpeed: vehicleData.increaseSimSpeed()
                onDecreaseSpeed: vehicleData.decreaseSimSpeed()
            }
        }
    }
}
