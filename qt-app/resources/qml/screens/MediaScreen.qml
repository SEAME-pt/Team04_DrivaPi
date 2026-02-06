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
                        GradientStop { position: 0.0; color: "#FF6B35" }
                        GradientStop { position: 1.0; color: "#C44D20" }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "♪"
                        font.pixelSize: 64
                        color: "#FFFFFF"
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
                    width: musicPlayerController.duration > 0 ? parent.width * (musicPlayerController.position / musicPlayerController.duration) : 0
                    height: parent.height
                    radius: 3
                    color: "#00BFFF"
                    
                    Behavior on width {
                        NumberAnimation { duration: 100 }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (musicPlayerController.duration > 0) {
                            var newPosition = (mouse.x / width) * musicPlayerController.duration
                            musicPlayerController.seek(newPosition)
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
                        onClicked: musicPlayerController.previous()
                        
                        onEntered: parent.scale = 1.05
                        onExited: parent.scale = 1.0
                        onPressed: parent.scale = 0.95
                        onReleased: parent.scale = containsMouse ? 1.05 : 1.0
                    }
                    
                    Behavior on scale {
                        NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
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
                        NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
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
                        onClicked: musicPlayerController.next()
                        
                        onEntered: parent.scale = 1.05
                        onExited: parent.scale = 1.0
                        onPressed: parent.scale = 0.95
                        onReleased: parent.scale = containsMouse ? 1.05 : 1.0
                    }
                    
                    Behavior on scale {
                        NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                    }
                }
            }

            // ====== VOLUME CONTROL ======
            RowLayout {
                Layout.fillWidth: true
                spacing: compact ? 8 : 12

                Image {
                    source: "qrc:/icons/controls/volume-mute.svg"
                    width: compact ? 16 : 20
                    height: compact ? 16 : 20
                    sourceSize: Qt.size(compact ? 16 : 20, compact ? 16 : 20)
                    smooth: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: compact ? 4 : 6
                    radius: 3
                    color: "#0a0f18"
                    border.color: "#1a2535"
                    border.width: 1

                    Rectangle {
                        id: volumeFill
                        width: parent.width * 0.7
                        height: parent.height
                        radius: 3
                        color: "#00BFFF"
                        
                        Behavior on width {
                            NumberAnimation { duration: 100 }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var volume = mouse.x / width
                            musicPlayerController.setVolume(volume)
                            volumeFill.width = parent.width * volume
                        }
                    }
                }

                Image {
                    source: "qrc:/icons/controls/volume-high.svg"
                    width: compact ? 16 : 20
                    height: compact ? 16 : 20
                    sourceSize: Qt.size(compact ? 16 : 20, compact ? 16 : 20)
                    smooth: true
                }
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
        var colors = ["#FF6B35", "#004E89", "#1AE5BE"];  // Orange, Blue, Teal
        return colors[index % colors.length];
    }
}
