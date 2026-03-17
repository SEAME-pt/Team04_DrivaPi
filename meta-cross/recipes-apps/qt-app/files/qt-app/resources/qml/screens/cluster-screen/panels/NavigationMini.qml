/**
 * @file NavigationMini.qml
 * @author DrivaPi Team
 * @brief Compact navigation panel showing next-turn info for the cluster SwipeView
 */

import QtQuick
import "../../../theme"

Item {
    id: root

    property real s: 1.0
    property int  fontSizeSmall:  18
    property int  fontSizeXSmall: 13

    implicitWidth:  column.width
    implicitHeight: column.height

    Column {
        id: column
        width: 120 * root.s
        anchors.centerIn: parent
        spacing: 6 * root.s

        Image {
            source: "qrc:/icons/common/arrow-forward.svg"
            width:  42 * root.s
            height: 42 * root.s
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "Next Turn"
            color: AppTheme.colors.text
            font.pixelSize: root.fontSizeSmall * root.s
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: "— m  •  —"
            color: AppTheme.colors.textSecondary
            font.pixelSize: root.fontSizeXSmall * root.s
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
