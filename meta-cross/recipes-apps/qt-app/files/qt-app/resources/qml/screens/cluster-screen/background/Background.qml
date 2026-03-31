import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../theme"
import "road-layer"
    
    
Item {
    id: backgroundLayer
    anchors.fill: parent
    z: 0

    // --- Glow Layers (top, center-left, center-right, bottom) ---
    GlowLayers {
        anchors.fill: parent
        s: root.s
        z: 1
    }

    // ==========================================================
    // ROAD LAYER (road.png is the only lane source)
    // ==========================================================
    RoadLayer {
        anchors.fill: parent
        z: 0
    }
}