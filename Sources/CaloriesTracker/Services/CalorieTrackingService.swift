import Foundation
import SwiftData

class CalorieTrackingService {
    private weak var modelContext: ModelContext?

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }

    func addFoodEntry(
        _ entry: FoodEntry,
        to context: ModelContext
    ) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Find or create today's balance
        var dailyBalance = findOrCreateDailyBalance(for: today, in: context)

        // Add entry to the balance
        dailyBalance.foodEntries.append(entry)
        dailyBalance.recalculateTotals()

        context.insert(entry)
    }

    func removeFoodEntry(
        _ entry: FoodEntry,
        from context: ModelContext
    ) {
        if let dailyBalance = entry.dailyBalance {
            dailyBalance.foodEntries.removeAll { $0.id == entry.id }
            dailyBalance.recalculateTotals()
        }

        context.delete(entry)
    }

    func getDailyBalance(for date: Date, in context: ModelContext) -> DailyBalance? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<DailyBalance>(
            predicate: #Predicate { balance in
                balance.date >= startOfDay && balance.date < endOfDay
            }
        )

        do {
            let results = try context.fetch(descriptor)
            return results.first
        } catch {
            return nil
        }
    }

    private func findOrCreateDailyBalance(for date: Date, in context: ModelContext) -> DailyBalance {
        if let existing = getDailyBalance(for: date, in: context) {
            return existing
        }

        let newBalance = DailyBalance(date: date)
        context.insert(newBalance)
        return newBalance
    }
}

private extension DailyBalance {
    func recalculateTotals() {
        totalCalories = foodEntries.reduce(0) { $0 + $1.calories }
        totalProtein = foodEntries.reduce(0) { $0 + $1.protein }
        totalCarbs = foodEntries.reduce(0) { $0 + $1.carbs }
        totalFats = foodEntries.reduce(0) { $0 + $1.fats }
    }
}
