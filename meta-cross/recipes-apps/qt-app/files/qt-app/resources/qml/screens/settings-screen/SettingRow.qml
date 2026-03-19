/**
 * @file SettingRow.qml
 * @author DrivaPi Team
 * @brief A labelled row layout for settings entries
 */

import QtQuick
import QtQuick.Layouts
import "../../theme"

RowLayout {
    id: root

    property string label: ""

    Layout.fillWidth:    true
    Layout.preferredHeight: 28
    spacing: 8

    Text {
        text:                parent.label
        Layout.preferredWidth: 70
        color:               AppTheme.colors.textSecondary
        font.pixelSize:      11
        verticalAlignment:   Text.AlignVCenter
    }
}
