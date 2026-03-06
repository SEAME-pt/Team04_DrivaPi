import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../theme"

Item {
    id: clusterTopBar

    // Signals
    signal batteryClicked

    // Public API
    property alias currentGear: gearSelector.currentGear

    property int batteryLevel: 85
    property string timeTextValue: Qt.formatDateTime(new Date(), "hh:mm")

    // Battery color logic - tied to AppTheme semantic colors
    property color batteryColor: {
        if (batteryLevel >= 60) return AppTheme.colors.primary;
        if (batteryLevel >= 30) return AppTheme.colors.warning;
        return AppTheme.colors.error;
    }

    property alias leftArrowVisible: leftArrow.visible
    property alias rightArrowVisible: rightArrow.visible

    // Responsive height
    height: Math.max(70, parent ? parent.height * 0.11 : 85)
    width: parent ? parent.width : 1280

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ====== TIME DISPLAY ======
        Item {
            Layout.preferredWidth: 100
            Layout.fillHeight: true

            Text {
                id: timeText
                anchors.centerIn: parent
                text: clusterTopBar.timeTextValue
                font.pixelSize: AppTheme.typography.headlineSmall
                font.family: AppTheme.typography.fontFamily
                font.weight: AppTheme.typography.weightMedium
                color: AppTheme.colors.text

                Behavior on color { ColorAnimation { duration: AppTheme.animation.normal } }
            }

            Timer {
                interval: 1000; running: true; repeat: true
                onTriggered: clusterTopBar.timeTextValue = Qt.formatDateTime(new Date(), "hh:mm")
            }
        }

        // Left Spacer
        Item { Layout.fillWidth: true; Layout.fillHeight: true }

        // ====== LEFT NAVIGATION ARROW ======
        Item {
            id: leftArrow
            Layout.preferredWidth: 150
            Layout.fillHeight: true

            Image {
                id: leftArrowImg
                anchors.centerIn: parent
                source: "qrc:/icons/cluster/left-arrow.svg"
                width: 32; height: 32
                opacity: AppTheme.isDark ? 0.4 : 0.7

                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: AppTheme.colors.text
                }
            }
        }

        // ====== CENTER GEAR SELECTOR ======
        Item {
            Layout.preferredWidth: 200
            Layout.fillHeight: true

            GearSelector {
                id: gearSelector
                anchors.centerIn: parent
            }
        }

        // ====== RIGHT NAVIGATION ARROW ======
        Item {
            id: rightArrow
            Layout.preferredWidth: 150
            Layout.fillHeight: true

            Image {
                id: rightArrowImg
                anchors.centerIn: parent
                source: "qrc:/icons/cluster/right-arrow.svg"
                width: 32; height: 32
                opacity: AppTheme.isDark ? 0.4 : 0.7

                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: AppTheme.colors.text
                }
            }
        }

        // Right Spacer
        Item { Layout.fillWidth: true; Layout.fillHeight: true }

        // ====== BATTERY INDICATOR (BMW-STYLE) ======
        Item {
            Layout.preferredWidth: 80
            Layout.fillHeight: true

            Column {
                anchors.centerIn: parent
                spacing: 2

                Item {
                    width: 45; height: 22

                    // Battery Shell
                    Rectangle {
                        anchors.fill: parent
                        anchors.rightMargin: 4
                        radius: 4
                        color: "transparent"
                        border.color: AppTheme.alpha(clusterTopBar.batteryColor, AppTheme.isDark ? 0.8 : 1.0)
                        border.width: AppTheme.isDark ? 1.5 : 2.0 // Thicker in light mode for contrast

                        // Liquid Fill
                        Rectangle {
                            anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                            anchors.margins: 2.5
                            width: Math.max(2, (parent.width - 5) * (clusterTopBar.batteryLevel / 100))
                            radius: 2

                            gradient: Gradient {
                                GradientStop { position: 0.0; color: AppTheme.shade(clusterTopBar.batteryColor, 0.1) }
                                GradientStop { position: 1.0; color: clusterTopBar.batteryColor }
                            }

                            Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutQuint } }
                        }
                    }

                    // Battery Terminal (The "Nub")
                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 3; height: 8; radius: 1
                        color: clusterTopBar.batteryColor
                    }
                }

                // Percentage Text
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: clusterTopBar.batteryLevel + "%"
                    font.pixelSize: AppTheme.typography.labelSmall
                    font.weight: AppTheme.typography.weightBold
                    font.family: AppTheme.typography.fontFamily
                    color: AppTheme.isDark ? clusterTopBar.batteryColor : AppTheme.colors.text
                }
            }

            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: clusterTopBar.batteryClicked()
            }
        }
    }
}
