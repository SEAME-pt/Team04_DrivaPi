import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtLocation
import QtCore
import "../../theme"

Rectangle {
    id: root
    // Bind to theme surface
    color: AppTheme.colors.surface

    // UI/state
    property bool showNavPanel: false
    property real currentLat: 0
    property real currentLon: 0
    property bool isNavigating: false
    property string currentDestination: ""
    property var turnByTurnInstructions: []

    property real destLat: NaN
    property real destLon: NaN

    property var routePath: []
    property real totalDistanceMeters: 0
    property real totalDurationSeconds: 0

    // --- Helpers ---
    function _coord(lat, lon) { return QtPositioning.coordinate(lat, lon); }
    function _isValidCoord(lat, lon) { return !isNaN(lat) && !isNaN(lon) && lat !== 0 && lon !== 0; }
    function _fmtDistance(m) {
        if (!m || m <= 0) return "";
        if (m >= 1000) return (m / 1000).toFixed(1) + " km";
        return Math.round(m) + " m";
    }
    function _parseNumberOrNaN(s) { var v = parseFloat(s); return isNaN(v) ? NaN : v; }

    // ... (Keep _decodePolyline6 and requestRoute exactly as they are) ...

    function startWazeMode(toLat, toLon, toName) {
        if (!_isValidCoord(currentLat, currentLon)) {
            turnByTurnInstructions = [{ instruction: "Waiting for GPS...", distance: "" }];
            return;
        }
        isNavigating = true;
        currentDestination = toName || "Destination";
        showNavPanel = false;
        destLat = toLat;
        destLon = toLon;
        turnByTurnInstructions = [{ instruction: "Calculating route...", distance: "" }];
        requestRoute(currentLat, currentLon, destLat, destLon);
        followTimer.restart();
    }

    function stopNavigation() {
        isNavigating = false;
        currentDestination = "";
        destLat = NaN; destLon = NaN;
        routePath = [];
        totalDistanceMeters = 0; totalDurationSeconds = 0;
        turnByTurnInstructions = [];
        followTimer.stop();
        if (_isValidCoord(currentLat, currentLon)) map.center = _coord(currentLat, currentLon);
    }

    PositionSource {
        id: positionSource
        active: true
        updateInterval: 2000
        onPositionChanged: {
            var lat = position.coordinate.latitude;
            var lon = position.coordinate.longitude;
            if (_isValidCoord(lat, lon)) {
                currentLat = lat; currentLon = lon;
                if (!isNavigating) map.center = _coord(currentLat, currentLon);
            }
        }
    }

    Timer {
        id: followTimer
        interval: 700
        repeat: true
        onTriggered: {
            if (isNavigating && _isValidCoord(currentLat, currentLon)) map.center = _coord(currentLat, currentLon);
        }
    }

    // --- Map plugin (Dynamic Dark/Light) ---
    Plugin {
        id: mapPlugin
        name: "osm"

        PluginParameter {
            name: "osm.mapping.cache.directory"
            // Use separate cache folders to prevent tile "ghosting" when switching modes
            value: StandardPaths.writableLocation(StandardPaths.CacheLocation) + (AppTheme.isDark ? "/osm-dark" : "/osm-light")
        }

        PluginParameter {
            name: "osm.mapping.custom.host"
            // CARTO Dark Matter for Dark Mode, CARTO Voyager for Light Mode
            value: AppTheme.isDark
                ? "https://a.basemaps.cartocdn.com/dark_all/%z/%x/%y.png"
                : "https://a.basemaps.cartocdn.com/rastertiles/voyager/%z/%x/%y.png"
        }

        PluginParameter {
            name: "osm.useragent"
            value: "DrivaPiHMI/1.0 (QtLocation)"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: AppTheme.colors.surface

            Map {
                id: map
                anchors.fill: parent
                plugin: mapPlugin
                zoomLevel: 15
                center: _coord(38.7223, -9.1393)

                MapQuickItem {
                    id: currentMarker
                    anchorPoint: Qt.point(8, 8)
                    coordinate: _isValidCoord(currentLat, currentLon) ? _coord(currentLat, currentLon) : map.center
                    sourceItem: Rectangle {
                        width: 16; height: 16; radius: 8
                        color: AppTheme.colors.primary
                        border.color: "#ffffff"
                        border.width: 2
                    }
                }

                MapQuickItem {
                    id: destMarker
                    visible: isNavigating && _isValidCoord(destLat, destLon)
                    anchorPoint: Qt.point(8, 8)
                    coordinate: _coord(destLat, destLon)
                    sourceItem: Rectangle {
                        width: 16; height: 16; radius: 8
                        color: AppTheme.colors.error
                        border.color: "#ffffff"
                        border.width: 2
                    }
                }

                MapPolyline {
                    id: routeLine
                    visible: isNavigating && routePath && routePath.length > 1
                    line.width: 6
                    line.color: AppTheme.colors.primary
                    path: routePath
                }
            }

            Text {
                anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.margins: 6
                text: "© OpenStreetMap contributors © CARTO"
                color: AppTheme.colors.textSecondary
                font.pixelSize: 9; opacity: 0.7; z: 999
            }
        }
    }

    // Floating toggle
    Rectangle {
        id: navToggle
        width: 56; height: 56; radius: 28
        color: showNavPanel ? AppTheme.colors.primary : AppTheme.colors.surfaceElevated
        border.color: AppTheme.colors.border
        border.width: 1
        anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 16
        z: 200; visible: !isNavigating

        Text {
            anchors.centerIn: parent
            text: "🧭"
            font.pixelSize: 22
        }

        MouseArea { anchors.fill: parent; onClicked: showNavPanel = !showNavPanel }
    }

    // Stop Navigation button
    Rectangle {
        id: stopNavButton
        width: 56; height: 56; radius: 28
        color: AppTheme.colors.error
        anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 16
        z: 200; visible: isNavigating

        Text {
            anchors.centerIn: parent
            text: "⏹"
            color: "#ffffff"
            font.pixelSize: 26
        }

        MouseArea { anchors.fill: parent; onClicked: stopNavigation() }
    }

    // Turn-by-turn panel
    Rectangle {
        id: wazeNavPanel
        width: 180
        height: Math.min(300, parent.height * 0.4)
        radius: AppTheme.radius.medium
        color: AppTheme.alpha(AppTheme.colors.surfaceVariant, 0.9)
        border.color: AppTheme.colors.border
        border.width: 1
        anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 16
        visible: isNavigating; z: 150; clip: true

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 8; spacing: 4
            Text {
                text: "🧭 Navigation"
                color: AppTheme.colors.text; font.pixelSize: 12; font.bold: true
                Layout.fillWidth: true
            }
            Rectangle { Layout.fillWidth: true; height: 1; color: AppTheme.colors.divider }

            Text {
                text: "To: " + currentDestination
                color: AppTheme.colors.primary; font.pixelSize: 10; font.bold: true
                elide: Text.ElideRight; Layout.fillWidth: true
            }

            ScrollView {
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                Column {
                    width: parent.width; spacing: 4
                    Repeater {
                        model: turnByTurnInstructions
                        delegate: Rectangle {
                            width: parent.width - 4
                            height: instructionText.height + 8
                            color: index === 0 ? AppTheme.alpha(AppTheme.colors.primary, 0.15) : "transparent"
                            radius: 4

                            Text {
                                id: instructionText
                                anchors.left: parent.left; anchors.right: distanceText.left
                                anchors.verticalCenter: parent.verticalCenter; anchors.margins: 4
                                text: modelData.instruction || ""
                                color: index === 0 ? AppTheme.colors.primary : AppTheme.colors.text
                                font.pixelSize: index === 0 ? 11 : 9; font.bold: index === 0
                                wrapMode: Text.WordWrap
                            }
                            Text {
                                id: distanceText
                                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; anchors.margins: 4
                                text: modelData.distance || ""
                                color: AppTheme.colors.success; font.pixelSize: 8
                            }
                        }
                    }
                }
            }
        }
    }

    // Destination chooser overlay
    Rectangle {
        id: navPanel
        width: 220
        height: parent.height - 32
        radius: AppTheme.radius.medium
        color: AppTheme.colors.surfaceElevated
        border.color: AppTheme.colors.border
        border.width: 1
        anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 16
        visible: showNavPanel; z: 150; clip: true

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 12; spacing: 8
            Text {
                text: "Set Destination"
                color: AppTheme.colors.text; font.pixelSize: 14; font.bold: true
            }

            // Latitude Input
            TextField {
                id: latInput
                Layout.fillWidth: true
                placeholderText: "Latitude"
                text: "38.6819"
                color: AppTheme.colors.text
                font.pixelSize: 11
                background: Rectangle {
                    color: AppTheme.colors.surfaceVariant
                    radius: 4; border.color: latInput.activeFocus ? AppTheme.colors.primary : AppTheme.colors.border
                }
            }

            // Longitude Input
            TextField {
                id: lonInput
                Layout.fillWidth: true
                placeholderText: "Longitude"
                text: "-9.4220"
                color: AppTheme.colors.text
                font.pixelSize: 11
                background: Rectangle {
                    color: AppTheme.colors.surfaceVariant
                    radius: 4; border.color: lonInput.activeFocus ? AppTheme.colors.primary : AppTheme.colors.border
                }
            }

            Button {
                Layout.fillWidth: true; Layout.preferredHeight: 40
                text: "START NAVIGATION"
                onClicked: {
                    startWazeMode(_parseNumberOrNaN(latInput.text), _parseNumberOrNaN(lonInput.text), "Cascais");
                }
                background: Rectangle {
                    color: parent.pressed ? AppTheme.colors.primaryDark : AppTheme.colors.primary
                    radius: 6
                }
                contentItem: Text {
                    text: parent.text; color: AppTheme.colors.surfaceElevated
                    font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
            }
            Item { Layout.fillHeight: true }
        }
    }
}
