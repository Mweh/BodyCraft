import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var profileStore: UserProfileStore
    @State private var showEditSheet = false

    private var profile: UserProfile { profileStore.profile }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // ── User Header ───────────────────────────────────
                        HStack(spacing: 16) {
                            ZStack(alignment: .bottomTrailing) {
                                // Photo
                                Group {
                                    if let data = profile.photoData,
                                       let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .fill(AppTheme.primary)
                                            .frame(width: 80, height: 80)
                                            .overlay(
                                                Text(profile.initials.isEmpty ? "?" : profile.initials)
                                                    .font(.title)
                                                    .foregroundColor(.white)
                                                    .bold()
                                            )
                                    }
                                }

                                // Edit badge
                                Button(action: { showEditSheet = true }) {
                                    Circle()
                                        .fill(AppTheme.primary)
                                        .frame(width: 24, height: 24)
                                        .overlay(Image(systemName: "pencil").font(.caption2).foregroundColor(.white))
                                }
                                .offset(x: 4, y: 4)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Button(action: { showEditSheet = true }) {
                                    HStack(spacing: 6) {
                                        Text(profile.name.isEmpty ? "Your Name" : profile.name)
                                            .font(.title2)
                                            .bold()
                                            .foregroundColor(.white)
                                    }
                                }

                                Text(profile.goal.isEmpty ? "Aesthetic Body Journey" : profile.goal)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)

                        // ── Lifetime Stats ────────────────────────────────
                        HStack(spacing: 12) {
                            StatBox(icon: "calendar", value: "0", label: "Days", iconColor: AppTheme.primary)
                            StatBox(icon: "figure.run", value: "0", label: "Workouts", iconColor: .cyan)
                            StatBox(icon: "flame", value: "0", label: "Calories", iconColor: .orange)
                        }
                        .padding(.horizontal)

                        // ── Body Stats ────────────────────────────────────
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Body Stats")
                                .font(.headline)
                                .foregroundColor(.white)

                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    StaticStatCard(
                                        title: "Height",
                                        value: profile.height.isEmpty ? "—" : "\(profile.height) cm"
                                    )
                                    StaticStatCard(
                                        title: "Weight",
                                        value: profile.weight.isEmpty ? "—" : "\(profile.weight) kg"
                                    )
                                }
                                HStack(spacing: 12) {
                                    StaticStatCard(
                                        title: "Body Fat",
                                        value: profile.bodyFat == 0 ? "—" : String(format: "%.0f%%", profile.bodyFat)
                                    )
                                    StaticStatCard(title: "BMI", value: profile.bmi)
                                }
                            }
                        }
                        .padding(.horizontal)

                        // ── Workout Preferences ───────────────────────────
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Workout Preferences")
                                .font(.headline)
                                .foregroundColor(.white)

                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    StaticStatCard(
                                        title: "Duration",
                                        value: profile.durationPerSession.isEmpty ? "—" : profile.durationPerSession
                                    )
                                }
                                HStack(spacing: 12) {
                                    StaticStatCard(
                                        title: "Activity Level",
                                        value: profile.activityLevel.isEmpty ? "—" : profile.activityLevel
                                    )
                                    StaticStatCard(
                                        title: "Equipment",
                                        value: profile.equipment.isEmpty ? "—" : profile.equipment
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)

                        Spacer().frame(height: 100)
                    }
                    .padding(.top)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditSheet) {
                EditProfileSheet(isPresented: $showEditSheet)
                    .environmentObject(profileStore)
            }
        }
    }
}

// MARK: - Edit Profile Sheet

struct EditProfileSheet: View {
    @EnvironmentObject var profileStore: UserProfileStore
    @Binding var isPresented: Bool

    @State private var name: String = ""
    @State private var age: String = ""
    @State private var gender: String = "Male"
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var bodyFat: Double = 20.0
    @State private var activityLevel: String = "Sedentary"
    @State private var goal: String = "Build Muscle"
    @State private var sessionsPerWeek: Int = 3
    @State private var durationPerSession: String = "45 min"
    @State private var equipment: String = "Full Gym"
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    @State private var isSaving = false
    @State private var errorMessage: String? = nil

