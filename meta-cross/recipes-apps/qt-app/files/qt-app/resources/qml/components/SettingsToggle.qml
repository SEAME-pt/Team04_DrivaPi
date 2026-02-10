import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property bool toggled: false
    signal toggleRequested()

    Layout.fillWidth: true
    Layout.preferredHeight: 80
    color: AppTheme.colors.surface

    RowLayout {
        anchors.fill: parent
        anchors.margins: AppTheme.spacing.medium
        spacing: AppTheme.spacing.medium

        Image { source: icon; sourceSize.width: 24; sourceSize.height: 24 }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: AppTheme.spacing.xSmall

            Text { text: title; color: AppTheme.colors.text; font.pixelSize: AppTheme.typography.labelLarge; font.weight: Font.Bold }
            Text { text: subtitle; color: AppTheme.colors.textSecondary; font.pixelSize: AppTheme.typography.labelSmall }
        }

        Rectangle {
            width: 50
            height: 28
            radius: 14
            color: toggled ? AppTheme.colors.primary : AppTheme.colors.surfaceElevated

            Rectangle {
                width: 24
                height: 24
                radius: 12
                color: AppTheme.colors.text
                anchors.verticalCenter: parent.verticalCenter
                x: toggled ? parent.width - width - 2 : 2

                Behavior on x { NumberAnimation { duration: 200 } }
            }

            MouseArea { anchors.fill: parent; onClicked: parent.parent.parent.toggleRequested() }
        }
    }
}