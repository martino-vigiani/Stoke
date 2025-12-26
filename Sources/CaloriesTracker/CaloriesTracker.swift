import SwiftUI
import SwiftData

@main
struct CaloriesTrackerApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try DataController.container()
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(1)

            TodayBalanceView()
                .tabItem {
                    Label("Balance", systemImage: "chart.pie.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(DataController.preview)
}
