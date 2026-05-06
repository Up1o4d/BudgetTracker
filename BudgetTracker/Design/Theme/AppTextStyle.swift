import SwiftUI

struct AppTextStyle {
    let font: Font
    let lineSpacing: CGFloat
    let tracking: CGFloat
    let textCase: Text.Case?

    init(
        font: Font,
        lineSpacing: CGFloat = 0,
        tracking: CGFloat = 0,
        textCase: Text.Case? = nil
    ) {
        self.font = font
        self.lineSpacing = lineSpacing
        self.tracking = tracking
        self.textCase = textCase
    }
}

// MARK: - Tokens

extension AppTextStyle {
    // ── Display ────────────────────────────────────────────────

    /// Insights hero — "$2,418". 44 / Bold, tabular figures.
    static let displayXL = AppTextStyle(
        font: .system(size: 44, weight: .bold, design: .default).monospacedDigit(),
        lineSpacing: 2,
        tracking: -1.2
    )

    /// Split-layout dashboard hero numbers + percentage deltas.
    static let displayLG = AppTextStyle(
        font: .system(size: 30, weight: .bold, design: .default).monospacedDigit(),
        tracking: -0.8
    )

    // ── Title ──────────────────────────────────────────────────

    /// iOS large navigation title.
    static let titleLG = AppTextStyle(
        font: .largeTitle.weight(.bold),
        lineSpacing: 7,
        tracking: 0.4
    )

    /// "Today" total in the trend card, secondary KPI labels.
    static let titleMD = AppTextStyle(
        font: .title2.weight(.bold).monospacedDigit(),
        tracking: -0.5
    )

    /// Brand header in the device chrome ("Meridian", "Insights").
    static let titleSM = AppTextStyle(
        font: .headline,
        tracking: -0.3
    )

    // ── Body ───────────────────────────────────────────────────

    /// Native iOS list rows (import preview, settings).
    static let bodyLG = AppTextStyle(
        font: .body,
        tracking: -0.43
    )

    /// Default merchant / category row label. Most-used token.
    static let bodyMD = AppTextStyle(
        font: .subheadline.weight(.medium)
    )

    /// Money values in transaction & category rows.
    static let bodyMDSemibold = AppTextStyle(
        font: .subheadline.weight(.semibold).monospacedDigit()
    )

    /// Secondary card descriptors, "avg/day" labels.
    static let bodySM = AppTextStyle(
        font: .footnote
    )

    /// Inline metadata: "of $3,200 budget", "vs March".
    static let bodyXS = AppTextStyle(
        font: .caption
    )

    // ── Mono · Data ────────────────────────────────────────────

    /// Section eyebrows above every card. Auto-uppercased.
    static let eyebrow = AppTextStyle(
        font: .system(size: 11, weight: .medium, design: .monospaced),
        tracking: 1.5,
        textCase: .uppercase
    )

    /// Inline mono — percentages, transaction tags, list-row indices.
    static let metadata = AppTextStyle(
        font: .system(size: 11, weight: .regular, design: .monospaced)
    )

    /// Trend pills "▲ 8.3%", "▼ 12%".
    static let delta = AppTextStyle(
        font: .system(size: 11, weight: .semibold, design: .monospaced)
    )

    /// Categorization rule expressions on the category-detail screen.
    static let code = AppTextStyle(
        font: .system(size: 13, weight: .regular, design: .monospaced)
    )

    // ── Interactive ────────────────────────────────────────────

    /// Primary CTAs ("Save & view dashboard", "Choose CSV file").
    static let buttonLG = AppTextStyle(
        font: .system(size: 16, weight: .semibold)
    )

    /// Filter chips, category pills.
    static let chip = AppTextStyle(
        font: .system(size: 12, weight: .medium)
    )

    /// Bottom-tab labels — inactive state.
    static let tab = AppTextStyle(
        font: .system(size: 10, weight: .regular),
        tracking: 0.2
    )

    /// Bottom-tab labels — active state.
    static let tabActive = AppTextStyle(
        font: .system(size: 10, weight: .semibold),
        tracking: 0.2
    )
}
