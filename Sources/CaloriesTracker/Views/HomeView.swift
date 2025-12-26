import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) var modelContext
    @StateObject private var foodParsingService = FoodParsingService()
    @State private var foodDescription: String = ""
    @State private var lastParsedFood: FoodParsingResponse?

    var body: some View {
        ZStack {
            AppTheme.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.spacing4) {
                    // Header
                    VStack(spacing: 8) {
                        Text("What did you eat?")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppTheme.text)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, AppTheme.spacing2)

                    // Input Area
                    VStack(spacing: AppTheme.spacing2) {
                        TextEditor(text: $foodDescription)
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.text)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 120)
                            .padding(AppTheme.spacing2)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                    .fill(AppTheme.surfaceSecondary)
                            )
                            .overlay(
                                Group {
                                    if foodDescription.isEmpty {
                                        VStack {
                                            HStack {
                                                Text("e.g., 2 eggs, avocado toast, coffee...")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(AppTheme.textSecondary)
                                                    .padding(.leading, AppTheme.spacing2 + 4)
                                                    .padding(.top, AppTheme.spacing2 + 8)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            )

                        // Analyze Button
                        Button(action: parseFoodDescription) {
                            HStack(spacing: 12) {
                                if foodParsingService.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "sparkles")
                                    Text("Analyze")
                                }
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                    .fill(foodDescription.isEmpty || foodParsingService.isLoading ? Color.gray : Color.black)
                            )
                        }
                        .disabled(foodDescription.isEmpty || foodParsingService.isLoading)
                    }

                    // Error Display
                    if let error = foodParsingService.lastError {
                        LiquidGlassCard {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.text)
                                Spacer()
                            }
                        }
                    }

                    // Results Display
                    if let food = lastParsedFood {
                        FoodResultCard(food: food, onAdd: addFoodEntry)
                    }

                    Spacer(minLength: 100)
                }
                .padding(AppTheme.spacing3)
            }
        }
    }

    private func parseFoodDescription() {
        Task {
            let result = await foodParsingService.parseFood(foodDescription)
            if let food = result {
                lastParsedFood = food
            }
        }
    }

    private func addFoodEntry(_ food: FoodParsingResponse) {
        let entry = FoodEntry(
            foodName: food.foodName,
            portionSize: food.portionSize,
            calories: food.calories,
            protein: food.macros.protein,
            carbs: food.macros.carbs,
            fats: food.macros.fats
        )
        modelContext.insert(entry)
        foodDescription = ""
        lastParsedFood = nil
    }
}

struct FoodResultCard: View {
    let food: FoodParsingResponse
    let onAdd: (FoodParsingResponse) -> Void

    var body: some View {
        LiquidGlassCard {
            VStack(spacing: AppTheme.spacing3) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(food.foodName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.text)

                    Text(food.portionSize)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                SeparatorLine()

                // Calories
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Calories")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("\(food.calories)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(AppTheme.text)
                        Text("kcal")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                }

                SeparatorLine()

                // Macros
                VStack(spacing: AppTheme.spacing2) {
                    SectionHeader(title: "Macronutrients")
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 12) {
                        MacroItem(label: "Protein", value: food.macros.protein)
                        MacroItem(label: "Carbs", value: food.macros.carbs)
                        MacroItem(label: "Fats", value: food.macros.fats)
                    }
                }

                // Add Button
                Button(action: { onAdd(food) }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add to Today")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                            .fill(Color.black)
                    )
                }
            }
        }
    }
}

struct MacroItem: View {
    let label: String
    let value: Double

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)

            Text("\(String(format: "%.1f", value))g")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.text)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                .fill(AppTheme.surfaceSecondary)
        )
    }
}

#Preview {
    HomeView()
        .modelContainer(DataController.preview)
}
