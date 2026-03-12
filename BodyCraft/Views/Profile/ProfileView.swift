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
                                        title: "Sessions / Week",
                                        value: profile.sessionsPerWeek == 0 ? "—" : "\(profile.sessionsPerWeek)x"
                                    )
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
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 32) {

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

                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.secondaryText)

                        TextField("Enter your name", text: $name)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(12)
                            .accentColor(AppTheme.primary)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, 24)
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
                        profileStore.update { p in
                            if !name.isEmpty { p.name = name }
                            if let data = selectedImageData { p.photoData = data }
                        }
                        isPresented = false
                    }
                    .foregroundColor(AppTheme.primary)
                    .bold()
                }
            }
            .onAppear {
                name = profileStore.profile.name
            }
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
