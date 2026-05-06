# Theming

All design tokens are defined under `BudgetTracker/Design/Theme/` and applied through extensions in `BudgetTracker/Design/Extensions/`. Colors and typography flow through a two-layer token system: a raw palette layer that names hex values, and a semantic layer that maps roles to palette entries. Views only consume the semantic layer, which means brand changes are a single-file edit and dark mode adapts automatically. Typography tokens bundle font, line spacing, tracking, and text case together so that text styling can't be partially applied — applying a token applies all four properties or none.

---

## Directory layout

```
Design/
├── Theme/
│   ├── Color+Palette.swift       # Raw named colors
│   ├── Color+ThemeColors.swift   # Semantic color constants
│   └── AppTextStyle.swift        # Typography token definitions
└── Extensions/
    ├── Color+Hex.swift            # Color(hex:) initializer
    ├── Color+LightDarkInit.swift  # Color(light:dark:) initializer
    ├── View+textStyle.swift       # .textStyle(_:) modifier
    └── View+DefaultScreenStyle.swift  # .defaultScreenStyle() modifier
```

---

## Color system

Colors flow through two layers: **palette → semantic**. Views only ever reference semantic names.

### Layer 1 — Palette (`Color+Palette.swift`)

`Color.Palette` is a caseless enum of raw static colors. Colors are defined as hex strings using the `Color(hex:)` initializer.

```swift
extension Color {
    enum Palette {
        // Neutrals
        static let ink        = Color(hex: "#0A0A0B")
        static let cream      = Color(hex: "#F4F3EE")
        static let graphite   = Color(hex: "#141416")
        static let warmGray   = Color(hex: "#EDEBE3")
        static let charcoal   = Color(hex: "#1C1C1F")
        static let systemGray = Color(hex: "#8E8E93")

        // Alpha variants
        static let blackA08 = black.opacity(0.08)
        static let blackA30 = black.opacity(0.30)
        static let blackA35 = black.opacity(0.35)
        static let blackA55 = black.opacity(0.55)
        static let whiteA07 = white.opacity(0.07)
        static let whiteA18 = white.opacity(0.18)
        static let whiteA35 = white.opacity(0.35)
        static let whiteA55 = white.opacity(0.55)
        static let whiteA70 = white.opacity(0.70)

        // Accent hues (vibrant = dark-mode value, muted = light-mode value)
        static let limeVibrant  = Color(hex: "#D4FF3A")
        static let limeMuted    = Color(hex: "#A8CC1F")
        static let pinkVibrant  = Color(hex: "#FF4D8F")
        static let pinkMuted    = Color(hex: "#E62E70")
        static let pinkSoft     = Color(hex: "#FF6B9D")
        static let cyanVibrant  = Color(hex: "#4DE8FF")
        static let cyanMuted    = Color(hex: "#1FBDDB")
        static let blueBright   = Color(hex: "#6BB9FF")
        static let blueMuted    = Color(hex: "#2A6FDB")
        static let amberVibrant = Color(hex: "#FFB84D")
        static let amberMuted   = Color(hex: "#DB8E1F")
        static let violetVibrant = Color(hex: "#B87DFF")
        static let violetMuted  = Color(hex: "#8B4DDB")
        static let violetSoft   = Color(hex: "#C79BFF")
        static let green        = Color(hex: "#00A676")
        static let teal         = Color(hex: "#4DE8C0")
        static let redBright    = Color(hex: "#FF6B6B")
        static let redMuted     = Color(hex: "#D1453B")
        static let orange       = Color(hex: "#FF8A65")
    }
}
```

Never use palette colors directly in views. They are an implementation detail of the semantic layer.

### Layer 2 — Semantic colors (`Color+ThemeColors.swift`)

Semantic constants are static members on `Color`, grouped by role. Light/dark variants are encoded here using `Color(light:dark:)`.

