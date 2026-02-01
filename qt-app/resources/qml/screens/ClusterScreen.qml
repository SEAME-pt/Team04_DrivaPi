import QtQuick
import QtQuick.Layouts
import "../components"
import QtQuick.Effects
import "../theme"

Rectangle {
    id: root

    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: "#05080e"
        }
        GradientStop {
            position: 0.5
            color: "#030509"
        }
        GradientStop {
            position: 1.0
            color: "#05080e"
        }
    }

    // --- Top Glow Layer ---
    Image {
        source: "qrc:/assets/oie_kUl6AfLcsUwE.png"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: parent.height * 0.07
        opacity: 0.95
        z: 1
    }

    // --- Center Glow Layer ---
    Image {
        source: "qrc:/assets/oie_e7ruG6vIvyll.png"
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        width: parent.width * 0.98
        height: parent.height * 0.60
        opacity: 0.95
        z: 2
    }

    // --- Bottom Glow Layer ---
    Image {
        source: "qrc:/assets/oie_OeB7IAtTvDtn.png"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.PreserveAspectFit
        width: parent.width * 0.95
        height: parent.height * 0.11
        opacity: 0.95
        z: 3
    }

    // Glass side panels - prominent borders
    Image {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        source: "qrc:/assets/cluster_left_panel.svg"
        fillMode: Image.PreserveAspectFit
        opacity: 1.0
        sourceSize.width: 450
    }

    Image {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        source: "qrc:/assets/cluster_right_panel.svg"
        fillMode: Image.PreserveAspectFit
        opacity: 1.0
        sourceSize.width: 450
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Top bar
        ClusterTopBar {
            id: topBar
            Layout.fillWidth: true
            z: 10

            currentGear: vehicleData.gear
            temperatureText: Math.round(vehicleData.temperature) + "°C"
            // timeTextValue is auto-updated internally, but you can override if you want
        }

        // Main content area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Background grid and glow
            Image {
                source: "qrc:/assets/cluster_floor_grid.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 30
                sourceSize.width: 1200
                opacity: 0.6
            }

            Image {
                source: "qrc:/assets/cluster_car_glow.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 90
                sourceSize.width: 900
                opacity: 0.9
            }

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.strokeStyle = "#1a3d52";
                    ctx.lineWidth = 2;
                    ctx.globalAlpha = 0.55;
                    ctx.beginPath();
                    ctx.moveTo(width / 2, height - 110);
                    ctx.lineTo(width * 0.16, height - 5);
                    ctx.moveTo(width / 2, height - 110);
                    ctx.lineTo(width * 0.84, height - 5);
                    ctx.stroke();
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 60
                spacing: 50

                // Left navigation panel
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 220

                    Canvas {
                        anchors.fill: parent
                        anchors.margins: 12
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            ctx.strokeStyle = "#4fb3d914";
                            ctx.lineWidth = 1;   // FIX: was ctx.lineWidth(1)
                            ctx.beginPath();
                            ctx.moveTo(10, height * 0.2);
                            ctx.lineTo(width * 0.7, height * 0.25);
                            ctx.moveTo(20, height * 0.45);
                            ctx.lineTo(width * 0.6, height * 0.5);
                            ctx.moveTo(30, height * 0.7);
                            ctx.lineTo(width * 0.65, height * 0.75);
                            ctx.moveTo(width * 0.4, 10);
                            ctx.lineTo(width * 0.35, height * 0.85);
                            ctx.moveTo(width * 0.6, 20);
                            ctx.lineTo(width * 0.55, height * 0.9);
                            ctx.stroke();
                        }
                        opacity: 0.4
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -20
                        spacing: 16

                        Item {
                            width: 110
                            height: 110
                            Layout.alignment: Qt.AlignHCenter

                            Rectangle {
                                anchors.fill: parent
                                radius: 55
                                color: "#4fb3d914"
                                border.color: "#4fb3d933"
                                border.width: 1
                            }
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 8
                                radius: 47
                                color: "#0f1c29cc"
                                border.color: "#4fb3d926"
                                border.width: 1
                            }
                            Image {
                                source: "qrc:/icons/navigation/turn-right.svg"
                                sourceSize.width: 64
                                sourceSize.height: 64
                                anchors.centerIn: parent
                            }
                        }

                        Text {
                            text: "500 m"
                            color: "#4fb3d9"
                            font.pixelSize: 36
                            font.weight: Font.Bold
                            Layout.alignment: Qt.AlignHCenter
                        }

                        RowLayout {
                            spacing: 6
                            Layout.alignment: Qt.AlignHCenter

                            Rectangle {
                                width: 16
                                height: 16
                                radius: 8
                                color: "#4fb3d9"
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    text: "A"
                                    color: "#0b1624"
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    anchors.centerIn: parent
                                }
                            }

                            Text {
                                text: "右转进入金科路"
                                color: "#7a8a9a"
                                font.pixelSize: 13
                            }
                        }
                    }
                }

                // CENTER: Speed Display
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        width: 600
                        height: 300
                        anchors.centerIn: parent
                        radius: 300
                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: "#0b1624"
                            }
                            GradientStop {
                                position: 0.5
                                color: "#0b1624"
                            }
                            GradientStop {
                                position: 1.0
                                color: "#08111a00"
                            }
                        }
                        opacity: 0.92
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -18
                        spacing: 8

                        Text {
                            text: Math.round(vehicleData.speed * 3.6).toString()
                            color: "#ffffff"
                            font.pixelSize: 170
                            font.weight: Font.ExtraBold
                            Layout.alignment: Qt.AlignHCenter
                            style: Text.Outline
                            styleColor: "#4fb3d9"
                        }

                        Text {
                            text: "km/h"
                            color: "#7a8a9a"
                            font.pixelSize: 26
                            font.weight: Font.DemiBold
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    Rectangle {
                        width: 260
                        height: 80
                        radius: 40
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 70
                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: "#0b1624"
                            }
                            GradientStop {
                                position: 0.5
                                color: "#4fb3d9"
                            }
                            GradientStop {
                                position: 1.0
                                color: "#0b1624"
                            }
                        }
                        opacity: 0.85
                    }

                    Image {
                        source: "qrc:/icons/cluster/model3.svg"
                        sourceSize.width: 200
                        sourceSize.height: 200
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 32
                        opacity: 1.0
                    }
                }

                // RIGHT: Media Player
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 220

                    ColumnLayout {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -20
                        spacing: 16

                        Rectangle {
                            width: 150
                            height: 150
                            radius: 14
                            color: "#1a2a3a"
                            border.color: "#4fb3d94d"
                            border.width: 1
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                source: "qrc:/assets/album_art.svg"
                                sourceSize.width: 100
                                sourceSize.height: 100
                                anchors.centerIn: parent
                                fillMode: Image.PreserveAspectFit
                                opacity: 0.9
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 10
                                gradient: Gradient {
                                    GradientStop {
                                        position: 0.0
                                        color: "#1a3040aa"
                                    }
                                    GradientStop {
                                        position: 1.0
                                        color: "#1a304000"
                                    }
                                }
                                opacity: 0.5
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "transparent"
                                border.color: "#4fb3d91a"
                                border.width: 1
                            }
                        }

                        Text {
                            text: "Send Me Your Love"
                            color: "#ffffff"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            Layout.alignment: Qt.AlignHCenter
                            Layout.maximumWidth: 190
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignHCenter
                        }

                        ColumnLayout {
                            spacing: 4
                            Layout.alignment: Qt.AlignHCenter

                            Text {
                                text: "OneRepublic"
                                color: "#7a8a9a"
                                font.pixelSize: 13
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Rectangle {
                                width: 90
                                height: 2
                                radius: 1
                                color: "#4fb3d9"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        Rectangle {
                            width: 180
                            height: 3
                            radius: 1.5
                            color: "#1a3040"
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 6

                            Rectangle {
                                width: parent.width * 0.6
                                height: parent.height
                                radius: parent.radius
                                color: "#4fb3d9"
                            }
                        }

                        RowLayout {
                            spacing: 26
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 6

                            Image {
                                source: "qrc:/icons/controls/previous.svg"
                                sourceSize.width: 22
                                sourceSize.height: 22
                                opacity: 0.7
                            }

                            Rectangle {
                                width: 46
                                height: 46
                                radius: 23
                                color: "#1c3048"
                                border.color: "#6fd3ff"
                                border.width: 2

                                Image {
                                    source: "qrc:/icons/controls/play.svg"
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    anchors.centerIn: parent
                                }
                            }

                            Image {
                                source: "qrc:/icons/controls/next.svg"
                                sourceSize.width: 22
                                sourceSize.height: 22
                                opacity: 0.7
                            }
                        }
                    }
                }
            }
        }

        // BOTTOM BAR: Trip, Power, ODO
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52

            // FIX: anchors.*Margin doesn't apply in Layouts — use Layout margins
            Layout.leftMargin: 40
            Layout.rightMargin: 40
            Layout.bottomMargin: 6

            color: "#070c13cc"
            border.color: "#232a35"
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 60

                Text {
                    text: "Trip A " + Math.round(vehicleData.trip || 568) + "km"
                    color: "#a6b4c2"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }

                Item {
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 10
                    Layout.alignment: Qt.AlignHCenter

                    Text {
                        text: "kw"
                        color: "#7a8a9a"
                        font.pixelSize: 11
                    }

                    Rectangle {
                        width: 110
                        height: 5
                        radius: 2.5
                        color: "#1a3040"

                        Rectangle {
                            width: parent.width * (vehicleData.power / 100 || 0.9)
                            height: parent.height
                            radius: parent.radius
                            color: "#4fb3d9"
                        }
                    }

                    Text {
                        text: Math.round(vehicleData.power || 98)
                        color: "#4fb3d9"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "ODO " + Math.round(vehicleData.odo || 1273) + "km"
                    color: "#a6b4c2"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }
            }
        }
    }
}
