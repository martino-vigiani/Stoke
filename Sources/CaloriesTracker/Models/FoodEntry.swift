import Foundation
import SwiftData

@Model
final class FoodEntry {
    var id: UUID = UUID()
    var foodName: String
    var portionSize: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fats: Double
    var timestamp: Date
    var dailyBalance: DailyBalance?

    init(
        foodName: String,
        portionSize: String,
        calories: Int,
        protein: Double,
        carbs: Double,
        fats: Double,
        timestamp: Date = Date()
    ) {
        self.foodName = foodName
        self.portionSize = portionSize
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.timestamp = timestamp
    }
}
