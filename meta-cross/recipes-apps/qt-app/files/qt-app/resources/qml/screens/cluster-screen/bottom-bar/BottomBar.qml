/**
 * @file BottomBar.qml
 * @author DrivaPi Team
 * @brief Bottom status bar showing trip distance, power output, and odometer
 */

import QtQuick
import QtQuick.Layouts
import "../../../theme"

Rectangle {
    id: root

    property bool vehicleDataAvailable: false
    property real s: 1.0
    property real sy: 1.0
    property int  fontSizeMedium: 22
    property real tripDistance: 0
    property real powerOutput: 0
    property real odometerDistance: 0

    signal resetRequested()

    color:         AppTheme.alpha(AppTheme.colors.surfaceVariant, 0.9)
    border.color:  AppTheme.colors.border
    border.width:  1
    radius:        4 * root.s

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14 * root.s
        spacing: 60 * root.s

        // Trip distance (left)
        Text {
            text: {
                if (!root.vehicleDataAvailable)
                    return "Trip A --";
                let dist = root.tripDistance;
                if (settingsManager.distanceUnit === "mi" || settingsManager.distanceUnit === "miles")
                    dist = dist * 0.621371;
                if (settingsManager.distanceUnit === "m")
                    dist = dist * 1000;
                return "Trip A " + Math.round(dist) + " " + settingsManager.distanceUnit;
            }
            color:          root.vehicleDataAvailable ? AppTheme.colors.textSecondary : AppTheme.colors.textTertiary
            font.pixelSize: root.fontSizeMedium * root.s
            font.weight:    Font.Medium
        }

        Item { Layout.fillWidth: true }

        // Power output indicator (center)
        RowLayout {
            spacing: 10 * root.s
            Layout.alignment: Qt.AlignHCenter

            Text {
                text: "kw"
                color: root.vehicleDataAvailable ? AppTheme.colors.textSecondary : AppTheme.colors.textTertiary
                font.pixelSize: root.fontSizeMedium * root.s
            }

            // Power bar (ISO 26262: Fail-safe visualization)
            Rectangle {
                width:  110 * root.s
                height: 5 * root.s
                radius: 2.5 * root.s
                color: root.vehicleDataAvailable ? AppTheme.colors.surface : AppTheme.colors.divider

                Rectangle {
                    width:  root.vehicleDataAvailable ? parent.width * (root.powerOutput / 100) : parent.width * 0.5
                    height: parent.height
                    radius: parent.radius
                    color:  root.vehicleDataAvailable ? AppTheme.colors.primary : AppTheme.colors.textTertiary
                }
            }

            Text {
                text:           root.vehicleDataAvailable ? Math.round(root.powerOutput) : "--"
                color:          root.vehicleDataAvailable ? AppTheme.colors.primary : AppTheme.colors.textTertiary
                font.pixelSize: root.fontSizeMedium * root.s
                font.weight:    Font.Bold
            }
        }

        Item { Layout.fillWidth: true }

        // Odometer (right) with reset button
        RowLayout {
            spacing: AppTheme.spacing.small
            Layout.alignment: Qt.AlignRight

            Text {
                text: {
                    let dist = Math.round(root.odometerDistance);
                    if (settingsManager.distanceUnit === "mi" || settingsManager.distanceUnit === "miles")
                        dist = dist * 0.621371;
                    if (settingsManager.distanceUnit === "m")
                        dist = dist * 1000;
                    return "ODO " + dist + settingsManager.distanceUnit;
                }
                color:          root.vehicleDataAvailable ? AppTheme.colors.textSecondary : AppTheme.colors.textTertiary
                font.pixelSize: root.fontSizeMedium * root.s
                font.weight:    Font.Medium
            }

            // Reset button
            Rectangle {
                width:  32
                height: 32
                radius: 4
                color:        resetMouseArea.containsMouse ? AppTheme.colors.primary : "transparent"
                border.color: AppTheme.colors.primary
                border.width: 1
                Layout.alignment: Qt.AlignVCenter

                Text {
                    anchors.centerIn: parent
                    text:           "↻"
                    color:          resetMouseArea.containsMouse ? AppTheme.colors.surfaceElevated : AppTheme.colors.primary
                    font.pixelSize: 18
                    font.weight:    Font.Bold
                }

                MouseArea {
                    id: resetMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.resetRequested()
                }
            }
        }
    }
}
