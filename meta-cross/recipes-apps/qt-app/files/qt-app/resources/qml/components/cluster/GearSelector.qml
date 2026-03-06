import QtQuick
import "../../theme"

Item {
    id: root

    property string currentGear: "P"
    signal gearUp
    signal gearDown

    height: 44
    width: 160

    Row {
        anchors.centerIn: parent

        // Main PRND container pill
        Rectangle {
            id: gearPill
            color: AppTheme.colors.surfaceVariant
            radius: 18
            border.color: AppTheme.colors.divider
            border.width: 1
            height: 36
            width: 160
            anchors.verticalCenter: parent.verticalCenter

            // Move the behavior here! gearPill is a Rectangle, so 'color' exists.
            Behavior on color { ColorAnimation { duration: AppTheme.animation.normal } }

            // Subtle inner shadow for Light Mode depth
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "transparent"
                border.color: AppTheme.alpha(AppTheme.colors.text, 0.05)
                border.width: 1
                visible: !AppTheme.isDark
            }

            Row {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                leftPadding: 6

                Repeater {
                    model: ["P", "R", "N", "D"]
                    delegate: Item {
                        width: 28
                        height: 28
                        anchors.verticalCenter: parent.verticalCenter
                        z: root.currentGear === modelData ? 2 : 1

                        Rectangle {
                            id: gearHighlight
                            anchors.fill: parent
                            radius: 14
                            color: root.currentGear === modelData ? AppTheme.colors.primary : "transparent"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        Text {
                            text: modelData
                            anchors.centerIn: parent
                            font.pixelSize: AppTheme.typography.labelLarge
                            font.family: AppTheme.typography.fontFamily
                            font.weight: Font.Bold
                            color: root.currentGear === modelData ?
                                (AppTheme.isDark ? AppTheme.colors.surface : "#FFFFFF") :
                                AppTheme.colors.text

                            opacity: root.currentGear === modelData ? 1.0 : 0.4

                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }
                    }
                }
            }
        }
    }
}
