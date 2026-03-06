import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../theme"

Rectangle {
    id: pillRoot
    property string text: ""
    property string icon: ""
    property bool selected: false
    signal clicked()

    Layout.fillWidth: true
    Layout.preferredHeight: 40
    radius: AppTheme.radius.small

    // Background color logic
    color: selected ? AppTheme.colors.primary : AppTheme.colors.surfaceElevated

    // Border logic: Subtle in dark mode, more defined in light mode
    border.color: selected ? AppTheme.colors.primary : AppTheme.colors.divider
    border.width: 1

    RowLayout {
        anchors.centerIn: parent
        spacing: AppTheme.spacing.small

        // Icon with ColorOverlay to ensure it flips color based on selection
        Item {
            width: 16
            height: 16
            visible: icon.length > 0
            Image {
                id: iconImg
                source: icon
                anchors.fill: parent
                sourceSize.width: 16
                sourceSize.height: 16
                layer.enabled: true
                layer.effect: ColorOverlay {
                    // If selected, icon matches the text (usually white/surface)
                    // If not selected, matches standard text color
                    color: selected ? (AppTheme.isDark ? AppTheme.colors.surface : "#FFFFFF") : AppTheme.colors.text
                }
            }
        }

        Text {
            text: pillRoot.text
            // Text color flips to white/light when the button is "filled" with primary blue
            color: selected ? (AppTheme.isDark ? AppTheme.colors.surface : "#FFFFFF") : AppTheme.colors.text
            font.pixelSize: AppTheme.typography.labelMedium
            font.family: AppTheme.typography.fontFamily
            font.weight: pillRoot.selected ? AppTheme.typography.weightBold : AppTheme.typography.weightMedium

            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: pillRoot.clicked()

        // Add a subtle scale effect when pressed
        onPressed: pillRoot.scale = 0.97
        onReleased: pillRoot.scale = 1.0
        onCanceled: pillRoot.scale = 1.0
    }

    // Smooth transitions for theme/state changes
    Behavior on color { ColorAnimation { duration: 200 } }
    Behavior on border.color { ColorAnimation { duration: 200 } }
    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
}
