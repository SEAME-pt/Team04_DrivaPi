import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    color: AppTheme.colors.surface

    // ====== MAIN LAYOUT (LEFT: Album Art + RIGHT: Controls) ======
    RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        // ====== LEFT: Album Art Area ======
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.35
            color: AppTheme.colors.surfaceVariant

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.medium
                spacing: AppTheme.spacing.medium

                // Album art
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: AppTheme.radius.medium
                    color: "#1a2a3a"

                    Image {
                        anchors.fill: parent
                        source: musicPlayerController.albumArtUrl
                        fillMode: Image.PreserveAspectCrop
                        visible: musicPlayerController.albumArtUrl.length > 0
                        smooth: true
                        asynchronous: true
                    }

                    // Fallback gradient when no album art
                    Rectangle {
                        anchors.fill: parent
                        visible: musicPlayerController.albumArtUrl.length === 0
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
                    }

                    Image {
                        source: "qrc:/icons/common/music-note.svg"
                        width: 64
                        height: 64
                        anchors.centerIn: parent
                        visible: musicPlayerController.albumArtUrl.length === 0
                    }
                }
            }
        }

        // ====== RIGHT: Track Info + Controls ======
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: AppTheme.colors.surface

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacing.large
                spacing: AppTheme.spacing.medium

                // ====== TRACK INFO ======
                ColumnLayout {
                    spacing: AppTheme.spacing.small
                    Layout.fillWidth: true

                    // Song title
                    Text {
                        text: musicPlayerController.trackTitle.length > 0 ? musicPlayerController.trackTitle : "No Music"
                        color: AppTheme.colors.text
                        font.pixelSize: AppTheme.typography.headlineSmall
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    // Artist name
                    Text {
                        text: musicPlayerController.artistName.length > 0 ? musicPlayerController.artistName : "Load MP3 files"
                        color: AppTheme.colors.textSecondary
                        font.pixelSize: AppTheme.typography.bodyMedium
                    }

                    // Track progress
                    Text {
                        text: formatTime(musicPlayerController.position) + " / " + formatTime(musicPlayerController.duration)
                        color: AppTheme.colors.textTertiary
                        font.pixelSize: AppTheme.typography.bodySmall
                    }
                }

                // ====== TIME SLIDER ======
                ColumnLayout {
                    spacing: AppTheme.spacing.small
                    Layout.fillWidth: true

                    // Progress bar
                    Rectangle {
                        Layout.fillWidth: true
                        height: 4
                        radius: 2
                        color: AppTheme.colors.surfaceVariant

                        Rectangle {
                            width: musicPlayerController.duration > 0 ? parent.width * (musicPlayerController.position / musicPlayerController.duration) : 0
                            height: parent.height
                            radius: 2
                            color: AppTheme.colors.primary
                        }
                    }

                    // Time display
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.small

                        Text {
                            text: formatTime(musicPlayerController.position)
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: formatTime(musicPlayerController.duration)
                            color: AppTheme.colors.textSecondary
                            font.pixelSize: AppTheme.typography.labelSmall
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                // ====== PLAYBACK CONTROLS ======
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    spacing: AppTheme.spacing.medium

                    // Previous
                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: AppTheme.radius.small
                        color: AppTheme.colors.surfaceVariant

                        Image {
                            source: "qrc:/icons/controls/previous.svg"
                            width: 24
                            height: 24
                            sourceSize: Qt.size(24, 24)
                            anchors.centerIn: parent
                        }

                        TapHandler {
                            onTapped: musicPlayerController.previous()
                        }
                    }

                    // Play/Pause (large)
                    Rectangle {
                        id: playPauseBtn
                        Layout.preferredWidth: 64
                        Layout.preferredHeight: 64
                        radius: AppTheme.radius.medium
                        color: AppTheme.colors.primary

                        Image {
                            source: musicPlayerController.isPlaying ? "qrc:/icons/controls/pause.svg" : "qrc:/icons/controls/play.svg"
                            width: 32
                            height: 32
                            sourceSize: Qt.size(32, 32)
                            anchors.centerIn: parent
                        }

                        TapHandler {
                            onTapped: musicPlayerController.togglePlayPause()
                        }
                    }

                    // Next
                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: AppTheme.radius.small
                        color: AppTheme.colors.surfaceVariant

                        Image {
                            source: "qrc:/icons/controls/next.svg"
                            width: 24
                            height: 24
                            sourceSize: Qt.size(24, 24)
                            anchors.centerIn: parent
                        }

                        TapHandler {
                            onTapped: musicPlayerController.next()
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Shuffle
                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: AppTheme.radius.small
                        color: AppTheme.colors.surfaceVariant

                        Image {
                            source: "qrc:/icons/controls/shuffle.svg"
                            width: 20
                            height: 20
                            sourceSize: Qt.size(20, 20)
                            anchors.centerIn: parent
                        }
                    }

                    // Repeat
                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: AppTheme.radius.small
                        color: AppTheme.colors.surfaceVariant

                        Image {
                            source: "qrc:/icons/controls/repeat.svg"
                            width: 20
                            height: 20
                            sourceSize: Qt.size(20, 20)
                            anchors.centerIn: parent
                        }
                    }
                }

                // ====== VOLUME CONTROL ======
                ColumnLayout {
                    spacing: AppTheme.spacing.small
                    Layout.fillWidth: true

                    Text {
                        text: "Volume"
                        color: AppTheme.colors.textSecondary
                        font.pixelSize: AppTheme.typography.labelSmall
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacing.small

                        Image {
                            source: "qrc:/icons/controls/volume-mute.svg"
                            width: 20
                            height: 20
                            sourceSize: Qt.size(20, 20)
                        }

                        // Volume slider
                        Rectangle {
                            Layout.fillWidth: true
                            height: 4
                            radius: 2
                            color: AppTheme.colors.surfaceVariant

                            Rectangle {
                                width: parent.width * 0.75
                                height: parent.height
                                radius: 2
                                color: AppTheme.colors.primary
                            }
                        }

                        Image {
                            source: "qrc:/icons/controls/volume-high.svg"
                            width: 20
                            height: 20
                            sourceSize: Qt.size(20, 20)
                        }
                    }
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
