import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Item {
    id: root
    clip: true

    // ---- Theme fallback (works even if AppTheme singleton is missing on Yocto) ----
    QtObject {
        id: Theme
        property var colors: (typeof AppTheme !== "undefined" && AppTheme.colors) ? AppTheme.colors : ({
                primary: "#00BFFF",
                surface: "#05080e",
                text: "#e6f0ff",
                textSecondary: "#8FA4B8",
                info: "#1a4d5c",
                warning: "#ffb020",
                error: "#ff4444"
            })
        property var spacing: (typeof AppTheme !== "undefined" && AppTheme.spacing) ? AppTheme.spacing : ({
                small: 6,
                medium: 12,
                large: 16
            })
        property var radius: (typeof AppTheme !== "undefined" && AppTheme.radius) ? AppTheme.radius : ({
                medium: 10
            })
        property var typography: (typeof AppTheme !== "undefined" && AppTheme.typography) ? AppTheme.typography : ({
                bodyMedium: 14
            })
    }

    // darken background to match cluster style
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

    // Online heuristics
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
                color: Theme.colors.primary
                opacity: 0.9
            }

            Text {
                text: "SYSTEM STATUS"
                font.pixelSize: 14
                font.weight: Font.Bold
                font.letterSpacing: 1
                color: Theme.colors.text
                opacity: 0.95
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: (rpiOnline && stmOnline) ? "#00ff88" : (rpiOnline || stmOnline) ? "#ffb020" : "#ff4444"
                opacity: 0.9
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

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
                        value: rpiOnline ? fmtInt(piHealthReader.batteryPercent, "%") : "--"
                        warn: rpiOnline && safeNum(piHealthReader.batteryPercent) < 20
                    }
                    MetricTileMini {
                        label: "VOLT"
                        value: rpiOnline ? fmt(piHealthReader.batteryVoltage, 2, "V") : "--"
                        warn: rpiOnline && (safeNum(piHealthReader.batteryVoltage) < 11.0 || safeNum(piHealthReader.batteryVoltage) > 13.0)
                    }
                }
            }

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

    component StatusCardCompact: Item {
        required property string title
        required property string icon
        required property bool online
        required property bool warn
        default property alias content: contentArea.data

        Rectangle {
            anchors.fill: card
            anchors.margins: -2
            radius: 12
            color: "#000"
            opacity: 0.22
            z: 0
        }
        Rectangle {
            anchors.fill: card
            anchors.margins: -6
            radius: 16
            color: "#000"
            opacity: 0.10
            z: 0
        }

        Rectangle {
            id: card
            anchors.fill: parent
            radius: 10
            color: "#13171f"
            border.width: 1
            border.color: online ? "#1a4d5c" : "#242a33"
            opacity: online ? 1.0 : 0.72
            z: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

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
                            color: Theme.colors.text
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: online ? "#00ff88" : "#666"
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

                Item {
                    id: contentArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
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

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 50

        property int padTop: 10
        property int padBottom: 10

        Text {
            text: label
            anchors.top: parent.top
            anchors.topMargin: padTop
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 9
            font.letterSpacing: 0.6
            color: "#6A7A8A"
        }

        Text {
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
