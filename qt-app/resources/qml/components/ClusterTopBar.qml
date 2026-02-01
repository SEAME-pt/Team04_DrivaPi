import QtQuick
import QtQuick.Layouts
import "../components"
import "../theme"

Item {
    id: clusterTopBar

    // Public API
    property alias currentGear: gearSelector.currentGear

    // Use normal properties (avoid alias+binding loops)
    property string temperatureText: ""
    property string timeTextValue: Qt.formatDateTime(new Date(), "hh:mm")

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

        // Temperature
        Item {
            Layout.preferredWidth: 80
            Layout.fillHeight: true

            Text {
                id: tempText
                anchors.centerIn: parent
                text: clusterTopBar.temperatureText
                font.pixelSize: 16
                font.family: "SF Pro Display"
                font.weight: Font.Light
                color: "#E0E0E0"
            }
        }
    }
}
