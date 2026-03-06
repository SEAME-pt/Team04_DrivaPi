import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../theme"

Rectangle {
    id: root
    color: AppTheme.colors.surface
    property bool keyboardAlwaysVisible: false
    property int keyboardHeight: 140
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (locationInput.activeFocus) {
                locationInput.focus = false;
            }
        }
        z: -1
    }

    property alias weatherDataModel: weatherData

    QtObject {
        id: weatherData
        property string location: ""
        property real latitude: 41.1579
        property real longitude: -8.6291

        property int weatherCode: 0
        property int temperature: 0
        property int apparentTemperature: 0
        property int humidity: 0
        property real windSpeed: 0
        property int windDirection: 0
        property int uvIndex: 0
        property real precipitation: 0
        property string dayOfWeek: ""
        property string hiLo: ""

        property var hourlyData: []
        property var dailyData: []

        property bool isLoading: true
        property bool hasError: false
        property string errorMessage: ""
        property string lastUpdated: ""
    }

    function fetchWeatherData(lat, lon, name) {
        weatherData.isLoading = true;
        weatherData.hasError = false;
        weatherData.errorMessage = "";
        weatherData.location = name;
        weatherData.latitude = lat;
        weatherData.longitude = lon;

        var xhr = new XMLHttpRequest();
        var tempParam = (settingsManager.temperatureUnit === "°F") ? "&temperature_unit=fahrenheit" : "";

        var windParam = "";
        if (settingsManager.windSpeedUnit === "m/s")
            windParam = "&wind_speed_unit=ms";
        else if (settingsManager.windSpeedUnit === "mph")
            windParam = "&wind_speed_unit=mph";
        else if (settingsManager.windSpeedUnit === "km/h")
            windParam = "&wind_speed_unit=kmh";

        var precipParam = (settingsManager.precipitationUnit === "inch") ? "&precipitation_unit=inch" : "";
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m,uv_index,precipitation&hourly=temperature_2m,weather_code,precipitation_probability&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,sunrise,sunset&timezone=auto&forecast_days=7" + tempParam + windParam + precipParam;

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        var current = data.current;
                        var daily = data.daily;
                        var hourly = data.hourly;

                        weatherData.weatherCode = current.weather_code;
                        weatherData.temperature = Math.round(current.temperature_2m);
                        weatherData.apparentTemperature = Math.round(current.apparent_temperature);
                        weatherData.humidity = current.relative_humidity_2m;
                        weatherData.windSpeed = Math.round(current.wind_speed_10m * 10) / 10;
                        weatherData.windDirection = Math.round(current.wind_direction_10m);
                        weatherData.uvIndex = Math.round(current.uv_index);
                        weatherData.precipitation = Math.round(current.precipitation * 10) / 10;
                        weatherData.dayOfWeek = new Date().toLocaleDateString(Qt.locale(), "dddd");
                        weatherData.hiLo = "H:" + Math.round(daily.temperature_2m_max[0]) + settingsManager.temperatureUnit + "  L:" + Math.round(daily.temperature_2m_min[0]) + settingsManager.temperatureUnit;
                        weatherData.lastUpdated = new Date().toLocaleTimeString(Qt.locale(), "HH:mm");

                        var now = new Date();
                        var hourlyItems = [];
                        for (var i = 0; i < hourly.time.length; i++) {
                            var hourTimeMs = Date.parse(hourly.time[i]);
                            if (isNaN(hourTimeMs))
                                continue;
                            if (hourTimeMs >= now.getTime() || hourlyItems.length > 0) {
                                hourlyItems.push({
                                    time: formatHour(hourly.time[i]),
                                    temp: Math.round(hourly.temperature_2m[i]),
                                    code: hourly.weather_code[i],
                                    precip: hourly.precipitation_probability[i]
                                });
                                if (hourlyItems.length >= 6)
                                    break;
                            }
                        }
                        if (hourlyItems.length === 0) {
                            for (var k = 0; k < Math.min(6, hourly.time.length); k++) {
                                hourlyItems.push({
                                    time: formatHour(hourly.time[k]),
                                    temp: Math.round(hourly.temperature_2m[k]),
                                    code: hourly.weather_code[k],
                                    precip: hourly.precipitation_probability[k]
                                });
                            }
                        }
                        weatherData.hourlyData = hourlyItems;

                        var dailyItems = [];
                        for (var j = 0; j < Math.min(3, daily.time.length); j++) {
                            dailyItems.push({
                                day: formatDay(daily.time[j]),
                                maxTemp: Math.round(daily.temperature_2m_max[j]),
                                minTemp: Math.round(daily.temperature_2m_min[j]),
                                code: daily.weather_code[j],
                                precipitation: Math.round(daily.precipitation_sum[j] * 10) / 10,
                                sunrise: formatTime(daily.sunrise[j]),
                                sunset: formatTime(daily.sunset[j])
                            });
                        }
                        weatherData.dailyData = dailyItems;
                        weatherData.isLoading = false;
                    } catch (e) {
                        weatherData.hasError = true;
                        weatherData.errorMessage = "Parse error";
                        weatherData.isLoading = false;
                    }
                } else {
                    weatherData.hasError = true;
                    weatherData.errorMessage = "Network error";
                    weatherData.isLoading = false;
                }
            }
        };
        xhr.open("GET", url);
        xhr.send();
    }

    function searchLocation(query) {
        if (!query || query.length < 2)
            return;
        var xhr = new XMLHttpRequest();
        var url = "https://geocoding-api.open-meteo.com/v1/search?" + "name=" + encodeURIComponent(query) + "&count=1&language=en&format=json";
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (data.results && data.results.length > 0) {
                        var result = data.results[0];
                        var name = result.name + ",";
                        if (result.country)
                            name += "\n" + result.country;
                        else if (result.admin1)
                            name += "\n" + result.admin1;
                        fetchWeatherData(result.latitude, result.longitude, name);
                    }
                } catch (e) {
                    weatherData.hasError = true;
                    weatherData.errorMessage = "Search error";
                }
            }
        };
        xhr.open("GET", url);
        xhr.send();
    }

    function getWeatherDescription(code) {
        if (code === 0) return "Clear sky";
        if (code === 1 || code === 2) return "Mostly clear";
        if (code === 3) return "Overcast";
        if (code === 45 || code === 48) return "Foggy";
        if (code >= 51 && code <= 55) return "Light drizzle";
        if (code >= 56 && code <= 57) return "Freezing drizzle";
        if (code >= 61 && code <= 65) return "Rain";
        if (code >= 66 && code <= 67) return "Freezing rain";
        if (code >= 71 && code <= 75) return "Snow";
        if (code === 77) return "Snow grains";
        if (code >= 80 && code <= 82) return "Rain showers";
        if (code >= 85 && code <= 86) return "Snow showers";
        if (code === 95 || code === 96 || code === 99) return "Thunderstorm";
        return "Unknown";
    }

    function getWeatherIcon(code) {
        if (code === 0) return "sun";
        if (code === 1 || code === 2 || code === 3) return "cloud";
        if (code === 45 || code === 48) return "fog";
        if (code >= 51 && code <= 67) return "rain";
        if (code >= 71 && code <= 77) return "snow";
        if (code >= 80 && code <= 82) return "rain";
        if (code >= 85 && code <= 86) return "snow";
        if (code >= 95 && code <= 99) return "cloud";
        return "sun";
    }

    function getWeatherIconType(code) {
        if (code === 0) return "sun";
        if (code === 1 || code === 2 || code === 3) return "cloud";
        if (code === 45 || code === 48) return "fog";
        if (code >= 51 && code <= 67) return "rain";
        if (code >= 71 && code <= 77) return "snow";
        if (code >= 80 && code <= 82) return "rain";
        if (code >= 85 && code <= 86) return "snow";
        if (code >= 95 && code <= 99) return "cloud";
        return "sun";
    }

    function getDailyMinTemp() {
        var minTemp = 999;
        for (var i = 0; i < weatherData.dailyData.length; i++) {
            minTemp = Math.min(minTemp, weatherData.dailyData[i].minTemp);
        }
        return minTemp === 999 ? 0 : minTemp;
    }

    function getDailyMaxTemp() {
        var maxTemp = -999;
        for (var i = 0; i < weatherData.dailyData.length; i++) {
            maxTemp = Math.max(maxTemp, weatherData.dailyData[i].maxTemp);
        }
        return maxTemp === -999 ? 0 : maxTemp;
    }

    function formatHour(isoString) {
        return new Date(isoString).toLocaleTimeString(Qt.locale(), "HH:mm");
    }

    function formatDay(isoString) {
        return new Date(isoString).toLocaleDateString(Qt.locale(), "ddd");
    }

    function formatTime(isoString) {
        return new Date(isoString).toLocaleTimeString(Qt.locale(), "HH:mm");
    }

    Component.onCompleted: {
        fetchWeatherData(41.1579, -8.6291, "Porto, Portugal");
    }

    Timer {
        id: refreshTimer
        interval: 600000
        repeat: true
        running: true
        onTriggered: fetchWeatherData(weatherData.latitude, weatherData.longitude, weatherData.location)
    }

    Connections {
        target: settingsManager
        function onTemperatureUnitChanged() {
            fetchWeatherData(weatherData.latitude, weatherData.longitude, weatherData.location);
        }
        function onWindSpeedUnitChanged() {
            fetchWeatherData(weatherData.latitude, weatherData.longitude, weatherData.location);
        }
        function onPrecipitationUnitChanged() {
            fetchWeatherData(weatherData.latitude, weatherData.longitude, weatherData.location);
        }
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 13
        anchors.topMargin: 12
        anchors.bottomMargin: locationInput.activeFocus ? keyboardPanel.height + 8 : 12
        spacing: 6
        clip: true

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 6
            Layout.rightMargin: 12

            Text {
                text: weatherData.location
                color: AppTheme.colors.text
                font.pixelSize: 15
                font.weight: Font.Medium
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                Layout.preferredWidth: 90
            }

            TextField {
                id: locationInput
                Layout.preferredWidth: 80
                Layout.preferredHeight: 30
                Layout.minimumWidth: 80
                placeholderText: "Search"
                Layout.rightMargin: 24
                placeholderTextColor: AppTheme.colors.textSecondary
                font.pixelSize: 11
                color: AppTheme.colors.text
                leftPadding: 10
                rightPadding: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                z: 20
                background: Rectangle {
                    color: AppTheme.colors.surfaceElevated
                    radius: 8
                    border.width: 1
                    border.color: locationInput.activeFocus ? AppTheme.colors.primary : AppTheme.colors.border
                }
                onAccepted: {
                    searchLocation(text);
                    locationInput.focus = false;
                }
                MouseArea {
                    anchors.fill: parent
                    onPressed: function(mouse) {
                        locationInput.forceActiveFocus();
                        mouse.accepted = false;
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 1

            AnimatedWeatherIcon {
                id: animatedIcon
                Layout.alignment: Qt.AlignHCenter
                size: 60
                type: getWeatherIconType(weatherData.weatherCode)
            }

            Text {
                text: weatherData.isLoading ? "--" : weatherData.temperature + settingsManager.temperatureUnit
                font.pixelSize: 56
                font.weight: Font.Light
                color: AppTheme.colors.text
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: weatherData.isLoading ? "" : getWeatherDescription(weatherData.weatherCode)
                font.pixelSize: 13
                color: AppTheme.colors.textSecondary
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: weatherData.isLoading ? "" : weatherData.hiLo
                font.pixelSize: 11
                color: AppTheme.colors.textTertiary
                Layout.bottomMargin: 4
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            Layout.topMargin: 2
            Layout.bottomMargin: 6

            Repeater {
                model: [
                    { label: "Wind", value: weatherData.windSpeed + " " + settingsManager.windSpeedUnit },
                    { label: "Humidity", value: weatherData.humidity + "%" },
                    { label: "UV", value: weatherData.uvIndex },
                    { label: "Feels", value: weatherData.apparentTemperature + settingsManager.temperatureUnit }
                ]

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1

                    Text {
                        text: modelData.label
                        font.pixelSize: 10
                        color: AppTheme.colors.textTertiary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: weatherData.isLoading ? "--" : modelData.value
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: AppTheme.colors.text
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: AppTheme.colors.divider
            opacity: 1.0
        }

        Text {
            text: "HOURLY FORECAST"
            font.pixelSize: 10
            color: AppTheme.colors.textTertiary
            font.weight: Font.Medium
            Layout.topMargin: 6
            Layout.bottomMargin: 4
        }

        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: 82
            orientation: ListView.Horizontal
            spacing: 12
            clip: true
            model: weatherData.hourlyData
            Layout.alignment: Qt.AlignHCenter

            delegate: ColumnLayout {
                width: 46
                spacing: 4

                Text {
                    text: modelData.time
                    font.pixelSize: 11
                    color: AppTheme.colors.textSecondary
                    font.weight: Font.Medium
                    Layout.alignment: Qt.AlignHCenter
                }

                Image {
                    source: "qrc:/icons/weather/" + getWeatherIcon(modelData.code) + ".svg"
                    sourceSize.width: 24
                    sourceSize.height: 24
                    Layout.alignment: Qt.AlignHCenter
                    opacity: 0.95
                    layer.enabled: true
                    layer.effect: ColorOverlay {
                        color: AppTheme.colors.text
                    }
                }

                Text {
                    text: modelData.precip > 0 ? modelData.precip + "%" : ""
                    font.pixelSize: 9
                    color: AppTheme.colors.primary
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: 12
                }

                Text {
                    text: modelData.temp + settingsManager.temperatureUnit
                    font.pixelSize: 13
                    color: AppTheme.colors.text
                    font.weight: Font.Medium
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: AppTheme.colors.divider
            opacity: 1.0
            Layout.topMargin: 4
        }

        Text {
            text: "3-DAY FORECAST"
            font.pixelSize: 10
            color: AppTheme.colors.textTertiary
            font.weight: Font.Medium
            Layout.topMargin: 6
            Layout.bottomMargin: 4
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: weatherData.dailyData

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Layout.alignment: Qt.AlignHCenter

                    Text {
                        text: modelData.day
                        font.pixelSize: 12
                        color: AppTheme.colors.textSecondary
                        Layout.preferredWidth: 36
                    }

                    Image {
                        source: "qrc:/icons/weather/" + getWeatherIcon(modelData.code) + ".svg"
                        sourceSize.width: 22
                        sourceSize.height: 22
                        layer.enabled: true
                        layer.effect: ColorOverlay {
                            color: AppTheme.colors.text
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: modelData.minTemp + settingsManager.temperatureUnit
                        font.pixelSize: 12
                        color: AppTheme.colors.textTertiary
                        Layout.preferredWidth: 30
                        horizontalAlignment: Text.AlignRight
                    }

                    Rectangle {
                        Layout.preferredWidth: 55
                        Layout.preferredHeight: 3
                        radius: 2
                        color: AppTheme.colors.surfaceVariant

                        property real minAll: getDailyMinTemp()
                        property real maxAll: getDailyMaxTemp()
                        property real range: Math.max(1, maxAll - minAll)
                        property real startRatio: (modelData.minTemp - minAll) / range
                        property real spanRatio: (modelData.maxTemp - modelData.minTemp) / range

                        Rectangle {
                            x: parent.width * parent.startRatio
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.max(6, parent.width * parent.spanRatio)
                            height: parent.height
                            radius: 2
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: AppTheme.colors.primary
                                }
                                GradientStop {
                                    position: 1.0
                                    color: AppTheme.tint(AppTheme.colors.primary, 0.2)
                                }
                            }
                        }
                    }

                    Text {
                        text: modelData.maxTemp + settingsManager.temperatureUnit
                        font.pixelSize: 12
                        color: AppTheme.colors.text
                        Layout.preferredWidth: 30
                    }
                }
            }
        }
    }

    WeatherKeyboard {
        id: keyboardPanel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: root.keyboardHeight
        visible: locationInput.activeFocus
        onCharacterTyped: function(ch) { locationInput.text += ch }
        onBackspaceRequested: locationInput.text = locationInput.text.slice(0, -1)
        onSpaceRequested: locationInput.text += " "
        onSearchRequested: {
            searchLocation(locationInput.text);
            locationInput.focus = false;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: AppTheme.colors.surfaceVariant
        radius: 12
        border.width: 1
        border.color: AppTheme.colors.border
        visible: weatherData.isLoading || weatherData.hasError

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10

            BusyIndicator {
                running: weatherData.isLoading
                visible: weatherData.isLoading
            }

            Text {
                text: weatherData.hasError ? "Failed to load weather" : "Fetching weather data..."
                font.pixelSize: 13
                color: AppTheme.colors.text
                Layout.alignment: Qt.AlignHCenter
            }

            Button {
                text: "Retry"
                visible: weatherData.hasError
                onClicked: fetchWeatherData(weatherData.latitude, weatherData.longitude, weatherData.location)
            }
        }
    }

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
                    height: 10
                    radius: 2
                    color: "#FFD766"
                    anchors.centerIn: parent
                    rotation: index * 45
                    y: -18
                    opacity: 0.6
                }
            }

            Rectangle {
                width: 28
                height: 28
                radius: 14
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

            // Adjust cloud color to contrast against light theme surfaces
            property color baseCloudColor: AppTheme.isDark ? "#E9EFF6" : AppTheme.colors.textTertiary

            Rectangle {
                x: 10
                y: 30
                width: 42
                height: 16
                radius: 8
                color: parent.baseCloudColor
                opacity: 0.98
            }
            Rectangle {
                x: 2
                y: 34
                width: 22
                height: 14
                radius: 7
                color: parent.baseCloudColor
                opacity: 0.98
            }
            Rectangle {
                x: 28
                y: 34
                width: 24
                height: 14
                radius: 7
                color: parent.baseCloudColor
                opacity: 0.98
            }
            Rectangle {
                x: 16
                y: 24
                width: 22
                height: 14
                radius: 7
                color: AppTheme.isDark ? "#F4F7FB" : AppTheme.colors.textSecondary
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
            model: type === "rain" ? 4 : 0
            Rectangle {
                width: 3
                height: 10
                radius: 2
                color: AppTheme.colors.info
                x: 14 + index * 10
                y: 50
                opacity: 0.85

                SequentialAnimation on y {
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: 48
                        to: 62
                        duration: 700
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        from: 62
                        to: 48
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
            model: type === "fog" ? 3 : 0
            Rectangle {
                width: 42 - index * 6
                height: 2
                radius: 1
                color: AppTheme.isDark ? "#C7D6E3" : AppTheme.colors.textTertiary
                x: 6 + index * 3
                y: 48 + index * 6
                opacity: 0.6

                SequentialAnimation on x {
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: 4
                        to: 10
                        duration: 2000
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        from: 10
                        to: 4
                        duration: 2000
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }

    component WeatherInfoItem: ColumnLayout {
        property string label: ""
        property string value: ""
        property string iconSource: ""

        Layout.fillWidth: true
        spacing: 4

        Image {
            source: iconSource
            sourceSize.width: 18
            sourceSize.height: 18
            opacity: 0.5
            Layout.alignment: Qt.AlignHCenter
            layer.enabled: true
            layer.effect: ColorOverlay {
                color: AppTheme.colors.text
            }
        }

        Text {
            text: label
            font.pixelSize: 10
            color: AppTheme.colors.textSecondary
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: value
            font.pixelSize: 13
            font.weight: Font.DemiBold
            color: AppTheme.colors.text
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
