import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"
    @AppStorage("calorieUnit") private var calorieUnit: String = "kcal"
    @AppStorage("enableDarkMode") private var enableDarkMode: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.gray.opacity(0.1),
                        Color.blue.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack {
                        Text("Settings")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.gray.gradient)

                    Form {
                        Section("App Settings") {
                            Picker("Language", selection: $selectedLanguage) {
                                Text("English").tag("en")
                                Text("Español").tag("es")
                                Text("Français").tag("fr")
                                Text("Italiano").tag("it")
                                Text("Deutsch").tag("de")
                            }

                            Toggle("Dark Mode", isOn: $enableDarkMode)
                        }

                        Section("Calorie Tracking") {
                            Picker("Calorie Unit", selection: $calorieUnit) {
                                Text("kcal (Kilocalories)").tag("kcal")
                                Text("kJ (Kilojoules)").tag("kj")
                            }

                            HStack {
                                Text("Conversion Rate")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("1 kcal = 4.184 kJ")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }

                        Section("About") {
                            HStack {
                                Text("Version")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("1.0.0")
                                    .foregroundColor(.gray)
                            }

                            HStack {
                                Text("Developer")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("Calories Tracker")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    SettingsView()
}
