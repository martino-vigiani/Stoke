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
        ZStack {
            AppTheme.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppTheme.spacing4) {
                    // Header
                    Text("Profile")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppTheme.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, AppTheme.spacing2)

                    if let profile = userProfile {
                        // Stats Overview
                        LiquidGlassCard {
                            VStack(spacing: AppTheme.spacing3) {
                                Text(profile.name)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(AppTheme.text)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                SeparatorLine()

                                VStack(spacing: 12) {
                                    ProfileStatRow(label: "Age", value: "\(profile.age) years")
                                    ProfileStatRow(label: "Height", value: "\(Int(profile.height)) cm")
                                    ProfileStatRow(label: "Weight", value: "\(String(format: "%.1f", profile.weight)) kg")
                                }
                            }
                        }

                        // Daily Goals
                        VStack(spacing: AppTheme.spacing2) {
                            SectionHeader(title: "Daily Goals")
                                .frame(maxWidth: .infinity, alignment: .leading)

                            LiquidGlassCard {
                                VStack(spacing: 16) {
                                    GoalRow(
                                        icon: "flame.fill",
                                        label: "Calories",
                                        value: "\(profile.dailyCalorieGoal)",
                                        unit: "kcal"
                                    )

                                    SeparatorLine()

                                    HStack(spacing: 12) {
                                        MiniGoalCard(
                                            label: "Protein",
                                            value: String(format: "%.0f", profile.proteinGoalGrams),
                                            unit: "g"
                                        )
                                        MiniGoalCard(
                                            label: "Carbs",
                                            value: String(format: "%.0f", profile.carbsGoalGrams),
                                            unit: "g"
                                        )
                                        MiniGoalCard(
                                            label: "Fats",
                                            value: String(format: "%.0f", profile.fatsGoalGrams),
                                            unit: "g"
                                        )
                                    }
                                }
                            }
                        }

                        // Edit Button
                        Button(action: { isEditingProfile = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "pencil")
                                Text("Edit Profile")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                    .fill(Color.black)
                            )
                        }

                    } else {
                        Text("Creating profile...")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.textSecondary)
                            .onAppear {
                                let newProfile = UserProfile()
                                modelContext.insert(newProfile)
                            }
                    }

                    Spacer(minLength: 100)
                }
                .padding(AppTheme.spacing3)
            }
        }
        .sheet(isPresented: $isEditingProfile) {
            if let profile = userProfile {
                EditProfileView(profile: profile)
            }
        }
    }
}

struct ProfileStatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.text)
        }
    }
}

struct GoalRow: View {
    let icon: String
    let label: String
    let value: String
    let unit: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.text)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.text)
            }

            Spacer()

            Text(unit)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
        }
    }
}

struct MiniGoalCard: View {
    let label: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.text)
                Text(unit)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                .fill(AppTheme.surfaceSecondary)
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
            ZStack {
                AppTheme.surface.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.spacing3) {
                        // Personal Info
                        VStack(spacing: AppTheme.spacing2) {
                            SectionHeader(title: "Personal Information")
                                .frame(maxWidth: .infinity, alignment: .leading)

                            LiquidGlassCard {
                                VStack(spacing: 20) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Name")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(AppTheme.textSecondary)
                                        TextField("Your name", text: $name)
                                            .font(.system(size: 16))
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(AppTheme.surfaceSecondary)
                                            )
                                    }

                                    StepperRow(
                                        label: "Age",
                                        value: $age,
                                        range: 10...100,
                                        unit: "years"
                                    )

                                    StepperRowDouble(
                                        label: "Height",
                                        value: $height,
                                        range: 120...250,
                                        unit: "cm"
                                    )

                                    StepperRowDouble(
                                        label: "Weight",
                                        value: $weight,
                                        range: 20...200,
                                        unit: "kg",
                                        step: 0.5
                                    )
                                }
                            }
                        }
                    }
                    .padding(AppTheme.spacing3)
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
                    .foregroundColor(.black)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.black)
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

struct StepperRow<T: BinaryInteger>: View {
    let label: String
    @Binding var value: T
    let range: ClosedRange<T>
    let unit: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                Text("\(Int(value)) \(unit)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.text)
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: { if value > range.lowerBound { value -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.text)
                }

                Button(action: { if value < range.upperBound { value += 1 } }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.text)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                .fill(AppTheme.surfaceSecondary)
        )
    }
}

struct StepperRowDouble<T: BinaryFloatingPoint>: View where T: CVarArg {
    let label: String
    @Binding var value: T
    let range: ClosedRange<T>
    let unit: String
    let step: T

    init(label: String, value: Binding<T>, range: ClosedRange<T>, unit: String, step: T = 1) {
        self.label = label
        self._value = value
        self.range = range
        self.unit = unit
        self.step = step
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                Text(String(format: "%.1f \(unit)", value))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.text)
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: { if value > range.lowerBound { value -= step } }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.text)
                }

                Button(action: { if value < range.upperBound { value += step } }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.text)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                .fill(AppTheme.surfaceSecondary)
        )
    }
}

#Preview {
    ProfileView()
        .modelContainer(DataController.preview)
}
