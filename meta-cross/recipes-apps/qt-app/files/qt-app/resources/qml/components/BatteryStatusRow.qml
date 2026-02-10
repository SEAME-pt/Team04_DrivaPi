import QtQuick
import QtQuick.Layouts
import "../theme"

// Single battery status row in the popup
Rectangle {
    id: statusRow

    property string label: "Battery"
    property int percentage: 100
    property bool isSystem: false  // If true, show with system color

    height: 50
    color: "transparent"

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 4
            rightMargin: 4
        }
        spacing: 12

        // Label
        Text {
            text: label
            color: AppTheme.textColor
            font.pixelSize: 13
            Layout.preferredWidth: 140
        }

        // Battery bar
        Rectangle {
            height: 20
            radius: 4
            color: AppTheme.backgroundColor
            border.color: getBatteryColor()
            border.width: 1
            Layout.fillWidth: true
            clip: true

            // Fill percentage
            Rectangle {
                width: parent.width * (percentage / 100)
                height: parent.height
                color: getBatteryColor()
                opacity: 0.7
                radius: 4
            }

            // Percentage text
            Text {
                anchors.centerIn: parent
                text: percentage + "%"
                color: AppTheme.textColor
                font {
                    pixelSize: 11
                    weight: Font.Bold
                }
                z: 1
            }
        }
    }

    function getBatteryColor() {
        if (isSystem) {
            // For system battery, use accent color
            return AppTheme.accentColor;
        }

        // Color coding for individual batteries
        if (percentage >= 60) {
            return "#4CAF50";  // Green
        } else if (percentage >= 30) {
            return "#FF9800";  // Orange
        } else {
            return "#F44336";  // Red
        }
    }
}
