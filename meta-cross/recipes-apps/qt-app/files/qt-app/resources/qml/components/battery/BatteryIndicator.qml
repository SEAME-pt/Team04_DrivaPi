import QtQuick
import "../../theme"

Row {
    id: root

    property int batteryLevel: 100

    readonly property color batteryColor: root.batteryLevel > 20 ? AppTheme.colors.success : AppTheme.colors.error

    spacing: 15

    Rectangle {
        width: 35
        height: 20
        color: "transparent"
        border.color: root.batteryColor
        border.width: 2.5
        radius: 3
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            anchors.fill: parent
            anchors.margins: 3.5
            color: root.batteryColor
            radius: 1
        }

        Rectangle {
            width: 5
            height: 12
            color: root.batteryColor
            anchors.left: parent.right
            anchors.leftMargin: -1
            anchors.verticalCenter: parent.verticalCenter
            radius: 2
        }
    }

    Text {
        text: Math.round(root.batteryLevel) + "%"
        font.pixelSize: 16
        font.family: AppTheme.typography.fontFamily
        color: AppTheme.colors.text
        anchors.verticalCenter: parent.verticalCenter
    }
}
