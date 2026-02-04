import QtQuick
import QtQuick.Layouts
import "../components"
import QtQuick.Effects
import "../theme"

Rectangle {
    id: root

    // 0..1 loop (seamless)
    property real roadPhase: 0

    // Demo / fallback (replace with your real signal if you have it)
    property int speedLimitValue: (vehicleData && vehicleData.speedLimit) ? Math.round(vehicleData.speedLimit) : 120

    // -----------------------------
    // Responsive scaling (1200x480 reference)
    // -----------------------------
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
            color: "#05080e"
        }
        GradientStop {
            position: 0.5
            color: "#030509"
        }
        GradientStop {
            position: 1.0
            color: "#05080e"
        }
    }

    // --- Top Glow Layer ---
    Image {
        source: "qrc:/assets/oie_kUl6AfLcsUwE.png"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: parent.height * 0.07
        opacity: 0.95
        z: 1
    }

    // --- Center Left Glow Layer ---
    Image {
        source: "qrc:/assets/left-dashboard.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.horizontalCenterOffset: parent.width * 0.225
        width: parent.width * 0.45
        height: parent.height * 0.60
        opacity: 0.95
        z: 2
    }

    // --- Center Right Glow Layer ---
    Image {
        source: "qrc:/assets/right-dashboard.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.horizontalCenterOffset: -parent.width * 0.225
        width: parent.width * 0.45
        height: parent.height * 0.60
        opacity: 0.95
        z: 2
    }

    // --- Bottom Glow Layer ---
    Image {
        source: "qrc:/assets/oie_OeB7IAtTvDtn.png"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.PreserveAspectFit
        width: parent.width * 0.95
        height: parent.height * 0.11
        opacity: 0.95
        z: 3
    }

    // Glass side panels
    Image {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        source: "qrc:/assets/cluster_left_panel.svg"
        fillMode: Image.PreserveAspectFit
        opacity: 1.0
        sourceSize.width: 450
        z: 4
    }

    Image {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        source: "qrc:/assets/cluster_right_panel.svg"
        fillMode: Image.PreserveAspectFit
        opacity: 1.0
        sourceSize.width: 450
        z: 4
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Top bar
        ClusterTopBar {
            id: topBar
            Layout.fillWidth: true
            z: 20
            currentGear: vehicleData.gear
            temperatureText: Math.round(vehicleData.temperature) + "°C"
        }

        // Main content area
        Item {
            id: contentArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            // ==========================================================
            // ROAD LAYER (road.png is the only lane source)
            // ==========================================================
            Item {
                id: roadLayer
                anchors.fill: parent
                z: 0

                Item {
                    id: roadWindow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.top: parent.top
                    // Keep horizon high enough for the rails to "agree"
                    // (1200x480 target tuned)
                    anchors.topMargin: root.clamp(parent.height * 0.15, 64 * root.sy, 130 * root.sy)  // Decreased from 0.20 to lower horizon
                    clip: true
                    // --- Perspective tuning ---
                    // Your rails converge more than the road asset -> we need:
                    // - slightly narrower road
                    // - taller/steeper road
                    // - push texture upward
                    property real roadW: width * 0.85  // Kept narrower for fit
                    property real roadH: height * 3.5  // Decreased from 4.0 for slightly flatter (longer) lines
                    property real baseY: -height * 0.8 // Less negative from 0.8 to shift texture down
                    property real px: root.roadPhase * roadH
                    Image {
                        id: roadImg1
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: roadWindow.roadW
                        height: roadWindow.roadH
                        y: roadWindow.baseY + roadWindow.px
                        source: "qrc:/assets/road.png"
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        opacity: 0.36
                    }
                    Image {
                        id: roadImg2
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: roadWindow.roadW
                        height: roadWindow.roadH
                        y: roadImg1.y - roadWindow.roadH
                        source: "qrc:/assets/road.png"
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        opacity: 0.36
                    }
                    // Fog cap: calm the sky and hide any seam
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: parent.height * 0.44
                        z: 3
                        gradient: Gradient {
                            GradientStop {
                                position: 0.00
                                color: "#05080eff"
                            }
                            GradientStop {
                                position: 0.62
                                color: "#05080eff"
                            }
                            GradientStop {
                                position: 1.00
                                color: "#05080e00"
                            }
                        }
                    }
                    // ADAS calming band behind the ADAS box (aligned with new ADAS position)
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width * 0.62
                        height: parent.height * 0.22
                        y: parent.height * 0.46
                        radius: 32 * root.s
                        z: 4
                        color: "#05080e"
                        opacity: 0.58
                    }
                    // Soft global fade
                    Rectangle {
                        anchors.fill: parent
                        z: 5
                        gradient: Gradient {
                            GradientStop {
                                position: 0.00
                                color: "#05080eff"
                            }
                            GradientStop {
                                position: 0.50
                                color: "#05080eff"  // Changed from 0.30/#e6 for less fade higher up
                            }
                            GradientStop {
                                position: 0.80
                                color: "#05080e88"  // Changed from 0.65 for fade starting lower
                            }
                            GradientStop {
                                position: 1.00
                                color: "#05080e00"
                            }
                        }
                    }
                    Rectangle {
                        anchors.fill: parent
                        z: 6
                        color: "#000000"
                        opacity: 0.05
                    }
                    Rectangle {
                        anchors.fill: parent
                        z: 7
                        color: "#4fb3d9"
                        opacity: 0.006
                    }
                }

                // Top protection matches roadWindow topMargin
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: roadWindow.anchors.topMargin
                    color: "#05080e"
                    opacity: 1.0
                    z: 10
                }
            }

            // Road animation (seamless)
            NumberAnimation {
                id: roadAnim
                target: root
                property: "roadPhase"
                from: 0
                to: 1
                loops: Animation.Infinite
                running: vehicleData.speed > 0.5

                property real kmh: vehicleData.speed * 3.6
                property real clamped: Math.max(10, Math.min(kmh, 160))
                duration: 1400 - (clamped * 6)
                onStopped: root.roadPhase = 0
            }

            // Background grid and glow
            Image {
                source: "qrc:/assets/cluster_floor_grid.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 26 * root.sy
                sourceSize.width: 1200
                opacity: 0.55
                z: 1
            }

            Image {
                source: "qrc:/assets/cluster_car_glow.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 74 * root.sy
                sourceSize.width: 900
                opacity: 0.9
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

                // Left navigation panel
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 220 * root.s

                    ColumnLayout {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -18 * root.sy
                        spacing: 16 * root.s

                        Item {
                            width: 110 * root.s
                            height: 110 * root.s
                            Layout.alignment: Qt.AlignHCenter

                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: "#4fb3d914"
                                border.color: "#4fb3d933"
                                border.width: 1
                            }
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 8 * root.s
                                radius: (width - 16 * root.s) / 2
                                color: "#0f1c29cc"
                                border.color: "#4fb3d926"
                                border.width: 1
                            }
                            Image {
                                source: "qrc:/icons/navigation/turn-right.svg"
                                sourceSize.width: 64 * root.s
                                sourceSize.height: 64 * root.s
                                anchors.centerIn: parent
                            }
                        }

                        Text {
                            text: "500 m"
                            color: "#4fb3d9"
                            font.pixelSize: 36 * root.s
                            font.weight: Font.Bold
                            Layout.alignment: Qt.AlignHCenter
                        }

                        RowLayout {
                            spacing: 6 * root.s
                            Layout.alignment: Qt.AlignHCenter

                            Rectangle {
                                width: 16 * root.s
                                height: 16 * root.s
                                radius: (16 * root.s) / 2
                                color: "#4fb3d9"
                                Layout.alignment: Qt.AlignVCenter
                                Text {
                                    text: "A"
                                    color: "#0b1624"
                                    font.pixelSize: 10 * root.s
                                    font.weight: Font.Bold
                                    anchors.centerIn: parent
                                }
                            }

                            Text {
                                text: "右转进入金科路"
                                color: "#7a8a9a"
                                font.pixelSize: 13 * root.s
                            }
                        }
                    }
                }

                // CENTER: Speed + ADAS (OEM position)
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Speed vignette (moved DOWN, less "sky")
                    Rectangle {
                        width: 600 * root.s
                        height: 240 * root.s
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -70 * root.sy
                        radius: height
                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: "#0b1624"
                            }
                            GradientStop {
                                position: 0.70
                                color: "#0b1624"
                            }
                            GradientStop {
                                position: 1.0
                                color: "#08111a00"
                            }
                        }
                        opacity: 0.82
                    }

                    ColumnLayout {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -82 * root.sy
                        spacing: 6 * root.s

                        Text {
                            text: Math.round(vehicleData.speed * 3.6).toString()
                            color: "#ffffff"
                            font.pixelSize: 158 * root.s
                            font.weight: Font.ExtraBold
                            Layout.alignment: Qt.AlignHCenter
                            style: Text.Outline
                            styleColor: "#4fb3d9"
                        }

                        Text {
                            text: "km/h"
                            color: "#7a8a9a"
                            font.pixelSize: 20 * root.s
                            font.weight: Font.DemiBold
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // ADAS / warnings area (closer to speed, smaller)
                    Rectangle {
                        id: adasZone
                        width: 560 * root.s
                        height: 175 * root.s
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 74 * root.sy
                        radius: 28 * root.s
                        color: "#2E0B1624"
                        border.color: "#4fb3d933"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16 * root.s
                            spacing: 14 * root.s

                            Item {
                                Layout.preferredWidth: 96 * root.s
                                Layout.preferredHeight: 96 * root.s
                                Layout.alignment: Qt.AlignVCenter

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 100 * root.s
                                    height: 100 * root.s
                                    radius: (100 * root.s) / 2
                                    color: "#d81f2a"
                                    opacity: 0.10
                                }

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 92 * root.s
                                    height: 92 * root.s
                                    radius: (92 * root.s) / 2
                                    color: "#ffffff"
                                    border.color: "#d81f2a"
                                    border.width: 7 * root.s
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: root.speedLimitValue.toString()
                                    color: "#0b1624"
                                    font.pixelSize: 32 * root.s
                                    font.weight: Font.ExtraBold
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Item {
                                Layout.preferredWidth: 72 * root.s
                                Layout.preferredHeight: 72 * root.s
                                Layout.alignment: Qt.AlignVCenter

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 56 * root.s
                                    height: 56 * root.s
                                    radius: 14 * root.s
                                    color: "#0b1624"
                                    border.color: "#4fb3d933"
                                    border.width: 1
                                    opacity: 0.55
                                }
                            }
                        }
                    }

                    // Car base glow
                    Rectangle {
                        width: 260 * root.s
                        height: 80 * root.s
                        radius: (80 * root.s) / 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 64 * root.sy
                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: "#0b1624"
                            }
                            GradientStop {
                                position: 0.5
                                color: "#4fb3d9"
                            }
                            GradientStop {
                                position: 1.0
                                color: "#0b1624"
                            }
                        }
                        opacity: 0.85
                    }

                    Image {
                        source: "qrc:/icons/cluster/model3.svg"
                        sourceSize.width: 200 * root.s
                        sourceSize.height: 200 * root.s
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 26 * root.sy
                        opacity: 1.0
                    }
                }

                // RIGHT: Media Player
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 220 * root.s

                    ColumnLayout {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -18 * root.sy
                        spacing: 16 * root.s

                        Rectangle {
                            width: 150 * root.s
                            height: 150 * root.s
                            radius: 14 * root.s
                            color: "#1a2a3a"
                            border.color: "#4fb3d94d"
                            border.width: 1
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                source: "qrc:/assets/album_art.svg"
                                sourceSize.width: 100 * root.s
                                sourceSize.height: 100 * root.s
                                anchors.centerIn: parent
                                fillMode: Image.PreserveAspectFit
                                opacity: 0.9
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 10 * root.s
                                gradient: Gradient {
                                    GradientStop {
                                        position: 0.0
                                        color: "#1a3040aa"
                                    }
                                    GradientStop {
                                        position: 1.0
                                        color: "#1a304000"
                                    }
                                }
                                opacity: 0.5
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "transparent"
                                border.color: "#4fb3d91a"
                                border.width: 1
                            }
                        }

                        Text {
                            text: "Send Me Your Love"
                            color: "#ffffff"
                            font.pixelSize: 16 * root.s
                            font.weight: Font.Bold
                            Layout.alignment: Qt.AlignHCenter
                            Layout.maximumWidth: 190 * root.s
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignHCenter
                        }

                        ColumnLayout {
                            spacing: 4 * root.s
                            Layout.alignment: Qt.AlignHCenter

                            Text {
                                text: "OneRepublic"
                                color: "#7a8a9a"
                                font.pixelSize: 13 * root.s
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Rectangle {
                                width: 90 * root.s
                                height: 2 * root.s
                                radius: 1 * root.s
                                color: "#4fb3d9"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        Rectangle {
                            width: 180 * root.s
                            height: 3 * root.s
                            radius: 1.5 * root.s
                            color: "#1a3040"
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 6 * root.s
                            Rectangle {
                                width: parent.width * 0.6
                                height: parent.height
                                radius: parent.radius
                                color: "#4fb3d9"
                            }
                        }

                        RowLayout {
                            spacing: 26 * root.s
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 6 * root.s

                            Image {
                                source: "qrc:/icons/controls/previous.svg"
                                sourceSize.width: 22 * root.s
                                sourceSize.height: 22 * root.s
                                opacity: 0.7
                            }

                            Rectangle {
                                width: 46 * root.s
                                height: 46 * root.s
                                radius: (46 * root.s) / 2
                                color: "#1c3048"
                                border.color: "#6fd3ff"
                                border.width: 2 * root.s
                                Image {
                                    source: "qrc:/icons/controls/play.svg"
                                    sourceSize.width: 20 * root.s
                                    sourceSize.height: 20 * root.s
                                    anchors.centerIn: parent
                                }
                            }

                            Image {
                                source: "qrc:/icons/controls/next.svg"
                                sourceSize.width: 22 * root.s
                                sourceSize.height: 22 * root.s
                                opacity: 0.7
                            }
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

            color: "#070c13cc"
            border.color: "#232a35"
            border.width: 1
            radius: 4 * root.s

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14 * root.s
                spacing: 60 * root.s

                Text {
                    text: "Trip A " + Math.round(vehicleData.trip || 568) + "km"
                    color: "#a6b4c2"
                    font.pixelSize: 12 * root.s
                    font.weight: Font.Medium
                }

                Item {
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 10 * root.s
                    Layout.alignment: Qt.AlignHCenter

                    Text {
                        text: "kw"
                        color: "#7a8a9a"
                        font.pixelSize: 11 * root.s
                    }

                    Rectangle {
                        width: 110 * root.s
                        height: 5 * root.s
                        radius: 2.5 * root.s
                        color: "#1a3040"
                        Rectangle {
                            width: parent.width * (vehicleData.power / 100 || 0.9)
                            height: parent.height
                            radius: parent.radius
                            color: "#4fb3d9"
                        }
                    }

                    Text {
                        text: Math.round(vehicleData.power || 98)
                        color: "#4fb3d9"
                        font.pixelSize: 12 * root.s
                        font.weight: Font.Bold
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "ODO " + Math.round(vehicleData.odo || 1273) + "km"
                    color: "#a6b4c2"
                    font.pixelSize: 12 * root.s
                    font.weight: Font.Medium
                }
            }
        }
    }
}
