import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../../../theme"

Item {
    id: roadWindow
    z: 0
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.top: parent.top
    anchors.topMargin: root.clamp(parent.height * root.horizonMarginRatio, 64 * root.sy, 130 * root.sy)
    clip: true

    property real roadW: width * root.roadWidthFactor
    property real roadH: height * root.roadHeightFactor
    property real baseY: -height * Math.abs(root.roadBaseOffset)

    readonly property bool laneDataAvailable: root.vehicleDataAvailable
                                         && vehicleData.laneOffset !== undefined
                                         && vehicleData.laneHeading !== undefined
    readonly property bool laneMaskActive: laneDataAvailable || root.demoLaneAnimation

    readonly property real laneOffsetGain: 2.4
    readonly property real laneHeadingGain: 3.0
    readonly property real laneOffsetVisual: laneDataAvailable
                                            ? root.clamp(vehicleData.laneOffset * laneOffsetGain, -1.0, 1.0)
                                            : (root.demoLaneAnimation ? Math.sin(root.motionPhase * 6.28318530718) * 0.35 : 0.0)
    readonly property real laneHeadingVisual: laneDataAvailable
                                             ? root.clamp(vehicleData.laneHeading * laneHeadingGain, -1.0, 1.0)
                                             : (root.demoLaneAnimation ? Math.sin((root.motionPhase * 6.28318530718) + 1.2) * 0.45 : 0.0)

    Image {
        id: roadImg1
        anchors.horizontalCenter: parent.horizontalCenter
        width: roadWindow.roadW
        height: roadWindow.roadH
        y: roadWindow.baseY
        source: "qrc:/assets/cluster/road.png"
        fillMode: Image.PreserveAspectCrop
        smooth: true
        opacity: roadWindow.laneMaskActive ? 0.0 : 0.95
    }

    Image {
        id: roadImg2
        visible: false
        source: "qrc:/assets/cluster/road.png"
    }

    Canvas {
        id: laneMaskCanvas
        anchors.fill: parent
        z: 2
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            if (!roadWindow.laneMaskActive)
                return;

            var horizonY = roadWindow.anchors.topMargin + 98 * root.sy;
            var bottomY = height + 12 * root.sy;
            var centerX = width / 2;
            var offsetPx = roadWindow.laneOffsetVisual * roadWindow.roadW * 0.24;
            var curvePx = roadWindow.laneHeadingVisual * roadWindow.roadW * 0.34;
            var laneHalfWidth = roadWindow.roadW * 0.19;
            var outerHalfWidth = roadWindow.roadW * 0.28;
            var controlY = horizonY + (bottomY - horizonY) * 0.58;

            function drawLaneBand(halfWidth, bandColor, coreAlpha, glowAlpha, bandWidth) {
                var leftTop = centerX + offsetPx - halfWidth;
                var rightTop = centerX + offsetPx + halfWidth;
                var leftBottom = centerX + offsetPx - halfWidth + curvePx * 0.95;
                var rightBottom = centerX + offsetPx + halfWidth + curvePx * 0.95;
                var leftCtrl = centerX + offsetPx - halfWidth + curvePx * 0.45;
                var rightCtrl = centerX + offsetPx + halfWidth + curvePx * 0.45;

                ctx.save();
                ctx.shadowColor = AppTheme.alpha(bandColor, glowAlpha);
                ctx.shadowBlur = bandWidth * 1.4;
                ctx.strokeStyle = AppTheme.alpha(bandColor, glowAlpha);
                ctx.lineCap = "round";
                ctx.lineJoin = "round";
                ctx.lineWidth = bandWidth * 1.35;
                ctx.beginPath();
                ctx.moveTo(leftTop, horizonY);
                ctx.quadraticCurveTo(leftCtrl, controlY, leftBottom, bottomY);
                ctx.moveTo(rightTop, horizonY);
                ctx.quadraticCurveTo(rightCtrl, controlY, rightBottom, bottomY);
                ctx.stroke();
                ctx.restore();

                ctx.save();
                ctx.strokeStyle = AppTheme.alpha(bandColor, coreAlpha);
                ctx.lineCap = "round";
                ctx.lineJoin = "round";
                ctx.lineWidth = bandWidth;
                ctx.beginPath();
                ctx.moveTo(leftTop, horizonY);
                ctx.quadraticCurveTo(leftCtrl, controlY, leftBottom, bottomY);
                ctx.moveTo(rightTop, horizonY);
                ctx.quadraticCurveTo(rightCtrl, controlY, rightBottom, bottomY);
                ctx.stroke();
                ctx.restore();
            }

            drawLaneBand(outerHalfWidth, "#41ff3d", 0.90, 0.38, 11 * root.s);
            drawLaneBand(laneHalfWidth, "#ffe82a", 0.92, 0.40, 12 * root.s);
            drawLaneBand(outerHalfWidth + 0.06 * roadWindow.roadW, "#ff3a1c", 0.88, 0.36, 10 * root.s);
        }

        Connections {
            target: root.vehicleDataAvailable ? vehicleData : null
            function onLaneOffsetChanged() { laneMaskCanvas.requestPaint(); }
            function onLaneHeadingChanged() { laneMaskCanvas.requestPaint(); }
        }

        Connections {
            target: root
            function onMotionPhaseChanged() {
                if (roadWindow.laneMaskActive)
                    laneMaskCanvas.requestPaint();
            }
            function onDemoLaneAnimationChanged() { laneMaskCanvas.requestPaint(); }
            function onVehicleDataAvailableChanged() { laneMaskCanvas.requestPaint(); }
        }

        Component.onCompleted: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    // ===== Horizon integration: blur + fade (top only) =====
    Item {
        id: horizonBlend
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: roadWindow.anchors.topMargin + 180 * root.sy
        clip: true
        z: 4
        visible: !roadWindow.laneMaskActive

        Image {
            x: roadImg1.x
            y: roadImg1.y
            width: roadImg1.width
            height: roadImg1.height
            source: roadImg1.source
            fillMode: Image.PreserveAspectCrop
            smooth: true
            opacity: 0.15
            scale: 1.05
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.00; color: AppTheme.alpha(AppTheme.colors.surface, 1.0) }
                GradientStop { position: 0.35; color: AppTheme.alpha(AppTheme.colors.surface, 0.8) }
                GradientStop { position: 0.70; color: AppTheme.alpha(AppTheme.colors.surface, 0.88) }
                GradientStop { position: 1.00; color: AppTheme.alpha(AppTheme.colors.surface, 0.0) }
            }
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.00; color: AppTheme.alpha(AppTheme.colors.surface, 1.0) }
                GradientStop { position: 0.55; color: AppTheme.alpha(AppTheme.colors.surface, 0.56) }
                GradientStop { position: 1.00; color: AppTheme.alpha(AppTheme.colors.surface, 0.0) }
            }
            opacity: 0.55
        }
    }

    // ===== FOG GRADIENT OVERLAYS =====
    FogLayer {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: roadWindow.anchors.topMargin + 180 * root.sy
        topProtectionHeight: roadWindow.anchors.topMargin
        z: 5
        visible: !roadWindow.laneMaskActive
    }
}
