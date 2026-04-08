import AppKit
import SwiftUI

enum EditorTheme: String, CaseIterable, Identifiable {
    case light = "light"
    case dark = "dark"
    case system = "system"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .light: return "浅色"
        case .dark: return "深色"
        case .system: return "跟随系统"
        }
    }

    var isDark: Bool {
        switch self {
        case .dark: return true
        case .light: return false
        case .system:
            return NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        }
    }

    var backgroundColor: NSColor {
        isDark ? NSColor(hex: "1E1E1E") : NSColor(hex: "FFFFFF")
    }

    var textColor: NSColor {
        isDark ? NSColor(hex: "D4D4D4") : NSColor(hex: "1E1E1E")
    }

    var gutterColor: NSColor {
        isDark ? NSColor(hex: "252526") : NSColor(hex: "F3F3F3")
    }

    var gutterTextColor: NSColor {
        isDark ? NSColor(hex: "858585") : NSColor(hex: "999999")
    }

    var selectionColor: NSColor {
        isDark ? NSColor(hex: "264F78") : NSColor(hex: "ADD6FF")
    }

    var cursorColor: NSColor {
        isDark ? NSColor(hex: "AEAFAD") : NSColor(hex: "000000")
    }
}

extension NSColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
