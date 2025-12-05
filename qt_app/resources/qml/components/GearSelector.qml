import QtQuick 2.15

Item {
    id: root

    property string currentGear: "P"
    signal gearUp
    signal gearDown

    height: 44

    Row {
        anchors.centerIn: parent
        spacing: 14

        Text {
            text: "◄"
            font.pixelSize: 20
            font.family: "SF Pro Display"
            font.weight: Font.Medium
            color: "#9A9A9A"
            opacity: 0.7
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.gearDown()
            }
        }

        Row {
            spacing: 20
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: ["P", "R", "N", "D"]

                Text {
                    text: modelData
                    font.pixelSize: 20
                    font.family: "SF Pro Display"
                    font.weight: Font.DemiBold
                    color: "#E6E6E6"
                    opacity: root.currentGear === modelData ? 0.95 : 0.25

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }
            }
        }

        Text {
            text: "►"
            font.pixelSize: 20
            font.family: "SF Pro Display"
            font.weight: Font.Medium
            color: "#9A9A9A"
            opacity: 0.7
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.gearUp()
            }
        }
    }
}