```swift
extension Color {
    // Surface
    static let bgCanvas     = Color(light: Palette.cream,     dark: Palette.ink)
    static let bgSurface    = Color(light: Palette.white,     dark: Palette.graphite)
    static let bgSurfaceAlt = Color(light: Palette.warmGray,  dark: Palette.charcoal)
    static let borderSubtle = Color(light: Palette.blackA08,  dark: Palette.whiteA07)

    // Text
    static let textPrimary   = Color(light: Palette.ink,      dark: Palette.white)
    static let textSecondary = Color(light: Palette.blackA55, dark: Palette.whiteA55)
    static let textTertiary  = Color(light: Palette.blackA35, dark: Palette.whiteA35)
    static let textOnAccent  = Color(light: Palette.ink,      dark: Palette.ink)

    // Accent — light value is the muted/darkened variant for legibility on white backgrounds
    static let accentLime   = Color(light: Palette.limeMuted,   dark: Palette.limeVibrant)
    static let accentPink   = Color(light: Palette.pinkMuted,   dark: Palette.pinkVibrant)
    static let accentCyan   = Color(light: Palette.cyanMuted,   dark: Palette.cyanVibrant)
    static let accentAmber  = Color(light: Palette.amberMuted,  dark: Palette.amberVibrant)
    static let accentViolet = Color(light: Palette.violetMuted, dark: Palette.violetVibrant)

    // Status
    static let statusPositive = Color(light: Palette.green,    dark: Palette.teal)
    static let statusNegative = Color(light: Palette.redMuted,  dark: Palette.redBright)
    static let statusNeutral  = Color(light: Palette.blackA35,  dark: Palette.whiteA18)
    static let statusInfo     = Color(light: Palette.blueMuted,  dark: Palette.blueBright)

    // Category — constant across modes (sit on tinted fills, not plain backgrounds)
    static let catGroceries    = Palette.limeVibrant
    static let catDining       = Palette.pinkSoft
    static let catTransport    = Palette.blueBright
    static let catShopping     = Palette.violetSoft
    static let catBills        = Palette.amberVibrant
    static let catEntertainment = Palette.teal
    static let catHealth       = Palette.orange
    static let catOther        = Palette.systemGray

    // Chrome
    static let chromeIsland = Color(light: Palette.black,    dark: Palette.black)
    static let chromeHandle = Color(light: Palette.blackA30, dark: Palette.whiteA70)
}
```

**Key decisions:**
- Accent colors use their muted palette variant in light mode and vibrant variant in dark mode. This keeps contrast acceptable on the cream/white light-mode backgrounds.
- Category colors are mode-invariant because they are always rendered on a tinted fill (not directly on the background canvas), so they don't need adaptation.
- `textOnAccent` is `ink` in both modes — the accent fills (lime, pink, etc.) are light enough in both modes that dark text reads well on top.

---

## Light/dark mode infrastructure

### `Color(hex:)` — `Color+Hex.swift`

Parses 3-, 6-, or 8-character hex strings into `Color` values using the sRGB color space.

```swift
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255,
                  blue: Double(b)/255, opacity: Double(a)/255)
    }
}
```

### `Color(light:dark:)` — `Color+LightDarkInit.swift`

Creates an adaptive `Color` backed by a `UIColor` that resolves based on `UITraitCollection.userInterfaceStyle`. This is what allows semantic colors to change automatically with the system appearance.

```swift
extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            UIColor(traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}
```

---

## Typography

### `AppTextStyle` (`AppTextStyle.swift`)

A plain struct that groups the four properties SwiftUI needs to fully specify a text style:

```swift
struct AppTextStyle {
    let font: Font
    let lineSpacing: CGFloat   // default 0
    let tracking: CGFloat      // default 0
    let textCase: Text.Case?   // default nil
}
```

Predefined tokens are static members in an extension:

