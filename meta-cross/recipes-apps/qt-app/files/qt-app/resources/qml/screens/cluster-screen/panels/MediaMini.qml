/**
 * @file MediaMini.qml
 * @author DrivaPi Team
 * @brief Compact media panel showing album art and track info for the cluster SwipeView
 */

import QtQuick
import QtQuick.Controls
import "../../../theme"

Item {
    id: root

    property real s: 1.0
    property int  fontSizeSmall:  18
    property int  fontSizeXSmall: 13
    property color albumColor: "#1e90ff"

    implicitWidth:  column.width
    implicitHeight: column.height

    Column {
        id: column
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: AppTheme.spacing.small

        // Album art box
        Rectangle {
            id: albumArtBox
            width:  102 * root.s
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            radius: AppTheme.radius.medium
            color: AppTheme.colors.surfaceElevated
            clip: true

            Image {
                anchors.fill: parent
                source: musicPlayerController.albumArtUrl
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
                visible: musicPlayerController.albumArtUrl.length > 0
            }

            Rectangle {
                anchors.fill: parent
                color: AppTheme.colors.surface
                opacity: 0.18
            }

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: AppTheme.alpha(AppTheme.colors.surfaceElevated, 0.4) }
                    GradientStop { position: 0.5; color: AppTheme.alpha(AppTheme.colors.surface, 0.0) }
                    GradientStop { position: 1.0; color: AppTheme.alpha(AppTheme.colors.surface, 0.5) }
                }
                opacity: 0.25
            }

            // Fallback colour gradient when no album art
            Rectangle {
                anchors.fill: parent
                visible: musicPlayerController.albumArtUrl.length === 0
                gradient: Gradient {
                    GradientStop { position: 0.0; color: root.albumColor }
                    GradientStop { position: 1.0; color: Qt.darker(root.albumColor, 1.5) }
                }
            }

            Image {
                source: "qrc:/icons/common/music-note.svg"
                width:  64 * root.s
                height: 64 * root.s
                anchors.centerIn: parent
                visible: musicPlayerController.albumArtUrl.length === 0
            }
        }

        // Track title
        Text {
            width: albumArtBox.width
            text: musicPlayerController.trackTitle.length > 0 ? musicPlayerController.trackTitle : "No Music"
            color: AppTheme.colors.text
            font.pixelSize: root.fontSizeSmall * root.s
            font.weight: Font.Bold
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }

        // Artist name
        Text {
            width: albumArtBox.width
            text: musicPlayerController.artistName.length > 0 ? musicPlayerController.artistName : "Local Music"
            color: AppTheme.colors.textSecondary
            font.pixelSize: root.fontSizeXSmall * root.s
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
