import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../theme"

Item {
    id: root
    clip: true

    //darken background to match cluster style
    Rectangle {
        anchors.fill: parent
        color: "#05080e"
    }

    // ---------- helpers ----------
    function safeNum(x) {
        return (x !== undefined && x !== null && !isNaN(x)) ? Number(x) : NaN;
    }
    function fmt(x, d, unit) {
        var n = safeNum(x);
        if (isNaN(n))
            return "--";
        return n.toFixed(d) + (unit || "");
    }
    function fmtInt(x, unit) {
        var n = safeNum(x);
        if (isNaN(n))
            return "--";
        return Math.round(n) + (unit || "");
    }

    // Online heuristics (replace with proper flags if you add them)
    property bool rpiOnline: !!piHealthReader && piHealthReader.isOnline
    property bool stmOnline: !!vehicleData && (vehicleData.stm32BatteryVoltage > 0 || vehicleData.stm32Battery > 0 || vehicleData.stm32Temperature !== 0 || vehicleData.stm32Humidity !== 0)

    property bool rpiWarn: rpiOnline && (piHealthReader.cpuTemp > 70 || piHealthReader.memoryPercent > 85 || piHealthReader.diskPercent > 90 || (safeNum(piHealthReader.batteryVoltage) < 11.0 || safeNum(piHealthReader.batteryVoltage) > 13.0) || safeNum(piHealthReader.batteryPercent) < 20)

    property bool stmWarn: stmOnline && (vehicleData.stm32Battery < 20 || vehicleData.stm32BatteryVoltage < 11.0 || vehicleData.stm32BatteryVoltage > 13.0 || vehicleData.stm32Temperature > 60 || vehicleData.stm32Humidity > 85)

    // ===== Layout (no scrolling) =====
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // ===== Header =====
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            spacing: 10

            Rectangle {
                width: 3
                height: 22
                radius: 2
                color: AppTheme.colors.primary
                opacity: 0.9
            }

            Text {
                text: "SYSTEM STATUS"
                font.pixelSize: 14
                font.weight: Font.Bold
                font.letterSpacing: 1
                color: AppTheme.colors.text
                opacity: 0.95
            }

            Item {
                Layout.fillWidth: true
            }

            // compact overall indicator
            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: (rpiOnline && stmOnline) ? "#00ff88" : (rpiOnline || stmOnline) ? "#ffb020" : "#ff4444"
                opacity: 0.9
            }
        }

        // ===== Cards container: must fit page =====
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            // ===== RPi Card (2 rows x 3 columns = 6 metrics) =====
            StatusCardCompact {
                Layout.fillWidth: true
                Layout.fillHeight: true

                title: "RASPBERRY PI 5"
                icon: "qrc:/icons/hardware/cpu.svg"
                online: rpiOnline
                warn: rpiWarn

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    columns: 3
                    rowSpacing: 10
                    columnSpacing: 10

                    MetricTileMini {
                        label: "CPU"
                        value: rpiOnline ? fmt(piHealthReader.cpuTemp, 0, "°") : "--"
                        warn: rpiOnline && piHealthReader.cpuTemp > 70
                    }
                    MetricTileMini {
                        label: "MEM"
                        value: rpiOnline ? fmtInt(piHealthReader.memoryPercent, "%") : "--"
                        warn: rpiOnline && piHealthReader.memoryPercent > 85
                    }
                    MetricTileMini {
                        label: "DISK"
                        value: rpiOnline ? fmtInt(piHealthReader.diskPercent, "%") : "--"
                        warn: rpiOnline && piHealthReader.diskPercent > 90
                    }

                    MetricTileMini {
                        label: "FREQ"
                        value: rpiOnline ? fmtInt(piHealthReader.cpuFreq, "MHz") : "--"
                        warn: false
                    }
                    MetricTileMini {
                        label: "BAT"
                        // expects PiHealthReader Q_PROPERTY batteryPercent
                        value: rpiOnline ? fmtInt(piHealthReader.batteryPercent, "%") : "--"
                        warn: rpiOnline && safeNum(piHealthReader.batteryPercent) < 20
                    }
                    MetricTileMini {
                        label: "VOLT"
                        // expects PiHealthReader Q_PROPERTY batteryVoltage
                        value: rpiOnline ? fmt(piHealthReader.batteryVoltage, 2, "V") : "--"
                        warn: rpiOnline && (safeNum(piHealthReader.batteryVoltage) < 11.0 || safeNum(piHealthReader.batteryVoltage) > 13.0)
                    }
                }
            }

            // ===== STM32 Card (2x2 = 4 metrics) =====
            StatusCardCompact {
                Layout.fillWidth: true
                Layout.fillHeight: true

                title: "STM32 HEALTH"
                icon: "qrc:/icons/hardware/mcu.svg"
                online: stmOnline
                warn: stmWarn

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    columns: 2
                    rowSpacing: 10
                    columnSpacing: 10

                    MetricTileMini {
                        label: "BATTERY"
                        value: stmOnline ? fmtInt(vehicleData.stm32Battery, "%") : "--"
                        warn: stmOnline && vehicleData.stm32Battery < 20
                    }
                    MetricTileMini {
                        label: "VOLTAGE"
                        value: stmOnline ? fmt(vehicleData.stm32BatteryVoltage, 2, "V") : "--"
                        warn: stmOnline && (vehicleData.stm32BatteryVoltage < 11.0 || vehicleData.stm32BatteryVoltage > 13.0)
                    }
                    MetricTileMini {
                        label: "TEMP"
                        value: stmOnline ? fmt(vehicleData.stm32Temperature, 1, "°C") : "--"
                        warn: stmOnline && vehicleData.stm32Temperature > 60
                    }
                    MetricTileMini {
                        label: "HUMIDITY"
                        value: stmOnline ? fmt(vehicleData.stm32Humidity, 0, "%") : "--"
                        warn: stmOnline && vehicleData.stm32Humidity > 85
                    }
                }
            }
        }
    }

    // ===== Card shell (compact; content fills remaining) =====
    component StatusCardCompact: Rectangle {
        required property string title
        required property string icon
        required property bool online
        required property bool warn
        default property alias content: contentArea.data

        radius: 10
        color: "#13171f"
        border.width: 1
        border.color: online ? "#1a4d5c" : "#242a33"
        opacity: online ? 1.0 : 0.72

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 18
            shadowOpacity: 0.18
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0

            // header strip
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                radius: 10
                color: "#0d1117"
                border.width: 1
                border.color: "#1a2533"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Image {
                        source: icon
                        sourceSize.width: 16
                        sourceSize.height: 16
                        opacity: 0.8
                    }

                    Text {
                        text: title
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        font.letterSpacing: 0.8
                        color: "#e6f0ff"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: online ? "#00ff88" : "#666666"
                    }

                    Rectangle {
                        visible: warn
                        radius: 999
                        height: 18
                        implicitWidth: warnText.implicitWidth + 14
                        color: "#2a1f10"
                        border.width: 1
                        border.color: "#7a4d1a"
                        Text {
                            id: warnText
                            anchors.centerIn: parent
                            text: "WARN"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: "#ffb36a"
                        }
                    }
                }
            }

            // content area
            Item {
                id: contentArea
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    component MetricTileMini: Rectangle {
        property string label: ""
        property string value: ""
        property bool warn: false

        radius: 8
        color: warn ? "#2d1a1a" : "#0d1117"
        border.width: 1
        border.color: warn ? "#5a2424" : "#1a2533"

        // Let GridLayout size the tiles naturally (no fixed heights!)
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 50   // small safety, won't explode the layout

        // tune these two to control label/value distance
        property int padTop: 10
        property int padBottom: 10

        Text {
            id: labelText
            text: label
            anchors.top: parent.top
            anchors.topMargin: padTop
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 9
            font.letterSpacing: 0.6
            color: "#6A7A8A"
        }

        Text {
            id: valueText
            text: value
            anchors.bottom: parent.bottom
            anchors.bottomMargin: padBottom
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 16
            font.weight: Font.Bold
            color: warn ? "#ff6644" : "#00BFFF"
            opacity: (value === "--") ? 0.55 : 1.0
            verticalAlignment: Text.AlignVCenter
        }
    }
}
