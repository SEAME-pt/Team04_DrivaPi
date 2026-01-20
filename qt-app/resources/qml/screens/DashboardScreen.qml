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
                    text: "Vehicle Dashboard"
                    font.pixelSize: AppTheme.typography.headlineSmall
                    font.weight: Font.Bold
                    color: AppTheme.colors.text
                }
                
                Item { Layout.fillWidth: true }
                
                // System status indicator
                RowLayout {
                    spacing: AppTheme.spacing.small
                    
                    Image {
                        source: "qrc:/icons/status/online-dot.svg"
                        sourceSize.width: 12
                        sourceSize.height: 12
                    }
                    
                    Text {
                        text: "System Online"
                        font.pixelSize: AppTheme.typography.labelSmall
                        color: AppTheme.colors.textSecondary
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
        
        // ====== SCROLLABLE CONTENT ======
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: dashboardContent.height
            clip: true
            
            ColumnLayout {
                id: dashboardContent
                width: parent.width
                spacing: 0
                
                // ====== SECTION 1: SYSTEM HEALTH ======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    color: AppTheme.colors.surfaceVariant
                    
                    Text {
                        text: "SYSTEM HEALTH"
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                        color: AppTheme.colors.textSecondary
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.spacing.large
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                // Health status cards
                StatusCard {
                    titleIcon: "qrc:/icons/status/check.svg"
                    title: "Overall Status"
                    status: "Excellent"
                    statusColor: AppTheme.colors.online
                    details: [
                        {label: "All Systems", value: "Operational"},
                        {label: "Last Check", value: "2s ago"},
                        {label: "Uptime", value: "2h 34m"}
                    ]
                }
                
                StatusCard {
                    titleIcon: "qrc:/icons/status/success-circle.svg"
                    title: "System Connectivity"
                    status: "Connected"
                    statusColor: AppTheme.colors.online
                    details: [
                        {label: "Primary", value: "Connected"},
                        {label: "Backup", value: "Ready"},
                        {label: "Latency", value: "12 ms"}
                    ]
                }
                
                // ====== SECTION 2: ALERTS & WARNINGS ======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    color: AppTheme.colors.surfaceVariant
                    
                    Text {
                        text: "ALERTS & WARNINGS"
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                        color: AppTheme.colors.textSecondary
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.spacing.large
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                StatusCard {
                    titleIcon: "qrc:/icons/status/bell.svg"
                    title: "Active Notifications"
                    status: "1 Alert"
                    statusColor: AppTheme.colors.warning
                    details: [
                        {label: "Critical", value: "0"},
                        {label: "Warnings", value: "1"},
                        {label: "Info", value: "3"}
                    ]
                }
                
                StatusCard {
                    titleIcon: "qrc:/icons/status/warning-icon.svg"
                    title: "Battery Temperature"
                    status: "Warning"
                    statusColor: AppTheme.colors.warning
                    details: [
                        {label: "Current", value: "65°C"},
                        {label: "Threshold", value: "75°C"},
                        {label: "Status", value: "High"}
                    ]
                }
                
                StatusCard {
                    titleIcon: "qrc:/icons/status/error.svg"
                    title: "Error Log"
                    status: "No Errors"
                    statusColor: AppTheme.colors.online
                    details: [
                        {label: "Critical", value: "0"},
                        {label: "Errors", value: "0"},
                        {label: "Warnings", value: "0"}
                    ]
                }
                
                // ====== SECTION 3: VEHICLE LIGHTS ======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    color: AppTheme.colors.surfaceVariant
                    
                    Text {
                        text: "VEHICLE LIGHTS"
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                        color: AppTheme.colors.textSecondary
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.spacing.large
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                // Lights grid
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: AppTheme.spacing.large
                    Layout.rightMargin: AppTheme.spacing.large
                    Layout.topMargin: AppTheme.spacing.medium
                    spacing: AppTheme.spacing.medium
                    
                    LightIndicator {
                        icon: "qrc:/icons/status/low-beam-headlights.svg"
                        label: "Low Beam"
                        active: false
                    }
                    
                    LightIndicator {
                        icon: "qrc:/icons/status/lights.svg"
                        label: "Lights"
                        active: false
                    }
                    
                    LightIndicator {
                        icon: "qrc:/icons/status/parking-lights.svg"
                        label: "Parking"
                        active: true
                    }
                    
                    LightIndicator {
                        icon: "qrc:/icons/status/rear-fog-lights.svg"
                        label: "Rear Fog"
                        active: false
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: AppTheme.spacing.large
                    Layout.rightMargin: AppTheme.spacing.large
                    Layout.topMargin: AppTheme.spacing.medium
                    Layout.preferredHeight: 1
                    color: AppTheme.colors.divider
                }
                
                // ====== SECTION 4: STATUS INDICATORS ======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    color: AppTheme.colors.surfaceVariant
                    
                    Text {
                        text: "STATUS INDICATORS"
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                        color: AppTheme.colors.textSecondary
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.spacing.large
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                IndicatorGrid {
                    indicators: [
                        {icon: "qrc:/icons/status/indicator-1.svg", label: "Level 1", value: "Good"},
                        {icon: "qrc:/icons/status/indicator-2.svg", label: "Level 2", value: "Normal"},
                        {icon: "qrc:/icons/status/indicator-3.svg", label: "Level 3", value: "OK"},
                        {icon: "qrc:/icons/status/indicator-1-grey.svg", label: "Offline", value: "N/A"},
                        {icon: "qrc:/icons/status/indicator-2-red.svg", label: "Alert 2", value: "Warning"},
                        {icon: "qrc:/icons/status/indicator-3-red.svg", label: "Alert 3", value: "Critical"}
                    ]
                }
                
                // ====== SECTION 5: OPERATION STATUS ======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    color: AppTheme.colors.surfaceVariant
                    
                    Text {
                        text: "OPERATION STATUS"
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                        color: AppTheme.colors.textSecondary
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.spacing.large
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                StatusCard {
                    titleIcon: "qrc:/icons/status/upload.svg"
                    title: "Data Upload"
                    status: "In Progress"
                    statusColor: AppTheme.colors.primary
                    details: [
                        {label: "Progress", value: "75%"},
                        {label: "Speed", value: "2.5 MB/s"},
                        {label: "ETA", value: "5s"}
                    ]
                }
                
                StatusCard {
                    titleIcon: "qrc:/icons/status/download.svg"
                    title: "Software Update"
                    status: "Available"
                    statusColor: AppTheme.colors.warning
                    details: [
                        {label: "Version", value: "v1.5.0"},
                        {label: "Size", value: "125 MB"},
                        {label: "Date", value: "2026-01-15"}
                    ]
                }
                
                // ====== SECTION 6: ASYNC OPERATIONS ======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    color: AppTheme.colors.surfaceVariant
                    
                    Text {
                        text: "BACKGROUND TASKS"
                        font.pixelSize: AppTheme.typography.labelSmall
                        font.weight: Font.Bold
                        color: AppTheme.colors.textSecondary
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.spacing.large
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                StatusCard {
                    titleIcon: "qrc:/icons/status/spinner.svg"
                    title: "Data Synchronization"
                    status: "Processing"
                    statusColor: AppTheme.colors.primary
                    details: [
                        {label: "Status", value: "Syncing..."},
                        {label: "Items", value: "234/512"},
                        {label: "Time", value: "45s elapsed"}
                    ]
                }
                
                StatusCard {
                    titleIcon: "qrc:/icons/status/info.svg"
                    title: "System Information"
                    status: "Current"
                    statusColor: AppTheme.colors.online
                    details: [
                        {label: "Kernel", value: "5.10.103"},
                        {label: "Build", value: "20260120"},
                        {label: "Checksum", value: "OK"}
                    ]
                }
                
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: AppTheme.spacing.large
                }
            }
        }
    }
    
    // ====== STATUS CARD COMPONENT ======
    component StatusCard: Rectangle {
        property string titleIcon: ""
        property string title: ""
        property string status: ""
        property color statusColor: AppTheme.colors.online
        property var details: []
        
        Layout.fillWidth: true
        Layout.leftMargin: AppTheme.spacing.large
        Layout.rightMargin: AppTheme.spacing.large
        Layout.topMargin: AppTheme.spacing.small
        Layout.preferredHeight: cardLayout.height + AppTheme.spacing.medium * 2
        
        color: AppTheme.colors.surface
        
        ColumnLayout {
            id: cardLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: AppTheme.spacing.medium
            spacing: AppTheme.spacing.small
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: AppTheme.spacing.small
                
                Image {
                    source: titleIcon
                    sourceSize.width: 18
                    sourceSize.height: 18
                    visible: titleIcon !== ""
                }
                
                Text {
                    text: title
                    font.pixelSize: AppTheme.typography.labelLarge
                    font.weight: Font.Bold
                    color: AppTheme.colors.text
                }
                
                Item { Layout.fillWidth: true }
                
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: statusColor
                }
                
                Text {
                    text: status
                    font.pixelSize: AppTheme.typography.labelSmall
                    color: statusColor
                    font.weight: Font.Bold
                }
            }
            
            // Details grid
            Flow {
                Layout.fillWidth: true
                spacing: AppTheme.spacing.medium
                
                Repeater {
                    model: details
                    
                    Item {
                        width: 180
                        height: 20
                        
                        RowLayout {
                            anchors.fill: parent
                            spacing: AppTheme.spacing.xsmall
                            
                            Text {
                                text: modelData.label
                                font.pixelSize: AppTheme.typography.labelSmall
                                color: AppTheme.colors.textSecondary
                                width: 60
                            }
                            
                            Text {
                                text: modelData.value
                                font.pixelSize: AppTheme.typography.labelSmall
                                color: AppTheme.colors.text
                                font.weight: Font.Bold
                            }
                        }
                    }
                }
            }
        }
    }
    
    // ====== LIGHT INDICATOR COMPONENT ======
    component LightIndicator: ColumnLayout {
        property string icon: ""
        property string label: ""
        property bool active: false
        
        spacing: AppTheme.spacing.xsmall
        
        Rectangle {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            radius: AppTheme.radius.small
            color: active ? AppTheme.colors.primary : AppTheme.colors.surfaceVariant
            
            Image {
                source: icon
                sourceSize.width: 24
                sourceSize.height: 24
                anchors.centerIn: parent
                opacity: active ? 1 : 0.5
            }
        }
        
        Text {
            text: label
            font.pixelSize: AppTheme.typography.labelSmall
            color: active ? AppTheme.colors.primary : AppTheme.colors.textSecondary
            Layout.alignment: Qt.AlignHCenter
            font.weight: active ? Font.Bold : Font.Normal
        }
    }
    
    // ====== INDICATOR GRID COMPONENT ======
    component IndicatorGrid: Rectangle {
        property var indicators: []
        
        Layout.fillWidth: true
        Layout.leftMargin: AppTheme.spacing.large
        Layout.rightMargin: AppTheme.spacing.large
        Layout.topMargin: AppTheme.spacing.medium
        Layout.preferredHeight: gridFlow.implicitHeight + AppTheme.spacing.medium * 2
        
        color: AppTheme.colors.surface
        
        Flow {
            id: gridFlow
            anchors.fill: parent
            anchors.margins: AppTheme.spacing.medium
            spacing: AppTheme.spacing.medium
            
            Repeater {
                model: indicators
                
                ColumnLayout {
                    spacing: AppTheme.spacing.xsmall
                    
                    Rectangle {
                        Layout.preferredWidth: 64
                        Layout.preferredHeight: 64
                        radius: AppTheme.radius.small
                        color: AppTheme.colors.surfaceVariant
                        
                        Image {
                            source: modelData.icon
                            sourceSize.width: 32
                            sourceSize.height: 32
                            anchors.centerIn: parent
                        }
                    }
                    
                    Text {
                        text: modelData.label
                        font.pixelSize: AppTheme.typography.labelSmall
                        color: AppTheme.colors.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: modelData.value
                        font.pixelSize: AppTheme.typography.labelSmall
                        color: AppTheme.colors.text
                        Layout.alignment: Qt.AlignHCenter
                        font.weight: Font.Bold
                    }
                }
            }
        }
    }
}
