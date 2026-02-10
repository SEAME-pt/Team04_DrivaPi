import QtQuick

Item {
    id: root

    property string currentGear: "P"
    signal gearUp
    signal gearDown

    height: 44

    Row {
        anchors.centerIn: parent

        // PRND pill background and highlight
        Rectangle {
            color: "#181f2b"
            radius: 18
            border.color: "#4fb3d9"
            border.width: 1.2
            height: 36
            width: 160
            anchors.verticalCenter: parent.verticalCenter

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 14
                Repeater {
                    model: ["P", "R", "N", "D"]
                    delegate: Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: root.currentGear === modelData ? "#6fd3ff" : "transparent"
                        border.color: root.currentGear === modelData ? "#6fd3ff" : "transparent"
                        border.width: root.currentGear === modelData ? 1.2 : 0
                        anchors.verticalCenter: parent.verticalCenter
                        z: root.currentGear === modelData ? 2 : 1
                        Text {
                            text: modelData
                            anchors.centerIn: parent
                            font.pixelSize: 18
                            font.family: "SF Pro Display"
                            font.weight: Font.Bold
                            color: root.currentGear === modelData ? "#181f2b" : "#E6E6E6"
                            opacity: root.currentGear === modelData ? 1.0 : 0.5
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 200
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
