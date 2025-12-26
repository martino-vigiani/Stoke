import SwiftData

actor DataController {
    static let shared = DataController()

    private init() {}

    nonisolated static var preview: ModelContext {
        let modelContext = ModelContext(
            ModelContainer(
                for: FoodEntry.self, UserProfile.self, DailyBalance.self,
                isStoredInMemoryOnly: true
            )
        )

        let sampleProfile = UserProfile(
            name: "Demo User",
            height: 170,
            weight: 70,
            age: 28,
            dailyCalorieGoal: 2000
        )
        modelContext.insert(sampleProfile)

        return modelContext
    }

    static func container() throws -> ModelContainer {
        let schema = Schema([
            FoodEntry.self,
            UserProfile.self,
            DailyBalance.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
}
