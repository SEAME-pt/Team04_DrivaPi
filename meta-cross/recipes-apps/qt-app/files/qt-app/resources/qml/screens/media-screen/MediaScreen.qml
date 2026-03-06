import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../theme"

Rectangle {
    id: root
    color: AppTheme.colors.surface // Automatically adapts to Light/Dark mode

    property bool compact: width < 520
    property int sideMargin: compact ? 10 : 16
    property int mainSpacing: compact ? 12 : 20
    property int albumArtWidth: compact ? 160 : 260
    property int titleSize: compact ? 16 : 20
    property int artistSize: compact ? 12 : 14
    property int timeSize: compact ? 11 : 12
    property int controlSize: compact ? 44 : 56
    property int playSize: compact ? 64 : 80
    property int iconSize: compact ? 20 : 24

    // Signal to notify parent when volume is being adjusted
    signal volumeInteractionChanged(bool interacting)

    // ====== MAIN LAYOUT ======
    GridLayout {
        anchors.fill: parent
        anchors.margins: sideMargin
        columnSpacing: mainSpacing
        rowSpacing: mainSpacing
        columns: compact ? 1 : 2

        // ====== LEFT: Album Art ======
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: !compact
            Layout.preferredWidth: compact ? -1 : albumArtWidth
            Layout.preferredHeight: compact ? 170 : -1

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: AppTheme.colors.surfaceElevated
                border.color: AppTheme.colors.border
                border.width: 1

                Image {
                    id: albumArt
                    anchors.fill: parent
                    anchors.margins: 8
                    source: musicPlayerController.albumArtUrl
                    fillMode: Image.PreserveAspectFit
                    visible: musicPlayerController.albumArtUrl.length > 0
                    smooth: true
                    asynchronous: true
                }

                // Fallback when no album art
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 8
                    visible: musicPlayerController.albumArtUrl.length === 0
                    radius: 8
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: getAlbumColor(musicPlayerController.currentTrackIndex)
                        }
                        GradientStop {
                            position: 1.0
                            color: AppTheme.tint(getAlbumColor(musicPlayerController.currentTrackIndex), 0.4)
                        }
                    }

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/icons/common/music-note.svg"
                        width: 64
                        height: 64
                        opacity: 0.5
                        layer.enabled: true
                        layer.effect: ColorOverlay { color: "#FFFFFF" }
                    }
                }
            }
        }

        // ====== RIGHT: Track Info + Controls ======
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 12

            // ====== TRACK INFO ======
            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true

                Text {
                    text: musicPlayerController.trackTitle.length > 0 ? musicPlayerController.trackTitle : "No Music"
                    color: AppTheme.colors.text
                    font.pixelSize: titleSize
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: musicPlayerController.artistName.length > 0 ? musicPlayerController.artistName : "Load MP3 files"
                    color: AppTheme.colors.textSecondary
                    font.pixelSize: artistSize
                    Layout.fillWidth: true
                }

                Text {
                    text: formatTime(musicPlayerController.position) + " / " + formatTime(musicPlayerController.duration)
                    color: AppTheme.colors.primary
                    font.pixelSize: timeSize
                    font.weight: Font.Medium
                    font.letterSpacing: 0.5
                }
            }

            // ====== PROGRESS BAR ======
            Rectangle {
                Layout.fillWidth: true
                height: compact ? 4 : 8
                radius: height / 2
                color: AppTheme.colors.surfaceVariant
                border.color: AppTheme.colors.divider
                border.width: 1

                Rectangle {
                    id: progressFill
                    width: musicPlayerController.duration > 0 ? parent.width * (musicPlayerController.position / musicPlayerController.duration) : 0
                    height: parent.height
                    radius: height / 2
                    color: AppTheme.colors.primary

                    Behavior on width {
                        enabled: !progressMouseArea.pressed
                        NumberAnimation { duration: 100 }
                    }
                }

                // Progress handle
                Rectangle {
                    id: progressHandle
                    width: 18
                    height: 18
                    radius: 9
                    color: progressMouseArea.pressed ? "#FFFFFF" : AppTheme.colors.primary
                    border.color: AppTheme.colors.surface
                    border.width: 3
                    x: progressFill.width - width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    visible: progressMouseArea.containsMouse || progressMouseArea.pressed

                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        radius: 4
                        color: "#40000000"
                    }
                }

                MouseArea {
                    id: progressMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true

                    onPressed: (mouse) => { updatePosition(mouse.x); mouse.accepted = true; }
                    onPositionChanged: (mouse) => { if (pressed) updatePosition(mouse.x); }

                    function updatePosition(x) {
                        if (musicPlayerController.duration > 0) {
                            var ratio = Math.max(0, Math.min(1, x / width));
                            musicPlayerController.setPosition(Math.round(ratio * musicPlayerController.duration));
                        }
                    }
                }
            }

            Item { Layout.fillHeight: !compact; Layout.preferredHeight: compact ? 6 : 0 }

            // ====== PLAYBACK CONTROLS ======
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: compact ? 10 : 20

                // Previous Button
                ControlCircle {
                    size: controlSize
                    icon: "qrc:/icons/controls/previous.svg"
                    onClicked: {
                        var wasPlaying = musicPlayerController.isPlaying;
                        musicPlayerController.previous();
                        if (wasPlaying) Qt.callLater(() => { if (!musicPlayerController.isPlaying) musicPlayerController.play(); });
                    }
                }

                // Play/Pause Button
                Rectangle {
                    width: playSize
                    height: playSize
                    radius: playSize / 2
                    color: AppTheme.colors.primary
                    scale: playMouse.pressed ? 0.92 : (playMouse.containsMouse ? 1.05 : 1.0)

                    // Outer Glow / Rings
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -6
                        radius: parent.radius + 3
                        color: "transparent"
                        border.color: AppTheme.colors.primary
                        border.width: 2
                        opacity: 0.2
                    }

                    Image {
                        anchors.centerIn: parent
                        source: musicPlayerController.isPlaying ? "qrc:/icons/controls/pause.svg" : "qrc:/icons/controls/play.svg"
                        width: compact ? 26 : 32
                        height: compact ? 26 : 32
                        layer.enabled: true
                        layer.effect: ColorOverlay { color: "#FFFFFF" }
                    }

                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: musicPlayerController.togglePlayPause()
                    }

                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                }

                // Next Button
                ControlCircle {
                    size: controlSize
                    icon: "qrc:/icons/controls/next.svg"
                    onClicked: {
                        var wasPlaying = musicPlayerController.isPlaying;
                        musicPlayerController.next();
                        if (wasPlaying) Qt.callLater(() => { if (!musicPlayerController.isPlaying) musicPlayerController.play(); });
                    }
                }
            }

            // ====== VOLUME CONTROL ======
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                property real previousVolume: 50

                Item {
                    width: iconSize + 8
                    height: iconSize + 8

                    Image {
                        anchors.centerIn: parent
                        source: musicPlayerController.volume > 0 ? "qrc:/icons/controls/volume-high.svg" : "qrc:/icons/controls/volume-mute.svg"
                        width: iconSize
                        height: iconSize
                        layer.enabled: true
                        layer.effect: ColorOverlay { color: AppTheme.colors.textSecondary }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (musicPlayerController.volume > 0) {
                                parent.parent.previousVolume = musicPlayerController.volume;
                                musicPlayerController.volume = 0;
                            } else {
                                musicPlayerController.volume = parent.parent.previousVolume || 50;
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    height: 32

                    Rectangle {
                        id: volumeTrack
                        anchors.centerIn: parent
                        width: parent.width
                        height: 6
                        radius: 3
                        color: AppTheme.colors.surfaceVariant

                        Rectangle {
                            width: parent.width * (musicPlayerController.volume / 100)
                            height: parent.height
                            radius: 3
                            color: AppTheme.colors.primary
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: (mouse) => { root.volumeInteractionChanged(true); updateVolume(mouse.x); }
                        onReleased: root.volumeInteractionChanged(false)
                        onPositionChanged: (mouse) => { if (pressed) updateVolume(mouse.x); }
                        function updateVolume(x) {
                            musicPlayerController.volume = Math.round(Math.max(0, Math.min(1, x / width)) * 100);
                        }
                    }
                }

                Text {
                    text: Math.round(musicPlayerController.volume) + "%"
                    color: AppTheme.colors.textSecondary
                    font.pixelSize: timeSize
                    Layout.preferredWidth: 35
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }

    // Helper Component for Next/Prev Buttons
    component ControlCircle: Rectangle {
        id: ctrl
        property alias icon: img.source
        property int size: 44
        signal clicked

        width: size
        height: size
        radius: size / 2
        color: AppTheme.colors.surfaceElevated
        border.color: AppTheme.colors.divider
        border.width: 1
        scale: mouse.pressed ? 0.9 : (mouse.containsMouse ? 1.05 : 1.0)

        Image {
            id: img
            anchors.centerIn: parent
            width: iconSize
            height: iconSize
            layer.enabled: true
            layer.effect: ColorOverlay { color: AppTheme.colors.text }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: ctrl.clicked()
        }

        Behavior on scale { NumberAnimation { duration: 100 } }
    }

    function formatTime(ms) {
        if (!ms || ms === 0) return "0:00";
        var totalSeconds = Math.floor(ms / 1000);
        var minutes = Math.floor(totalSeconds / 60);
        var seconds = totalSeconds % 60;
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
    }

    function getAlbumColor(index) {
        var colors = [AppTheme.colors.primary, AppTheme.colors.info, AppTheme.colors.success];
        return colors[index % colors.length];
    }
}
