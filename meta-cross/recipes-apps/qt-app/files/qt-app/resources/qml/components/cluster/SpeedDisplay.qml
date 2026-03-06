import QtQuick
import "../../theme"

Item {
    id: root
    width: speedNumber.width
    height: speedNumber.height + 25

    property real speed: 0.0

    // Main Speed Number
    Text {
        id: speedNumber
        // We use Math.floor or toFixed(0) usually for speed,
        // but keeping your .toFixed(1) as requested
        text: root.speed.toFixed(1).toString()
        renderType: Text.NativeRendering
        font.pixelSize: AppTheme.typography.displayLarge * 2.5 // Scaling based on theme
        font.family: AppTheme.typography.fontFamily
        font.weight: Font.DemiBold

        // Context-aware color
        color: AppTheme.colors.text

        // Subtle outline for depth, adjusted for theme
        style: Text.Outline
        styleColor: AppTheme.isDark ? AppTheme.alpha("#000000", 0.5) : AppTheme.alpha("#000000", 0.1)

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 0 // Adjusted from -100 for standard Item layout

        layer.enabled: true

        Behavior on color { ColorAnimation { duration: AppTheme.animation.normal } }
    }

    // Unit Label
    Text {
        text: "KM/H"
        font.pixelSize: AppTheme.typography.labelLarge
        font.family: AppTheme.typography.fontFamily
        font.weight: AppTheme.typography.weightLight

        // Uses the secondary text color (gray in dark, muted navy in light)
        color: AppTheme.colors.textSecondary

        anchors.horizontalCenter: speedNumber.horizontalCenter
        anchors.top: speedNumber.bottom
        anchors.topMargin: -5 // Pulled up slightly for a tighter look

        opacity: 0.8
        Behavior on color { ColorAnimation { duration: AppTheme.animation.normal } }
    }
}
