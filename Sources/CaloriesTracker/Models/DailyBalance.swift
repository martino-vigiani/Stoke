import Foundation
import SwiftData

@Model
final class DailyBalance {
    var id: UUID = UUID()
    var date: Date
    var totalCalories: Int = 0
    var totalProtein: Double = 0
    var totalCarbs: Double = 0
    var totalFats: Double = 0
    @Relationship(deleteRule: .cascade, inverse: \FoodEntry.dailyBalance)
    var foodEntries: [FoodEntry] = []

    init(date: Date) {
        self.date = date
    }

    func addEntry(_ entry: FoodEntry) {
        foodEntries.append(entry)
        recalculateTotals()
    }

    func removeEntry(_ entry: FoodEntry) {
        foodEntries.removeAll { $0.id == entry.id }
        recalculateTotals()
    }

    private func recalculateTotals() {
        totalCalories = foodEntries.reduce(0) { $0 + $1.calories }
        totalProtein = foodEntries.reduce(0) { $0 + $1.protein }
        totalCarbs = foodEntries.reduce(0) { $0 + $1.carbs }
        totalFats = foodEntries.reduce(0) { $0 + $1.fats }
    }
}
