import QtQuick

/**
 * @file AppTheme.qml
 * @brief Global theme and styling system for HMI
 * 
 * Provides centralized color palette, typography, and spacing definitions.
 * Import as: import "theme"
 * Usage: AppTheme.colors.primary, AppTheme.spacing.medium, etc.
 */

QtObject {
    id: theme
    
    // ====== COLOR PALETTE ======
    readonly property QtObject colors: QtObject {
        // Primary branding
        readonly property color primary: "#0084FF"        // Cyan/Blue
        readonly property color primaryDark: "#0056B3"
        
        // Surfaces and backgrounds
        readonly property color surface: "#1a1a1a"        // Very dark gray
        readonly property color surfaceVariant: "#2a2a2a"
        readonly property color surfaceElevated: "#3a3a3a"
        
        // Text
        readonly property color text: "#FFFFFF"           // White
        readonly property color textSecondary: "#B0B0B0"
        readonly property color textTertiary: "#808080"
        
        // Semantic colors
        readonly property color success: "#4ACA5C"        // Green
        readonly property color warning: "#FFA500"        // Amber/Orange
        readonly property color error: "#FF3B30"          // Red
        readonly property color info: "#2196F3"           // Light Blue
        
        // Status colors
        readonly property color online: "#4ACA5C"
        readonly property color offline: "#FF3B30"
        readonly property color connecting: "#FFA500"
        
        // UI elements
        readonly property color accentAccent: "#FF6B35"   // Orange accent
        readonly property color divider: "#404040"
        readonly property color border: "#505050"
    }
    
    // ====== TYPOGRAPHY ======
    readonly property QtObject typography: QtObject {
        // Font families
        readonly property string fontFamily: "Roboto, sans-serif"
        readonly property string fontMonospace: "Courier New, monospace"
        
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
