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

            function tile(iconPath, labelText) {
                return ColumnLayout {
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

            // Row 1
            tile("qrc:/icons/common/home.svg", "Home")
            tile("qrc:/icons/common/menu.svg", "Menu")
            tile("qrc:/icons/common/search.svg", "Search")
            tile("qrc:/icons/common/plus.svg", "Add")

            // Row 2
            tile("qrc:/icons/common/minus.svg", "Remove")
            tile("qrc:/icons/common/save.svg", "Save")
            tile("qrc:/icons/common/edit.svg", "Edit")
            tile("qrc:/icons/common/trash.svg", "Delete")

            // Row 3
            tile("qrc:/icons/common/back.svg", "Back")
            tile("qrc:/icons/common/arrow-forward.svg", "Forward")
            tile("qrc:/icons/common/chevron-up.svg", "Up")
            tile("qrc:/icons/common/chevron-down.svg", "Down")

            // Row 4
            tile("qrc:/icons/common/media-mode.svg", "Media Mode")
            tile("qrc:/icons/common/media-mode-active.svg", "Media Active")
            tile("qrc:/icons/common/nav-mode.svg", "Nav Mode")
            tile("qrc:/icons/common/nav-mode-active.svg", "Nav Active")

            // Row 5
            tile("qrc:/icons/common/steering-mode.svg", "Steering")
            tile("qrc:/icons/common/steering-mode-active.svg", "Steering Active")
            tile("qrc:/icons/common/close.svg", "Close")
        }
    }
}
