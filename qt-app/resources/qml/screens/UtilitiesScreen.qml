import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    color: AppTheme.colors.surface

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AppTheme.spacing.large
        spacing: AppTheme.spacing.medium

        Text {
            text: "Utility Actions"
            font.pixelSize: AppTheme.typography.headlineSmall
            font.weight: Font.Bold
            color: AppTheme.colors.text
        }

        GridLayout {
            columns: 4
            rowSpacing: AppTheme.spacing.medium
            columnSpacing: AppTheme.spacing.medium
            Layout.fillWidth: true

            // Row 1
            UtilityTile { iconPath: "qrc:/icons/common/home.svg"; labelText: "Home" }
            UtilityTile { iconPath: "qrc:/icons/common/menu.svg"; labelText: "Menu" }
            UtilityTile { iconPath: "qrc:/icons/common/search.svg"; labelText: "Search" }
            UtilityTile { iconPath: "qrc:/icons/common/plus.svg"; labelText: "Add" }

            // Row 2
            UtilityTile { iconPath: "qrc:/icons/common/minus.svg"; labelText: "Remove" }
            UtilityTile { iconPath: "qrc:/icons/common/save.svg"; labelText: "Save" }
            UtilityTile { iconPath: "qrc:/icons/common/edit.svg"; labelText: "Edit" }
            UtilityTile { iconPath: "qrc:/icons/common/trash.svg"; labelText: "Delete" }

            // Row 3
            UtilityTile { iconPath: "qrc:/icons/common/back.svg"; labelText: "Back" }
            UtilityTile { iconPath: "qrc:/icons/common/arrow-forward.svg"; labelText: "Forward" }
            UtilityTile { iconPath: "qrc:/icons/common/chevron-up.svg"; labelText: "Up" }
            UtilityTile { iconPath: "qrc:/icons/common/chevron-down.svg"; labelText: "Down" }

            // Row 4
            UtilityTile { iconPath: "qrc:/icons/common/media-mode.svg"; labelText: "Media Mode" }
            UtilityTile { iconPath: "qrc:/icons/common/media-mode-active.svg"; labelText: "Media Active" }
            UtilityTile { iconPath: "qrc:/icons/common/nav-mode.svg"; labelText: "Nav Mode" }
            UtilityTile { iconPath: "qrc:/icons/common/nav-mode-active.svg"; labelText: "Nav Active" }

            // Row 5
            UtilityTile { iconPath: "qrc:/icons/common/steering-mode.svg"; labelText: "Steering" }
            UtilityTile { iconPath: "qrc:/icons/common/steering-mode-active.svg"; labelText: "Steering Active" }
            UtilityTile { iconPath: "qrc:/icons/common/close.svg"; labelText: "Close" }
        }
    }

    component UtilityTile: ColumnLayout {
        property string iconPath
        property string labelText
        
        spacing: AppTheme.spacing.xsmall
        Layout.alignment: Qt.AlignHCenter

        Rectangle {
            width: 64
            height: 64
            radius: AppTheme.radius.small
            color: AppTheme.colors.surfaceVariant

            Image {
                anchors.centerIn: parent
                source: iconPath
                sourceSize.width: 28
                sourceSize.height: 28
            }
        }

        Text {
            text: labelText
            font.pixelSize: AppTheme.typography.labelSmall
            color: AppTheme.colors.textSecondary
            Layout.alignment: Qt.AlignHCenter
        }
    }
}

