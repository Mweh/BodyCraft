import SwiftUI
import Combine

struct ShoulderWorkoutDetailView: View {
    @Environment(\.dismiss) private var dismiss
    var onDismiss: (() -> Void)? = nil
    @StateObject private var vm = ShoulderExerciseListViewModel()
    @State private var selectedExercise: LocalExerciseSearchItem?
    
    // Using the same image URL as the banner for Shoulder & Arms Sculptor
    let imageURL = "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080"
    
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
                                    .frame(height: 300)
                                    .clipped()
                            } else {
                                Rectangle()
                                    .fill(AppTheme.surface)
                                    .frame(height: 300)
                            }
                        }

                        LinearGradient(
                            colors: [.clear, .black.opacity(0.95)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(height: 300)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Shoulder & Arms Sculptor")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)

                            HStack(spacing: 14) {
                                Label("45 min", systemImage: "clock.fill")
                                Label("320 kcal", systemImage: "flame.fill")
                                Text("Beginner")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(24)
                    }
                    .frame(height: 300)
                    
                    ShoulderExerciseListView(vm: vm) { exercise in
                        selectedExercise = exercise
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
        .navigationDestination(item: $selectedExercise) { exercise in
            ExerciseDetailView(exerciseId: exercise.exerciseId)
        }
    }
}

// MARK: - Local JSON-backed Shoulder Exercise List

@MainActor
final class ShoulderExerciseListViewModel: ObservableObject {
    @Published var items: [LocalExerciseSearchItem] = []
    
    init() {
        loadFromBundle()
    }
    
    private func loadFromBundle() {
        guard let url = Bundle.main.url(forResource: "shoulder_exercises", withExtension: "json") else {
            items = []
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(LocalExerciseSearchResponse.self, from: data)
            items = decoded.data
        } catch {
            print("Failed reading shoulder mock data: \(error)")
            items = []
        }
    }
}

struct ShoulderExerciseListView: View {
    @ObservedObject var vm: ShoulderExerciseListViewModel
    let onSelect: (LocalExerciseSearchItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Exercises")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("Shoulder (Offline Data)")
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Capsule())
            }
            
            if vm.items.isEmpty {
                Text("No exercises available.")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.secondaryText)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(vm.items) { item in
                        Button {
                            onSelect(item)
                        } label: {
                            ShoulderExerciseRow(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct ShoulderExerciseRow: View {
    let item: LocalExerciseSearchItem
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Color.white.opacity(0.04)
                
                if let url = item.imageUrl {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "dumbbell.fill")
                                .foregroundColor(AppTheme.secondaryText.opacity(0.3))
                        }
                    }
                } else {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(AppTheme.secondaryText.opacity(0.3))
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text("Shoulder")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(AppTheme.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppTheme.secondaryText.opacity(0.5))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.surface.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct ShoulderWorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ShoulderWorkoutDetailView()
    }
}
