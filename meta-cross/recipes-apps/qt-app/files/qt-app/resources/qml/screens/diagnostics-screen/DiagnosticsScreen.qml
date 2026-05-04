import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../theme"

Item {
    id: root
    clip: true

    // Darken background to match cluster style - now theme-aware
    Rectangle {
        anchors.fill: parent
        color: AppTheme.isDark ? AppTheme.colors.surfaceVariant : AppTheme.colors.surface
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
    function getTemp(c) {
        var val = safeNum(c);
        if (isNaN(val))
            return NaN;

        if (settingsManager.temperatureUnit === "°F") {
            return (val * 9 / 5) + 32;
        } else if (settingsManager.temperatureUnit === "K") {
            return val + 273.15;
        }
        return val; // Base is °C
    }

    // Online heuristics
    property bool rpiOnline: !!piHealthReader && piHealthReader.isOnline
    property bool stmOnline: !!vehicleData && (vehicleData.stm32BatteryVoltage > 0 || vehicleData.stm32Battery > 0 || vehicleData.stm32Temperature !== 0 || vehicleData.stm32Humidity !== 0)

    // RPi UPS is a 2S2P pack: valid range is around 6.0V..8.4V
    property bool rpiWarn: rpiOnline && (vehicleData.rpiBatteryVoltage < 6.0 || vehicleData.rpiBatteryVoltage > 8.4 || vehicleData.rpiBattery < 20)

    property bool stmWarn: stmOnline && (vehicleData.stm32Battery < 20 || vehicleData.stm32BatteryVoltage < 11.0 || vehicleData.stm32BatteryVoltage > 13.0)

    // ===== Layout =====
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
            }

            Text {
                text: "SYSTEM STATUS"
                font.pixelSize: 14
                font.weight: Font.Bold
                font.letterSpacing: 1
                color: AppTheme.colors.text
            }

            Item {
                Layout.fillWidth: true
            }

            // Status LED
            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: (rpiOnline && stmOnline) ? AppTheme.colors.success : (rpiOnline || stmOnline) ? AppTheme.colors.warning : AppTheme.colors.error

                // Subtle glow in dark mode
                layer.enabled: AppTheme.isDark
                layer.effect: ShaderEffect {
                    // This creates a simple glow if needed, or use a Rectangle with opacity
                }
            }
        }

        // ===== Cards container =====
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            // ===== RPi Card =====
            StatusCardCompact {
                Layout.fillWidth: true
                Layout.fillHeight: true

                title: "RASPBERRY PI 5"
                icon: "qrc:/icons/hardware/cpu.svg"
                online: rpiOnline
                warn: rpiWarn

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    columns: 3
                    rowSpacing: 8
                    columnSpacing: 8

                    MetricTileMini {
                        label: "SOC"
                        value: rpiOnline ? fmtInt(vehicleData.rpiBattery, "%") : "--"
                        warn: rpiOnline && vehicleData.rpiBattery < 20
                    }
                    MetricTileMini {
                        label: "VOLT"
                        value: rpiOnline ? fmt(vehicleData.rpiBatteryVoltage, 2, "V") : "--"
                        warn: rpiOnline && (vehicleData.rpiBatteryVoltage < 6.0 || vehicleData.rpiBatteryVoltage > 8.4)
                    }
                    MetricTileMini {
                        label: "CURR"
                        value: rpiOnline ? fmt(vehicleData.rpiBatteryCurrent, 2, "A") : "--"
                    }

                    MetricTileMini {
                        label: "CPU"
                        value: rpiOnline ? fmt(getTemp(piHealthReader.cpuTemp), 0, settingsManager.temperatureUnit) : "--"
                        warn: rpiOnline && piHealthReader.cpuTemp > 70
                    }
                    MetricTileMini {
                        label: "FREQ"
                        value: rpiOnline ? fmtInt(piHealthReader.cpuFreq, "MHz") : "--"
                    }
                    MetricTileMini {
                        label: "MEM"
                        value: rpiOnline ? fmtInt(piHealthReader.memoryPercent, "%") : "--"
                        warn: rpiOnline && piHealthReader.memoryPercent > 85
                    }
                }
            }

            // ===== STM32 Card =====
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
                        label: "SOC"
                        value: stmOnline ? fmtInt(vehicleData.stm32Battery, "%") : "--"
                        warn: stmOnline && vehicleData.stm32Battery < 20
                    }
                    MetricTileMini {
                        label: "VOLT"
                        value: stmOnline ? fmt(vehicleData.stm32BatteryVoltage, 2, "V") : "--"
                        warn: stmOnline && (vehicleData.stm32BatteryVoltage < 11.0 || vehicleData.stm32BatteryVoltage > 13.0)
                    }
                    MetricTileMini {
                        label: "TEMP"
                        value: stmOnline ? fmt(getTemp(vehicleData.stm32Temperature), 1, settingsManager.temperatureUnit) : "--"
                        warn: stmOnline && vehicleData.stm32Temperature > 60
                    }
                    MetricTileMini {
                        label: "HUM"
                        value: stmOnline ? fmt(vehicleData.stm32Humidity, 0, "%") : "--"
                        warn: stmOnline && vehicleData.stm32Humidity > 85
                    }
                }
            }
        }
    }

    // ===== Card shell =====
}
