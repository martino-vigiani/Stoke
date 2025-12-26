import SwiftData

actor DataController {
    static let shared = DataController()

    private init() {}

    nonisolated static var preview: ModelContainer {
        let schema = Schema([
            FoodEntry.self,
            UserProfile.self,
            DailyBalance.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])

        let sampleProfile = UserProfile(
            name: "Demo User",
            height: 170,
            weight: 70,
            age: 28,
            dailyCalorieGoal: 2000
        )

        let modelContext = ModelContext(container)
        modelContext.insert(sampleProfile)

        return container
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
