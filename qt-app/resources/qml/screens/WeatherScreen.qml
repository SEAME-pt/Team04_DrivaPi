import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    color: AppTheme.colors.surface

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AppTheme.spacing.large
        spacing: AppTheme.spacing.medium

        Text {
            text: "Weather Overview"
            font.pixelSize: AppTheme.typography.headlineSmall
            font.weight: Font.Bold
            color: AppTheme.colors.text
        }

        GridLayout {
            columns: 5
            rowSpacing: AppTheme.spacing.medium
            columnSpacing: AppTheme.spacing.medium
            Layout.fillWidth: true

            ColumnLayout {
                spacing: AppTheme.spacing.xsmall
                Layout.alignment: Qt.AlignHCenter

                Rectangle {
                    width: 64
                    height: 64
                    radius: AppTheme.radius.small
                    color: AppTheme.colors.surfaceVariant

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/icons/weather/sun.svg"
                        sourceSize.width: 32
                        sourceSize.height: 32
                    }
                }

                Text { text: "Clear"; color: AppTheme.colors.textSecondary; font.pixelSize: AppTheme.typography.labelSmall; Layout.alignment: Qt.AlignHCenter }
            }

            ColumnLayout {
                spacing: AppTheme.spacing.xsmall
                Layout.alignment: Qt.AlignHCenter

                Rectangle {
                    width: 64
                    height: 64
                    radius: AppTheme.radius.small
                    color: AppTheme.colors.surfaceVariant

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/icons/weather/cloud.svg"
                        sourceSize.width: 32
                        sourceSize.height: 32
                    }
                }

                Text { text: "Cloudy"; color: AppTheme.colors.textSecondary; font.pixelSize: AppTheme.typography.labelSmall; Layout.alignment: Qt.AlignHCenter }
            }

            ColumnLayout {
                spacing: AppTheme.spacing.xsmall
                Layout.alignment: Qt.AlignHCenter

                Rectangle {
                    width: 64
                    height: 64
                    radius: AppTheme.radius.small
                    color: AppTheme.colors.surfaceVariant

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/icons/weather/rain.svg"
                        sourceSize.width: 32
                        sourceSize.height: 32
                    }
                }

                Text { text: "Rain"; color: AppTheme.colors.textSecondary; font.pixelSize: AppTheme.typography.labelSmall; Layout.alignment: Qt.AlignHCenter }
            }

            ColumnLayout {
                spacing: AppTheme.spacing.xsmall
                Layout.alignment: Qt.AlignHCenter

                Rectangle {
                    width: 64
                    height: 64
                    radius: AppTheme.radius.small
                    color: AppTheme.colors.surfaceVariant

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/icons/weather/snow.svg"
                        sourceSize.width: 32
                        sourceSize.height: 32
                    }
                }

                Text { text: "Snow"; color: AppTheme.colors.textSecondary; font.pixelSize: AppTheme.typography.labelSmall; Layout.alignment: Qt.AlignHCenter }
            }

            ColumnLayout {
                spacing: AppTheme.spacing.xsmall
                Layout.alignment: Qt.AlignHCenter

                Rectangle {
                    width: 64
                    height: 64
                    radius: AppTheme.radius.small
                    color: AppTheme.colors.surfaceVariant

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/icons/weather/fog.svg"
                        sourceSize.width: 32
                        sourceSize.height: 32
                    }
                }

                Text { text: "Fog"; color: AppTheme.colors.textSecondary; font.pixelSize: AppTheme.typography.labelSmall; Layout.alignment: Qt.AlignHCenter }
            }
        }
    }
}
