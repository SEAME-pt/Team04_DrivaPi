import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../theme"

Rectangle {
    id: headerRoot
    required property string text
    property string icon: ""

    Layout.fillWidth: true
    Layout.preferredHeight: 50

    // Transparent by default to let the screen color show through,
    // or use surface if you want a distinct block.
    color: "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: AppTheme.spacing.medium
        anchors.rightMargin: AppTheme.spacing.medium
        spacing: AppTheme.spacing.small

        // Icon with ColorOverlay to ensure it matches the Primary branding
        Item {
            width: 20
            height: 20
            visible: icon.length > 0

            Image {
                id: iconImg
                source: icon
                anchors.fill: parent
                sourceSize.width: 20
                sourceSize.height: 20
                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: AppTheme.colors.primary
                }
            }
        }

        Text {
            text: headerRoot.text.toUpperCase() // Headers look cleaner in Uppercase for HMIs
            color: AppTheme.colors.primary
            font.pixelSize: AppTheme.typography.labelSmall
            font.family: AppTheme.typography.fontFamily
            font.weight: AppTheme.typography.weightBold
            font.letterSpacing: 1.5 // Increased spacing for that "premium" automotive look

            Layout.fillWidth: true
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Optional: A very subtle bottom divider to define the section
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: AppTheme.spacing.medium
        height: 1
        color: AppTheme.colors.divider
        opacity: 0.5
    }
}
