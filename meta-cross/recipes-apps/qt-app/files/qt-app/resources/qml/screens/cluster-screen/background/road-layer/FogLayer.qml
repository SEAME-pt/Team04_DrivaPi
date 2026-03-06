import QtQuick 2.15
import "../../../../theme"


Item {
    property real topProtectionHeight: 0

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            z: 5
            gradient: Gradient {
                GradientStop { position: 0.00; color: AppTheme.alpha(AppTheme.colors.surface, 1.0) }
                GradientStop { position: 0.20; color: AppTheme.alpha(AppTheme.colors.surface, 0.88) }
                GradientStop { position: 0.50; color: AppTheme.alpha(AppTheme.colors.surface, 0.25) }
                GradientStop { position: 1.00; color: AppTheme.alpha(AppTheme.colors.surface, 0.0) }
            }
            opacity: 0.65
        }

        // ADAS calming band behind the ADAS box
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.62
            height: parent.height * 0.22
            y: parent.height * 0.46
            radius: 32 * root.s
            z: 6
            visible: false
            color: AppTheme.colors.surfaceVariant
            opacity: 0.40
        }

        // Soft global fade (full height, smooth transition)
        Rectangle {
            anchors.fill: parent
            z: 7
            gradient: Gradient {
                GradientStop { position: 0.00; color: AppTheme.alpha(AppTheme.colors.surface, 1.0) }
                GradientStop { position: 0.30; color: AppTheme.alpha(AppTheme.colors.surface, 0.75) }
                GradientStop { position: 0.70; color: AppTheme.alpha(AppTheme.colors.surface, 0.18) }
                GradientStop { position: 1.00; color: AppTheme.alpha(AppTheme.colors.surface, 0.0) }
            }
            opacity: 0.50
        }

        Rectangle {
            anchors.fill: parent
            z: 8
            color: AppTheme.colors.text
            opacity: 0.02
        }

        Rectangle {
            anchors.fill: parent
            z: 9
            color: AppTheme.colors.primary
            opacity: 0.003
        }

        // Top protection matches roadWindow topMargin
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: topProtectionHeight
            color: AppTheme.colors.surfaceVariant
            opacity: 1.0
            z: 10
        }
    }