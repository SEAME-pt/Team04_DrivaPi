/**
 * @file EmergencyAlert.qml
 * @author DrivaPi Team
 * @brief ADAS / V2X alert overlay.
 *
 * If iconSource is set, the component displays the detected ADAS sign.
 * If iconSource is empty, it falls back to the original V2X text alert.
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects as Effects
import "../../../theme"

Item {
    id: root

    property bool isActive: false
    property int priorityLevel: 2 // 1 = Warning, 2 = High priority
    property string alertMessage: "EMERGENCY VEHICLE"
    property url iconSource: ""
    property real s: 1.0

    readonly property bool hasIcon: root.iconSource.toString().length > 0
    readonly property color mainColor: priorityLevel >= 2 ? "#FF1A1A" : "#FF9900"
    readonly property color glowColor: priorityLevel >= 2 ? "#99FF0000" : "#99FF9900"
    readonly property color gradientStart: priorityLevel >= 2 ? "#D91A0000" : "#D9331A00"
    readonly property color gradientEnd: "#E6050505"
    readonly property int pulseDuration: priorityLevel >= 2 ? 400 : 800

    width: hasIcon ? (115 * s) : (560 * s)
	height: hasIcon ? (115 * s) : (70 * s)

	anchors.horizontalCenter: parent.horizontalCenter
	anchors.horizontalCenterOffset: hasIcon ? (90 * s) : 0
	anchors.top: parent.top
	anchors.topMargin: isActive ? (hasIcon ? (82 * s) : (70 * s)) : (-height - 40)

    opacity: isActive ? 1.0 : 0.0
    visible: opacity > 0.01
    z: 99999

    Behavior on anchors.topMargin {
        NumberAnimation {
            duration: 700
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutQuad
        }
    }

    layer.enabled: true
    layer.effect: Effects.DropShadow {
        transparentBorder: true
        radius: 22 * root.s
        samples: 35
        color: root.isActive ? root.glowColor : "transparent"
        verticalOffset: 4
    }

    // ==========================================================
    // ADAS IMAGE MODE
    // ==========================================================
    Image {
        id: signIcon
        anchors.fill: parent
        source: root.iconSource
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        cache: false
        visible: root.hasIcon

        SequentialAnimation on scale {
            running: root.isActive && root.hasIcon
            loops: Animation.Infinite

            NumberAnimation {
                to: 0.92
                duration: root.pulseDuration
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                to: 1.0
                duration: root.pulseDuration
                easing.type: Easing.InOutSine
            }
        }
    }

    // ==========================================================
    // V2X TEXT FALLBACK MODE
    // ==========================================================
    Shape {
        id: angularBackground
        anchors.fill: parent
        visible: !root.hasIcon

        ShapePath {
            strokeWidth: 2 * root.s
            strokeColor: root.mainColor

            fillGradient: LinearGradient {
                x1: 0
                y1: 0
                x2: 0
                y2: root.height

                GradientStop { position: 0.0; color: root.gradientStart }
                GradientStop { position: 1.0; color: root.gradientEnd }
            }

            startX: 20 * root.s
            startY: 0

            PathLine { x: root.width - 20 * root.s; y: 0 }
            PathLine { x: root.width; y: root.height / 2 }
            PathLine { x: root.width - 20 * root.s; y: root.height }
            PathLine { x: 20 * root.s; y: root.height }
            PathLine { x: 0; y: root.height / 2 }
            PathLine { x: 20 * root.s; y: 0 }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 40 * root.s
        anchors.rightMargin: 40 * root.s
        spacing: 20 * root.s
        visible: !root.hasIcon

        Image {
            source: "qrc:/icons/common/alert.svg"
            Layout.preferredWidth: 30 * root.s
            Layout.preferredHeight: 30 * root.s

            layer.enabled: true
            layer.effect: Effects.ColorOverlay {
                color: root.mainColor
            }

            SequentialAnimation on opacity {
                running: root.isActive && !root.hasIcon
                loops: Animation.Infinite

                NumberAnimation {
                    to: 0.3
                    duration: root.pulseDuration
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    to: 1.0
                    duration: root.pulseDuration
                    easing.type: Easing.InOutSine
                }
            }
        }

        Text {
            text: root.alertMessage
            color: "#FFFFFF"
            font.family: AppTheme.typography.fontFamily
            font.pixelSize: 22 * root.s
            font.weight: Font.Black
            font.letterSpacing: 3.0
            font.capitalization: Font.AllUppercase
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            layer.enabled: true
            layer.effect: Effects.DropShadow {
                radius: 4
                samples: 8
                color: "#000000"
                verticalOffset: 2
            }
        }
    }
}
