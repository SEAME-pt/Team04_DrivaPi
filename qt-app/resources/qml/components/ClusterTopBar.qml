import QtQuick
import QtQuick.Layouts
import "../components"
import "../theme"

Item {
    id: clusterTopBar

    // Signals
    signal batteryClicked

    // Public API
    property alias currentGear: gearSelector.currentGear

    // Use normal properties (avoid alias+binding loops)
    property int batteryLevel: 85
    property string timeTextValue: Qt.formatDateTime(new Date(), "hh:mm")

    // Battery color based on level - matching cluster cyan theme
    property color batteryColor: {
        if (batteryLevel >= 60)
            return "#00BFFF";  // Cyan
        if (batteryLevel >= 30)
            return "#FFA500";  // Orange
        return "#FF3B30";  // Red
    }

    property alias leftArrowVisible: leftArrow.visible
    property alias rightArrowVisible: rightArrow.visible

    property string navArrowSource: "qrc:/icons/navigation/turn-left.svg"
    property real navArrowOpacity: 0.15

    // Responsive height
    height: Math.max(70, parent ? parent.height * 0.11 : 85)
    width: parent ? parent.width : 1280

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Time
        Item {
            Layout.preferredWidth: 80
            Layout.fillHeight: true

            Text {
                id: timeText
                anchors.centerIn: parent
                text: clusterTopBar.timeTextValue
                font.pixelSize: 16
                font.family: "SF Pro Display"
                font.weight: Font.Light
                color: "#E0E0E0"
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clusterTopBar.timeTextValue = Qt.formatDateTime(new Date(), "hh:mm")
            }
        }

        // Spacer
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        // Left navigation arrow
        Item {
            id: leftArrow
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            visible: true

            Image {
                anchors.centerIn: parent
                source: "qrc:/icons/cluster/left-arrow.svg"
                width: 32
                height: 32
                opacity: 0.6
            }
        }

        // Gear selector (center)
        Item {
            Layout.preferredWidth: 200
            Layout.fillHeight: true

            GearSelector {
                id: gearSelector
                anchors.centerIn: parent
            }
        }

        // Right navigation arrow
        Item {
            id: rightArrow
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            visible: true

            Image {
                anchors.centerIn: parent
                source: "qrc:/icons/cluster/right-arrow.svg"
                width: 32
                height: 32
                opacity: 0.6
            }
        }

        // Spacer
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        // Battery indicator (BMW-style)
        Item {
            Layout.preferredWidth: 60
            Layout.fillHeight: true

            Item {
                anchors.centerIn: parent
                width: 45
                height: 24

                // Battery outer border
                Rectangle {
                    anchors.fill: parent
                    anchors.rightMargin: 3
                    width: 40
                    height: 24
                    radius: 2
                    color: "transparent"
                    border.color: clusterTopBar.batteryColor
                    border.width: 1.5

                    // Battery fill
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 2
                        width: Math.max(2, parent.width - 4) * (clusterTopBar.batteryLevel / 100)
                        radius: 1
                        color: clusterTopBar.batteryColor

                        Behavior on width {
                            NumberAnimation {
                                duration: 400
                                easing.type: Easing.OutQuad
                            }
                        }

                        // Subtle gradient
                        gradient: Gradient {
                            GradientStop {
                                position: 0
                                color: Qt.lighter(clusterTopBar.batteryColor, 1.1)
                            }
                            GradientStop {
                                position: 1
                                color: clusterTopBar.batteryColor
                            }
                        }
                    }
                }

                // Battery terminal (nub on right side)
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 6
                    width: 3
                    height: 12
                    radius: 1
                    color: clusterTopBar.batteryColor
                    opacity: 0.8
                }

                // Battery percentage label (below icon)
                Text {
                    anchors.top: parent.bottom
                    anchors.topMargin: 3
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: clusterTopBar.batteryLevel + "%"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: clusterTopBar.batteryColor
                }
            }

            // Mouse area to make battery clickable
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: clusterTopBar.batteryClicked()
            }
        }
    }
}
