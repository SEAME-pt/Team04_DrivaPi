import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    property string text: ""
    property string icon: ""
    property bool selected: false
    signal clicked()

    Layout.fillWidth: true
    Layout.preferredHeight: 40
    radius: AppTheme.radius.small
    color: selected ? AppTheme.colors.primary : AppTheme.colors.surface
    border.color: selected ? AppTheme.colors.primary : AppTheme.colors.divider
    border.width: 1

    RowLayout {
        anchors.centerIn: parent
        spacing: AppTheme.spacing.xSmall

        Image { source: icon; sourceSize.width: 16; sourceSize.height: 16; visible: icon.length > 0 }
        Text { text: parent.text; color: selected ? AppTheme.colors.surface : AppTheme.colors.text; font.pixelSize: AppTheme.typography.labelMedium; font.weight: Font.Bold }
    }

    MouseArea { anchors.fill: parent; onClicked: parent.clicked() }
}