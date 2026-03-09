/**
 * @file CustomComboBox.qml
 * @author DrivaPi Team
 * @brief Themed ComboBox with styled background, indicator arrow, and popup
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../theme"

ComboBox {
    id: combo

    Layout.fillWidth:    true
    Layout.preferredHeight: 28
    font.pixelSize: 11

    contentItem: Text {
        text: combo.displayText
        color: AppTheme.colors.text
        verticalAlignment: Text.AlignVCenter
        leftPadding: 10
        font: combo.font
    }

    background: Rectangle {
        radius:       8
        color:        AppTheme.colors.surfaceElevated
        border.color: combo.activeFocus ? AppTheme.colors.primary : AppTheme.colors.border
        border.width: 1
    }

    indicator: Canvas {
        x: combo.width - width - 10
        y: (combo.height - height) / 2
        width: 8; height: 6
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.moveTo(0, 0);
            ctx.lineTo(width, 0);
            ctx.lineTo(width / 2, height);
            ctx.closePath();
            ctx.fillStyle = AppTheme.colors.primary;
            ctx.fill();
        }
    }

    delegate: ItemDelegate {
        width: combo.width
        height: 28
        contentItem: Text {
            text: modelData
            color: highlighted ? "#FFFFFF" : AppTheme.colors.text
            font.pixelSize: 11
            verticalAlignment: Text.AlignVCenter
            leftPadding: 10
        }
        background: Rectangle {
            color: highlighted ? AppTheme.colors.primary : "transparent"
        }
    }

    popup: Popup {
        y: combo.height + 4
        width: combo.width
        padding: 4
        background: Rectangle {
            radius:       8
            color:        AppTheme.colors.surfaceElevated
            border.color: AppTheme.colors.border
            border.width: 1
            layer.enabled: !AppTheme.isDark
            layer.effect: DropShadow { radius: 8; color: "#20000000"; samples: 17 }
        }
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: combo.delegateModel
        }
    }
}
