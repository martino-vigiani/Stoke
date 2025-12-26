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
        ZStack {
            AppTheme.surface.ignoresSafeArea()

            VStack(spacing: 0) {
                // Main Content
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(0)

                    TodayBalanceView()
                        .tag(1)

                    ProfileView()
                        .tag(2)

                    SettingsView()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Custom Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "pencil.line",
                label: "Home",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }

            TabBarButton(
                icon: "chart.bar.fill",
                label: "Today",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }

            TabBarButton(
                icon: "person.fill",
                label: "Profile",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }

            TabBarButton(
                icon: "gearshape.fill",
                label: "Settings",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(AppTheme.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppTheme.text : AppTheme.textSecondary)

                Text(label)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppTheme.text : AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppTheme.surfaceSecondary : Color.clear)
            )
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(DataController.preview)
}
