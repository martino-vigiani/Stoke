import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) var modelContext
    @Query var profiles: [UserProfile]
    @State private var isEditingProfile: Bool = false

    var userProfile: UserProfile? {
        profiles.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack {
                        Text("Profile")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue.gradient)

                    // Content
                    ScrollView {
                        VStack(spacing: 20) {
                            if let profile = userProfile {
                                // Glass morphism cards
                                GlassCard {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("Basic Information")
                                            .font(.headline)
                                            .foregroundColor(.white)

                                        ProfileRow(label: "Name", value: profile.name)
                                        ProfileRow(label: "Age", value: "\(profile.age) years")
                                        ProfileRow(label: "Height", value: "\(Int(profile.height)) cm")
                                        ProfileRow(label: "Weight", value: "\(String(format: "%.1f", profile.weight)) kg")
                                    }
                                }

                                GlassCard {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("Daily Goals")
                                            .font(.headline)
                                            .foregroundColor(.white)

                                        ProfileRow(label: "Calories", value: "\(profile.dailyCalorieGoal) kcal")
                                        ProfileRow(label: "Protein", value: "\(String(format: "%.1f", profile.proteinGoalGrams))g")
                                        ProfileRow(label: "Carbs", value: "\(String(format: "%.1f", profile.carbsGoalGrams))g")
                                        ProfileRow(label: "Fats", value: "\(String(format: "%.1f", profile.fatsGoalGrams))g")
                                    }
                                }

                                Button(action: { isEditingProfile = true }) {
                                    Text("Edit Profile")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            } else {
                                Text("No profile found. Creating default profile...")
                                    .onAppear {
                                        let newProfile = UserProfile()
                                        modelContext.insert(newProfile)
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isEditingProfile) {
                if let profile = userProfile {
                    EditProfileView(profile: profile)
                }
            }
        }
    }
}

struct ProfileRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .backdrop()
    }
}

extension View {
    func backdrop() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Material.thin)
            )
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    let profile: UserProfile
    @State private var name: String = ""
    @State private var height: Double = 170
    @State private var weight: Double = 70
    @State private var age: Int = 30

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $name)
                    Stepper("Age: \(age)", value: $age, in: 10...100)
                    Stepper(
                        "Height: \(Int(height)) cm",
                        value: $height,
                        in: 120...250,
                        step: 1
                    )
                    Stepper(
                        "Weight: \(String(format: "%.1f", weight)) kg",
                        value: $weight,
                        in: 20...200,
                        step: 0.5
                    )
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        profile.name = name
                        profile.age = age
                        profile.height = height
                        profile.weight = weight
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                name = profile.name
                age = profile.age
                height = profile.height
                weight = profile.weight
            }
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(DataController.preview)
}
