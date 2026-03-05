import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../theme"

Item {
    id: glowRoot
    anchors.fill: parent

    property real s: 1.0

    // --- Top Glow Layer ---
    Image {
        source: "qrc:/assets/top_dashboard.png"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: 36 * 2.5 * glowRoot.s
        opacity: AppTheme.isDark ? 0.95 : 0.3
        z: 1

        layer.enabled: true
        layer.effect: ColorOverlay {
            color: AppTheme.isDark ? "transparent" : AppTheme.colors.surfaceVariant
            Behavior on color {
                ColorAnimation { duration: AppTheme.animation.normal }
            }
        }
    }

    // --- Center Left Glow Layer ---
    Image {
        source: "qrc:/assets/left_dashboard.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        width: parent.width * 0.45
        height: parent.height * 0.60
        opacity: AppTheme.isDark ? 0.95 : 0.5
        z: 1

        layer.enabled: true
        layer.effect: ColorOverlay {
            color: AppTheme.isDark ? "transparent" : AppTheme.colors.surfaceVariant
            Behavior on color {
                ColorAnimation { duration: AppTheme.animation.normal }
            }
        }
    }

    // --- Center Right Glow Layer ---
    Image {
        source: "qrc:/assets/right_dashboard.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        width: parent.width * 0.45
        height: parent.height * 0.60
        opacity: AppTheme.isDark ? 0.95 : 0.3
        z: 1

        layer.enabled: true
        layer.effect: ColorOverlay {
            color: AppTheme.isDark ? "transparent" : AppTheme.colors.surfaceVariant
            Behavior on color {
                ColorAnimation { duration: AppTheme.animation.normal }
            }
        }
    }

    // --- Bottom Glow Layer ---
    Image {
        source: "qrc:/assets/bottom_dashboard.png"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.PreserveAspectFit
        width: parent.width * 0.95
        height: 36 * 3.5 * glowRoot.s
        opacity: AppTheme.isDark ? 0.95 : 0.3
        z: 1

        layer.enabled: true
        layer.effect: ColorOverlay {
            color: AppTheme.isDark ? "transparent" : AppTheme.colors.surfaceVariant
            Behavior on color {
                ColorAnimation { duration: AppTheme.animation.normal }
            }
        }
    }
}
