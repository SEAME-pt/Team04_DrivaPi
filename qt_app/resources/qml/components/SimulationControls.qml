import QtQuick 2.15

Item {
    id: root

    property bool isRunning: false
    property int simSpeed: 1

    signal startSimulation
    signal stopSimulation
    signal increaseSpeed
    signal decreaseSpeed

    width: 120
    height: 100

    Column {
        anchors.fill: parent
        spacing: 10

        // Start/Stop button
        Rectangle {
            width: 120
            height: 35
            color: root.isRunning ? "#00AA00" : "#AA0000"
            radius: 8

            Text {
                anchors.centerIn: parent
                text: root.isRunning ? "⏸ Stop" : "▶ Start"
                color: "#FFFFFF"
                font.pixelSize: 14
                font.family: "SF Pro Display"
                font.weight: Font.Medium
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.isRunning) {
                        root.stopSimulation();
                    } else {
                        root.startSimulation();
                    }
                }
            }
        }

        // Speed controls
        Row {
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                width: 35
                height: 35
                color: "#333333"
                radius: 6

                Text {
                    anchors.centerIn: parent
                    text: "−"
                    color: "#FFFFFF"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.decreaseSpeed()
                }
            }

            Text {
                text: Math.round(root.simSpeed) + "x"
                color: "#8A8A8A"
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: 35
                height: 35
                color: "#333333"
                radius: 6

                Text {
                    anchors.centerIn: parent
                    text: "+"
                    color: "#FFFFFF"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.increaseSpeed()
                }
            }
        }
    }
}
