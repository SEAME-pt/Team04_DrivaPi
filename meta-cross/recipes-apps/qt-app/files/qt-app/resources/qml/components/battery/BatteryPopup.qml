import QtQuick
import QtQuick.Layouts
import "../../theme"

// Battery Status Popup - Shows both STM32 and RPi battery levels
Item {
    id: popup

    // Properties
    property int stm32BatteryLevel: 100
    property int rpiBatteryLevel: 100

    visible: false
    anchors.fill: parent
    z: 1000

    // Close on click outside
    MouseArea {
        anchors.fill: parent
        onClicked: popup.close()
    }

    // Popup content card - positioned at top right, near battery indicator
    Rectangle {
        id: popupCard
        width: 280
        height: 200
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 80
            rightMargin: 20
        }

        // Dynamic gradient adapting to light/dark mode
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: AppTheme.colors.surfaceElevated
            }
            GradientStop {
                position: 0.5
                color: AppTheme.colors.surface
            }
            GradientStop {
                position: 1.0
                color: AppTheme.colors.surfaceVariant
            }
        }

        // Subtle border for definition using theme
        border.color: AppTheme.colors.border
        border.width: 1
        radius: AppTheme.radius.medium

        // Subtle glow effect using shadow rectangle
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: parent.radius
            color: "transparent"
            border.color: AppTheme.colors.primary
            border.width: 1
            opacity: AppTheme.isDark ? 0.1 : 0.05 // Less glow in light mode
            z: -1
        }

        ColumnLayout {
            anchors {
                fill: parent
                margins: AppTheme.spacing.medium
            }
            spacing: 10

            // Title with cluster styling
            Text {
                text: "BATTERY STATUS"
                color: AppTheme.colors.primary
                font {
                    pixelSize: AppTheme.typography.labelMedium
                    weight: Font.Bold
                    letterSpacing: 1.5
                }
                Layout.alignment: Qt.AlignHCenter
            }

            // STM32 Battery
            Rectangle {
                height: 40
                color: "transparent"
                Layout.fillWidth: true

                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    Text {
                        text: "STM32"
                        color: AppTheme.colors.textSecondary
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.letterSpacing: 0.5
                        Layout.preferredWidth: 80
                    }

                    Rectangle {
                        height: 16
                        radius: AppTheme.radius.small / 2
                        color: AppTheme.colors.surfaceVariant
                        border.color: stm32BatteryLevel >= 60 ? AppTheme.colors.primary : (stm32BatteryLevel >= 30 ? AppTheme.colors.warning : AppTheme.colors.error)
                        border.width: 1
                        Layout.fillWidth: true
                        clip: true

                        Rectangle {
                            width: parent.width * (stm32BatteryLevel / 100)
                            height: parent.height
                            color: stm32BatteryLevel >= 60 ? AppTheme.colors.primary : (stm32BatteryLevel >= 30 ? AppTheme.colors.warning : AppTheme.colors.error)
                            opacity: AppTheme.isDark ? 0.3 : 0.5 // Boost fill opacity slightly in light mode for visibility

                            Behavior on width {
                                NumberAnimation {
                                    duration: AppTheme.animation.normal
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: stm32BatteryLevel + "%"
                            color: AppTheme.colors.text
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            // RPi Battery
            Rectangle {
                height: 40
                color: "transparent"
                Layout.fillWidth: true

                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    Text {
                        text: "RASPBERRY PI"
                        color: AppTheme.colors.textSecondary
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.letterSpacing: 0.5
                        Layout.preferredWidth: 80
                    }

                    Rectangle {
                        height: 16
                        radius: AppTheme.radius.small / 2
                        color: AppTheme.colors.surfaceVariant
                        border.color: rpiBatteryLevel >= 60 ? AppTheme.colors.primary : (rpiBatteryLevel >= 30 ? AppTheme.colors.warning : AppTheme.colors.error)
                        border.width: 1
                        Layout.fillWidth: true
                        clip: true

                        Rectangle {
                            width: parent.width * (rpiBatteryLevel / 100)
                            height: parent.height
                            color: rpiBatteryLevel >= 60 ? AppTheme.colors.primary : (rpiBatteryLevel >= 30 ? AppTheme.colors.warning : AppTheme.colors.error)
                            opacity: AppTheme.isDark ? 0.3 : 0.5

                            Behavior on width {
                                NumberAnimation {
                                    duration: AppTheme.animation.normal
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: rpiBatteryLevel + "%"
                            color: AppTheme.colors.text
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            // Divider line
            Rectangle {
                height: 1
                color: AppTheme.colors.divider
                Layout.fillWidth: true
                opacity: AppTheme.isDark ? 0.5 : 1.0 // Stronger divider line in light mode
            }

            // System Battery (Minimum)
            Rectangle {
                height: 40
                color: "transparent"
                Layout.fillWidth: true

                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    Text {
                        text: "SYSTEM"
                        color: AppTheme.colors.primary
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                        font.letterSpacing: 0.5
                        Layout.preferredWidth: 80
                    }

                    Rectangle {
                        height: 16
                        radius: AppTheme.radius.small / 2
                        color: AppTheme.colors.surfaceVariant
                        border.color: AppTheme.colors.primary
                        border.width: 1
                        Layout.fillWidth: true
                        clip: true

                        Rectangle {
                            width: parent.width * (Math.min(stm32BatteryLevel, rpiBatteryLevel) / 100)
                            height: parent.height
                            color: AppTheme.colors.primary
                            opacity: AppTheme.isDark ? 0.3 : 0.5

                            Behavior on width {
                                NumberAnimation {
                                    duration: AppTheme.animation.normal
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: Math.min(stm32BatteryLevel, rpiBatteryLevel) + "%"
                            color: AppTheme.colors.text
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }  // Spacer
        }
    }

    // Show/hide animations with slide from top
    NumberAnimation {
        id: showAnimation
        target: popupCard
        property: "anchors.topMargin"
        from: -popupCard.height
        to: 80
        duration: AppTheme.animation.normal
        easing.type: Easing.OutBack
    }

    NumberAnimation {
        id: hideAnimation
        target: popupCard
        property: "anchors.topMargin"
        from: 80
        to: -popupCard.height
        duration: AppTheme.animation.normal
        easing.type: Easing.InQuad
    }

    // Fade animations
    PropertyAnimation {
        id: fadeIn
        target: popup
        property: "opacity"
        from: 0
        to: 1
        duration: AppTheme.animation.fast * 2
    }

    PropertyAnimation {
        id: fadeOut
        target: popup
        property: "opacity"
        from: 1
        to: 0
        duration: AppTheme.animation.fast * 2
    }

    // Functions
    function open() {
        popup.visible = true;
        popup.opacity = 0;
        fadeIn.start();
        showAnimation.start();
    }

    function close() {
        hideAnimation.start();
        fadeOut.start();
    }

    // Clean up after hide animation
    Connections {
        target: hideAnimation
        function onStopped() {
            popup.visible = false;
        }
    }

    opacity: 0
}
