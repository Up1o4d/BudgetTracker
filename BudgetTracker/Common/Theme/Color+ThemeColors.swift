import SwiftUI

extension Color {
    // MARK: - Surface

    static let bgCanvas = Color(light: Palette.cream, dark: Palette.ink)
    static let bgSurface = Color(light: Palette.white, dark: Palette.graphite)
    static let bgSurfaceAlt = Color(light: Palette.warmGray, dark: Palette.charcoal)
    static let borderSubtle = Color(light: Palette.black.opacity(0.08), dark: Palette.white.opacity(0.07))

    // MARK: - Text

    static let textPrimary = Color(light: Palette.ink, dark: Palette.white)
    static let textSecondary = Color(light: Palette.black.opacity(0.55), dark: Palette.white.opacity(0.55))
    static let textTertiary = Color(light: Palette.black.opacity(0.35), dark: Palette.white.opacity(0.35))
    static let textOnAccent = Color(light: Palette.ink, dark: Palette.ink)

    // MARK: - Accent (light value is the darkened variant for legibility on white)

    static let accentLime = Color(light: Palette.limeMuted, dark: Palette.limeVibrant)
    static let accentPink = Color(light: Palette.pinkMuted, dark: Palette.pinkVibrant)
    static let accentCyan = Color(light: Palette.cyanMuted, dark: Palette.cyanVibrant)
    static let accentAmber = Color(light: Palette.amberMuted, dark: Palette.amberVibrant)
    static let accentViolet = Color(light: Palette.violetMuted, dark: Palette.violetVibrant)

    // MARK: - Status

    static let statusPositive = Color(light: Palette.green, dark: Palette.teal)
    static let statusNegative = Color(light: Palette.redMuted, dark: Palette.redBright)
    static let statusNeutral = Color(light: Palette.black.opacity(0.35), dark: Palette.white.opacity(0.18))
    static let statusInfo = Color(light: Palette.blueMuted, dark: Palette.blueBright)

    // MARK: - Category (constant across modes — sit on tinted fills)

    static let catGroceries = Palette.limeVibrant
    static let catDining = Palette.pinkSoft
    static let catTransport = Palette.blueBright
    static let catShopping = Palette.violetSoft
    static let catBills = Palette.amberVibrant
    static let catEntertainment = Palette.teal
    static let catHealth = Palette.orange
    static let catOther = Palette.systemGray

    // MARK: - Chrome

    static let chromeIsland = Color(light: Palette.black, dark: Palette.black)
    static let chromeHandle = Color(light: Palette.black.opacity(0.30), dark: Palette.white.opacity(0.70))
}
