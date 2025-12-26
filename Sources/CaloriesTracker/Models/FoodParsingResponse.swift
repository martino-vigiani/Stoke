import Foundation

struct FoodParsingResponse: Codable {
    let foodName: String
    let portionSize: String
    let calories: Int
    let macros: Macros

    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case portionSize = "portion_size"
        case calories
        case macros
    }
}

struct Macros: Codable {
    let protein: Double
    let carbs: Double
    let fats: Double
}
