import SwiftUI

extension Color {
    // MARK: - Surface

    static let bgCanvas = Color(
        light: Color(hex: "#F4F3EE"),
        dark: Color(hex: "#0A0A0B")
    )

    static let bgSurface = Color(
        light: Color(hex: "#FFFFFF"),
        dark: Color(hex: "#141416")
    )

    static let bgSurfaceAlt = Color(
        light: Color(hex: "#EDEBE3"),
        dark: Color(hex: "#1C1C1F")
    )

    static let borderSubtle = Color(
        light: Color(hex: "#000000").opacity(0.08),
        dark: Color(hex: "#FFFFFF").opacity(0.07)
    )

    // MARK: - Text

    static let textPrimary = Color(
        light: Color(hex: "#0A0A0B"),
        dark: Color(hex: "#FFFFFF")
    )

    static let textSecondary = Color(
        light: Color(hex: "#000000").opacity(0.55),
        dark: Color(hex: "#FFFFFF").opacity(0.55)
    )

    static let textTertiary = Color(
        light: Color(hex: "#000000").opacity(0.35),
        dark: Color(hex: "#FFFFFF").opacity(0.35)
    )

    static let textOnAccent = Color(
        light: Color(hex: "#0A0A0B"),
        dark: Color(hex: "#0A0A0B")
    )

    // MARK: - Accent (light value is the darkened variant for legibility on white)

    static let accentLime = Color(
        light: Color(hex: "#A8CC1F"),
        dark: Color(hex: "#D4FF3A")
    )

    static let accentPink = Color(
        light: Color(hex: "#E62E70"),
        dark: Color(hex: "#FF4D8F")
    )

    static let accentCyan = Color(
        light: Color(hex: "#1FBDDB"),
        dark: Color(hex: "#4DE8FF")
    )

    static let accentAmber = Color(
        light: Color(hex: "#DB8E1F"),
        dark: Color(hex: "#FFB84D")
    )

    static let accentViolet = Color(
        light: Color(hex: "#8B4DDB"),
        dark: Color(hex: "#B87DFF")
    )

    // MARK: - Status

    static let statusPositive = Color(
        light: Color(hex: "#00A676"),
        dark: Color(hex: "#4DE8C0")
    )

    static let statusNegative = Color(
        light: Color(hex: "#D1453B"),
        dark: Color(hex: "#FF6B6B")
    )

    static let statusNeutral = Color(
        light: Color(hex: "#000000").opacity(0.35),
        dark: Color(hex: "#FFFFFF").opacity(0.18)
    )

    static let statusInfo = Color(
        light: Color(hex: "#2A6FDB"),
        dark: Color(hex: "#6BB9FF")
    )

    // MARK: - Category (constant across modes — sit on tinted fills)

    static let catGroceries = Color(hex: "#D4FF3A")
    static let catDining = Color(hex: "#FF6B9D")
    static let catTransport = Color(hex: "#6BB9FF")
    static let catShopping = Color(hex: "#C79BFF")
    static let catBills = Color(hex: "#FFB84D")
    static let catEntertainment = Color(hex: "#4DE8C0")
    static let catHealth = Color(hex: "#FF8A65")
    static let catOther = Color(hex: "#8E8E93")

    // MARK: - Chrome

    static let chromeIsland = Color(
        light: Color(hex: "#000000"),
        dark: Color(hex: "#000000")
    )

    static let chromeHandle = Color(
        light: Color(hex: "#000000").opacity(0.30),
        dark: Color(hex: "#FFFFFF").opacity(0.70)
    )
}
