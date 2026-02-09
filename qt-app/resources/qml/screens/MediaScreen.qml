import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import "../theme"

Rectangle {
    id: root
    color: "#05080e"  // Match cluster dark background

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
                radius: 8
                color: "#0a0f18"
                border.color: "#1a2535"
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
                    radius: 4
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: getAlbumColor(musicPlayerController.currentTrackIndex)
                        }
                        GradientStop {
                            position: 1.0
                            color: Qt.darker(getAlbumColor(musicPlayerController.currentTrackIndex), 1.5)
                        }
                    }

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/icons/common/music-note.svg"
                        width: 64
                        height: 64
                        opacity: 0.5
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
                    color: "#E0E0E0"
                    font.pixelSize: titleSize
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: musicPlayerController.artistName.length > 0 ? musicPlayerController.artistName : "Load MP3 files"
                    color: "#8FA4B8"
                    font.pixelSize: artistSize
                    Layout.fillWidth: true
                }

                Text {
                    text: formatTime(musicPlayerController.position) + " / " + formatTime(musicPlayerController.duration)
                    color: "#00BFFF"
                    font.pixelSize: timeSize
                    font.letterSpacing: 0.5
                }
            }

            // ====== PROGRESS BAR ======
            Rectangle {
                Layout.fillWidth: true
                height: compact ? 4 : 6
                radius: 3
                color: "#0a0f18"
                border.color: "#1a2535"
                border.width: 1

                Rectangle {
                    id: progressFill
                    width: musicPlayerController.duration > 0 ? parent.width * (musicPlayerController.position / musicPlayerController.duration) : 0
                    height: parent.height
                    radius: 3
                    color: "#00BFFF"

                    Behavior on width {
                        enabled: !progressMouseArea.pressed  // Disable animation when dragging
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }

                // Progress handle (shows when hovering/dragging)
                Rectangle {
                    id: progressHandle
                    width: 16
                    height: 16
                    radius: 8
                    color: progressMouseArea.pressed ? "#ffffff" : "#00BFFF"
                    border.color: "#0a0f18"
                    border.width: 2
                    x: progressFill.width - width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    visible: progressMouseArea.containsMouse || progressMouseArea.pressed

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }
                }

                MouseArea {
                    id: progressMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true  // Prevents SwipeView from stealing events
                    propagateComposedEvents: false

                    onPressed: function (mouse) {
                        updatePosition(mouse.x);
                        mouse.accepted = true;
                    }

                    onPositionChanged: function (mouse) {
                        if (pressed) {
                            updatePosition(mouse.x);
                        }
                        mouse.accepted = true;
                    }

                    onReleased: function (mouse) {
                        mouse.accepted = true;
                    }

                    function updatePosition(x) {
                        if (musicPlayerController.duration > 0) {
                            var ratio = Math.max(0, Math.min(1, x / width));
                            var newPosition = Math.round(ratio * musicPlayerController.duration);
                            console.log("Seeking to:", newPosition, "ms");
                            musicPlayerController.setPosition(newPosition);
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: !compact
                Layout.preferredHeight: compact ? 6 : 0
            }

            // ====== PLAYBACK CONTROLS ======
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: compact ? 10 : 16

                // Previous Button
                Rectangle {
                    width: controlSize
                    height: controlSize
                    radius: controlSize / 2
                    color: "#0a0f18"
                    border.color: "#1a2535"
                    border.width: 1

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/icons/controls/previous.svg"
                        width: iconSize
                        height: iconSize
                        sourceSize: Qt.size(iconSize, iconSize)
                        smooth: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var wasPlaying = musicPlayerController.isPlaying;
                            musicPlayerController.previous();
                            if (wasPlaying) {
                                Qt.callLater(function () {
                                    if (!musicPlayerController.isPlaying) {
                                        musicPlayerController.play();
                                    }
                                });
                            }
                        }

                        onEntered: parent.scale = 1.05
                        onExited: parent.scale = 1.0
                        onPressed: parent.scale = 0.95
                        onReleased: parent.scale = containsMouse ? 1.05 : 1.0
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutQuad
                        }
                    }
                }

                // Play/Pause Button (Large)
                Rectangle {
                    width: playSize
                    height: playSize
                    radius: playSize / 2
                    color: "#00BFFF"

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowBlur: 15
                        shadowColor: "#00BFFF40"
                        shadowOpacity: 0.8
                    }

                    Image {
                        anchors.centerIn: parent
                        source: musicPlayerController.isPlaying ? "qrc:/icons/controls/pause.svg" : "qrc:/icons/controls/play.svg"
                        width: compact ? 26 : 32
                        height: compact ? 26 : 32
                        sourceSize: Qt.size(compact ? 26 : 32, compact ? 26 : 32)
                        smooth: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: musicPlayerController.togglePlayPause()

                        onEntered: parent.scale = 1.05
                        onExited: parent.scale = 1.0
                        onPressed: parent.scale = 0.95
                        onReleased: parent.scale = containsMouse ? 1.05 : 1.0
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutQuad
                        }
                    }
                }

                // Next Button
                Rectangle {
                    width: controlSize
                    height: controlSize
                    radius: controlSize / 2
                    color: "#0a0f18"
                    border.color: "#1a2535"
                    border.width: 1

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/icons/controls/next.svg"
                        width: iconSize
                        height: iconSize
                        sourceSize: Qt.size(iconSize, iconSize)
                        smooth: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var wasPlaying = musicPlayerController.isPlaying;
                            musicPlayerController.next();
                            if (wasPlaying) {
                                Qt.callLater(function () {
                                    if (!musicPlayerController.isPlaying) {
                                        musicPlayerController.play();
                                    }
                                });
                            }
                        }

                        onEntered: parent.scale = 1.05
                        onExited: parent.scale = 1.0
                        onPressed: parent.scale = 0.95
                        onReleased: parent.scale = containsMouse ? 1.05 : 1.0
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }

            // ====== VOLUME CONTROL ======
            RowLayout {
                Layout.fillWidth: true
                spacing: compact ? 8 : 12

                property real previousVolume: 50  // Store previous volume for unmute

                // Volume icon with mute toggle
                Rectangle {
                    width: iconSize + 8
                    height: iconSize + 8
                    radius: 4
                    color: volumeIconMouseArea.containsMouse ? "#1a2535" : "transparent"

                    Image {
                        anchors.centerIn: parent
                        source: musicPlayerController.volume > 0 ? "qrc:/icons/controls/volume-high.svg" : "qrc:/icons/controls/volume-mute.svg"
                        width: iconSize
                        height: iconSize
                        sourceSize: Qt.size(iconSize, iconSize)
                        smooth: true
                    }

                    MouseArea {
                        id: volumeIconMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // Toggle mute
                            if (musicPlayerController.volume > 0) {
                                parent.parent.previousVolume = musicPlayerController.volume;
                                musicPlayerController.volume = 0;
                            } else {
                                musicPlayerController.volume = parent.parent.previousVolume || 50;
                            }
                        }
                    }
                }

                // Volume slider container (prevents swipe interference)
                Item {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    height: 40  // Larger hit area for easier interaction

                    // Volume slider background
                    Rectangle {
                        id: volumeTrack
                        anchors.centerIn: parent  // Center it vertically in the container
                        width: parent.width
                        height: compact ? 6 : 8  // Slightly taller so it's more visible
                        radius: 4
                        color: "#0a0f18"
                        border.color: "#1a2535"
                        border.width: 1

                        Rectangle {
                            id: volumeFill
                            width: parent.width * (musicPlayerController.volume / 100)
                            height: parent.height
                            radius: 4
                            color: "#00BFFF"

                            Behavior on width {
                                NumberAnimation {
                                    duration: 100
                                }
                            }
                        }
                    }

                    // Volume handle
                    Rectangle {
                        id: volumeHandle
                        width: 20
                        height: 20
                        radius: 10
                        color: volumeClickArea.pressed ? "#ffffff" : "#00BFFF"
                        border.color: "#0a0f18"
                        border.width: 2
                        x: volumeFill.width - width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        visible: volumeClickArea.containsMouse || volumeClickArea.pressed

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }
                        }

                        Behavior on x {
                            NumberAnimation {
                                duration: 100
                            }
                        }
                    }

                    // MouseArea on the track itself
                    MouseArea {
                        id: volumeClickArea
                        anchors.fill: parent
                        anchors.margins: -15  // Expand hit area
                        hoverEnabled: true
                        preventStealing: true  // Prevents SwipeView from stealing events
                        propagateComposedEvents: false

                        onPressed: function (mouse) {
                            root.volumeInteractionChanged(true);
                            updateVolume(mouse.x);
                            mouse.accepted = true;
                        }

                        onReleased: function (mouse) {
                            root.volumeInteractionChanged(false);
                            mouse.accepted = true;
                        }

                        onPositionChanged: function (mouse) {
                            if (pressed) {
                                updateVolume(mouse.x);
                            }
                            mouse.accepted = true;
                        }

                        function updateVolume(x) {
                            // x is relative to this MouseArea
                            var ratio = Math.max(0, Math.min(1, x / width));
                            var newValue = Math.round(ratio * 100);
                            console.log("Setting volume to:", newValue);
                            musicPlayerController.volume = newValue;
                        }
                    }
                }
            }

            // Volume percentage (MOVED INSIDE RowLayout)
            Text {
                text: Math.round(musicPlayerController.volume) + "%"
                color: "#8FA4B8"
                font.pixelSize: timeSize
                font.weight: Font.Medium
                Layout.preferredWidth: 35
                horizontalAlignment: Text.AlignRight
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    function formatTime(ms) {
        if (!ms || ms === 0)
            return "0:00";
        var totalSeconds = Math.floor(ms / 1000);
        var minutes = Math.floor(totalSeconds / 60);
        var seconds = totalSeconds % 60;
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
    }

    function getAlbumColor(index) {
        var colors = ["#FF6B35", "#004E89", "#1AE5BE"];
        return colors[index % colors.length];
    }
}
