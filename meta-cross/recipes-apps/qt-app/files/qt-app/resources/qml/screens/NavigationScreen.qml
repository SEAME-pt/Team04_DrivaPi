import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtWebEngine
import QtPositioning

Rectangle {
    id: root
    color: "#000000"

    property bool showNavPanel: false
    property real currentLat: 0
    property real currentLon: 0
    property bool isNavigating: false
    property string currentDestination: ""
    property var turnByTurnInstructions: []

    // Start Waze-mode navigation with animation
    function startWazeMode(destLat, destLon, destName) {
        isNavigating = true;
        currentDestination = destName;
        showNavPanel = false;  // Hide selection panel

        // Initialize with mock instructions (will be replaced by real ones)
        turnByTurnInstructions = [
            {
                instruction: "Starting navigation...",
                distance: ""
            }
        ];

        navigateTo(destLat, destLon, destName);

        // Start GPS tracking animation
        if (positionSource.active) {
            console.log("Waze mode activated: Following GPS to", destName);
        }
    }

    // Stop navigation
    function stopNavigation() {
        isNavigating = false;
        currentDestination = "";
        turnByTurnInstructions = [];
        updateMapLocation(currentLat, currentLon);
    }

    // WebEngine profile with mobile user agent and dark theme
    WebEngineProfile {
        id: mobileProfile
        httpUserAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
        storageName: "DrivaPiMaps"
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        httpCacheType: WebEngineProfile.DiskHttpCache
    }

    PositionSource {
        id: positionSource
        active: true
        updateInterval: 5000

        onPositionChanged: {
            var lat = position.coordinate.latitude;
            var lon = position.coordinate.longitude;

            if (!isNaN(lat) && !isNaN(lon) && lat !== 0 && lon !== 0) {
                console.log("GPS: ", lat, lon);
                currentLat = lat;
                currentLon = lon;

                // If navigating, update map smoothly with animation
                if (isNavigating) {
                    updateMapWithAnimation(lat, lon);
                } else {
                    updateMapLocation(lat, lon);
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Map area - takes most of the space
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#0F1419"

            WebEngineView {
                id: mapsView
                anchors.fill: parent
                profile: mobileProfile
                backgroundColor: "#000000"

                // Grant geolocation to the web content
                onFeaturePermissionRequested: function (securityOrigin, feature) {
                    if (feature === WebEngineView.Geolocation) {
                        grantFeaturePermission(securityOrigin, feature, true);
                    } else {
                        grantFeaturePermission(securityOrigin, feature, false);
                    }
                }

                Component.onCompleted: {
                    // Wait a moment for GPS, then initialize
                    initTimer.start();
                }

                Timer {
                    id: initTimer
                    interval: 1500
                    running: false
                    repeat: false
                    onTriggered: initializeLocation()
                }

                onLoadingChanged: function (loadRequest) {
                    if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                        // Leaflet/OSM handles dark theme natively
                        console.log("Map loaded successfully with Leaflet/OSM dark theme");
                    }
                }
            }
        }
    }

    // Floating toggle for navigation panel
    Rectangle {
        id: navToggle
        width: 56
        height: 56
        radius: 28
        color: showNavPanel ? "#0066ff" : "#1e1e1e"
        border.color: "#444"
        border.width: 1
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16
        z: 200
        visible: !isNavigating  // Hide when navigating

        Text {
            anchors.centerIn: parent
            text: "🧭"
            color: "#ffffff"
            font.pixelSize: 22
        }

        MouseArea {
            anchors.fill: parent
            onClicked: showNavPanel = !showNavPanel
        }
    }

    // Stop Navigation button (shown when navigating)
    Rectangle {
        id: stopNavButton
        width: 56
        height: 56
        radius: 28
        color: "#ff3333"
        border.color: "#ff0000"
        border.width: 2
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16
        z: 200
        visible: isNavigating

        Text {
            anchors.centerIn: parent
            text: "⏹"
            color: "#ffffff"
            font.pixelSize: 26
        }

        MouseArea {
            anchors.fill: parent
            onClicked: stopNavigation()
        }
    }

    // Waze-style navigation info panel (compact, shown during navigation)
    Rectangle {
        id: wazeNavPanel
        width: 150
        height: Math.min(300, parent.height * 0.4)
        radius: 10
        color: "#0f1419"
        border.color: "#444"
        border.width: 1
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16
        visible: isNavigating
        z: 150
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            // Header with stop button
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "🧭 Navigation"
                    color: "#ffffff"
                    font.pixelSize: 12
                    font.bold: true
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#444"
            }

            // Route info (compact)
            Text {
                text: "Start: " + currentLat.toFixed(4) + ", " + currentLon.toFixed(4)
                color: "#999999"
                font.pixelSize: 9
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: "Destination: " + currentDestination
                color: "#ffffff"
                font.pixelSize: 10
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#333"
                Layout.topMargin: 4
                Layout.bottomMargin: 4
            }

            // Turn-by-turn instructions
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Column {
                    width: parent.width
                    spacing: 4

                    Repeater {
                        model: turnByTurnInstructions
                        delegate: Rectangle {
                            width: parent.width - 4
                            height: instructionText.height + 8
                            color: index === 0 ? "#1e3a5f" : "transparent"
                            radius: 4

                            Text {
                                id: instructionText
                                anchors.left: parent.left
                                anchors.right: distanceText.left
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: 4
                                text: modelData.instruction || ""
                                color: index === 0 ? "#00bfff" : "#cccccc"
                                font.pixelSize: index === 0 ? 11 : 9
                                font.bold: index === 0
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                id: distanceText
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: 4
                                text: modelData.distance || ""
                                color: index === 0 ? "#00ff00" : "#999999"
                                font.pixelSize: index === 0 ? 10 : 8
                                font.bold: index === 0
                            }
                        }
                    }
                }
            }
        }
    }

    // Navigation panel overlay (calls real routing)
    Rectangle {
        id: navPanel
        width: 200
        height: parent.height - 32
        radius: 10
        color: "#0f1419"
        border.color: "#444"
        border.width: 1
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16
        visible: showNavPanel
        z: 150
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            Text {
                text: "🧭 Navigation"
                color: "#ffffff"
                font.pixelSize: 14
                font.bold: true
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#444"
            }

            Text {
                text: "Destination:"
                color: "#999999"
                font.pixelSize: 10
            }

            TextField {
                id: destinationInput
                Layout.fillWidth: true
                placeholderText: "Enter address or place..."
                color: "#ffffff"
                font.pixelSize: 11
                background: Rectangle {
                    color: "#1e1e1e"
                    border.color: destinationInput.focus ? "#0066ff" : "#444"
                    border.width: 1
                    radius: 4
                }
            }

            Text {
                text: "Or use coordinates:"
                color: "#999999"
                font.pixelSize: 9
                Layout.topMargin: 4
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                TextField {
                    id: latInput
                    Layout.fillWidth: true
                    placeholderText: "Latitude"
                    text: "38.6819"
                    color: "#ffffff"
                    font.pixelSize: 10
                    background: Rectangle {
                        color: "#1e1e1e"
                        border.color: "#444"
                        border.width: 1
                        radius: 3
                    }
                }

                TextField {
                    id: lonInput
                    Layout.fillWidth: true
                    placeholderText: "Longitude"
                    text: "-9.4220"
                    color: "#ffffff"
                    font.pixelSize: 10
                    background: Rectangle {
                        color: "#1e1e1e"
                        border.color: "#444"
                        border.width: 1
                        radius: 3
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: "🚗 START NAVIGATION"
                enabled: (destinationInput.text !== "") || (latInput.text !== "" && lonInput.text !== "")
                onClicked: {
                    var destName = destinationInput.text || "Destination";
                    var lat = parseFloat(latInput.text);
                    var lon = parseFloat(lonInput.text);

                    if (!isNaN(lat) && !isNaN(lon)) {
                        startWazeMode(lat, lon, destName);
                    } else {
                        console.log("Geocoding not yet implemented, using coordinates");
                    }
                }

                background: Rectangle {
                    color: parent.enabled ? (parent.pressed ? "#00dd00" : "#00cc00") : "#444444"
                    radius: 6
                }

                contentItem: Text {
                    text: parent.text
                    color: parent.enabled ? "#000000" : "#666666"
                    font.bold: true
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    // Initialize with GPS or IP geolocation
    function initializeLocation() {
        var gpsValid = false;

        // Check if GPS has valid position
        if (positionSource.position.coordinate && !isNaN(positionSource.position.coordinate.latitude) && positionSource.position.coordinate.latitude !== 0) {
            gpsValid = true;
            var lat = positionSource.position.coordinate.latitude;
            var lon = positionSource.position.coordinate.longitude;
            updateMapLocation(lat, lon);
        } else {
            // No GPS - use IP geolocation
            console.log("No GPS, using IP geolocation");
            fetchIPLocation();
        }
    }

    // Fetch location based on IP (try multiple APIs)
    function fetchIPLocation() {
        var xhr = new XMLHttpRequest();

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    console.log("IP Location:", data.lat || data.latitude, data.lon || data.longitude);
                    updateMapLocation(data.lat || data.latitude, data.lon || data.longitude);
                } catch (e) {
                    console.error("Failed to parse IP location, trying fallback");
                    // Try fallback API
                    tryFallbackIP();
                }
            } else if (xhr.readyState === XMLHttpRequest.DONE && xhr.status !== 200) {
                console.error("IP location request failed, trying fallback");
                tryFallbackIP();
            }
        };

        // Try ipapi.co first (more reliable)
        console.log("Fetching IP location from ipapi.co");
        xhr.open("GET", "https://ipapi.co/json/");
        xhr.send();
    }

    // Fallback IP geolocation
    function tryFallbackIP() {
        var xhr = new XMLHttpRequest();

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    console.log("Fallback IP Location:", data.latitude, data.longitude);
                    updateMapLocation(data.latitude, data.longitude);
                } catch (e) {
                    console.error("Fallback IP failed, using default");
                    updateMapLocation(38.7223, -9.1393);
                }
            } else if (xhr.readyState === XMLHttpRequest.DONE) {
                console.error("Fallback IP request failed, using default");
                updateMapLocation(38.7223, -9.1393);
            }
        };

        // Fallback to freegeoip
        console.log("Fetching IP location from freegeoip.app");
        xhr.open("GET", "https://freegeoip.app/json/");
        xhr.send();
    }

    // Update map with coordinates - Leaflet OSM with dark theme
    function updateMapLocation(lat, lon) {
        if (isNaN(lat) || isNaN(lon)) {
            lat = 38.7223;
            lon = -9.1393;
        }

        currentLat = lat;
        currentLon = lon;

        // Build HTML with Leaflet + OSM with dark theme
        var html = `
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
                <style>
                    * { margin: 0; padding: 0; }
                    body { height: 100vh; background: #1e1e1e; }
                    #map { height: 100%; width: 100%; }

                    /* Dark theme - override leaflet defaults */
                    .leaflet-control-zoom {
                        background: #2d2d2d !important;
                        border: 1px solid #444 !important;
                    }
                    .leaflet-control-zoom a {
                        background: #2d2d2d !important;
                        color: #fff !important;
                        border-bottom: 1px solid #444 !important;
                    }
                    .leaflet-control-attribution {
                        background: rgba(0,0,0,0.8) !important;
                        color: #999 !important;
                        font-size: 11px;
                    }
                </style>
            </head>
            <body>
                <div id="map"></div>
                <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
                <script>
                    // Initialize map
                    var map = L.map('map').setView([${lat}, ${lon}], 15);

                    // Dark theme tile layer
                    L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
                        attribution: '© OpenStreetMap, © CartoDB',
                        maxZoom: 20,
                        crossOrigin: true
                    }).addTo(map);

                    // Add marker for current location
                    L.marker([${lat}, ${lon}], {
                        title: 'Your Location'
                    }).addTo(map).bindPopup('<b>Current Location</b><br>' +
                        '${lat.toFixed(4)}, ${lon.toFixed(4)}');

                    // Add circle around location
                    L.circle([${lat}, ${lon}], {
                        color: '#00bfff',
                        fill: true,
                        fillColor: '#00bfff',
                        fillOpacity: 0.1,
                        radius: 50
                    }).addTo(map);

                    console.log('Map loaded at', ${lat}, ${lon});
                </script>
            </body>
            </html>
        `;

        console.log("Loading Leaflet/OSM map (dark theme):", lat, lon);
        mapsView.url = "data:text/html;charset=utf-8," + encodeURIComponent(html);
    }

    // Update map with smooth animation (for GPS tracking during navigation)
    function updateMapWithAnimation(lat, lon) {
        if (isNaN(lat) || isNaN(lon)) {
            return;
        }

        // Inject JavaScript to smoothly pan to new position
        mapsView.runJavaScript(`
            if (typeof map !== 'undefined' && map) {
                map.panTo([${lat}, ${lon}], {animate: true, duration: 1.0});

                // Update current position marker if it exists
                if (typeof currentPosMarker !== 'undefined') {
                    currentPosMarker.setLatLng([${lat}, ${lon}]);
                } else {
                    currentPosMarker = L.circleMarker([${lat}, ${lon}], {
                        radius: 8,
                        fillColor: '#0066ff',
                        color: '#fff',
                        weight: 2,
                        opacity: 1,
                        fillOpacity: 0.8
                    }).addTo(map);
                }
            }
        `);

        console.log("Animated map update:", lat, lon);
    }

    // Navigate to destination (optional - for future route planning)
    function navigateTo(destLat, destLon, destName) {
        // Get current position or use last known position
        var startLat = positionSource.position.coordinate.latitude;
        var startLon = positionSource.position.coordinate.longitude;

        if (isNaN(startLat) || isNaN(startLon) || startLat === 0 || startLon === 0) {
            startLat = currentLat;
            startLon = currentLon;
        }

        if (isNaN(startLat) || isNaN(startLon) || startLat === 0 || startLon === 0) {
            console.error("Current position not available");
            return;
        }

        if (isNaN(destLat) || isNaN(destLon)) {
            console.error("Destination position invalid");
            return;
        }

        // Build navigation HTML with real routing (OSRM)
        var html = `
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
                <link rel="stylesheet" href="https://unpkg.com/leaflet-routing-machine@3.2.12/dist/leaflet-routing-machine.css" />
                <style>
                    * { margin: 0; padding: 0; }
                    body { height: 100vh; background: #1e1e1e; font-family: Arial, sans-serif; }
                    #map { height: 100%; width: 100%; }

                    .info-panel {
                        position: absolute;
                        top: 10px;
                        right: 10px;
                        background: #2d2d2d;
                        color: #fff;
                        padding: 15px;
                        border-radius: 5px;
                        max-width: 250px;
                        z-index: 1000;
                        border: 1px solid #444;
                    }

                    .leaflet-routing-container {
                        background: #2d2d2d !important;
                        color: #fff !important;
                        border: 1px solid #444 !important;
                        border-radius: 5px !important;
                        max-height: 50vh;
                        overflow: auto;
                    }

                    .leaflet-routing-alt {
                        background: #2d2d2d !important;
                        color: #fff !important;
                        border-top: 1px solid #444 !important;
                    }

                    .leaflet-routing-geocoders input {
                        background: #1e1e1e !important;
                        color: #fff !important;
                        border: 1px solid #444 !important;
                    }

                    .info-panel h3 {
                        margin: 0 0 10px 0;
                        color: #00bfff;
                    }

                    .info-panel p {
                        margin: 5px 0;
                        font-size: 12px;
                    }

                    /* Dark theme controls */
                    .leaflet-control-zoom {
                        background: #2d2d2d !important;
                        border: 1px solid #444 !important;
                    }
                    .leaflet-control-zoom a {
                        background: #2d2d2d !important;
                        color: #fff !important;
                        border-bottom: 1px solid #444 !important;
                    }
                    .leaflet-control-attribution {
                        background: rgba(0,0,0,0.8) !important;
                        color: #999 !important;
                        font-size: 11px;
                    }
                </style>
            </head>
            <body>
                <div id="map"></div>
                <div class="info-panel">
                    <h3>🧭 Navigation</h3>
                    <p><b>Start:</b> ${startLat.toFixed(4)}, ${startLon.toFixed(4)}</p>
                    <p><b>Destination:</b> ${destName || 'Waypoint'}</p>
                    <p><b>Target:</b> ${destLat.toFixed(4)}, ${destLon.toFixed(4)}</p>
                </div>
                <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
                <script src="https://unpkg.com/leaflet-routing-machine@3.2.12/dist/leaflet-routing-machine.js"></script>
                <script>
                    var startLat = ${startLat};
                    var startLon = ${startLon};
                    var destLat = ${destLat};
                    var destLon = ${destLon};

                    // Initialize map centered on route midpoint
                    var midLat = (startLat + destLat) / 2;
                    var midLon = (startLon + destLon) / 2;
                    var map = L.map('map').setView([midLat, midLon], 13);

                    // Dark theme tile layer
                    L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
                        attribution: '© OpenStreetMap, © CartoDB',
                        maxZoom: 20,
                        crossOrigin: true
                    }).addTo(map);

                    // Real routing using OSRM (turn-by-turn)
                    var currentPosMarker = null;  // Store marker for animation updates

                    var routingControl = L.Routing.control({
                        waypoints: [
                            L.latLng(startLat, startLon),
                            L.latLng(destLat, destLon)
                        ],
                        routeWhileDragging: false,
                        showAlternatives: false,
                        fitSelectedRoutes: true,
                        lineOptions: {
                            styles: [{ color: '#00bfff', opacity: 0.9, weight: 5 }]
                        },
                        altLineOptions: {
                            styles: [{ color: '#666', opacity: 0.6, weight: 4 }]
                        },
                        router: L.Routing.osrmv1({
                            serviceUrl: 'https://router.project-osrm.org/route/v1'
                        }),
                        createMarker: function(i, wp) {
                            var color = i === 0 ? '#0066ff' : '#ff3333';
                            return L.circleMarker(wp.latLng, {
                                radius: 8,
                                fillColor: color,
                                color: '#fff',
                                weight: 2,
                                opacity: 1,
                                fillOpacity: 0.8
                            });
                        }
                    }).addTo(map);

                    routingControl.on('routesfound', function(e) {
                        console.log('Routes found:', e.routes.length);
                        // Zoom to show full route with padding
                        var bounds = L.latLngBounds([startLat, startLon], [destLat, destLon]);
                        map.fitBounds(bounds, {padding: [50, 50], maxZoom: 14});

                        // Extract turn-by-turn instructions
                        if (e.routes.length > 0 && e.routes[0].instructions) {
                            var instructions = [];
                            for (var i = 0; i < e.routes[0].instructions.length; i++) {
                                var instr = e.routes[0].instructions[i];
                                instructions.push({
                                    instruction: instr.text || instr.road || 'Continue',
                                    distance: (instr.distance >= 1000 ?
                                        (instr.distance / 1000).toFixed(1) + ' km' :
                                        Math.round(instr.distance) + ' m')
                                });
                            }
                            // Store in window object for QML to retrieve
                            window.routingInstructions = instructions;
                            console.log('Instructions stored:', instructions.length);
                        }
                    });

                    routingControl.on('routingerror', function(err) {
                        console.error('Routing error:', err);
                        // Fallback: draw straight line if routing fails
                        L.polyline([
                            [startLat, startLon],
                            [destLat, destLon]
                        ], {
                            color: '#00bfff',
                            weight: 3,
                            opacity: 0.7,
                            dashArray: '5, 5'
                        }).addTo(map);
                    });

                    console.log('Navigation route loaded');
                </script>
            </body>
            </html>
        `;

        console.log("Navigating to destination:", destName, destLat, destLon);
        mapsView.url = "data:text/html;charset=utf-8," + encodeURIComponent(html);

        // Wait for routing to complete, then extract instructions
        extractInstructionsTimer.restart();
    }

    // Timer to extract routing instructions after they're calculated
    Timer {
        id: extractInstructionsTimer
        interval: 3000
        running: false
        repeat: false
        onTriggered: {
            mapsView.runJavaScript("typeof window.routingInstructions !== 'undefined' ? JSON.stringify(window.routingInstructions) : '[]'", function (result) {
                try {
                    var instructions = JSON.parse(result);
                    if (instructions && instructions.length > 0) {
                        turnByTurnInstructions = instructions;
                        console.log("Loaded", instructions.length, "turn-by-turn instructions");
                    }
                } catch (e) {
                    console.error("Failed to parse instructions:", e);
                }
            });
        }
    }
}
