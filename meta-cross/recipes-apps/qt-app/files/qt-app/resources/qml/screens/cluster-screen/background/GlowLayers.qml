import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../theme"

Item {
    id: glowRoot
    anchors.fill: parent

    property real s: 1.0

    // --- Top Glow Layer ---
    Image {
        source: "qrc:/assets/cluster/top-dashboard.png"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: 36 * 2.5 * glowRoot.s
        opacity: AppTheme.isDark ? 0.95 : 0.25
        z: 1

        layer.enabled: true
        layer.effect: ColorOverlay {
            color: AppTheme.isDark ? "transparent" : Qt.lighter(AppTheme.colors.primary, 1.6)
            Behavior on color {
                ColorAnimation { duration: AppTheme.animation.normal }
            }
        }
    }

    // --- Center Left Glow Layer ---
    Image {
        source: "qrc:/assets/cluster/left-dashboard.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        width: parent.width * 0.45
        height: parent.height * 0.60
        opacity: AppTheme.isDark ? 0.95 : 0.25
        z: 1

        layer.enabled: true
        layer.effect: ColorOverlay {
            color: AppTheme.isDark ? "transparent" : Qt.lighter(AppTheme.colors.primary, 1.6)
            Behavior on color {
                ColorAnimation { duration: AppTheme.animation.normal }
            }
        }
    }

    // --- Center Right Glow Layer ---
    Image {
        source: "qrc:/assets/cluster/right-dashboard.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        width: parent.width * 0.45
        height: parent.height * 0.60
        opacity: AppTheme.isDark ? 0.95 : 0.25
        z: 1

        layer.enabled: true
        layer.effect: ColorOverlay {
            color: AppTheme.isDark ? "transparent" : Qt.lighter(AppTheme.colors.primary, 1.6)
            Behavior on color {
                ColorAnimation { duration: AppTheme.animation.normal }
            }
        }
    }

    // --- Bottom Glow Layer ---
    Image {
        source: "qrc:/assets/cluster/bottom-dashboard.png"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.PreserveAspectFit
        width: parent.width * 0.95
        height: 36 * 3.5 * glowRoot.s
        opacity: AppTheme.isDark ? 0.95 : 0.25
        z: 1

        layer.enabled: true
        layer.effect: ColorOverlay {
            color: AppTheme.isDark ? "transparent" : Qt.lighter(AppTheme.colors.primary, 1.6)
            Behavior on color {
                ColorAnimation { duration: AppTheme.animation.normal }
            }
        }
    }
}
