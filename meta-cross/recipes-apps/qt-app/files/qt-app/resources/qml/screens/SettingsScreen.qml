import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../theme"

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
                onActivated: settingsManager.theme = textAt(index)
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
                value: settingsManager.screenBrightness
                onValueChanged: settingsManager.screenBrightness = value

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
                onActivated: settingsManager.speedUnit = textAt(index)
            }
        }

        SettingRow {
            label: "Temp"
            CustomComboBox {
                model: tempModel
                currentIndex: idx(tempModel, settingsManager.temperatureUnit)
                onActivated: settingsManager.temperatureUnit = textAt(index)
            }
        }

        SettingRow {
            label: "Distance"
            CustomComboBox {
                model: distanceModel
                currentIndex: idx(distanceModel, settingsManager.distanceUnit)
                onActivated: settingsManager.distanceUnit = textAt(index)
            }
        }

        SettingRow {
            label: "Wind"
            CustomComboBox {
                model: windModel
                currentIndex: idx(windModel, settingsManager.windSpeedUnit)
                onActivated: settingsManager.windSpeedUnit = textAt(index)
            }
        }

        SettingRow {
            label: "Precip"
            CustomComboBox {
                model: precipModel
                currentIndex: idx(precipModel, settingsManager.precipitationUnit)
                onActivated: settingsManager.precipitationUnit = textAt(index)
            }
        }

        Item { Layout.fillHeight: true }
    }

    // --- Component: Standard Setting Row ---
    component SettingRow: RowLayout {
        property string label: ""
        Layout.fillWidth: true
        Layout.preferredHeight: 28
        spacing: 8

        Text {
            text: parent.label
            Layout.preferredWidth: 70
            color: AppTheme.colors.textSecondary
            font.pixelSize: 11
            verticalAlignment: Text.AlignVCenter
        }
    }

    // --- Component: Themed ComboBox ---
    component CustomComboBox: ComboBox {
        id: combo
        Layout.fillWidth: true
        Layout.preferredHeight: 28
        font.pixelSize: 11

        contentItem: Text {
            text: combo.displayText
            color: AppTheme.colors.text
            verticalAlignment: Text.AlignVCenter
            leftPadding: 10
            font: combo.font
        }

        background: Rectangle {
            radius: 8
            color: AppTheme.colors.surfaceElevated
            border.color: combo.activeFocus ? AppTheme.colors.primary : AppTheme.colors.border
            border.width: 1
        }

        indicator: Canvas {
            id: canvas
            x: combo.width - width - 10
            y: (combo.height - height) / 2
            width: 8
            height: 6
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.moveTo(0, 0);
                ctx.lineTo(width, 0);
                ctx.lineTo(width / 2, height);
                ctx.closePath();
                ctx.fillStyle = AppTheme.colors.primary;
                ctx.fill();
            }
        }

        delegate: ItemDelegate {
            width: combo.width
            height: 28
            contentItem: Text {
                text: modelData
                color: highlighted ? "#FFFFFF" : AppTheme.colors.text
                font.pixelSize: 11
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
            }
            background: Rectangle {
                color: highlighted ? AppTheme.colors.primary : "transparent"
            }
        }

        popup: Popup {
            y: combo.height + 4
            width: combo.width
            padding: 4
            background: Rectangle {
                radius: 8
                color: AppTheme.colors.surfaceElevated
                border.color: AppTheme.colors.border
                border.width: 1
                // Add a small shadow in light mode for depth
                layer.enabled: !AppTheme.isDark
                layer.effect: Qt.createQmlObject('import Qt5Compat.GraphicalEffects; DropShadow { radius: 8; color: "#20000000"; samples: 17 }', combo)
            }
            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: combo.delegateModel
            }
        }
    }
}
