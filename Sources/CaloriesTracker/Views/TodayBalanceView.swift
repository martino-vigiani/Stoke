import SwiftUI
import SwiftData

struct TodayBalanceView: View {
    @Environment(\.modelContext) var modelContext
    @Query var profiles: [UserProfile]
    @Query(sort: \FoodEntry.timestamp, order: .reverse) var allEntries: [FoodEntry]

    var userProfile: UserProfile? {
        profiles.first
    }

    var todayEntries: [FoodEntry] {
        let calendar = Calendar.current
        return allEntries.filter { calendar.isDateInToday($0.timestamp) }
    }

    var totalCalories: Int {
        todayEntries.reduce(0) { $0 + $1.calories }
    }

    var totalProtein: Double {
        todayEntries.reduce(0) { $0 + $1.protein }
    }

    var totalCarbs: Double {
        todayEntries.reduce(0) { $0 + $1.carbs }
    }

    var totalFats: Double {
        todayEntries.reduce(0) { $0 + $1.fats }
    }

    var body: some View {
        ZStack {
            AppTheme.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.spacing4) {
                    // Header
                    Text("Today")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppTheme.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, AppTheme.spacing2)

                    // Calories Summary
                    LiquidGlassCard {
                        VStack(spacing: AppTheme.spacing3) {
                            HStack(alignment: .firstTextBaseline) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Calories")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Text("\(totalCalories)")
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(AppTheme.text)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Goal")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Text("\(userProfile?.dailyCalorieGoal ?? 2000)")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }

                            // Progress Bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(AppTheme.separator)

                                    let progress = Double(totalCalories) / Double(userProfile?.dailyCalorieGoal ?? 2000)
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.black)
                                        .frame(width: geometry.size.width * min(progress, 1.0))
                                }
                            }
                            .frame(height: 8)
                        }
                    }

                    // Macros Breakdown
                    VStack(spacing: AppTheme.spacing2) {
                        SectionHeader(title: "Macronutrients")
                            .frame(maxWidth: .infinity, alignment: .leading)

                        LiquidGlassCard {
                            HStack(spacing: 12) {
                                MacroProgressCard(
                                    label: "Protein",
                                    current: totalProtein,
                                    goal: userProfile?.proteinGoalGrams ?? 100
                                )
                                MacroProgressCard(
                                    label: "Carbs",
                                    current: totalCarbs,
                                    goal: userProfile?.carbsGoalGrams ?? 250
                                )
                                MacroProgressCard(
                                    label: "Fats",
                                    current: totalFats,
                                    goal: userProfile?.fatsGoalGrams ?? 65
                                )
                            }
                        }
                    }

                    // Food Entries
                    if !todayEntries.isEmpty {
                        VStack(spacing: AppTheme.spacing2) {
                            SectionHeader(title: "Meals")
                                .frame(maxWidth: .infinity, alignment: .leading)

                            LiquidGlassCard {
                                VStack(spacing: 16) {
                                    ForEach(Array(todayEntries.enumerated()), id: \.element.id) { index, entry in
                                        if index > 0 {
                                            SeparatorLine()
                                        }
                                        FoodEntryRow(entry: entry)
                                    }
                                }
                            }
                        }
                    } else {
                        LiquidGlassCard {
                            VStack(spacing: 16) {
                                Image(systemName: "fork.knife.circle")
                                    .font(.system(size: 48))
                                    .foregroundColor(AppTheme.textSecondary)
                                Text("No meals logged today")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppTheme.text)
                                Text("Start tracking your meals from the Home tab")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, AppTheme.spacing3)
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(AppTheme.spacing3)
            }
        }
    }
}

struct MacroProgressCard: View {
    let label: String
    let current: Double
    let goal: Double

    var progress: Double {
        current / goal
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                ProgressRing(progress: 0, lineWidth: 6, color: AppTheme.separator)
                ProgressRing(progress: min(progress, 1.0), lineWidth: 6, color: .black)

                VStack(spacing: 2) {
                    Text("\(Int(current))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.text)
                    Text("g")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .frame(height: 80)

            VStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.text)
                Text("\(Int(goal))g")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct FoodEntryRow: View {
    let entry: FoodEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.foodName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.text)

                Text(entry.portionSize)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)

                HStack(spacing: 12) {
                    MacroTag(label: "P", value: entry.protein)
                    MacroTag(label: "C", value: entry.carbs)
                    MacroTag(label: "F", value: entry.fats)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.calories)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.text)
                Text("kcal")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }
}

struct MacroTag: View {
    let label: String
    let value: Double

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppTheme.textSecondary)
            Text("\(Int(value))g")
                .font(.system(size: 10))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(AppTheme.surfaceSecondary)
        )
    }
}

#Preview {
    TodayBalanceView()
        .modelContainer(DataController.preview)
}
