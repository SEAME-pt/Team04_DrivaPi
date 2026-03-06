/**
 * @file StatusCardCompact.qml
 * @author DrivaPi Team
 * @brief Compact status card with icon header, online indicator, and warn badge
 */

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../theme"

Rectangle {
    id: root

    required property string title
    required property string icon
    required property bool   online
    required property bool   warn
    default property alias   content: contentArea.data

    radius:       10
    color:        AppTheme.colors.surfaceElevated
    border.width: 1
    border.color: AppTheme.colors.border
    opacity:      online ? 1.0 : 0.6

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            radius: 10
            color:        AppTheme.colors.surfaceVariant
            border.width: 1
            border.color: AppTheme.colors.divider

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin:  12
                anchors.rightMargin: 12
                spacing: 8

                Image {
                    source: root.icon
                    sourceSize: Qt.size(16, 16)
                    layer.enabled: true
                    layer.effect: ColorOverlay { color: AppTheme.colors.textSecondary }
                }

                Text {
                    text:            root.title
                    font.pixelSize:  11
                    font.weight:     Font.Bold
                    font.letterSpacing: 0.8
                    color:           AppTheme.colors.text
                }

                Item { Layout.fillWidth: true }

                // Online/offline dot
                Rectangle {
                    width: 8; height: 8; radius: 4
                    color: root.online ? AppTheme.colors.success : AppTheme.colors.textTertiary
                }

                // Warn badge
                Rectangle {
                    visible:      root.warn
                    radius:       4
                    height:       18
                    implicitWidth: warnText.implicitWidth + 12
                    color:        AppTheme.alpha(AppTheme.colors.warning, 0.2)
                    border.width: 1
                    border.color: AppTheme.colors.warning

                    Text {
                        id: warnText
                        anchors.centerIn: parent
                        text:           "WARN"
                        font.pixelSize: 9
                        font.weight:    Font.Bold
                        color:          AppTheme.colors.warning
                    }
                }
            }
        }

        // Content area (accepts children via default alias)
        Item {
            id: contentArea
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
