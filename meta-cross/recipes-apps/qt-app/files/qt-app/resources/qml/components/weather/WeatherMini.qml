import QtQuick
import QtQuick.Layouts
import "../../theme"

Item {
    id: root
    width: 280
    height: 170

    property QtObject weatherData: null

    property bool hasData: weatherData !== null && weatherData !== undefined && !weatherData.isLoading && !weatherData.hasError

    property string locationText: {
        if (!weatherData) return "--";
        return (weatherData.location && weatherData.location.length > 0) ? weatherData.location : "--";
    }

    property int temperatureValue: hasData ? weatherData.temperature : 0
    property int weatherCodeValue: hasData ? weatherData.weatherCode : 0
    property string descriptionText: hasData ? getWeatherDescription(weatherCodeValue) : ""
    property string hiLoText: {
        if (!hasData) return "";
        return (weatherData.hiLo && weatherData.hiLo.length > 0) ? weatherData.hiLo : "";
    }

    // ... (getWeatherDescription and getWeatherIconType remain the same) ...

    function getWeatherDescription(code) {
        if (code === 0) return "Clear";
        if (code === 1 || code === 2) return "Mostly Clear";
        if (code === 3) return "Overcast";
        if (code === 45 || code === 48) return "Foggy";
        if (code >= 51 && code <= 55) return "Drizzle";
        if (code >= 61 && code <= 65) return "Rain";
        if (code >= 71 && code <= 75) return "Snow";
        if (code >= 95 && code <= 99) return "Thunder";
        return "Unknown";
    }

    function getWeatherIconType(code) {
        if (code === 0) return "sun";
        if (code === 1 || code === 2 || code === 3) return "cloud";
        if (code === 45 || code === 48) return "fog";
        if (code >= 51 && code <= 67) return "rain";
        if (code >= 71 && code <= 86) return "snow";
        if (code >= 95 && code <= 99) return "cloud";
        return "sun";
    }

    // ====== COMPACT LAYOUT ======
    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width - AppTheme.spacing.large
        height: parent.height - AppTheme.spacing.large
        spacing: AppTheme.spacing.xSmall

        // Location Label
        Text {
            text: locationText.toUpperCase()
            color: AppTheme.colors.textSecondary
            font.pixelSize: AppTheme.typography.labelSmall
            font.weight: AppTheme.typography.weightMedium
            font.letterSpacing: 1
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        // Weather icon + temp (horizontal)
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: AppTheme.spacing.medium

            AnimatedWeatherIcon {
                type: hasData ? getWeatherIconType(weatherCodeValue) : "cloud"
                size: AppTheme.sizes.iconXLarge
                opacity: hasData ? 1.0 : 0.4
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                spacing: 0
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: hasData ? (temperatureValue + "°") : "--"
                    color: AppTheme.colors.text
                    font.pixelSize: AppTheme.typography.displayMedium
                    font.weight: AppTheme.typography.weightLight
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: descriptionText
                    visible: descriptionText.length > 0
                    color: AppTheme.colors.primary
                    font.pixelSize: AppTheme.typography.labelSmall
                    font.weight: AppTheme.typography.weightMedium
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // Hi/Lo temps
        Text {
            text: hiLoText
            visible: hiLoText.length > 0
            color: AppTheme.colors.textTertiary
            font.pixelSize: AppTheme.typography.labelSmall
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // ====== ANIMATED WEATHER ICON ======
    component AnimatedWeatherIcon: Item {
        property string type: "sun"
        property int size: 72
        width: size
        height: size

        // --- SUN ICON ---
        Item {
            id: sunIcon
            anchors.fill: parent
            visible: type === "sun"

            Repeater {
                model: 8
                Rectangle {
                    width: 2
                    height: size * 0.12
                    radius: AppTheme.radius.small
                    color: AppTheme.isDark ? "#FFD766" : "#FFA500"
                    anchors.centerIn: parent
                    rotation: index * 45
                    transform: Translate { y: -(size * 0.22) }
                }
            }

            Rectangle {
                width: size * 0.35
                height: size * 0.35
                radius: width / 2
                anchors.centerIn: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#FFE08A" }
                    GradientStop { position: 1.0; color: "#FFB300" }
                }
            }

            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 1.08; duration: 2000; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 1.08; to: 1.0; duration: 2000; easing.type: Easing.InOutQuad }
            }
        }

        // --- CLOUD ICON ---
        Item {
            id: cloudIcon
            anchors.fill: parent
            visible: type === "cloud" || type === "rain" || type === "fog"

            readonly property color cloudColor: AppTheme.isDark ? "#E9EFF6" : "#FFFFFF"

            // Subtle shadow for light mode clouds
            Rectangle {
                x: 8; y: 25; width: 34; height: 13; radius: 6
                color: AppTheme.alpha(AppTheme.colors.text, 0.1)
                visible: !AppTheme.isDark
            }

            Rectangle { x: 8; y: 24; width: 34; height: 13; radius: 6; color: parent.cloudColor }
            Rectangle { x: 2; y: 27; width: 18; height: 11; radius: 6; color: parent.cloudColor }
            Rectangle { x: 24; y: 27; width: 20; height: 11; radius: 6; color: parent.cloudColor }
            Rectangle {
                x: 14; y: 19; width: 18; height: 11; radius: 6;
                color: AppTheme.isDark ? "#F4F7FB" : AppTheme.tint(parent.cloudColor, 0.05)
            }

            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { from: 0; to: 2; duration: 2500; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 2; to: 0; duration: 2500; easing.type: Easing.InOutQuad }
            }
        }

        // --- RAIN DROPS ---
        Repeater {
            model: type === "rain" ? 3 : 0
            Rectangle {
                width: 2
                height: 8
                radius: 1
                color: AppTheme.colors.info
                x: (size * 0.2) + index * (size * 0.15)
                y: size * 0.6

                SequentialAnimation on y {
                    loops: Animation.Infinite
                    NumberAnimation { from: size * 0.55; to: size * 0.75; duration: 600; easing.type: Easing.InQuad }
                    PropertyAction { value: size * 0.55 }
                }

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { from: 0; to: 1; duration: 300 }
                    NumberAnimation { from: 1; to: 0; duration: 300 }
                }
            }
        }

        // --- FOG LINES ---
        Repeater {
            model: type === "fog" ? 2 : 0
            Rectangle {
                width: size * 0.5 - index * 8
                height: 2
                radius: 1
                color: AppTheme.colors.divider
                x: (size * 0.1) + index * 4
                y: (size * 0.6) + index * 6

                SequentialAnimation on x {
                    loops: Animation.Infinite
                    NumberAnimation { from: x; to: x + 4; duration: 2000; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: x + 4; to: x; duration: 2000; easing.type: Easing.InOutQuad }
                }
            }
        }
    }
}
