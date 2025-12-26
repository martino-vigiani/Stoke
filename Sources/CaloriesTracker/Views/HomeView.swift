import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) var modelContext
    @StateObject private var foodParsingService = FoodParsingService()
    @State private var foodDescription: String = ""
    @State private var lastParsedFood: FoodParsingResponse?
    @State private var showError: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Navbar
                VStack {
                    Text("What did you eat?")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue.gradient)

                // Main content
                VStack(spacing: 20) {
                    // Text input
                    TextEditor(text: $foodDescription)
                        .frame(minHeight: 150)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .placeholder(when: foodDescription.isEmpty) {
                            Text("e.g., 2 eggs, toast with butter, orange juice")
                                .foregroundColor(.gray)
                                .padding(8)
                        }

                    // Submit button
                    Button(action: parseFoodDescription) {
                        if foodParsingService.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Parse Food")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(foodDescription.isEmpty || foodParsingService.isLoading)

                    // Error display
                    if let error = foodParsingService.lastError {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.caption)
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }

                    // Results display
                    if let food = lastParsedFood {
                        FoodResultCard(food: food, onAdd: addFoodEntry)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.foodName)
                        .font(.headline)
                    Text(food.portionSize)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(food.calories) kcal")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }

            Divider()

            HStack(spacing: 20) {
                VStack(alignment: .center, spacing: 4) {
                    Text("Protein")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(String(format: "%.1f", food.macros.protein))g")
                        .font(.headline)
                }
                VStack(alignment: .center, spacing: 4) {
                    Text("Carbs")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(String(format: "%.1f", food.macros.carbs))g")
                        .font(.headline)
                }
                VStack(alignment: .center, spacing: 4) {
                    Text("Fats")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(String(format: "%.1f", food.macros.fats))g")
                        .font(.headline)
                }
                Spacer()
            }

            Button(action: { onAdd(food) }) {
                Text("Add to Today")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

extension View {
    func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(DataController.preview)
}
