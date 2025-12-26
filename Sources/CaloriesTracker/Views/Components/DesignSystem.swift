import SwiftUI

// MARK: - Design System

struct AppTheme {
    // Colors - Minimal B&W palette
    static let background = Color.black
    static let surface = Color.white
    static let surfaceSecondary = Color(white: 0.98)
    static let text = Color.black
    static let textSecondary = Color(white: 0.4)
    static let separator = Color(white: 0.9)
    static let accent = Color.black

    // Spacing
    static let spacing1: CGFloat = 8
    static let spacing2: CGFloat = 16
    static let spacing3: CGFloat = 24
    static let spacing4: CGFloat = 32

    // Corner Radius - Everything rounded
    static let cornerRadiusSmall: CGFloat = 16
    static let cornerRadiusMedium: CGFloat = 24
    static let cornerRadiusLarge: CGFloat = 32

    // Border
    static let borderWidth: CGFloat = 1
}

// MARK: - Liquid Glass Card

struct LiquidGlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppTheme.spacing3)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .fill(AppTheme.surface)
                    .shadow(color: Color.black.opacity(0.03), radius: 20, x: 0, y: 10)
            )
    }
}

// MARK: - Glass Container with blur effect

struct GlassContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(AppTheme.spacing3)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .fill(Material.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                            .stroke(AppTheme.separator, lineWidth: AppTheme.borderWidth)
                    )
            )
    }
}

// MARK: - Modern Button

struct ModernButton: View {
    let title: String
    let action: () -> Void
    let style: ButtonStyle

    enum ButtonStyle {
        case primary
        case secondary
    }

    init(_ title: String, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(style == .primary ? .white : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                        .fill(style == .primary ? Color.black : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                .stroke(style == .primary ? Color.clear : AppTheme.separator, lineWidth: AppTheme.borderWidth)
                        )
                )
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(AppTheme.textSecondary)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String?

    init(title: String, value: String, subtitle: String? = nil) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.text)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.spacing2)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                .fill(AppTheme.surfaceSecondary)
        )
    }
}

// MARK: - Modern Text Field

struct ModernTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .font(.system(size: 16))
            .padding(AppTheme.spacing2)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                    .fill(AppTheme.surfaceSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                    .stroke(AppTheme.separator, lineWidth: AppTheme.borderWidth)
            )
    }
}

// MARK: - Progress Ring

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let color: Color

    init(progress: Double, lineWidth: CGFloat = 8, color: Color = .black) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.color = color
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.separator, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Separator Line

struct SeparatorLine: View {
    var body: some View {
        Rectangle()
            .fill(AppTheme.separator)
            .frame(height: AppTheme.borderWidth)
    }
}
