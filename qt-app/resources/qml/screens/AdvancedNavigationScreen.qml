import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    color: AppTheme.colors.surface

    // ====== MAIN LAYOUT ======
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        // ====== TOP: Route Overview Header ======
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            color: AppTheme.colors.surfaceElevated

            RowLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.medium
                spacing: AppTheme.spacing.medium

                // Route Info
                ColumnLayout {
                    spacing: AppTheme.spacing.xxSmall
                    Layout.fillWidth: true

                    RowLayout {
                        spacing: AppTheme.spacing.small

                        Image {
                            source: "qrc:/icons/navigation/map-pin.svg"
                            sourceSize.width: 16
                            sourceSize.height: 16
                        }

                        Text {
                            text: "San Francisco Convention Center"
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.labelMedium
                            font.weight: Font.Medium
                        }
                    }

                    RowLayout {
                        spacing: AppTheme.spacing.small
                        Layout.topMargin: AppTheme.spacing.xsmall

                        Image {
                            source: "qrc:/icons/navigation/route.svg"
                            sourceSize.width: 14
                            sourceSize.height: 14
                        }

                        Text {
                            text: "12.5 km • 18 min"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                        }

                        Rectangle {
                            width: 1
                            height: 14
                            color: AppTheme.colors.divider
                        }

                        Image {
                            source: "qrc:/icons/navigation/traffic-green.svg"
                            sourceSize.width: 14
                            sourceSize.height: 14
                        }

                        Text {
                            text: "No delays"
                            color: AppTheme.colors.success
                            font.pixelSize: AppTheme.typography.labelSmall
                        }
                    }
                }

                // Alternative routes button
                Rectangle {
                    width: 40
                    height: 40
                    color: AppTheme.colors.primary
                    radius: AppTheme.spacing.xxSmall

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/icons/navigation/route.svg"
                        sourceSize.width: 20
                        sourceSize.height: 20
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: console.log("View alternative routes")
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: AppTheme.colors.divider
            }
        }

        // ====== MIDDLE: Turn-by-Turn Maneuvers ======
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            color: AppTheme.colors.surface

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.medium
                spacing: AppTheme.spacing.medium

                Text {
                    text: "Upcoming Maneuvers"
                    color: AppTheme.colors.text
                    font.pixelSize: AppTheme.typography.labelMedium
                    font.weight: Font.Medium
                }

                // Maneuver items
                ColumnLayout {
                    spacing: AppTheme.spacing.medium
                    Layout.fillWidth: true

                    // Maneuver 1: Turn Left
                    RowLayout {
                        spacing: AppTheme.spacing.medium
                        Layout.fillWidth: true

                        Rectangle {
                            width: 50
                            height: 50
                            color: AppTheme.colors.primaryContainer
                            radius: AppTheme.spacing.small

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/turn-left.svg"
                                sourceSize.width: 28
                                sourceSize.height: 28
                            }
                        }

                        ColumnLayout {
                            spacing: AppTheme.spacing.xxSmall
                            Layout.fillWidth: true

                            Text {
                                text: "Turn left onto Market Street"
                                color: AppTheme.colors.text
                                font.pixelSize: AppTheme.typography.bodySmall
                                font.weight: Font.Medium
                            }

                            Text {
                                text: "500 m ahead"
                                color: AppTheme.colors.textSecondary
                                font.pixelSize: AppTheme.typography.labelSmall
                            }
                        }
                    }

                    // Maneuver 2: Merge Right
                    RowLayout {
                        spacing: AppTheme.spacing.medium
                        Layout.fillWidth: true

                        Rectangle {
                            width: 50
                            height: 50
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/merge-right.svg"
                                sourceSize.width: 28
                                sourceSize.height: 28
                            }
                        }

                        ColumnLayout {
                            spacing: AppTheme.spacing.xxSmall
                            Layout.fillWidth: true

                            Text {
                                text: "Merge right onto I-280"
                                color: AppTheme.colors.text
                                font.pixelSize: AppTheme.typography.bodySmall
                                font.weight: Font.Medium
                            }

                            Text {
                                text: "1.2 km ahead"
                                color: AppTheme.colors.textSecondary
                                font.pixelSize: AppTheme.typography.labelSmall
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: AppTheme.colors.divider
            }
        }

        // ====== CENTER-TOP: Complex Maneuvers ======
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            color: AppTheme.colors.surface

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.medium
                spacing: AppTheme.spacing.medium

                Text {
                    text: "Complex Maneuvers"
                    color: AppTheme.colors.text
                    font.pixelSize: AppTheme.typography.labelMedium
                    font.weight: Font.Medium
                }

                // Complex maneuvers grid
                GridLayout {
                    columns: 4
                    rowSpacing: AppTheme.spacing.medium
                    columnSpacing: AppTheme.spacing.medium
                    Layout.fillWidth: true

                    // U-Turn Left
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/u-turn-left.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "U-Turn"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Roundabout
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/roundabout.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "Roundabout"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Straight
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/straight.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "Continue"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // U-Turn Right
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/u-turn-right.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "U-Turn"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: AppTheme.colors.divider
            }
        }

        // ====== BOTTOM: Directional & Highway Info ======
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            color: AppTheme.colors.surface

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.medium
                spacing: AppTheme.spacing.medium

                Text {
                    text: "Direction & Road Info"
                    color: AppTheme.colors.text
                    font.pixelSize: AppTheme.typography.labelMedium
                    font.weight: Font.Medium
                }

                // Directional & Highway Grid
                GridLayout {
                    columns: 4
                    rowSpacing: AppTheme.spacing.medium
                    columnSpacing: AppTheme.spacing.medium
                    Layout.fillWidth: true

                    // Arrow Up
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/arrow-up.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "North"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Arrow Left
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/arrow-left.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "West"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Arrow Right
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/arrow-right.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "East"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Compass
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/compass.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "Compass"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // Additional Info Row
                RowLayout {
                    spacing: AppTheme.spacing.medium
                    Layout.fillWidth: true
                    Layout.topMargin: AppTheme.spacing.small

                    Rectangle {
                        width: 44
                        height: 44
                        color: AppTheme.colors.surfaceVariant
                        radius: AppTheme.spacing.small

                        Image {
                            anchors.centerIn: parent
                            source: "qrc:/icons/navigation/parking.svg"
                            sourceSize.width: 24
                            sourceSize.height: 24
                        }
                    }

                    ColumnLayout {
                        spacing: AppTheme.spacing.xxSmall
                        Layout.fillWidth: true

                        Text {
                            text: "Parking available at destination"
                            color: AppTheme.colors.text
                            font.pixelSize: AppTheme.typography.bodySmall
                        }

                        Text {
                            text: "Multiple lots available"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                        }
                    }

                    Item { Layout.fillWidth: true }
                }
            }
        }

        // ====== ADDITIONAL TURNS & MERGE OPTIONS ======
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            color: AppTheme.colors.surface

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.medium
                spacing: AppTheme.spacing.medium

                Text {
                    text: "Turn & Merge Variations"
                    color: AppTheme.colors.text
                    font.pixelSize: AppTheme.typography.labelMedium
                    font.weight: Font.Medium
                }

                // Turns Grid
                GridLayout {
                    columns: 4
                    rowSpacing: AppTheme.spacing.medium
                    columnSpacing: AppTheme.spacing.medium
                    Layout.fillWidth: true

                    // Turn Slight Left
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/turn-slight-left.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "Slight L"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Turn Slight Right
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/turn-slight-right.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "Slight R"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Merge Left
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/merge-left.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "Merge L"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Keep Left
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/keep-left.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "Keep L"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Keep Right
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/keep-right.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "Keep R"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // Second Row
                GridLayout {
                    columns: 4
                    rowSpacing: AppTheme.spacing.medium
                    columnSpacing: AppTheme.spacing.medium
                    Layout.fillWidth: true

                    // Exit Left
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/exit-left.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "Exit L"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Exit Right
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/exit-right.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "Exit R"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Highway Info
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/highway.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "Highway"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Destination
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 44
                            height: 44
                            color: AppTheme.colors.primary
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/destination.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }
                        }

                        Text {
                            text: "Destination"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }

        // ====== TRAFFIC & SPEED LIMITS EXTENDED ======
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            color: AppTheme.colors.surface

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.medium
                spacing: AppTheme.spacing.medium

                Text {
                    text: "Traffic Conditions & Speed Limits"
                    color: AppTheme.colors.text
                    font.pixelSize: AppTheme.typography.labelMedium
                    font.weight: Font.Medium
                }

                // Speed Limits Extended Grid
                GridLayout {
                    columns: 4
                    rowSpacing: AppTheme.spacing.medium
                    columnSpacing: AppTheme.spacing.medium
                    Layout.fillWidth: true

                    // Speed Limit 30 SVG
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 50
                            height: 50
                            color: AppTheme.colors.warning
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/speed-limit-30.svg"
                                sourceSize.width: 40
                                sourceSize.height: 40
                            }
                        }

                        Text {
                            text: "30 km/h"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Speed Limit 50 SVG Icon
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 50
                            height: 50
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/speed-limit-50.svg"
                                sourceSize.width: 40
                                sourceSize.height: 40
                            }
                        }

                        Text {
                            text: "50 km/h"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Speed Limit 100 SVG
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 50
                            height: 50
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/speed-limit-100.svg"
                                sourceSize.width: 40
                                sourceSize.height: 40
                            }
                        }

                        Text {
                            text: "100 km/h"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Traffic Red
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 50
                            height: 50
                            color: AppTheme.colors.error
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/traffic-red.svg"
                                sourceSize.width: 28
                                sourceSize.height: 28
                            }
                        }

                        Text {
                            text: "Congested"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // Second Row
                GridLayout {
                    columns: 4
                    rowSpacing: AppTheme.spacing.medium
                    columnSpacing: AppTheme.spacing.medium
                    Layout.fillWidth: true

                    // Speed Limit 120 SVG
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 50
                            height: 50
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/speed-limit-120.svg"
                                sourceSize.width: 40
                                sourceSize.height: 40
                            }
                        }

                        Text {
                            text: "120 km/h"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Speed Limit 80
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 50
                            height: 50
                            color: AppTheme.colors.surfaceVariant
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Text {
                                anchors.centerIn: parent
                                text: "80"
                                color: AppTheme.colors.text
                                font.pixelSize: AppTheme.typography.headlineSmall
                                font.weight: Font.Bold
                            }
                        }

                        Text {
                            text: "Highway"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Traffic Yellow
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 50
                            height: 50
                            color: AppTheme.colors.warning
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/traffic-yellow.svg"
                                sourceSize.width: 28
                                sourceSize.height: 28
                            }
                        }

                        Text {
                            text: "Moderate"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Traffic Green
                    ColumnLayout {
                        spacing: AppTheme.spacing.xsmall
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 50
                            height: 50
                            color: AppTheme.colors.success
                            radius: AppTheme.spacing.small
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.centerIn: parent
                                source: "qrc:/icons/navigation/traffic-green.svg"
                                sourceSize.width: 28
                                sourceSize.height: 28
                            }
                        }

                        Text {
                            text: "Clear"
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }
    }
}
