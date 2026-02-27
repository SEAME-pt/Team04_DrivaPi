import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../theme"

Rectangle {
    id: root
    color: "transparent" // let the right panel background show through (cluster-like)

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

    // Panel background (dark glass card like Cluster bottom bar)
    Rectangle {
        anchors.fill: parent
        color: "#05080e"
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

        // ---- helper: compact row ----
        // (repeated explicitly to keep QML simple/robust)

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            spacing: 8

            Text {
                text: "Theme"
                Layout.preferredWidth: 70
                color: "#93a6bf"
                font.pixelSize: 11
                verticalAlignment: Text.AlignVCenter
            }

            ComboBox {
                id: themeBox
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                model: themeModel
                currentIndex: idx(themeModel, settingsManager.theme)
                onActivated: settingsManager.theme = textAt(index)

                font.pixelSize: 11
                contentItem: Text {
                    text: themeBox.displayText
                    color: "#e6f0ff"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    leftPadding: 8
                }
                background: Rectangle {
                    radius: 7
                    color: "#0b1420"
                    border.color: "#232a35"
                    border.width: 1
                }
                indicator: Rectangle {
                    width: 10
                    height: 10
                    radius: 2
                    color: "#4fb3d9"
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 0.95
                }
                delegate: ItemDelegate {
                    width: themeBox.width
                    height: 26
                    contentItem: Text {
                        text: modelData
                        color: "#e6f0ff"
                        font.pixelSize: 11
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }
                    background: Rectangle {
                        color: (index === themeBox.currentIndex) ? "#101e2c" : "transparent"
                    }
                }
                popup: Popup {
                    y: themeBox.height + 4
                    width: themeBox.width
                    padding: 4
                    background: Rectangle {
                        radius: 8
                        color: "#0b1420"
                        border.color: "#232a35"
                        border.width: 1
                    }
                    contentItem: ListView {
                        clip: true
                        implicitHeight: Math.min(contentHeight, 6 * 26)
                        model: themeBox.delegateModel
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            spacing: 8

            Text {
                text: "Bright"
                Layout.preferredWidth: 70
                color: "#93a6bf"
                font.pixelSize: 11
                verticalAlignment: Text.AlignVCenter
            }

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
                    color: "#0b1420"
                    border.color: "#232a35"
                    border.width: 1

                    Rectangle {
                        width: parent.width * brightSlider.visualPosition
                        height: parent.height
                        radius: 2
                        color: "#4fb3d9"
                        opacity: 0.95
                    }
                }

                handle: Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: "#4fb3d9"
                    border.color: "#05080e"
                    border.width: 1
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#232a35"
            opacity: 0.8
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            spacing: 8

            Text {
                text: "Speed"
                Layout.preferredWidth: 70
                color: "#93a6bf"
                font.pixelSize: 11
            }
            ComboBox {
                id: speedBox
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                model: speedModel
                currentIndex: idx(speedModel, settingsManager.speedUnit)
                onActivated: settingsManager.speedUnit = textAt(index)
                
                font.pixelSize: 11
                contentItem: Text {
                    text: speedBox.displayText
                    color: "#e6f0ff"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    leftPadding: 8
                }
                background: Rectangle {
                    radius: 7
                    color: "#0b1420"
                    border.color: "#232a35"
                    border.width: 1
                }
                indicator: Rectangle {
                    width: 10
                    height: 10
                    radius: 2
                    color: "#4fb3d9"
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                }

                delegate: ItemDelegate {
                    width: speedBox.width
                    height: 26
                    contentItem: Text {
                        text: modelData
                        color: "#e6f0ff"
                        font.pixelSize: 11
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }
                    background: Rectangle {
                        color: (index === speedBox.currentIndex) ? "#101e2c" : "transparent"
                    }
                }
                popup: Popup {
                    y: speedBox.height + 4
                    width: speedBox.width
                    padding: 4
                    background: Rectangle {
                        radius: 8
                        color: "#0b1420"
                        border.color: "#232a35"
                        border.width: 1
                    }
                    contentItem: ListView {
                        clip: true
                        implicitHeight: Math.min(contentHeight, 6 * 26)
                        model: speedBox.delegateModel
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            spacing: 8

            Text {
                text: "Temp"
                Layout.preferredWidth: 70
                color: "#93a6bf"
                font.pixelSize: 11
            }
            ComboBox {
                id: tempBox
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                model: tempModel
                currentIndex: idx(tempModel, settingsManager.temperatureUnit)
                onActivated: settingsManager.temperatureUnit = textAt(index)

                font.pixelSize: 11
                contentItem: Text {
                    text: tempBox.displayText
                    color: "#e6f0ff"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    leftPadding: 8
                }
                background: Rectangle {
                    radius: 7
                    color: "#0b1420"
                    border.color: "#232a35"
                    border.width: 1
                }
                indicator: Rectangle {
                    width: 10
                    height: 10
                    radius: 2
                    color: "#4fb3d9"
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                }

                delegate: ItemDelegate {
                    width: tempBox.width
                    height: 26
                    contentItem: Text {
                        text: modelData
                        color: "#e6f0ff"
                        font.pixelSize: 11
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }
                    background: Rectangle {
                        color: (index === tempBox.currentIndex) ? "#101e2c" : "transparent"
                    }
                }
                popup: Popup {
                    y: tempBox.height + 4
                    width: tempBox.width
                    padding: 4
                    background: Rectangle {
                        radius: 8
                        color: "#0b1420"
                        border.color: "#232a35"
                        border.width: 1
                    }
                    contentItem: ListView {
                        clip: true
                        implicitHeight: Math.min(contentHeight, 6 * 26)
                        model: tempBox.delegateModel
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            spacing: 8

            Text {
                text: "Distance"
                Layout.preferredWidth: 70
                color: "#93a6bf"
                font.pixelSize: 11
            }
            ComboBox {
                id: distBox
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                model: distanceModel
                currentIndex: idx(distanceModel, settingsManager.distanceUnit)
                onActivated: settingsManager.distanceUnit = textAt(index)

                font.pixelSize: 11
                contentItem: Text {
                    text: distBox.displayText
                    color: "#e6f0ff"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    leftPadding: 8
                }
                background: Rectangle {
                    radius: 7
                    color: "#0b1420"
                    border.color: "#232a35"
                    border.width: 1
                }
                indicator: Rectangle {
                    width: 10
                    height: 10
                    radius: 2
                    color: "#4fb3d9"
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                }

                delegate: ItemDelegate {
                    width: distBox.width
                    height: 26
                    contentItem: Text {
                        text: modelData
                        color: "#e6f0ff"
                        font.pixelSize: 11
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }
                    background: Rectangle {
                        color: (index === distBox.currentIndex) ? "#101e2c" : "transparent"
                    }
                }
                popup: Popup {
                    y: distBox.height + 4
                    width: distBox.width
                    padding: 4
                    background: Rectangle {
                        radius: 8
                        color: "#0b1420"
                        border.color: "#232a35"
                        border.width: 1
                    }
                    contentItem: ListView {
                        clip: true
                        implicitHeight: Math.min(contentHeight, 6 * 26)
                        model: distBox.delegateModel
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            spacing: 8

            Text {
                text: "Wind"
                Layout.preferredWidth: 70
                color: "#93a6bf"
                font.pixelSize: 11
            }
            ComboBox {
                id: windBox
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                model: windModel
                currentIndex: idx(windModel, settingsManager.windSpeedUnit)
                onActivated: settingsManager.windSpeedUnit = textAt(index)

                font.pixelSize: 11
                contentItem: Text {
                    text: windBox.displayText
                    color: "#e6f0ff"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    leftPadding: 8
                }
                background: Rectangle {
                    radius: 7
                    color: "#0b1420"
                    border.color: "#232a35"
                    border.width: 1
                }
                indicator: Rectangle {
                    width: 10
                    height: 10
                    radius: 2
                    color: "#4fb3d9"
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                }

                delegate: ItemDelegate {
                    width: windBox.width
                    height: 26
                    contentItem: Text {
                        text: modelData
                        color: "#e6f0ff"
                        font.pixelSize: 11
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }
                    background: Rectangle {
                        color: (index === windBox.currentIndex) ? "#101e2c" : "transparent"
                    }
                }
                popup: Popup {
                    y: windBox.height + 4
                    width: windBox.width
                    padding: 4
                    background: Rectangle {
                        radius: 8
                        color: "#0b1420"
                        border.color: "#232a35"
                        border.width: 1
                    }
                    contentItem: ListView {
                        clip: true
                        implicitHeight: Math.min(contentHeight, 6 * 26)
                        model: windBox.delegateModel
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            spacing: 8

            Text {
                text: "Precip"
                Layout.preferredWidth: 70
                color: "#93a6bf"
                font.pixelSize: 11
            }
            ComboBox {
                id: precipBox
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                model: precipModel
                currentIndex: idx(precipModel, settingsManager.precipitationUnit)
                onActivated: settingsManager.precipitationUnit = textAt(index)

                font.pixelSize: 11
                contentItem: Text {
                    text: precipBox.displayText
                    color: "#e6f0ff"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    leftPadding: 8
                }
                background: Rectangle {
                    radius: 7
                    color: "#0b1420"
                    border.color: "#232a35"
                    border.width: 1
                }
                indicator: Rectangle {
                    width: 10
                    height: 10
                    radius: 2
                    color: "#4fb3d9"
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                }

                delegate: ItemDelegate {
                    width: precipBox.width
                    height: 26
                    contentItem: Text {
                        text: modelData
                        color: "#e6f0ff"
                        font.pixelSize: 11
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }
                    background: Rectangle {
                        color: (index === precipBox.currentIndex) ? "#101e2c" : "transparent"
                    }
                }
                popup: Popup {
                    y: precipBox.height + 4
                    width: precipBox.width
                    padding: 4
                    background: Rectangle {
                        radius: 8
                        color: "#0b1420"
                        border.color: "#232a35"
                        border.width: 1
                    }
                    contentItem: ListView {
                        clip: true
                        implicitHeight: Math.min(contentHeight, 6 * 26)
                        model: precipBox.delegateModel
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        } // pushes content up, guarantees no scroll
    }
}
