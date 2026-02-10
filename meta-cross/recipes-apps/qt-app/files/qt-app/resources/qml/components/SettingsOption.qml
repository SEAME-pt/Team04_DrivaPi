import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property bool hasSlider: false
    property real sliderValue: 0.5
    signal sliderChanged(real value)

    Layout.fillWidth: true
    Layout.preferredHeight: hasSlider ? 100 : 80
    color: AppTheme.colors.surfaceVariant

    default property alias content: optionContent.data

    RowLayout {
        anchors.fill: parent
        anchors.margins: AppTheme.spacing.medium
        spacing: AppTheme.spacing.medium

        Image { source: icon; sourceSize.width: 24; sourceSize.height: 24; visible: icon.length > 0 }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: AppTheme.spacing.xSmall

            Text { text: title; color: AppTheme.colors.text; font.pixelSize: AppTheme.typography.labelLarge; font.weight: Font.Bold }
            Text { text: subtitle; color: AppTheme.colors.textSecondary; font.pixelSize: AppTheme.typography.labelSmall; visible: subtitle.length > 0 }

            Item { id: optionContent; Layout.fillWidth: true; Layout.preferredHeight: hasSlider ? 40 : implicitHeight }

            Rectangle {
                id: sliderTrack
                visible: hasSlider
                Layout.fillWidth: true
                Layout.preferredHeight: 8
                radius: 4
                color: AppTheme.colors.surface

                Rectangle {
                    width: parent.width * sliderValue
                    height: parent.height
                    radius: 4
                    color: AppTheme.colors.primary
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: updateValue(mouse.x)
                    onPositionChanged: if (pressed) updateValue(mouse.x)

                    function updateValue(xPos) {
                        var v = Math.max(0, Math.min(1, xPos / sliderTrack.width))
                        sliderChanged(v)
                    }
                }
            }
        }
    }
}