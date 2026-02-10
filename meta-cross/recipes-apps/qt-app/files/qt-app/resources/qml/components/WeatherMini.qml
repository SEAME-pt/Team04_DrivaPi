import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root
    width: 280
    height: 170

    property QtObject weatherData: null

    property bool hasData: weatherData !== null && weatherData !== undefined && !weatherData.isLoading && !weatherData.hasError

    property string locationText: {
        if (!weatherData)
            return "--";
        if (weatherData.location && weatherData.location.length > 0)
            return weatherData.location;
        return "--";
    }

    property int temperatureValue: hasData ? weatherData.temperature : 0
    property int weatherCodeValue: hasData ? weatherData.weatherCode : 0
    property string descriptionText: hasData ? getWeatherDescription(weatherCodeValue) : ""
    property string hiLoText: {
        if (!hasData)
            return "";
        return (weatherData.hiLo && weatherData.hiLo.length > 0) ? weatherData.hiLo : "";
    }

    function getWeatherDescription(code) {
        if (code === 0)
            return "Clear";
        if (code === 1 || code === 2)
            return "Mostly Clear";
        if (code === 3)
            return "Overcast";
        if (code === 45 || code === 48)
            return "Foggy";
        if (code >= 51 && code <= 55)
            return "Drizzle";
        if (code >= 56 && code <= 57)
            return "Freezing Drizzle";
        if (code >= 61 && code <= 65)
            return "Rain";
        if (code >= 66 && code <= 67)
            return "Freezing Rain";
        if (code >= 71 && code <= 75)
            return "Snow";
        if (code === 77)
            return "Snow Grains";
        if (code >= 80 && code <= 82)
            return "Showers";
        if (code >= 85 && code <= 86)
            return "Snow Showers";
        if (code === 95 || code === 96 || code === 99)
            return "Thunder";
        return "Unknown";
    }

    function getWeatherIconType(code) {
        if (code === 0)
            return "sun";
        if (code === 1 || code === 2 || code === 3)
            return "cloud";
        if (code === 45 || code === 48)
            return "fog";
        if (code >= 51 && code <= 57)
            return "rain";
        if (code >= 61 && code <= 67)
            return "rain";
        if (code >= 71 && code <= 77)
            return "snow";
        if (code >= 80 && code <= 82)
            return "rain";
        if (code >= 85 && code <= 86)
            return "snow";
        if (code >= 95 && code <= 99)
            return "cloud";
        return "sun";
    }

    // ====== COMPACT LAYOUT ======
    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width - 20
        height: parent.height - 20
        spacing: 4

        // Location
        Text {
            text: locationText
            color: "#93a6bf"
            font.pixelSize: 10
            font.weight: Font.Medium
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        // Weather icon + temp (horizontal)
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            AnimatedWeatherIcon {
                type: hasData ? getWeatherIconType(weatherCodeValue) : "cloud"
                size: 42
                opacity: hasData ? 1.0 : 0.35
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                spacing: 0
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: hasData ? (temperatureValue + "°") : "--"
                    color: "#ffffff"
                    font.pixelSize: 24
                    font.weight: Font.Light
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: descriptionText
                    visible: descriptionText.length > 0
                    color: "#00BFFF"
                    font.pixelSize: 9
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // Hi/Lo temps
        Text {
            text: hiLoText
            visible: hiLoText.length > 0
            color: "#6A7A8A"
            font.pixelSize: 9
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

        Item {
            id: sunIcon
            anchors.centerIn: parent
            visible: type === "sun"

            Repeater {
                model: 8
                Rectangle {
                    width: 2
                    height: 8
                    radius: 1
                    color: "#FFD766"
                    anchors.centerIn: parent
                    rotation: index * 45
                    y: -14
                    opacity: 0.6
                }
            }

            Rectangle {
                width: 22
                height: 22
                radius: 11
                anchors.centerIn: parent
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "#FFE08A"
                    }
                    GradientStop {
                        position: 1.0
                        color: "#FFC24A"
                    }
                }
                opacity: 0.95
            }

            SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation {
                    from: 1.0
                    to: 1.05
                    duration: 1600
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    from: 1.05
                    to: 1.0
                    duration: 1600
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Item {
            id: cloudIcon
            anchors.centerIn: parent
            visible: type === "cloud" || type === "rain" || type === "fog"

            Rectangle {
                x: 8
                y: 24
                width: 34
                height: 13
                radius: 6
                color: "#E9EFF6"
                opacity: 0.98
            }
            Rectangle {
                x: 2
                y: 27
                width: 18
                height: 11
                radius: 6
                color: "#E9EFF6"
                opacity: 0.98
            }
            Rectangle {
                x: 24
                y: 27
                width: 20
                height: 11
                radius: 6
                color: "#E9EFF6"
                opacity: 0.98
            }
            Rectangle {
                x: 14
                y: 19
                width: 18
                height: 11
                radius: 6
                color: "#F4F7FB"
                opacity: 0.85
            }

            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation {
                    from: 0
                    to: 2
                    duration: 1800
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    from: 2
                    to: 0
                    duration: 1800
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Repeater {
            model: type === "rain" ? 3 : 0
            Rectangle {
                width: 2
                height: 8
                radius: 1
                color: "#5CC8FF"
                x: 12 + index * 10
                y: 42
                opacity: 0.85

                SequentialAnimation on y {
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: 40
                        to: 52
                        duration: 700
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        from: 52
                        to: 40
                        duration: 0
                    }
                }

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: 0.4
                        to: 0.9
                        duration: 700
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        from: 0.9
                        to: 0.4
                        duration: 0
                    }
                }
            }
        }

        Repeater {
            model: type === "fog" ? 2 : 0
            Rectangle {
                width: 32 - index * 8
                height: 1.5
                radius: 1
                color: "#C7D6E3"
                x: 5 + index * 2
                y: 40 + index * 5
                opacity: 0.6

                SequentialAnimation on x {
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: x
                        to: x + 2
                        duration: 1500
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        from: x + 2
                        to: x
                        duration: 1500
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
}
