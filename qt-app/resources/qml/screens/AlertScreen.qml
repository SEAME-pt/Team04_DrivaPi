import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    color: AppTheme.colors.surface
    
    // ====== MAIN LAYOUT ======
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0
        
        // ====== HEADER ======
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: AppTheme.colors.surfaceElevated
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: AppTheme.spacing.large
                anchors.rightMargin: AppTheme.spacing.large
                spacing: AppTheme.spacing.large
                
                Text {
                    text: "Alerts & Notifications"
                    font.pixelSize: AppTheme.typography.headlineSmall
                    font.weight: Font.Bold
                    color: AppTheme.colors.text
                }
                
                Item { Layout.fillWidth: true }
                
                // Alert count badge
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: AppTheme.colors.warning
                    
                    Text {
                        text: "5"
                        font.pixelSize: AppTheme.typography.bodyMedium
                        font.weight: Font.Bold
                        color: AppTheme.colors.surface
                        anchors.centerIn: parent
                    }
                }
            }
        }
        
        // ====== DIVIDER ======
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: AppTheme.colors.divider
        }
        
        // ====== SCROLLABLE ALERTS ======
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: alertsContent.height
            clip: true
            
            ColumnLayout {
                id: alertsContent
                width: parent.width
                spacing: 0
                
                // ====== CRITICAL ALERTS ======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    color: AppTheme.colors.surfaceVariant
                    
                    Text {
                        text: "CRITICAL ALERTS"
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                        color: AppTheme.colors.textSecondary
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.spacing.large
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                AlertItem {
                    icon: "qrc:/icons/status/warning-icon-red.svg"
                    title: "Critical System Failure"
                    message: "Motor control system malfunction detected"
                    timestamp: "Just now"
                    severity: "critical"
                }
                
                // ====== WARNING ALERTS ======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    color: AppTheme.colors.surfaceVariant
                    
                    Text {
                        text: "WARNING ALERTS"
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                        color: AppTheme.colors.textSecondary
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.spacing.large
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                AlertItem {
                    icon: "qrc:/icons/status/warning.svg"
                    title: "High Temperature"
                    message: "Battery temperature approaching threshold (65°C)"
                    timestamp: "5 min ago"
                    severity: "warning"
                }
                
                AlertItem {
                    icon: "qrc:/icons/status/warning-icon.svg"
                    title: "Low Battery"
                    message: "Battery charge at 25%, recommend charging"
                    timestamp: "12 min ago"
                    severity: "warning"
                }
                
                AlertItem {
                    icon: "qrc:/icons/status/offline-dot.svg"
                    title: "Connection Lost"
                    message: "KUKSA server connection interrupted"
                    timestamp: "3 min ago"
                    severity: "warning"
                }
                
                // ====== INFO ALERTS ======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    color: AppTheme.colors.surfaceVariant
                    
                    Text {
                        text: "INFORMATIONAL"
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                        color: AppTheme.colors.textSecondary
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.spacing.large
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                AlertItem {
                    icon: "qrc:/icons/status/info.svg"
                    title: "Software Update Available"
                    message: "New version v1.5.0 is available for download"
                    timestamp: "1 hour ago"
                    severity: "info"
                }
                
                AlertItem {
                    icon: "qrc:/icons/status/check.svg"
                    title: "Diagnostics Complete"
                    message: "All system checks passed successfully"
                    timestamp: "2 hours ago"
                    severity: "success"
                }
                
                // ====== OPERATION ALERTS ======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    color: AppTheme.colors.surfaceVariant
                    
                    Text {
                        text: "ONGOING OPERATIONS"
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                        color: AppTheme.colors.textSecondary
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.spacing.large
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                AlertItem {
                    icon: "qrc:/icons/status/spinner.svg"
                    title: "Data Sync in Progress"
                    message: "Uploading telemetry data to cloud (234/512 items)"
                    timestamp: "Currently running"
                    severity: "info"
                    isLoading: true
                }
                
                AlertItem {
                    icon: "qrc:/icons/status/download.svg"
                    title: "Firmware Download"
                    message: "New firmware available: v1.5.0 (45% downloaded)"
                    timestamp: "3 min remaining"
                    severity: "info"
                }
                
                // ====== SUCCESS NOTIFICATIONS ======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    color: AppTheme.colors.surfaceVariant
                    
                    Text {
                        text: "RECENT COMPLETIONS"
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                        color: AppTheme.colors.textSecondary
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.spacing.large
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                AlertItem {
                    icon: "qrc:/icons/status/success-circle.svg"
                    title: "Upload Complete"
                    message: "Log file successfully uploaded (125 MB)"
                    timestamp: "30 min ago"
                    severity: "success"
                }
                
                AlertItem {
                    icon: "qrc:/icons/status/upload.svg"
                    title: "Configuration Saved"
                    message: "All settings have been backed up to storage"
                    timestamp: "1 hour ago"
                    severity: "success"
                }
                
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: AppTheme.spacing.large
                }
            }
        }
    }
    
    // ====== ALERT ITEM COMPONENT ======
    component AlertItem: Rectangle {
        property string icon: ""
        property string title: ""
        property string message: ""
        property string timestamp: ""
        property string severity: "info" // info, warning, critical, success
        property bool isLoading: false
        
        Layout.fillWidth: true
        Layout.leftMargin: AppTheme.spacing.large
        Layout.rightMargin: AppTheme.spacing.large
        Layout.topMargin: AppTheme.spacing.small
        Layout.preferredHeight: 90
        
        color: {
            switch(severity) {
                case "critical": return AppTheme.colors.error.concat("20")
                case "warning": return AppTheme.colors.warning.concat("20")
                case "success": return AppTheme.colors.online.concat("20")
                default: return AppTheme.colors.surfaceVariant
            }
        }
        
        radius: AppTheme.radius.small
        border.width: 1
        border.color: {
            switch(severity) {
                case "critical": return AppTheme.colors.error
                case "warning": return AppTheme.colors.warning
                case "success": return AppTheme.colors.online
                default: return AppTheme.colors.divider
            }
        }
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: AppTheme.spacing.medium
            spacing: AppTheme.spacing.medium
            
            // Icon section
            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: AppTheme.radius.small
                color: {
                    switch(severity) {
                        case "critical": return AppTheme.colors.error
                        case "warning": return AppTheme.colors.warning
                        case "success": return AppTheme.colors.online
                        default: return AppTheme.colors.primary
                    }
                }
                
                Image {
                    source: icon
                    sourceSize.width: 24
                    sourceSize.height: 24
                    anchors.centerIn: parent
                }
            }
            
            // Content section
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: AppTheme.spacing.xsmall
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: AppTheme.spacing.small
                    
                    Text {
                        text: title
                        font.pixelSize: AppTheme.typography.labelLarge
                        font.weight: Font.Bold
                        color: AppTheme.colors.text
                    }
                    
                    if (isLoading) {
                        Image {
                            source: "qrc:/icons/status/spinner.svg"
                            sourceSize.width: 14
                            sourceSize.height: 14
                            RotationAnimation {
                                target: parent
                                from: 0
                                to: 360
                                duration: 1000
                                loops: Animation.Infinite
                            }
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                }
                
                Text {
                    text: message
                    font.pixelSize: AppTheme.typography.bodySmall
                    color: AppTheme.colors.textSecondary
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                
                Text {
                    text: timestamp
                    font.pixelSize: AppTheme.typography.labelSmall
                    color: AppTheme.colors.textTertiary
                }
            }
        }
    }
}
