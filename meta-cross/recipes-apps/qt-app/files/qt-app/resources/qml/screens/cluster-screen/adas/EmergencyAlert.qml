/**
 * @file EmergencyAlert.qml
 * @author DrivaPi Team
 * @brief V2X Emergency Vehicle Priority Alert Overlay
 */

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../../theme"

Item {
    id: root

    property bool isActive: false
    property string alertMessage: "EMERGENCY VEHICLE"
    property real s: 1.0

    width: 480 * s
    height: 72 * s

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: isActive ? (80 * s) : (-height - 20)

    opacity: isActive ? 1.0 : 0.0

    Behavior on anchors.topMargin {
        NumberAnimation { duration: AppTheme.animation.normal; easing.type: Easing.OutBack }
    }
    Behavior on opacity {
        NumberAnimation { duration: AppTheme.animation.fast }
    }

    // Efeito de pulso externo (Glow) - Não afeta a legibilidade do texto
    Rectangle {
        id: pulseBorder
        anchors.fill: parent
        anchors.margins: -4 * root.s
        radius: AppTheme.radius.medium + (4 * root.s)
        color: "transparent"
        border.color: AppTheme.colors.error
        border.width: 3 * root.s
        opacity: 0.0

        SequentialAnimation on opacity {
            running: root.isActive
            loops: Animation.Infinite
            NumberAnimation { to: 0.65; duration: 600; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 0.0; duration: 600; easing.type: Easing.InOutQuad }
        }
    }

    // Fundo principal do alerta (Opacidade Estável)
    Rectangle {
        id: alertBackground
        anchors.fill: parent
        radius: AppTheme.radius.medium
        color: AppTheme.colors.error
        border.color: AppTheme.colors.surfaceElevated
        border.width: 2 * root.s

        layer.enabled: !AppTheme.isDark
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 8
            samples: 17
            color: AppTheme.alpha(AppTheme.colors.error, 0.6)
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: AppTheme.spacing.medium * root.s
            spacing: AppTheme.spacing.medium * root.s

            Image {
                source: "qrc:/icons/hardware/sensor.svg"
                Layout.preferredWidth: 32 * root.s
                Layout.preferredHeight: 32 * root.s
                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: "#FFFFFF"
                }
            }

            Text {
                text: root.alertMessage
                color: "#FFFFFF"
                style: Text.Outline
                styleColor: "#80000000"
                font.family: AppTheme.typography.fontFamily
                font.pixelSize: Math.max(18, AppTheme.typography.headlineMedium * root.s)
                font.weight: Font.ExtraBold
                font.letterSpacing: 2.0
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Item { Layout.preferredWidth: 32 * root.s }
        }
    }
}
