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
        opacity: 0.95
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

            function fillLaneMask(halfWidth, topAlpha, bottomAlpha, strokeAlpha) {
                var leftTop = centerX + offsetPx - halfWidth;
                var rightTop = centerX + offsetPx + halfWidth;
                var leftBottom = centerX + offsetPx - halfWidth + curvePx * 0.95;
                var rightBottom = centerX + offsetPx + halfWidth + curvePx * 0.95;
                var leftCtrl = centerX + offsetPx - halfWidth + curvePx * 0.45;
                var rightCtrl = centerX + offsetPx + halfWidth + curvePx * 0.45;

                var fill = ctx.createLinearGradient(0, horizonY, 0, bottomY);
                fill.addColorStop(0.0, AppTheme.alpha(AppTheme.colors.primary, topAlpha));
                fill.addColorStop(0.45, AppTheme.alpha(AppTheme.colors.primary, (topAlpha + bottomAlpha) * 0.5));
                fill.addColorStop(1.0, AppTheme.alpha(AppTheme.colors.primary, bottomAlpha));

                ctx.beginPath();
                ctx.moveTo(leftTop, horizonY);
                ctx.quadraticCurveTo(leftCtrl, controlY, leftBottom, bottomY);
                ctx.lineTo(rightBottom, bottomY);
                ctx.quadraticCurveTo(rightCtrl, controlY, rightTop, horizonY);
                ctx.closePath();

                ctx.fillStyle = fill;
                ctx.fill();

                ctx.lineWidth = 2.2 * root.s;
                ctx.strokeStyle = AppTheme.alpha(AppTheme.colors.primary, strokeAlpha);
                ctx.stroke();
            }

            ctx.save();
            ctx.shadowColor = AppTheme.alpha(AppTheme.colors.primary, 0.30);
            ctx.shadowBlur = 22 * root.s;
            fillLaneMask(outerHalfWidth, 0.05, 0.14, 0.12);
            ctx.restore();

            ctx.save();
            ctx.shadowColor = AppTheme.alpha(AppTheme.colors.primary, 0.18);
            ctx.shadowBlur = 10 * root.s;
            fillLaneMask(laneHalfWidth, 0.10, 0.26, 0.20);
            ctx.restore();

            ctx.save();
            ctx.setLineDash([16 * root.s, 14 * root.s]);
            ctx.lineDashOffset = -root.motionPhase * 220 * root.s;
            ctx.lineCap = "round";
            ctx.lineWidth = 4.5 * root.s;
            ctx.strokeStyle = AppTheme.alpha(AppTheme.colors.surface, 0.65);
            ctx.beginPath();
            ctx.moveTo(centerX + offsetPx, horizonY);
            ctx.quadraticCurveTo(centerX + offsetPx + curvePx * 0.45, controlY, centerX + offsetPx + curvePx * 0.95, bottomY);
            ctx.stroke();
            ctx.restore();

            ctx.beginPath();
            ctx.moveTo(centerX + offsetPx - laneHalfWidth, horizonY);
            ctx.quadraticCurveTo(centerX + offsetPx - laneHalfWidth + curvePx * 0.45, controlY, centerX + offsetPx - laneHalfWidth + curvePx * 0.95, bottomY);
            ctx.strokeStyle = AppTheme.alpha(AppTheme.colors.text, 0.16);
            ctx.lineWidth = 1.5 * root.s;
            ctx.stroke();

            ctx.beginPath();
            ctx.moveTo(centerX + offsetPx + laneHalfWidth, horizonY);
            ctx.quadraticCurveTo(centerX + offsetPx + laneHalfWidth + curvePx * 0.45, controlY, centerX + offsetPx + laneHalfWidth + curvePx * 0.95, bottomY);
            ctx.strokeStyle = AppTheme.alpha(AppTheme.colors.text, 0.16);
            ctx.lineWidth = 1.5 * root.s;
            ctx.stroke();
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
    }
}
