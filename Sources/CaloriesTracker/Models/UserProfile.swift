import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID = UUID()
    var name: String
    var height: Double
    var weight: Double
    var age: Int
    var dailyCalorieGoal: Int
    var proteinGoalGrams: Double
    var carbsGoalGrams: Double
    var fatsGoalGrams: Double

    init(
        name: String = "User",
        height: Double = 170,
        weight: Double = 70,
        age: Int = 30,
        dailyCalorieGoal: Int = 2000,
        proteinGoalGrams: Double = 100,
        carbsGoalGrams: Double = 250,
        fatsGoalGrams: Double = 65
    ) {
        self.name = name
        self.height = height
        self.weight = weight
        self.age = age
        self.dailyCalorieGoal = dailyCalorieGoal
        self.proteinGoalGrams = proteinGoalGrams
        self.carbsGoalGrams = carbsGoalGrams
        self.fatsGoalGrams = fatsGoalGrams
    }
}
