/**
 * @file RightInfoPanel.qml
 * @author DrivaPi Team
 * @brief Swipeable right panel (Media / Weather / Navigation) for the cluster screen
 */

import QtQuick
import QtQuick.Controls
import "../../../components/weather"
import "../../../theme"

Item {
    id: root

    property real  s: 1.0
    property real  sy: 1.0
    property int   fontSizeSmall:  18
    property int   fontSizeXSmall: 13
    property color albumColor: "#1e90ff"
    property var   weatherData: null

    SwipeView {
        id: rightSwipe
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: pageIndicator.top
        anchors.bottomMargin: 4 * root.sy
        interactive: true
        clip: true

        // --- Page 1: Media ---
        Item {
            MediaMini {
                anchors.centerIn: parent
                s: root.s
                fontSizeSmall:  root.fontSizeSmall
                fontSizeXSmall: root.fontSizeXSmall
                albumColor: root.albumColor
            }
        }

        // --- Page 2: Weather ---
        Item {
            WeatherMini {
                anchors.centerIn: parent
                width: 280 * root.s
                height: 170 * root.s
                weatherData: root.weatherData
            }
        }

        // --- Page 3: Navigation ---
        Item {
            NavigationMini {
                anchors.centerIn: parent
                s: root.s
                fontSizeSmall:  root.fontSizeSmall
                fontSizeXSmall: root.fontSizeXSmall
            }
        }
    }

    PageIndicator {
        id: pageIndicator
        count: rightSwipe.count
        currentIndex: rightSwipe.currentIndex
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 4 * root.sy
    }
}