    private let activityLevels = ["Sedentary", "Lightly Active", "Moderately Active", "Very Active", "Extremely Active"]
    private let goals = ["Lose Weight", "Maintain", "Build Muscle"]
    private let equipmentOptions = ["No Equipment", "Dumbbells Only", "Full Gym"]
    private let durations = ["30 min", "45 min", "60 min", "90 min"]

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Photo picker
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ZStack(alignment: .bottomTrailing) {
                                Group {
                                    if let data = selectedImageData ?? profileStore.profile.photoData,
                                       let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .fill(AppTheme.primary)
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                Text(profileStore.profile.initials.isEmpty ? "?" : profileStore.profile.initials)
                                                    .font(.largeTitle)
                                                    .foregroundColor(.white)
                                                    .bold()
                                            )
                                    }
                                }

                                Circle()
                                    .fill(AppTheme.primary)
                                    .frame(width: 30, height: 30)
                                    .overlay(Image(systemName: "camera.fill").font(.caption).foregroundColor(.white))
                                    .offset(x: 4, y: 4)
                            }
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }

                        // Sections
                        VStack(spacing: 20) {
                            // Basic Info
                            EditSection(title: "Basic Info") {
                                EditField(label: "Name", text: $name)
                                EditField(label: "Age", text: $age, keyboardType: .numberPad)
                                
                                Picker("Gender", selection: $gender) {
                                    Text("Male").tag("Male")
                                    Text("Female").tag("Female")
                                }
                                .pickerStyle(.segmented)
                                .padding(.top, 4)
                            }

                            // Body Stats
                            EditSection(title: "Body Stats") {
                                EditField(label: "Height (cm)", text: $height, keyboardType: .numberPad)
                                EditField(label: "Weight (kg)", text: $weight, keyboardType: .numberPad)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Body Fat")
                                            .font(.subheadline)
                                            .foregroundColor(AppTheme.secondaryText)
                                        Spacer()
                                        Text("\(Int(bodyFat))%")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .bold()
                                    }
                                    Slider(value: $bodyFat, in: 5...50, step: 1)
                                        .accentColor(AppTheme.primary)
                                }
                            }

                            // Fitness Goal & Preferences
                            EditSection(title: "Preferences") {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Fitness Goal")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.secondaryText)
                                    Picker("Goal", selection: $goal) {
                                        ForEach(goals, id: \.self) { Text($0) }
                                    }
                                    .pickerStyle(.segmented)
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Sessions per Week")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.secondaryText)
                                    Stepper("\(sessionsPerWeek) sessions", value: $sessionsPerWeek, in: 1...7)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AppTheme.background.opacity(0.5))
                                        .cornerRadius(8)
                                }

                                EditPicker(label: "Activity Level", selection: $activityLevel, options: activityLevels)
                                EditPicker(label: "Workout Duration", selection: $durationPerSession, options: durations)
                                EditPicker(label: "Equipment", selection: $equipment, options: equipmentOptions)
                            }
                        }
                        .padding(.horizontal)
                        
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding()
                        }

                        Spacer().frame(height: 100)
                    }
                    .padding(.top, 24)
                }
                
                if isSaving {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    VStack(spacing: 20) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                        Text("Regenerating AI Plan...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(AppTheme.secondaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAction()
                    }
                    .foregroundColor(AppTheme.primary)
                    .bold()
                    .disabled(isSaving)
                }
            }
            .onAppear {
                let p = profileStore.profile
                name = p.name
                age = p.age
                gender = p.gender
                height = p.height
                weight = p.weight
                bodyFat = p.bodyFat
                activityLevel = p.activityLevel
                goal = p.goal
                sessionsPerWeek = p.sessionsPerWeek
                durationPerSession = p.durationPerSession
                equipment = p.equipment
            }
        }
    }

    private func saveAction() {
        let oldProfile = profileStore.profile
        
        // Check if critical changes occurred
        let criticalChanged = oldProfile.goal != goal || 
                             oldProfile.sessionsPerWeek != sessionsPerWeek || 
                             oldProfile.equipment != equipment
        
        profileStore.update { p in
            p.name = name
            p.age = age
            p.gender = gender
            p.height = height
            p.weight = weight
            p.bodyFat = bodyFat
            p.activityLevel = activityLevel
            p.goal = goal
            p.sessionsPerWeek = sessionsPerWeek
            p.durationPerSession = durationPerSession
            p.equipment = equipment
            if let data = selectedImageData { p.photoData = data }
        }
        
        if criticalChanged {
            isSaving = true
            Task {
                do {
                    try await WorkoutRepository.shared.regeneratePlan(for: profileStore.profile)
                    await MainActor.run {
                        isSaving = false
                        isPresented = false
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = "Failed to update AI plan. Basic info saved."
                        isSaving = false
                        // We still allow closing if user wants, but show error
                    }
                }
            }
        } else {
            isPresented = false
        }
    }
}

// MARK: - Helper Components

struct EditSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppTheme.primary)
            
            VStack(spacing: 16) {
                content
            }
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(16)
        }
    }
}

struct EditField: View {
    let label: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryText)
            
            TextField(label, text: $text)
                .padding()
                .background(AppTheme.background.opacity(0.5))
                .cornerRadius(12)
                .foregroundColor(.white)
                .keyboardType(keyboardType)
        }
    }
}

struct EditPicker: View {
    let label: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryText)
            
            Picker(label, selection: $selection) {
                ForEach(options, id: \.self) { Text($0) }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(AppTheme.background.opacity(0.5))
            .cornerRadius(12)
            .accentColor(.white)
        }
    }
}

// MARK: - Subviews

struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    let iconColor: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.surface)
        .cornerRadius(16)
    }
}

struct StaticStatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryText)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserProfileStore())
    }
}
