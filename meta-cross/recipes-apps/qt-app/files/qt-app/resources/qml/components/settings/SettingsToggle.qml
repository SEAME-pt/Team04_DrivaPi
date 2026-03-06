import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../theme"

Rectangle {
    id: cardRoot
    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property bool toggled: false
    signal toggleRequested()

    Layout.fillWidth: true
    Layout.preferredHeight: 80

    // Use surfaceVariant to give the card a slight "lift" or distinction
    color: AppTheme.colors.surfaceVariant
    radius: AppTheme.radius.medium

    // Add a very subtle border for Light Mode definition
    border.color: AppTheme.colors.divider
    border.width: AppTheme.isDark ? 0 : 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: AppTheme.spacing.medium
        spacing: AppTheme.spacing.medium

        // Icon with theme-aware color overlay
        Item {
            width: 24
            height: 24
            Image {
                id: iconImg
                source: icon
                anchors.fill: parent
                sourceSize.width: 24
                sourceSize.height: 24
                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: cardRoot.toggled ? AppTheme.colors.primary : AppTheme.colors.textSecondary
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: AppTheme.spacing.xxSmall

            Text {
                text: title
                color: AppTheme.colors.text
                font.pixelSize: AppTheme.typography.bodyLarge
                font.family: AppTheme.typography.fontFamily
                font.weight: AppTheme.typography.weightBold
            }

            Text {
                text: subtitle
                color: AppTheme.colors.textSecondary
                font.pixelSize: AppTheme.typography.labelSmall
                font.family: AppTheme.typography.fontFamily
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                opacity: 0.8
            }
        }

        // ====== THEMED TOGGLE SWITCH ======
        Rectangle {
            id: switchTrack
            width: 52
            height: 28
            radius: height / 2
            // Track is primary when ON, elevated surface when OFF
            color: toggled ? AppTheme.colors.primary : AppTheme.colors.surfaceElevated
            border.color: toggled ? "transparent" : AppTheme.colors.border
            border.width: 1

            Rectangle {
                id: handle
                width: 22
                height: 22
                radius: 11
                // The handle should be white in Dark Mode, but perhaps AppTheme.colors.surface in Light
                color: AppTheme.isDark ? "#FFFFFF" : AppTheme.colors.surfaceElevated
                anchors.verticalCenter: parent.verticalCenter
                x: toggled ? parent.width - width - 3 : 3

                // Handle shadow for Light Mode depth
                layer.enabled: !AppTheme.isDark
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 0
                    verticalOffset: 1
                    radius: 4
                    samples: 8
                    color: "#40000000"
                }

                Behavior on x {
                    NumberAnimation { duration: AppTheme.animation.fast; easing.type: Easing.OutCubic }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: cardRoot.toggleRequested()
            }
        }
    }

    // Smooth color transitions when theme changes
    Behavior on color { ColorAnimation { duration: AppTheme.animation.normal } }
}
