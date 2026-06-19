/**
 * @file EmergencyAlert.qml
 * @author DrivaPi Team
 * @brief V2X Emergency Vehicle Priority Alert Overlay (Premium Angular Style)
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects as Effects
import "../../../theme"

Item {
    id: root

    property bool isActive: false
    property string alertMessage: "EMERGENCY VEHICLE"
    property real s: 1.0

    width: 460 * s
    height: 70 * s

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: isActive ? (70 * s) : (-height - 40)

    opacity: isActive ? 1.0 : 0.0

    Behavior on anchors.topMargin {
        NumberAnimation { duration: 700; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
    }
    Behavior on opacity {
        NumberAnimation { duration: 400; easing.type: Easing.OutQuad }
    }

    // Outer glow effect
    layer.enabled: true
    layer.effect: Effects.DropShadow {
        transparentBorder: true
        radius: 20 * root.s
        samples: 35
        color: root.isActive ? "#99FF0000" : "transparent"
        verticalOffset: 4
    }

    // Angular background shape
    Shape {
        id: angularBackground
        anchors.fill: parent
        
        ShapePath {
            strokeWidth: 2 * root.s
            strokeColor: "#FF1A1A"
            
            fillGradient: LinearGradient {
                x1: 0; y1: 0; x2: 0; y2: root.height
                GradientStop { position: 0.0; color: "#D91A0000" } 
                GradientStop { position: 1.0; color: "#E6050505" } 
            }

            startX: 20 * root.s; startY: 0
            PathLine { x: root.width - 20 * root.s; y: 0 }
            PathLine { x: root.width; y: root.height / 2 }
            PathLine { x: root.width - 20 * root.s; y: root.height }
            PathLine { x: 20 * root.s; y: root.height }
            PathLine { x: 0; y: root.height / 2 }
            PathLine { x: 20 * root.s; y: 0 }
        }
    }

    // Content layout
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 40 * root.s
        anchors.rightMargin: 40 * root.s
        spacing: 20 * root.s

        Image {
            source: "qrc:/icons/common/alert.svg"
            Layout.preferredWidth: 30 * root.s
            Layout.preferredHeight: 30 * root.s
            layer.enabled: true
            layer.effect: Effects.ColorOverlay {
                color: "#FF3333"
            }

            SequentialAnimation on opacity {
                running: root.isActive
                loops: Animation.Infinite
                NumberAnimation { to: 0.3; duration: 800; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
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
                radius: 4; samples: 8; color: "#000000"; verticalOffset: 2
            }
        }
    }
}
