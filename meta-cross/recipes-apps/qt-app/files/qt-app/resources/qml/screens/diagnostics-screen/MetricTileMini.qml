/**
 * @file MetricTileMini.qml
 * @author DrivaPi Team
 * @brief Small metric tile showing a labelled value with optional warning style
 */

import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
    id: root

    property string label: ""
    property string value: ""
    property bool   warn:  false

    radius:       8
    color:        root.warn ? AppTheme.alpha(AppTheme.colors.error, 0.1) : AppTheme.colors.surfaceVariant
    border.width: 1
    border.color: root.warn ? AppTheme.colors.error : AppTheme.colors.divider

    Layout.fillWidth:   true
    Layout.fillHeight:  true
    Layout.minimumHeight: 50

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 2

        Text {
            Layout.fillWidth: true
            text:               root.label
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize:     9
            font.weight:        Font.Medium
            color:              AppTheme.colors.textTertiary
        }

        Text {
            Layout.fillWidth: true
            text:               root.value
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize:     16
            font.weight:        Font.Bold
            color:              root.warn ? AppTheme.colors.error : AppTheme.colors.primary
            opacity:            (root.value === "--") ? 0.4 : 1.0
        }
    }
}
