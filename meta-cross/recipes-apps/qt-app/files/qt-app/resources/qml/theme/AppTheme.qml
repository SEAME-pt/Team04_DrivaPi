pragma Singleton
import QtQuick

QtObject {
    id: theme

    // Master switch for the UI. We will toggle this from main.qml
    property bool isDark: true

    // ====== COLOR PALETTE ======
    readonly property QtObject colors: QtObject {
        // Primary branding (Deepen the blue in light mode for better contrast)
        readonly property color primary: theme.isDark? "#00BFFF" : "#0066CC"
        readonly property color primaryDark: theme.isDark? "#0056B3" : "#004C99"

        // Surfaces (Dark: Deep space black | Light: Soft cool gray to reduce glare)
        readonly property color surface: theme.isDark? "#05080e" : "#E8ECEF"
        readonly property color surfaceVariant: theme.isDark? "#0a0f18" : "#D9E1E8"
        readonly property color surfaceElevated: theme.isDark? "#131b26" : "#FFFFFF"

        // Text (High contrast without harsh pure black)
        readonly property color text: theme.isDark? "#FFFFFF" : "#1A222B"
        readonly property color textSecondary: theme.isDark? "#8FA4B8" : "#5C6A79"
        readonly property color textTertiary: theme.isDark? "#6A7A8A" : "#8A9BAE"

        // Semantic colors
        readonly property color success: "#4ACA5C"
        readonly property color warning: "#FFA500"
        readonly property color error: "#FF3B30"
        readonly property color info: "#2196F3"

        // UI elements
        readonly property color divider: theme.isDark? "#1A2535" : "#C4D0DB"
        readonly property color border: theme.isDark? "#232a35" : "#B3C2D1"
    }

    // ====== TYPOGRAPHY ======
    readonly property QtObject typography: QtObject {
        // Font families
        readonly property string fontFamily: "Roboto"
        readonly property string fontMonospace: "Courier New"

        // Sizes (in points)
        readonly property int displayLarge: 32
        readonly property int displayMedium: 28
        readonly property int displaySmall: 24

        readonly property int headlineLarge: 24
        readonly property int headlineMedium: 20
        readonly property int headlineSmall: 18

        readonly property int bodyLarge: 16
        readonly property int bodyMedium: 14
        readonly property int bodySmall: 12

        readonly property int labelLarge: 14
        readonly property int labelMedium: 12
        readonly property int labelSmall: 11

        // Font weights
        readonly property int weightLight: 300
        readonly property int weightRegular: 400
        readonly property int weightMedium: 500
        readonly property int weightBold: 700

        // Line heights
        readonly property real lineHeightTight: 1.2
        readonly property real lineHeightNormal: 1.5
        readonly property real lineHeightRelaxed: 1.75
    }

    // ====== SPACING ======
    readonly property QtObject spacing: QtObject {
        readonly property int xxSmall: 2
        readonly property int xSmall: 4
        readonly property int small: 8
        readonly property int medium: 16
        readonly property int large: 24
        readonly property int xLarge: 32
        readonly property int xxLarge: 48

        // Common sizes
        readonly property int padding: 16
        readonly property int margin: 24
        readonly property int gutter: 8
    }

    // ====== CORNER RADIUS ======
    readonly property QtObject radius: QtObject {
        readonly property int none: 0
        readonly property int small: 4
        readonly property int medium: 8
        readonly property int large: 12
        readonly property int xLarge: 16
        readonly property int full: 9999
    }

    // ====== SHADOWS ======
    readonly property QtObject shadows: QtObject {
        readonly property int elevationNone: 0
        readonly property int elevationSmall: 2
        readonly property int elevationMedium: 4
        readonly property int elevationLarge: 8
        readonly property int elevationXLarge: 16
    }

    // ====== ANIMATION DURATIONS ======
    readonly property QtObject animation: QtObject {
        readonly property int instant: 0
        readonly property int fast: 100
        readonly property int normal: 300
        readonly property int slow: 500
        readonly property int slowest: 1000
    }

    // ====== COMPONENT SIZES ======
    readonly property QtObject sizes: QtObject {
        readonly property int buttonMinHeight: 48
        readonly property int buttonMinWidth: 48
        readonly property int iconSmall: 16
        readonly property int iconMedium: 24
        readonly property int iconLarge: 32
        readonly property int iconXLarge: 48
        readonly property int gauge: 280
        readonly property int card: 200
    }

    // ====== HELPER FUNCTIONS ======
    function tint(color, amount) {
        var c = Qt.darker(color, 1 + amount);
        return c;
    }

    function shade(color, amount) {
        return Qt.lighter(color, 1 + amount);
    }

    function alpha(color, opacity) {
        var a = Qt.rgba(color.r, color.g, color.b, opacity);
        return a;
    }
}
