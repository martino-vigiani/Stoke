import SwiftUI
import SwiftData
import Charts

struct TodayBalanceView: View {
    @Environment(\.modelContext) var modelContext
    @Query var profiles: [UserProfile]
    @Query(sort: \DailyBalance.date, order: .reverse) var dailyBalances: [DailyBalance]
    @State private var selectedDay: Date = Date()

    var todayBalance: DailyBalance? {
        let calendar = Calendar.current
        return dailyBalances.first { balance in
            calendar.isDateInToday(balance.date)
        }
    }

    var userProfile: UserProfile? {
        profiles.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.green.opacity(0.1),
                        Color.blue.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack {
                        Text("Today's Balance")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.green.gradient)

                    ScrollView {
                        VStack(spacing: 20) {
                            // Calories summary
                            if let balance = todayBalance {
                                CalorieSummaryCard(
                                    consumed: balance.totalCalories,
                                    goal: userProfile?.dailyCalorieGoal ?? 2000
                                )

                                // Macros breakdown
                                MacrosBreakdownCard(
                                    balance: balance,
                                    profile: userProfile
                                )

                                // Food entries list
                                if !balance.foodEntries.isEmpty {
                                    FoodEntriesListView(entries: balance.foodEntries)
                                } else {
                                    VStack(spacing: 12) {
                                        Image(systemName: "fork.knife")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                        Text("No food entries yet")
                                            .foregroundColor(.gray)
                                        Text("Add some food to see your daily balance")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(40)
                                }
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "chart.pie")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("No data for today")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(40)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct CalorieSummaryCard: View {
    let consumed: Int
    let goal: Int

    var remaining: Int {
        max(0, goal - consumed)
    }

    var progress: Double {
        Double(consumed) / Double(goal)
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 30) {
                VStack(alignment: .center, spacing: 8) {
                    Text("Consumed")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(consumed)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("kcal")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Divider()

                VStack(alignment: .center, spacing: 8) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(remaining)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(remaining < 0 ? .red : .green)
                    Text("kcal")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Daily Progress")
                        .font(.caption)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.gray)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))

                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.green, .blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * min(progress, 1.0))
                    }
                }
                .frame(height: 12)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MacrosBreakdownCard: View {
    let balance: DailyBalance
    let profile: UserProfile?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Macros Breakdown")
                .font(.headline)

            HStack(spacing: 16) {
                MacroProgressRing(
                    label: "Protein",
                    value: Int(balance.totalProtein),
                    goal: Int(profile?.proteinGoalGrams ?? 100),
                    color: .red
                )

                MacroProgressRing(
                    label: "Carbs",
                    value: Int(balance.totalCarbs),
                    goal: Int(profile?.carbsGoalGrams ?? 250),
                    color: .orange
                )

                MacroProgressRing(
                    label: "Fats",
                    value: Int(balance.totalFats),
                    goal: Int(profile?.fatsGoalGrams ?? 65),
                    color: .yellow
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MacroProgressRing: View {
    let label: String
    let value: Int
    let goal: Int
    let color: Color

    var progress: Double {
        Double(value) / Double(goal)
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(value)")
                        .font(.headline)
                    Text(label)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .frame(height: 80)

            Text("\(goal)g")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct FoodEntriesListView: View {
    let entries: [FoodEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Food Entries")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(entries, id: \.id) { entry in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.foodName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(entry.portionSize)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(entry.calories) kcal")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("P:\(String(format: "%.0f", entry.protein))g C:\(String(format: "%.0f", entry.carbs))g")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(8)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    TodayBalanceView()
        .modelContainer(DataController.preview)
}
