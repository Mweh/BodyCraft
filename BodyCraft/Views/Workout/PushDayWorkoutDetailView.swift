import SwiftUI

struct PushDayWorkoutDetailView: View {
    @Environment(\.dismiss) private var dismiss
    var onDismiss: (() -> Void)? = nil
    
    // Using the same image URL as the banner
    let imageURL = "https://images.unsplash.com/photo-1552848031-326ec03fe2ec?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxneW0lMjB3ZWlnaHQlMjB0cmFpbmluZyUyMHdvcmtvdXR8ZW58MXx8fHwxNzcyODU5MDIzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppTheme.background

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: URL(string: imageURL)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 220)
                                    .clipped()
                            } else {
                                Rectangle()
                                    .fill(AppTheme.surface)
                                    .frame(height: 220)
                            }
                        }

                        LinearGradient(
                            colors: [Color.black.opacity(0.05), Color.black.opacity(0.75), AppTheme.background],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 220)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Push Day - Chest & Triceps")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            HStack(spacing: 14) {
                                Label("50 min", systemImage: "timer")
                                Label("380 kcal", systemImage: "flame")
                                Text("Intermediate")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.blue)
                                    .clipShape(Capsule())
                            }
                            .font(.caption)
                            .foregroundColor(AppTheme.secondaryText)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 220)
                    }

                    VStack(spacing: 16) {
                        ExerciseRowView(
                            title: "Bench Press",
                            target: "Chest",
                            sets: "4 sets",
                            reps: "8-10 reps",
                            rest: "Rest 90s",
                            instruction: "Turunkan bar sampai dada, dorong dengan kontrol"
                        )

                        ExerciseRowView(
                            title: "Incline Dumbbell Press",
                            target: "Upper Chest",
                            sets: "3 sets",
                            reps: "10-12 reps",
                            rest: "Rest 60s",
                            instruction: "Sudut 30-45 derajat, fokus pada kontraksi"
                        )

                        ExerciseRowView(
                            title: "Cable Fly",
                            target: "Chest",
                            sets: "3 sets",
                            reps: "12-15 reps",
                            rest: "Rest 45s",
                            instruction: "Squeeze di puncak gerakan"
                        )

                        ExerciseRowView(
                            title: "Overhead Tricep Extension",
                            target: "Triceps",
                            sets: "3 sets",
                            reps: "10-12 reps",
                            rest: "Rest 60s",
                            instruction: "Jaga siku tetap stabil"
                        )

                        ExerciseRowView(
                            title: "Tricep Pushdown",
                            target: "Triceps",
                            sets: "3 sets",
                            reps: "12-15 reps",
                            rest: "Rest 45s",
                            instruction: "Tarik handle ke bawah, tahan saat puncak"
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                }
            }

            Button(action: {
                if let onDismiss {
                    onDismiss()
                } else {
                    dismiss()
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.55))
                    .clipShape(Circle())
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
    }
}

// Reusable Component for maintainability
struct ExerciseRowView: View {
    let title: String
    let target: String
    let sets: String
    let reps: String
    let rest: String
    let instruction: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text(target)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.05)) // Subtle background for tags
                    .foregroundColor(AppTheme.secondaryText)
                    .clipShape(Capsule())
            }
            
            HStack(spacing: 16) {
                Text(sets)
                Text(reps)
                Text(rest)
            }
            .font(.subheadline)
            .foregroundColor(AppTheme.secondaryText)
            
            Text(instruction)
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryText.opacity(0.8))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct PushDayWorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PushDayWorkoutDetailView()
    }
}
