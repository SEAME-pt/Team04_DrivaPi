import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../theme"

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

        // Dark gradient matching cluster design
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#0a0f18"
            }
            GradientStop {
                position: 0.5
                color: "#050810"
            }
            GradientStop {
                position: 1.0
                color: "#020508"
            }
        }

        // Subtle border for definition
        border.color: "#1a2535"
        border.width: 1
        radius: 8

        // Subtle glow effect
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 15
            shadowColor: "#00BFFF20"
            shadowOpacity: 0.5
        }

        ColumnLayout {
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 10

            // Title with cluster styling
            Text {
                text: "BATTERY STATUS"
                color: "#00BFFF"
                font {
                    pixelSize: 12
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
                        color: "#8FA4B8"
                        font.pixelSize: 11
                        font.letterSpacing: 0.5
                        Layout.preferredWidth: 80
                    }

                    Rectangle {
                        height: 16
                        radius: 2
                        color: "#0a0f18"
                        border.color: stm32BatteryLevel >= 60 ? "#00BFFF" : (stm32BatteryLevel >= 30 ? "#FFA500" : "#FF3B30")
                        border.width: 1
                        Layout.fillWidth: true
                        clip: true

                        Rectangle {
                            width: parent.width * (stm32BatteryLevel / 100)
                            height: parent.height
                            color: stm32BatteryLevel >= 60 ? "#00BFFF" : (stm32BatteryLevel >= 30 ? "#FFA500" : "#FF3B30")
                            opacity: 0.3

                            Behavior on width {
                                NumberAnimation {
                                    duration: 400
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: stm32BatteryLevel + "%"
                            color: "#E0E0E0"
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
                        color: "#8FA4B8"
                        font.pixelSize: 11
                        font.letterSpacing: 0.5
                        Layout.preferredWidth: 80
                    }

                    Rectangle {
                        height: 16
                        radius: 2
                        color: "#0a0f18"
                        border.color: rpiBatteryLevel >= 60 ? "#00BFFF" : (rpiBatteryLevel >= 30 ? "#FFA500" : "#FF3B30")
                        border.width: 1
                        Layout.fillWidth: true
                        clip: true

                        Rectangle {
                            width: parent.width * (rpiBatteryLevel / 100)
                            height: parent.height
                            color: rpiBatteryLevel >= 60 ? "#00BFFF" : (rpiBatteryLevel >= 30 ? "#FFA500" : "#FF3B30")
                            opacity: 0.3

                            Behavior on width {
                                NumberAnimation {
                                    duration: 400
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: rpiBatteryLevel + "%"
                            color: "#E0E0E0"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            // Divider line
            Rectangle {
                height: 1
                color: "#1a2535"
                Layout.fillWidth: true
                opacity: 0.5
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
                        color: "#00BFFF"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        font.letterSpacing: 0.5
                        Layout.preferredWidth: 80
                    }

                    Rectangle {
                        height: 16
                        radius: 2
                        color: "#0a0f18"
                        border.color: "#00BFFF"
                        border.width: 1
                        Layout.fillWidth: true
                        clip: true

                        Rectangle {
                            width: parent.width * (Math.min(stm32BatteryLevel, rpiBatteryLevel) / 100)
                            height: parent.height
                            color: "#00BFFF"
                            opacity: 0.3

                            Behavior on width {
                                NumberAnimation {
                                    duration: 400
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: Math.min(stm32BatteryLevel, rpiBatteryLevel) + "%"
                            color: "#E0E0E0"
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
        duration: 400
        easing.type: Easing.OutBack
    }

    NumberAnimation {
        id: hideAnimation
        target: popupCard
        property: "anchors.topMargin"
        from: 80
        to: -popupCard.height
        duration: 300
        easing.type: Easing.InQuad
    }

    // Fade animations
    PropertyAnimation {
        id: fadeIn
        target: popup
        property: "opacity"
        from: 0
        to: 1
        duration: 200
    }

    PropertyAnimation {
        id: fadeOut
        target: popup
        property: "opacity"
        from: 1
        to: 0
        duration: 200
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
