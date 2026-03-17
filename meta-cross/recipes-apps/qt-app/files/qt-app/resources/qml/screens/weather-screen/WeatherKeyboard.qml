/**
 * @file WeatherKeyboard.qml
 * @author DrivaPi Team
 * @brief On-screen QWERTY keyboard for the weather location search input
 */

import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
    id: root

    signal characterTyped(string ch)
    signal backspaceRequested()
    signal spaceRequested()
    signal searchRequested()

    color:         AppTheme.colors.surfaceVariant
    border.width:  1
    border.color:  AppTheme.colors.border
    opacity:       0.98
    radius:        0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        // Row 1: QWERTYUIOP
        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            Repeater {
                model: ["Q","W","E","R","T","Y","U","I","O","P"]
                Rectangle {
                    Layout.fillWidth: true
                    height: 24
                    radius: 6
                    color:         keyMouse1.pressed ? AppTheme.colors.primary : AppTheme.colors.surfaceElevated
                    border.color:  AppTheme.colors.border
                    border.width:  1
                    Text {
                        anchors.centerIn: parent
                        text:           modelData
                        font.pixelSize: 11
                        font.weight:    Font.Medium
                        color:          keyMouse1.pressed ? AppTheme.colors.surfaceElevated : AppTheme.colors.text
                    }
                    MouseArea {
                        id: keyMouse1
                        anchors.fill: parent
                        onClicked: root.characterTyped(modelData.toLowerCase())
                    }
                }
            }
        }

        // Row 2: ASDFGHJKL
        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            Repeater {
                model: ["A","S","D","F","G","H","J","K","L"]
                Rectangle {
                    Layout.fillWidth: true
                    height: 24
                    radius: 6
                    color:         keyMouse2.pressed ? AppTheme.colors.primary : AppTheme.colors.surfaceElevated
                    border.width:  1
                    border.color:  AppTheme.colors.border
                    Text {
                        anchors.centerIn: parent
                        text:           modelData
                        font.pixelSize: 11
                        font.weight:    Font.Medium
                        color:          keyMouse2.pressed ? AppTheme.colors.surfaceElevated : AppTheme.colors.text
                    }
                    MouseArea {
                        id: keyMouse2
                        anchors.fill: parent
                        onClicked: root.characterTyped(modelData.toLowerCase())
                    }
                }
            }
        }

        // Row 3: ZXCVBNM
        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            Repeater {
                model: ["Z","X","C","V","B","N","M"]
                Rectangle {
                    Layout.fillWidth: true
                    height: 24
                    radius: 6
                    color:         keyMouse3.pressed ? AppTheme.colors.primary : AppTheme.colors.surfaceElevated
                    border.width:  1
                    border.color:  AppTheme.colors.border
                    Text {
                        anchors.centerIn: parent
                        text:           modelData
                        font.pixelSize: 11
                        font.weight:    Font.Medium
                        color:          keyMouse3.pressed ? AppTheme.colors.surfaceElevated : AppTheme.colors.text
                    }
                    MouseArea {
                        id: keyMouse3
                        anchors.fill: parent
                        onClicked: root.characterTyped(modelData.toLowerCase())
                    }
                }
            }
        }

        // Row 4: Backspace, Space, Enter
        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            Rectangle {
                Layout.preferredWidth: 60
                height: 24
                radius: 6
                color:        backMouse.pressed ? AppTheme.colors.error : AppTheme.colors.surfaceElevated
                border.width: 1
                border.color: AppTheme.colors.border
                Text {
                    anchors.centerIn: parent
                    text: "⌫"
                    font.pixelSize: 14
                    color: backMouse.pressed ? AppTheme.colors.surfaceElevated : AppTheme.colors.text
                }
                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    onClicked: root.backspaceRequested()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 24
                radius: 6
                color:        spaceMouse.pressed ? AppTheme.colors.primary : AppTheme.colors.surfaceElevated
                border.width: 1
                border.color: AppTheme.colors.border
                Text {
                    anchors.centerIn: parent
                    text: "SPACE"
                    font.pixelSize: 10
                    color: spaceMouse.pressed ? AppTheme.colors.surfaceElevated : AppTheme.colors.text
                }
                MouseArea {
                    id: spaceMouse
                    anchors.fill: parent
                    onClicked: root.spaceRequested()
                }
            }

            Rectangle {
                Layout.preferredWidth: 60
                height: 24
                radius: 6
                color:        enterMouse.pressed ? AppTheme.colors.primary : AppTheme.colors.surfaceElevated
                border.width: 1
                border.color: AppTheme.colors.border
                Text {
                    anchors.centerIn: parent
                    text: "⏎"
                    font.pixelSize: 14
                    color: enterMouse.pressed ? AppTheme.colors.surfaceElevated : AppTheme.colors.text
                }
                MouseArea {
                    id: enterMouse
                    anchors.fill: parent
                    onClicked: root.searchRequested()
                }
            }
        }
    }
}
