import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"
    @AppStorage("calorieUnit") private var calorieUnit: String = "kcal"

    var body: some View {
        ZStack {
            AppTheme.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.spacing4) {
                    // Header
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppTheme.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, AppTheme.spacing2)

                    // Preferences
                    VStack(spacing: AppTheme.spacing2) {
                        SectionHeader(title: "Preferences")
                            .frame(maxWidth: .infinity, alignment: .leading)

                        LiquidGlassCard {
                            VStack(spacing: 0) {
                                SettingRow(
                                    icon: "globe",
                                    label: "Language",
                                    value: languageName(selectedLanguage)
                                )

                                SeparatorLine()
                                    .padding(.vertical, 16)

                                SettingRow(
                                    icon: "flame",
                                    label: "Calorie Unit",
                                    value: calorieUnit == "kcal" ? "Kilocalories" : "Kilojoules"
                                )
                            }
                        }
                    }

                    // About
                    VStack(spacing: AppTheme.spacing2) {
                        SectionHeader(title: "About")
                            .frame(maxWidth: .infinity, alignment: .leading)

                        LiquidGlassCard {
                            VStack(spacing: 0) {
                                InfoRow(label: "Version", value: "1.0.0")

                                SeparatorLine()
                                    .padding(.vertical, 16)

                                InfoRow(label: "Build", value: "2024.12.26")
                            }
                        }
                    }

                    // Conversion Info
                    if calorieUnit == "kj" {
                        LiquidGlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(AppTheme.textSecondary)
                                    Text("Conversion")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(AppTheme.textSecondary)
                                }

                                Text("1 kcal = 4.184 kJ")
                                    .font(.system(size: 15))
                                    .foregroundColor(AppTheme.text)
                            }
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(AppTheme.spacing3)
            }
        }
    }

    private func languageName(_ code: String) -> String {
        switch code {
        case "en": return "English"
        case "es": return "Español"
        case "fr": return "Français"
        case "it": return "Italiano"
        case "de": return "Deutsch"
        default: return "English"
        }
    }
}

struct SettingRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppTheme.text)
                .frame(width: 28)

            Text(label)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.text)

            Spacer()

            Text(value)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondary)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.text)
        }
    }
}

#Preview {
    SettingsView()
}
