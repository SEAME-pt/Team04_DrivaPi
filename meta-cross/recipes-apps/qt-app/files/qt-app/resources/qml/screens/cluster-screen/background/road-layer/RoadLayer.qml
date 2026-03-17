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

    // ===== Horizon integration: blur + fade (top only) =====
    // Simplified horizon blend without MultiEffect
    Item {
        id: horizonBlend
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: roadWindow.anchors.topMargin + 180 * root.sy
        clip: true
        z: 4

        // Blurred road image (using opacity/scale for subtle effect)
        Image {
            x: roadImg1.x
            y: roadImg1.y
            width: roadImg1.width
            height: roadImg1.height
            source: roadImg1.source
            fillMode: Image.PreserveAspectCrop
            smooth: true
            opacity: 0.15
            scale: 1.05  // Slightly enlarged for blur effect
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop {
                    position: 0.00
                    color: AppTheme.alpha(AppTheme.colors.surface, 1.0)
                }
                GradientStop {
                    position: 0.35
                    color: AppTheme.alpha(AppTheme.colors.surface, 0.8)
                }
                GradientStop {
                    position: 0.70
                    color: AppTheme.alpha(AppTheme.colors.surface, 0.88)
                }
                GradientStop {
                    position: 1.00
                    color: AppTheme.alpha(AppTheme.colors.surface, 0.0)
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop {
                    position: 0.00
                    color: AppTheme.alpha(AppTheme.colors.surface, 1.0)
                }
                GradientStop {
                    position: 0.55
                    color: AppTheme.alpha(AppTheme.colors.surface, 0.56)
                }
                GradientStop {
                    position: 1.00
                    color: AppTheme.alpha(AppTheme.colors.surface, 0.0)
                }
            }
            opacity: 0.55
        }
    }

    // ===== Center dashed lane line =====
    Item {
        id: laneLines
        width: roadWindow.roadW
        x: (parent.width - width) / 2
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        z: 3
        visible: true
        clip: true

        readonly property real startY: roadWindow.anchors.topMargin + 120 * root.sy
        readonly property int dashCount: 12
        readonly property real dashBaseH: 26 * root.sy
        readonly property real travel: (height - startY) + dashBaseH * 2

        function dashY(i) {
            return startY - dashBaseH + root.wrap01(root.motionPhase + (i / dashCount)) * travel;
        }
        function tForY(y) {
            return root.clamp((y - startY + dashBaseH) / travel, 0, 1);
        }
        function dashW(y) {
            var t = tForY(y);
            return (2.0 + 8.0 * t) * root.s;
        }
        function dashH(y) {
            var t = tForY(y);
            return dashBaseH * (0.30 + 0.70 * t);
        }
        function dashOpacity(y) {
            var t = tForY(y);
            var baseOpacity = 0.12 + 0.18 * root.motionIntensity;
            return baseOpacity * Math.pow(t, 1.35);
        }

        Repeater {
            model: laneLines.dashCount
            Rectangle {
                property real yy: laneLines.dashY(index)
                y: yy
                width: laneLines.dashW(yy)
                height: laneLines.dashH(yy)
                x: (parent.width - width) / 2
                radius: width / 2
                color: AppTheme.colors.primary
                opacity: laneLines.dashOpacity(yy)
            }
        }
    }

    // ===== Two faint "flow lines" =====
    Item {
        id: laneFlow
        width: roadWindow.roadW * 0.45
        x: (parent.width - width) / 2
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        z: 3
        visible: true
        clip: true

        readonly property real startY: roadWindow.anchors.topMargin + 140 * root.sy
        readonly property int streakCount: 8
        readonly property real baseLen: 80 * root.sy
        readonly property real travel: (height - startY) + baseLen * 2

        function yFor(i) {
            return startY - baseLen + root.wrap01(root.motionPhase + (i / streakCount)) * travel;
        }
        function tForY(y) {
            return root.clamp((y - startY + baseLen) / travel, 0, 1);
        }
        function xOffset(t) {
            return (8 + 20 * t) * root.s;
        }

        Repeater {
            model: laneFlow.streakCount
            Item {
                property real yy: laneFlow.yFor(index)
                readonly property real t: laneFlow.tForY(yy)

                y: yy
                width: parent.width
                height: laneFlow.baseLen * (0.4 + 0.8 * t) * (0.6 + 0.6 * root.motionIntensity)

                readonly property real a: (0.15 + 0.25 * root.motionIntensity) * Math.pow(t, 1.2)
                readonly property real w: (2.0 + 4.0 * t) * root.s

                Rectangle {
                    x: (parent.width / 2) - laneFlow.xOffset(parent.t) - (parent.w / 2)
                    width: parent.w
                    height: parent.height
                    radius: width / 2
                    color: AppTheme.colors.primary
                    opacity: parent.a
                }

                Rectangle {
                    x: (parent.width / 2) + laneFlow.xOffset(parent.t) - (parent.w / 2)
                    width: parent.w
                    height: parent.height
                    radius: width / 2
                    color: AppTheme.colors.primary
                    opacity: parent.a
                }
            }
        }
    }

    // --- Motion Shadows (3 bands) ---
    Item {
        id: motionShadows
        anchors.fill: parent
        z: 2

        readonly property real bandH: Math.max(40 * root.sy, parent.height * 0.22)
        readonly property real travel: parent.height + bandH * 2

        function bandY(offset) {
            return -bandH + root.wrap01(root.motionPhase + offset) * travel;
        }

        Rectangle {
            width: roadWindow.roadW * 0.98
            height: motionShadows.bandH
            x: (parent.width - width) / 2
            y: motionShadows.bandY(0.00)
            radius: 22 * root.s
            opacity: 0.08 + 0.18 * root.motionIntensity
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: AppTheme.alpha(AppTheme.colors.text, 0.0)
                }
                GradientStop {
                    position: 0.5
                    color: AppTheme.colors.text
                }
                GradientStop {
                    position: 1.0
                    color: AppTheme.alpha(AppTheme.colors.text, 0.0)
                }
            }
        }

        Rectangle {
            width: roadWindow.roadW * 0.95
            height: motionShadows.bandH * 0.85
            x: (parent.width - width) / 2
            y: motionShadows.bandY(0.33)
            radius: 22 * root.s
            opacity: 0.06 + 0.14 * root.motionIntensity
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: AppTheme.alpha(AppTheme.colors.text, 0.0)
                }
                GradientStop {
                    position: 0.5
                    color: AppTheme.colors.text
                }
                GradientStop {
                    position: 1.0
                    color: AppTheme.alpha(AppTheme.colors.text, 0.0)
                }
            }
        }

        Rectangle {
            width: roadWindow.roadW * 0.92
            height: motionShadows.bandH * 0.75
            x: (parent.width - width) / 2
            y: motionShadows.bandY(0.66)
            radius: 22 * root.s
            opacity: 0.05 + 0.10 * root.motionIntensity
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: AppTheme.alpha(AppTheme.colors.text, 0.0)
                }
                GradientStop {
                    position: 0.5
                    color: AppTheme.colors.text
                }
                GradientStop {
                    position: 1.0
                    color: AppTheme.alpha(AppTheme.colors.text, 0.0)
                }
            }
        }
    }

    //===== FOG GRADIENT OVERLAYS =====
    //Fog cap: subtle horizon fade
    FogLayer {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: roadWindow.anchors.topMargin + 180 * root.sy
        topProtectionHeight: roadWindow.anchors.topMargin
        z: 5
    }
}