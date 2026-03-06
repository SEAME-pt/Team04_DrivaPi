/**
 * @file RightInfoPanel.qml
 * @author DrivaPi Team
 * @brief Swipeable right panel (Media / Weather / Navigation) for the cluster screen
 */

import QtQuick
import QtQuick.Controls
import "../../../components"
import "../../../theme"

Item {
    id: root

    property real  s: 1.0
    property real  sy: 1.0
    property int   fontSizeSmall:  18
    property int   fontSizeXSmall: 13
    property color albumColor: "#1e90ff"
    property var   weatherData: null

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -10 * root.sy
        spacing: 6 * root.s

        SwipeView {
            id: rightSwipe
            width: 280 * root.s
            height: 170 * root.s
            interactive: true
            clip: true

            // --- Page 1: Media ---
            Item {
                width: rightSwipe.width
                height: rightSwipe.height

                MediaMini {
                    anchors.fill: parent
                    s: root.s
                    fontSizeSmall:  root.fontSizeSmall
                    fontSizeXSmall: root.fontSizeXSmall
                    albumColor: root.albumColor
                }
            }

            // --- Page 2: Weather ---
            Item {
                width: rightSwipe.width
                height: rightSwipe.height

                WeatherMini {
                    anchors.centerIn: parent
                    width: rightSwipe.width
                    height: rightSwipe.height
                    weatherData: root.weatherData
                }
            }

            // --- Page 3: Navigation ---
            Item {
                width: rightSwipe.width
                height: rightSwipe.height

                NavigationMini {
                    anchors.fill: parent
                    s: root.s
                    fontSizeSmall:  root.fontSizeSmall
                    fontSizeXSmall: root.fontSizeXSmall
                }
            }
        }

        PageIndicator {
            count: rightSwipe.count
            currentIndex: rightSwipe.currentIndex
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
