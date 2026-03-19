import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../theme"

Rectangle {
    id: sliderCardRoot
    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property bool hasSlider: false
    property real sliderValue: 0.5
    signal sliderChanged(real value)

    Layout.fillWidth: true
    // Dynamic height based on slider presence
    Layout.preferredHeight: hasSlider ? 110 : 80

    color: AppTheme.colors.surfaceVariant
    radius: AppTheme.radius.medium
    border.color: AppTheme.colors.divider
    border.width: AppTheme.isDark ? 0 : 1

    // To allow extra components to be injected
    default property alias content: optionContent.data

    RowLayout {
        anchors.fill: parent
        anchors.margins: AppTheme.spacing.medium
        spacing: AppTheme.spacing.medium

        // Icon with theme-aware color
        Item {
            width: 24
            height: 24
            visible: icon.length > 0
            Image {
                source: icon
                anchors.fill: parent
                sourceSize.width: 24
                sourceSize.height: 24
                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: AppTheme.colors.textSecondary
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: AppTheme.spacing.small

            // Title & Subtitle
            ColumnLayout {
                spacing: 2
                Text {
                    text: title
                    color: AppTheme.colors.text
                    font.pixelSize: AppTheme.typography.bodyLarge
                    font.weight: AppTheme.typography.weightBold
                    font.family: AppTheme.typography.fontFamily
                }
                Text {
                    text: subtitle
                    color: AppTheme.colors.textSecondary
                    font.pixelSize: AppTheme.typography.labelSmall
                    font.family: AppTheme.typography.fontFamily
                    visible: subtitle.length > 0
                    opacity: 0.8
                }
            }

            Item { id: optionContent; Layout.fillWidth: true; Layout.preferredHeight: childrenRect.height }

            // ====== THEMED SLIDER ======
            Item {
                visible: hasSlider
                Layout.fillWidth: true
                Layout.preferredHeight: 32 // Increased touch target area
                Layout.topMargin: 4

                // Track Background
                Rectangle {
                    id: sliderTrack
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 6
                    radius: 3
                    // In light mode, we want a slightly darker track than the card
                    color: AppTheme.isDark ? AppTheme.colors.surface : AppTheme.tint(AppTheme.colors.surfaceVariant, 0.1)

                    // Filled Part
                    Rectangle {
                        width: parent.width * sliderValue
                        height: parent.height
                        radius: 3
                        color: AppTheme.colors.primary
                    }

                    // Interactive Handle (Knob)
                    Rectangle {
                        x: (parent.width * sliderValue) - (width / 2)
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20
                        height: 20
                        radius: 10
                        color: AppTheme.isDark ? "#FFFFFF" : AppTheme.colors.surfaceElevated
                        border.color: AppTheme.colors.primary
                        border.width: 1

                        // Shadow for Light Mode depth
                        layer.enabled: !AppTheme.isDark
                        layer.effect: DropShadow {
                            radius: 4
                            color: "#40000000"
                            samples: 8
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SizeHorCursor
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

    Behavior on color { ColorAnimation { duration: AppTheme.animation.normal } }
}
