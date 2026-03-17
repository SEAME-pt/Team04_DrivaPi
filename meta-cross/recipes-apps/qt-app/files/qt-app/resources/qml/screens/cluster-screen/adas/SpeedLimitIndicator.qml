/**
 * @file SpeedLimitIndicator.qml
 * @author DrivaPi Team
 * @brief Speed limit sign indicator (ISO 26262 Safety-Critical Element)
 */

import QtQuick
import QtQuick.Layouts
import "../../../theme"

Item {
    id: root

    property bool vehicleDataAvailable: false
    property int  speedLimitValue: 120
    property real s: 1.0

    // Size constants (logical pixels, scaled by s)
    readonly property int outerGlow:   128
    readonly property int midGlow:     116
    readonly property int innerGlow:   110
    readonly property int mainCircle:  102
    readonly property int borderWidth:   9
    readonly property int fontSizeLarge: 28

    width:  120 * s
    height: 120 * s

    // Outer glow layer
    Rectangle {
        anchors.centerIn: parent
        width:  root.outerGlow * root.s
        height: root.outerGlow * root.s
        radius: (root.outerGlow * root.s) / 2
        color:   root.vehicleDataAvailable ? "#d81f2a" : AppTheme.colors.textSecondary
        opacity: 0.15
    }

    // Mid-tone glow (depth effect)
    Rectangle {
        anchors.centerIn: parent
        width:  root.midGlow * root.s
        height: root.midGlow * root.s
        radius: (root.midGlow * root.s) / 2
        color:   root.vehicleDataAvailable ? "#d81f2a" : AppTheme.colors.textSecondary
        opacity: 0.08
    }

    // Background glow (low opacity - fail-safe indicator)
    Rectangle {
        anchors.centerIn: parent
        width:  root.innerGlow * root.s
        height: root.innerGlow * root.s
        radius: (root.innerGlow * root.s) / 2
        color:   root.vehicleDataAvailable ? "#d81f2a" : AppTheme.colors.textSecondary
        opacity: 0.12
    }

    // Main speed limit circle
    Rectangle {
        anchors.centerIn: parent
        width:  root.mainCircle * root.s
        height: root.mainCircle * root.s
        radius: (root.mainCircle * root.s) / 2
        color:         root.vehicleDataAvailable ? AppTheme.colors.surfaceElevated : AppTheme.colors.surfaceVariant
        border.color:  root.vehicleDataAvailable ? "#d81f2a" : AppTheme.colors.border
        border.width:  root.borderWidth * root.s
    }

    // Speed limit value text
    Text {
        anchors.centerIn: parent
        text:           root.vehicleDataAvailable ? root.speedLimitValue.toString() : "--"
        color:          root.vehicleDataAvailable ? AppTheme.colors.text : AppTheme.colors.textSecondary
        font.pixelSize: root.fontSizeLarge * root.s
        font.weight:    Font.ExtraBold
    }
}
