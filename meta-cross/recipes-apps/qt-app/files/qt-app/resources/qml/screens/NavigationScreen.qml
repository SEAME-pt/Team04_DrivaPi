import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtLocation

Rectangle {
    id: root
    color: "#000000"

    // UI/state
    property bool showNavPanel: false
    property real currentLat: 0
    property real currentLon: 0
    property bool isNavigating: false
    property string currentDestination: ""
    property var turnByTurnInstructions: []   // [{ instruction: "...", distance: "..." }, ...]

    // Destination
    property real destLat: NaN
    property real destLon: NaN

    // Route polyline (QtLocation uses list<coordinate>)
    property var routePath: []                // [ coordinate(), coordinate(), ... ]
    property real totalDistanceMeters: 0
    property real totalDurationSeconds: 0

    // --- Helpers ---
    function _coord(lat, lon) {
        return QtPositioning.coordinate(lat, lon);
    }

    function _isValidCoord(lat, lon) {
        return !isNaN(lat) && !isNaN(lon) && lat !== 0 && lon !== 0;
    }

    function _fmtDistance(m) {
        if (!m || m <= 0)
            return "";
        if (m >= 1000)
            return (m / 1000).toFixed(1) + " km";
        return Math.round(m) + " m";
    }

    function _parseNumberOrNaN(s) {
        var v = parseFloat(s);
        return isNaN(v) ? NaN : v;
    }

    // Decode OSRM polyline6
    // Reference: OSRM uses polyline6 by default when geometries=polyline6
    function _decodePolyline6(str) {
        var coords = [];
        var index = 0;
        var lat = 0;
        var lon = 0;

        function decodeValue() {
            var result = 0;
            var shift = 0;
            var b;
            do {
                b = str.charCodeAt(index++) - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20 && index < str.length)

            var delta = (result & 1) ? ~(result >> 1) : (result >> 1);
            return delta;
        }

        while (index < str.length) {
            lat += decodeValue();
            lon += decodeValue();
            coords.push(_coord(lat / 1e6, lon / 1e6));
        }
        return coords;
    }

    // --- OSRM routing (public demo server) ---
    // NOTE: This hits the internet. If your target has no WAN access, replace serviceUrl with your own OSRM.
    function requestRoute(fromLat, fromLon, toLat, toLon) {
        var url = "https://router.project-osrm.org/route/v1/driving/" + fromLon + "," + fromLat + ";" + toLon + "," + toLat + "?overview=full&geometries=polyline6&steps=true&annotations=false";

        console.log("OSRM route:", url);

        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return;

            if (xhr.status !== 200) {
                console.error("OSRM error:", xhr.status, xhr.responseText);
                // Fallback: clear route but keep map centered
                routePath = [];
                turnByTurnInstructions = [
                    {
                        instruction: "Route unavailable (OSRM error)",
                        distance: ""
                    }
                ];
                return;
            }

            try {
                var data = JSON.parse(xhr.responseText);
                if (!data.routes || data.routes.length === 0) {
                    console.error("OSRM: no routes");
                    routePath = [];
                    turnByTurnInstructions = [
                        {
                            instruction: "No route found",
                            distance: ""
                        }
                    ];
                    return;
                }

                var r = data.routes[0];
                totalDistanceMeters = r.distance || 0;
                totalDurationSeconds = r.duration || 0;

                // Geometry
                routePath = _decodePolyline6(r.geometry);

                // Steps -> turn-by-turn
                var tbt = [];
                if (r.legs && r.legs.length > 0 && r.legs[0].steps) {
                    for (var i = 0; i < r.legs[0].steps.length; i++) {
                        var step = r.legs[0].steps[i];
                        var man = step.maneuver || {};
                        var name = step.name || "";
                        var type = man.type || "";
                        var modifier = man.modifier || "";

                        // Build a human-ish instruction
                        var text = "";
                        if (type === "depart")
                            text = "Start";
                        else if (type === "arrive")
                            text = "Arrive";
                        else if (type === "roundabout")
                            text = "Roundabout";
                        else if (type === "turn")
                            text = "Turn";
                        else if (type === "merge")
                            text = "Merge";
                        else if (type === "on ramp")
                            text = "On ramp";
                        else if (type === "off ramp")
                            text = "Off ramp";
                        else if (type === "continue")
                            text = "Continue";
                        else
                            text = type ? type : "Continue";

                        if (modifier)
                            text += " " + modifier;
                        if (name)
                            text += " onto " + name;

                        tbt.push({
                            instruction: text,
                            distance: _fmtDistance(step.distance || 0)
                        });
                    }
                }

                // Put header entry first
                var header = "Route: " + _fmtDistance(totalDistanceMeters);
                tbt.unshift({
                    instruction: header,
                    distance: ""
                });

                turnByTurnInstructions = tbt;

                // Fit map to route bounds
                fitMapToRoute();

                console.log("OSRM route ok. points:", routePath.length, "steps:", tbt.length);
            } catch (e) {
                console.error("OSRM parse error:", e);
                routePath = [];
                turnByTurnInstructions = [
                    {
                        instruction: "Route parse error",
                        distance: ""
                    }
                ];
            }
        };

        xhr.open("GET", url);
        xhr.send();
    }

    function fitMapToRoute() {
        if (!routePath || routePath.length < 2)
            return;

        var minLat = 90, maxLat = -90, minLon = 180, maxLon = -180;
        for (var i = 0; i < routePath.length; i++) {
            var c = routePath[i];
            minLat = Math.min(minLat, c.latitude);
            maxLat = Math.max(maxLat, c.latitude);
            minLon = Math.min(minLon, c.longitude);
            maxLon = Math.max(maxLon, c.longitude);
        }

        var tl = _coord(maxLat, minLon);
        var br = _coord(minLat, maxLon);
        map.visibleRegion = QtPositioning.rectangle(tl, br);
    }

    // --- Start/Stop navigation ---
    function startWazeMode(toLat, toLon, toName) {
        if (!_isValidCoord(currentLat, currentLon)) {
            turnByTurnInstructions = [
                {
                    instruction: "Waiting for GPS...",
                    distance: ""
                }
            ];
            return;
        }
        if (!_isValidCoord(toLat, toLon)) {
            turnByTurnInstructions = [
                {
                    instruction: "Destination invalid",
                    distance: ""
                }
            ];
            return;
        }

        isNavigating = true;
        currentDestination = toName || "Destination";
        showNavPanel = false;

        destLat = toLat;
        destLon = toLon;

        // Quick header while we fetch
        turnByTurnInstructions = [
            {
                instruction: "Calculating route...",
                distance: ""
            }
        ];

        requestRoute(currentLat, currentLon, destLat, destLon);

        // Follow current position with gentle animation
        followTimer.restart();
    }

    function stopNavigation() {
        isNavigating = false;
        currentDestination = "";
        destLat = NaN;
        destLon = NaN;
        routePath = [];
        totalDistanceMeters = 0;
        totalDurationSeconds = 0;
        turnByTurnInstructions = [];
        followTimer.stop();
        // Re-center on current position
        if (_isValidCoord(currentLat, currentLon)) {
            map.center = _coord(currentLat, currentLon);
        }
    }

    // --- Location ---
    PositionSource {
        id: positionSource
        active: true
        updateInterval: 2000

        onPositionChanged: {
            var lat = position.coordinate.latitude;
            var lon = position.coordinate.longitude;

            if (_isValidCoord(lat, lon)) {
                currentLat = lat;
                currentLon = lon;

                // If navigating, keep map following (but not too jumpy)
                if (isNavigating) {
                    // map center update is handled by followTimer for smoothness
                } else {
                    map.center = _coord(currentLat, currentLon);
                }
            }
        }
    }

    // Smooth follow of GPS while navigating
    Timer {
        id: followTimer
        interval: 700
        repeat: true
        running: false
        onTriggered: {
            if (!isNavigating)
                return;
            if (!_isValidCoord(currentLat, currentLon))
                return;
            map.center = _coord(currentLat, currentLon);
        }
    }

    // --- Map plugin (OSM) ---
    Plugin {
        id: mapPlugin
        name: "osm"
        // Default OSM tiles. If you want dark tiles, see note below.
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#0F1419"

            Map {
                id: map
                anchors.fill: parent
                plugin: mapPlugin
                zoomLevel: 15
                center: _coord(38.7223, -9.1393) // default Lisbon

                // Current position marker
                MapQuickItem {
                    id: currentMarker
                    anchorPoint.x: 8
                    anchorPoint.y: 8
                    coordinate: _isValidCoord(currentLat, currentLon) ? _coord(currentLat, currentLon) : map.center
                    sourceItem: Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        color: "#0066ff"
                        border.color: "#ffffff"
                        border.width: 2
                    }
                }

                // Destination marker
                MapQuickItem {
                    id: destMarker
                    visible: isNavigating && _isValidCoord(destLat, destLon)
                    anchorPoint.x: 8
                    anchorPoint.y: 8
                    coordinate: _coord(destLat, destLon)
                    sourceItem: Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        color: "#ff3333"
                        border.color: "#ffffff"
                        border.width: 2
                    }
                }

                // Route polyline
                MapPolyline {
                    id: routeLine
                    visible: isNavigating && routePath && routePath.length > 1
                    line.width: 6
                    line.color: "#00bfff"
                    path: routePath
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
        visible: !isNavigating

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

            Text {
                text: "Start: " + (currentLat ? currentLat.toFixed(4) : "—") + ", " + (currentLon ? currentLon.toFixed(4) : "—")
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

    // Navigation panel overlay (destination chooser)
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
                text: "Destination (coords):"
                color: "#999999"
                font.pixelSize: 10
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

            TextField {
                id: destinationInput
                Layout.fillWidth: true
                placeholderText: "Name (optional)"
                color: "#ffffff"
                font.pixelSize: 11
                background: Rectangle {
                    color: "#1e1e1e"
                    border.color: destinationInput.focus ? "#0066ff" : "#444"
                    border.width: 1
                    radius: 4
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: "🚗 START NAVIGATION"
                enabled: latInput.text !== "" && lonInput.text !== ""
                onClicked: {
                    var lat = _parseNumberOrNaN(latInput.text);
                    var lon = _parseNumberOrNaN(lonInput.text);
                    var name = destinationInput.text || "Destination";
                    startWazeMode(lat, lon, name);
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

    // Initial centering once we get GPS
    Component.onCompleted: {
        // If GPS never comes, keep Lisbon default.
        // Once we get a valid coordinate, PositionSource will center the map.
    }
}
