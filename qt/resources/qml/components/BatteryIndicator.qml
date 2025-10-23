import QtQuick 2.15

Row {
    id: root

    property int batteryLevel: 100

    spacing: 15

    Rectangle {
        width: 35
        height: 20
        color: "transparent"
        border.color: root.batteryLevel > 20 ? "#00D66C" : "#FF3B3B"
        border.width: 2.5
        radius: 3
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            anchors.fill: parent
            anchors.margins: 3.5
            color: root.batteryLevel > 20 ? "#00D66C" : "#FF3B3B"
            radius: 1
        }

        Rectangle {
            width: 5
            height: 12
            color: root.batteryLevel > 20 ? "#00D66C" : "#FF3B3B"
            anchors.left: parent.right
            anchors.leftMargin: -1
            anchors.verticalCenter: parent.verticalCenter
            radius: 2
        }
    }

    Text {
        text: Math.round(root.batteryLevel) + "%"
        font.pixelSize: 16
        font.family: "SF Pro Display"
        color: "#FFFFFF"
        anchors.verticalCenter: parent.verticalCenter
    }
}
