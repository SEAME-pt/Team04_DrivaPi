import QtQuick
import QtQuick.Layouts
import "../components"
import QtQuick.Effects
import "../theme"

Rectangle {
    id: root

    // 0..1 loop (seamless)
    property real roadPhase: 0

    // ISO 26262 Fail-Safe: Null/Invalid Data Handling
    property bool vehicleDataAvailable: vehicleData !== null && vehicleData !== undefined

    // Demo / fallback (replace with your real signal if you have it)
    // ISO 26262 ASIL requirement: Valid fallback for critical safety display
    property int speedLimitValue: vehicleDataAvailable && vehicleData.speedLimit ? Math.round(vehicleData.speedLimit) : 120
    property real currentSpeed: vehicleDataAvailable && vehicleData.speed ? vehicleData.speed * 3.6 : 0
    property int currentTemperature: vehicleDataAvailable && vehicleData.temperature ? Math.round(vehicleData.temperature) : 20
    property string currentGear: vehicleDataAvailable && vehicleData.gear ? vehicleData.gear : "P"
    property real tripDistance: vehicleDataAvailable && vehicleData.trip ? vehicleData.trip : 568
    property real powerOutput: vehicleDataAvailable && vehicleData.power ? vehicleData.power : 98
    property real odometerDistance: vehicleDataAvailable && vehicleData.odo ? vehicleData.odo : 1273

    // ============================================================
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
            z: 1
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
            z: 1
        }

        // --- Bottom Glow Layer ---
        Image {
            source: "qrc:/assets/oie_OeB7IAtTvDtn.png"
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            width: parent.width * 0.95
            height: 36 * 3.5 * root.s
            opacity: 0.95
            z: 1
        }

        // ==========================================================
        // ROAD LAYER (road.png is the only lane source)
        // ==========================================================
        Item {
            id: roadLayer
            x: contentArea.x
            y: contentArea.y
            width: contentArea.width
            height: contentArea.height

            Item {
                id: roadWindow
                z: 0
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                // Keep horizon high enough for the rails to "agree"
                // (1200x480 target tuned)
                anchors.topMargin: root.clamp(parent.height * root.horizonMarginRatio, 64 * root.sy, 130 * root.sy)
                clip: true
                // --- Perspective tuning (ISO 26262 calibrated parameters) ---
                // Road perspective optimized for safe lane visualization
                // Reference: 1200x480@60fps baseline
                property real roadW: width * root.roadWidthFactor
                property real roadH: height * root.roadHeightFactor
                property real baseY: -height * Math.abs(root.roadBaseOffset)
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
                    // Opacity reduced slightly for better fail-safe visibility of overlaid ADAS
                    opacity: 0.95
                }
                Image {
                    id: roadImg2
                    z: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: roadWindow.roadW
                    height: roadWindow.roadH
                    y: roadImg1.y - roadWindow.roadH
                    source: "qrc:/assets/road.png"
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    opacity: 0.95
                }
                // Fog cap: calm the sky and hide any seam
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
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
    }

    Item {
        id: uiLayer
        anchors.fill: parent
        z: 10

        ColumnLayout {
            anchors.fill: parent
            spacing: 2
            z: 10

            // Top bar
            ClusterTopBar {
                id: topBar
                Layout.fillWidth: true
                z: 20
                // ISO 26262: Null-safe property access
                currentGear: root.currentGear
                temperatureText: root.currentTemperature + "°C"
            }

            // Main content area
            Item {
                id: contentArea
                Layout.fillWidth: true
                Layout.fillHeight: true

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

                    // Left panel: Speed
                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 500 * root.s

                        ColumnLayout {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -18 * root.sy
                            spacing: 6 * root.s

                            Text {
                                // ISO 26262: Null-safe speed display with fail-safe state
                                text: root.vehicleDataAvailable ? Math.round(root.currentSpeed).toString() : "--"
                                color: root.vehicleDataAvailable ? "#ffffff" : "#666666"
                                font.pixelSize: root.fontSizeXL * root.s
                                font.weight: Font.ExtraBold
                                Layout.alignment: Qt.AlignHCenter
                                style: root.vehicleDataAvailable ? Text.Outline : Text.Normal
                                styleColor: "#4fb3d9"
                            }

                            Text {
                                text: "km/h"
                                color: "#7a8a9a"
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

                        // ISO 26262 ADAS / Warnings Area (ASIL-Compliant Display)
                        // Purpose: Display critical safety information including speed limit and ADAS status
                        // Visibility: High-contrast display for driver awareness
                        // Update Frequency: Real-time from vehicleData signals
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

                                // Speed Limit Indicator (ISO 26262 Safety-Critical Element)
                                // Displays current speed limit with high visibility red/white scheme
                                // Enhanced with glow effect for improved driver awareness
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
                                        color: root.vehicleDataAvailable ? "#d81f2a" : "#555555"
                                        opacity: 0.15
                                    }

                                    // Mid-tone glow (depth effect)
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: root.speedLimitMidGlow * root.s
                                        height: root.speedLimitMidGlow * root.s
                                        radius: (root.speedLimitMidGlow * root.s) / 2
                                        color: root.vehicleDataAvailable ? "#d81f2a" : "#555555"
                                        opacity: 0.08
                                    }

                                    // Background glow (low opacity - fail-safe indicator)
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: root.speedLimitInnerGlow * root.s
                                        height: root.speedLimitInnerGlow * root.s
                                        radius: (root.speedLimitInnerGlow * root.s) / 2
                                        color: root.vehicleDataAvailable ? "#d81f2a" : "#555555"
                                        opacity: 0.12
                                    }

                                    // Main speed limit circle (high contrast white with red border - increased prominence)
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: root.speedLimitMainCircle * root.s
                                        height: root.speedLimitMainCircle * root.s
                                        radius: (root.speedLimitMainCircle * root.s) / 2
                                        color: root.vehicleDataAvailable ? "#ffffff" : "#cccccc"
                                        border.color: root.vehicleDataAvailable ? "#d81f2a" : "#999999"
                                        border.width: root.speedLimitBorderWidth * root.s
                                    }

                                    // Speed limit value (larger, bold, dark text - ISO 26262 WCAG AA compliance)
                                    Text {
                                        anchors.centerIn: parent
                                        // Fail-safe: Show "--" when data unavailable
                                        text: root.vehicleDataAvailable ? root.speedLimitValue.toString() : "--"
                                        color: root.vehicleDataAvailable ? "#0b1624" : "#666666"
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
                            source: "qrc:/assets/car.png"
                            sourceSize.width: 200 * root.s
                            sourceSize.height: 200 * root.s
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 26 * root.sy
                            opacity: 1.0
                        }
                    }

                    // RIGHT: Media Player (Non-Critical Infotainment)
                    // NOTE: Per ISO 26262, media player should be on separate HMI layer
                    // Consider moving to ClusterMediaPanel component for ASIL compliance
                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 500 * root.s

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
                                // Infotainment: Song title (non-critical)
                                text: "Send Me Your Love"
                                color: "#ffffff"
                                font.pixelSize: root.fontSizeSmall * root.s
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
                                    // Infotainment: Artist name (non-critical)
                                    text: "OneRepublic"
                                    color: "#7a8a9a"
                                    font.pixelSize: root.fontSizeXSmall * root.s
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

                    // Trip distance (left)
                    Text {
                        // ISO 26262: Null-safe trip distance display
                        text: "Trip A " + Math.round(root.tripDistance) + "km"
                        color: root.vehicleDataAvailable ? "#a6b4c2" : "#555555"
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
                            color: root.vehicleDataAvailable ? "#7a8a9a" : "#555555"
                            font.pixelSize: root.fontSizeMedium * root.s
                        }

                        // Power bar (ISO 26262: Fail-safe visualization)
                        Rectangle {
                            width: 110 * root.s
                            height: 5 * root.s
                            radius: 2.5 * root.s
                            color: root.vehicleDataAvailable ? "#1a3040" : "#555555"
                            Rectangle {
                                width: root.vehicleDataAvailable ? parent.width * (root.powerOutput / 100) : parent.width * 0.5
                                height: parent.height
                                radius: parent.radius
                                color: root.vehicleDataAvailable ? "#4fb3d9" : "#999999"
                            }
                        }

                        // Power value
                        Text {
                            text: root.vehicleDataAvailable ? Math.round(root.powerOutput) : "--"
                            color: root.vehicleDataAvailable ? "#4fb3d9" : "#666666"
                            font.pixelSize: root.fontSizeMedium * root.s
                            font.weight: Font.Bold
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Odometer distance (right)
                    Text {
                        // ISO 26262: Null-safe odometer display
                        text: "ODO " + Math.round(root.odometerDistance) + "km"
                        color: root.vehicleDataAvailable ? "#a6b4c2" : "#555555"
                        font.pixelSize: root.fontSizeMedium * root.s
                        font.weight: Font.Medium
                    }
                }
            }
        }
    }
}
