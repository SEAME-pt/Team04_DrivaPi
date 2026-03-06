import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../theme"

Rectangle {
    id: root
    color: "transparent"

    // Compact models
    readonly property var themeModel: ["Dark", "Light", "Auto"]
    readonly property var speedModel: ["km/h", "m/s", "mph"]
    readonly property var tempModel: ["°C", "°F", "K"]
    readonly property var distanceModel: ["km", "mi", "m"]
    readonly property var windModel: ["m/s", "km/h", "mph"]
    readonly property var precipModel: ["mm", "in"]

    function idx(model, value) {
        var i = model.indexOf(value);
        return i < 0 ? 0 : i;
    }

    // Panel background
    Rectangle {
        anchors.fill: parent
        color: AppTheme.colors.surfaceVariant
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        Text {
            text: "Settings"
            color: AppTheme.colors.primary
            font.pixelSize: 14
            font.weight: Font.Bold
        }

        // ---- Theme Row ----
        SettingRow {
            label: "Theme"
            CustomComboBox {
                id: themeBox
                model: themeModel
                currentIndex: idx(themeModel, settingsManager.theme)
                onActivated: function(index) { settingsManager.theme = textAt(index) }
            }
        }

        // ---- Brightness Row ----
        SettingRow {
            label: "Bright"
            Slider {
                id: brightSlider
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                from: 0
                to: 1
                Component.onCompleted: brightSlider.value = settingsManager.screenBrightness
                onMoved: settingsManager.screenBrightness = value

                background: Rectangle {
                    x: 0
                    y: (parent.height - 4) / 2
                    width: parent.width
                    height: 4
                    radius: 2
                    color: AppTheme.colors.surfaceElevated
                    border.color: AppTheme.colors.border
                    border.width: 1

                    Rectangle {
                        width: parent.width * brightSlider.visualPosition
                        height: parent.height
                        radius: 2
                        color: AppTheme.colors.primary
                    }
                }

                handle: Rectangle {
                    x: brightSlider.leftPadding + brightSlider.visualPosition * (brightSlider.availableWidth - width)
                    y: brightSlider.topPadding + (brightSlider.availableHeight - height) / 2
                    width: 14
                    height: 14
                    radius: 7
                    color: brightSlider.pressed ? "#FFFFFF" : AppTheme.colors.primary
                    border.color: AppTheme.colors.surface
                    border.width: 2
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: AppTheme.colors.divider
        }

        // ---- Units Section ----
        SettingRow {
            label: "Speed"
            CustomComboBox {
                model: speedModel
                currentIndex: idx(speedModel, settingsManager.speedUnit)
                onActivated: function(index) { settingsManager.speedUnit = textAt(index) }
            }
        }

        SettingRow {
            label: "Temp"
            CustomComboBox {
                model: tempModel
                currentIndex: idx(tempModel, settingsManager.temperatureUnit)
                onActivated: function(index) { settingsManager.temperatureUnit = textAt(index) }
            }
        }

        SettingRow {
            label: "Distance"
            CustomComboBox {
                model: distanceModel
                currentIndex: idx(distanceModel, settingsManager.distanceUnit)
                onActivated: function(index) { settingsManager.distanceUnit = textAt(index) }
            }
        }

        SettingRow {
            label: "Wind"
            CustomComboBox {
                model: windModel
                currentIndex: idx(windModel, settingsManager.windSpeedUnit)
                onActivated: function(index) { settingsManager.windSpeedUnit = textAt(index) }
            }
        }

        SettingRow {
            label: "Precip"
            CustomComboBox {
                model: precipModel
                currentIndex: idx(precipModel, settingsManager.precipitationUnit)
                onActivated: function(index) { settingsManager.precipitationUnit = textAt(index) }
            }
        }

        Item { Layout.fillHeight: true }
    }

}
