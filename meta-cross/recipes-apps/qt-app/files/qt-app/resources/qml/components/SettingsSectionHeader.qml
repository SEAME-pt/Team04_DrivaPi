import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    required property string text
    property string icon: ""

    Layout.fillWidth: true
    Layout.preferredHeight: 50
    color: AppTheme.colors.surface

    RowLayout {
        anchors.fill: parent
        anchors.margins: AppTheme.spacing.medium
        spacing: AppTheme.spacing.medium

        Image { source: icon; sourceSize.width: 20; sourceSize.height: 20; visible: icon.length > 0 }

        Text {
            text: parent.text
            color: AppTheme.colors.primary
            font.pixelSize: AppTheme.typography.labelLarge
            font.weight: Font.Bold
            font.letterSpacing: 0.5
        }
    }
}