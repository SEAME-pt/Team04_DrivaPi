import QtQuick
import "../../theme"

Item {
    id: root
    width: energyNumber.width
    height: energyNumber.height + 25

    property real energy: 0.0

    // Main Energy Consumption Value
    Text {
        id: energyNumber
        text: root.energy.toFixed(1)
        renderType: Text.NativeRendering

        // Use global typography settings
        font.pixelSize: AppTheme.typography.displayLarge * 2.5
        font.family: AppTheme.typography.fontFamily
        font.weight: AppTheme.typography.weightBold

        // Theme-aware color
        color: AppTheme.colors.text

        // Adaptive outline for legibility
        style: Text.Outline
        styleColor: AppTheme.isDark ? AppTheme.alpha("#000000", 0.5) : AppTheme.alpha("#000000", 0.1)

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 0 // Resetting margin for standard component containment

        layer.enabled: true

        // Smooth color transition on theme change
        Behavior on color { ColorAnimation { duration: AppTheme.animation.normal } }
    }

    // Unit Label
    Text {
        text: "KWH / 100KM"
        font.pixelSize: AppTheme.typography.labelMedium
        font.family: AppTheme.typography.fontFamily
        font.weight: AppTheme.typography.weightLight
        font.letterSpacing: 1.2

        // Uses the secondary text color for better visual hierarchy
        color: AppTheme.colors.textSecondary

        anchors.horizontalCenter: energyNumber.horizontalCenter
        anchors.top: energyNumber.bottom
        anchors.topMargin: -5 // Tighter spacing for a modern look

        opacity: 0.8

        Behavior on color { ColorAnimation { duration: AppTheme.animation.normal } }
    }
}
