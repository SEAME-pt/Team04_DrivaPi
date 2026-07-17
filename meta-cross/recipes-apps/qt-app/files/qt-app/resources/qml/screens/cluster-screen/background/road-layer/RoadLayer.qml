import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../../theme"

Item {
    id: roadWindow
    z: 0
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.top: parent.top
    anchors.topMargin: root.clamp(parent.height * root.horizonMarginRatio, 64 * root.sy, 130 * root.sy)
    clip: true

    property real roadW: width * root.roadWidthFactor
    property real roadH: height * root.roadHeightFactor
    property real baseY: -height * Math.abs(root.roadBaseOffset)

    readonly property bool laneDataAvailable: root.vehicleDataAvailable
                                             && vehicleData.laneOffset !== undefined
                                             && vehicleData.laneHeading !== undefined
    readonly property bool laneMaskActive: laneDataAvailable || root.demoLaneAnimation

    // ===== Horizon integration: blur + fade (top only) =====
    Item {
        id: horizonBlend
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: roadWindow.anchors.topMargin + 180 * root.sy
        clip: true
        z: 4
        visible: !roadWindow.laneMaskActive

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.00; color: AppTheme.alpha(AppTheme.colors.surface, 1.0) }
                GradientStop { position: 0.35; color: AppTheme.alpha(AppTheme.colors.surface, 0.8) }
                GradientStop { position: 0.70; color: AppTheme.alpha(AppTheme.colors.surface, 0.88) }
                GradientStop { position: 1.00; color: AppTheme.alpha(AppTheme.colors.surface, 0.0) }
            }
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.00; color: AppTheme.alpha(AppTheme.colors.surface, 1.0) }
                GradientStop { position: 0.55; color: AppTheme.alpha(AppTheme.colors.surface, 0.56) }
                GradientStop { position: 1.00; color: AppTheme.alpha(AppTheme.colors.surface, 0.0) }
            }
            opacity: 0.55
        }
    }

    // ===== FOG GRADIENT OVERLAYS =====
    FogLayer {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: roadWindow.anchors.topMargin + 180 * root.sy
        topProtectionHeight: roadWindow.anchors.topMargin
        z: 5
        visible: !roadWindow.laneMaskActive
    }
}
