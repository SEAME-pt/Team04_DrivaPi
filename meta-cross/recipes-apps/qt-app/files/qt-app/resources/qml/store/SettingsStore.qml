pragma Singleton
import QtQuick
import Qt.labs.settings

QtObject {
    Settings {
        id: persisted
        category: "Settings"

        property string themeMode: "Dark"
        property real screenBrightness: 0.75
        property string speedUnit: "km/h"
        property string temperatureUnit: "°C"
        property string distanceUnit: "km"
        property string windSpeedUnit: "m/s"
        property string precipitationUnit: "mm"
    }

    property alias themeMode: persisted.themeMode
    property alias screenBrightness: persisted.screenBrightness
    property alias speedUnit: persisted.speedUnit
    property alias temperatureUnit: persisted.temperatureUnit
    property alias distanceUnit: persisted.distanceUnit
    property alias windSpeedUnit: persisted.windSpeedUnit
    property alias precipitationUnit: persisted.precipitationUnit
}