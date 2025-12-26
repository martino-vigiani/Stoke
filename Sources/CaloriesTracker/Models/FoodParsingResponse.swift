import Foundation

struct FoodParsingResponse: Codable {
    let kcal: Double
    let Descrizione: String
    let Macros: Macros
    let data: String?
    let ora: String?
    let porzioni: Double?
    let fonte: String?
    let note: String?

    // Computed properties for backward compatibility
    var calories: Int {
        Int(kcal)
    }

    var foodName: String {
        Descrizione
    }

    var portionSize: String {
        if let portions = porzioni {
            return "\(String(format: "%.1f", portions)) porzioni"
        }
        return "Standard"
    }

    var macros: MacrosLegacy {
        MacrosLegacy(
            protein: Macros.proteine,
            carbs: Macros.carboidrati,
            fats: Macros.grassi
        )
    }
}

struct Macros: Codable {
    let proteine: Double
    let carboidrati: Double
    let grassi: Double
}

// For backward compatibility with existing views
struct MacrosLegacy {
    let protein: Double
    let carbs: Double
    let fats: Double
}