| Token | Font | Size | Weight | Notes |
|---|---|---|---|---|
| `displayXL` | system | 44 | Bold | Monospaced digits, tracking −1.2. Hero currency amounts. |
| `displayLG` | system | 30 | Bold | Monospaced digits, tracking −0.8. Dashboard numbers. |
| `titleLG` | largeTitle | — | Bold | Line spacing 7, tracking +0.4. Navigation titles. |
| `titleMD` | title2 | — | Bold | Monospaced digits, tracking −0.5. Trend card totals. |
| `titleSM` | headline | — | — | Tracking −0.3. Brand headers. |
| `bodyLG` | body | — | — | Tracking −0.43. Import/settings list rows. |
| `bodyMD` | subheadline | — | Medium | Default token. Merchant/category row labels. |
| `bodyMDSemibold` | subheadline | — | Semibold | Monospaced digits. Money values in rows. |
| `bodySM` | footnote | — | — | Card descriptors, avg/day labels. |
| `bodyXS` | caption | — | — | Inline metadata. |
| `eyebrow` | monospaced | 11 | Medium | Tracking +1.5, auto-uppercased. Section headers. |
| `metadata` | monospaced | 11 | Regular | Percentages, tags, list indices. |
| `delta` | monospaced | 11 | Semibold | Trend pills (▲/▼). |
| `code` | monospaced | 13 | Regular | Rule expressions on category-detail screen. |
| `buttonLG` | system | 16 | Semibold | Primary CTAs. |
| `chip` | system | 12 | Medium | Filter chips, category pills. |
| `tab` | system | 10 | Regular | Tab bar labels, inactive. Tracking +0.2. |
| `tabActive` | system | 10 | Semibold | Tab bar labels, active. Tracking +0.2. |

Tokens that show numbers use `.monospacedDigit()` so digits don't shift width as values change.

### Applying typography — `View+textStyle.swift`

```swift
extension View {
    func textStyle(_ style: AppTextStyle) -> some View {
        font(style.font)
            .lineSpacing(style.lineSpacing)
            .tracking(style.tracking)
            .textCase(style.textCase)
    }
}
```

Usage:

```swift
Text("$2,418")
    .textStyle(.displayXL)

Text("Groceries")
    .textStyle(.bodyMD)
```

---

## Screen-level defaults — `View+DefaultScreenStyle.swift`

`.defaultScreenStyle()` applies a complete baseline to any screen root in one call:

```swift
extension View {
    func defaultScreenStyle() -> some View {
        textStyle(.bodyMD)
            .foregroundStyle(Color.textPrimary)
            .tint(Color.accentLime)
            .background(Color.bgCanvas)
    }
}
```

This sets: `bodyMD` typography, `textPrimary` foreground, `accentLime` tint (controls system controls like toggles and buttons), and `bgCanvas` background. Apply it at the outermost view of every screen — child views override individual properties as needed.

---

## Example — `CategoryChip`

`CategoryChip` is a representative consumer of the theming system. It uses typography tokens, semantic colors, and the per-category color from the `Category` model:

```swift
struct CategoryChip: View {
    let category: Category

    var body: some View {
        HStack {
            Image(systemName: category.symbolName)
                .foregroundStyle(category.color)    // category color (cat* constant)
            Text(category.name)
                .textStyle(.chip)                   // typography token
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .foregroundStyle(Color.textSecondary)        // semantic text color
        .background(Capsule().foregroundStyle(Color.bgSurface))   // semantic surface
        .overlay(Capsule().stroke(Color.borderSubtle, lineWidth: 1))
    }
}
```

---

## Rules

1. **Never use palette colors in views.** Always go through the semantic layer (`Color.bgCanvas`, `Color.textPrimary`, etc.).
2. **Never hardcode hex or opacity values in views.** If a needed color doesn't exist as a semantic constant, add it to `Color+ThemeColors.swift`.
3. **Always use `AppTextStyle` tokens.** Don't call `.font(...)` directly in views.
4. **Call `.defaultScreenStyle()` at the root of every new screen.**
