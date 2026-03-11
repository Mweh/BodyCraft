import SwiftUI
import Combine

struct ShoulderWorkoutDetailView: View {
    @Environment(\.dismiss) private var dismiss
    var onDismiss: (() -> Void)? = nil
    @StateObject private var vm = ShoulderExerciseListViewModel()
    @State private var selectedExercise: ExerciseSearchItem?
    
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
                            Text("Shoulder & Arms Sculptor")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 14) {
                                Label("45 min", systemImage: "timer")
                                Label("320 kcal", systemImage: "flame")
                                Text("Beginner")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.orange)
                                    .clipShape(Capsule())
                            }
                            .font(.caption)
                            .foregroundColor(AppTheme.secondaryText)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 220)
                    }
                    
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
    @Published var items: [ExerciseSearchItem] = []
    
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
            let decoded = try JSONDecoder().decode(ExerciseSearchResponse.self, from: data)
            items = decoded.data
        } catch {
            print("Failed reading shoulder mock data: \(error)")
            items = []
        }
    }
}

struct ShoulderExerciseListView: View {
    @ObservedObject var vm: ShoulderExerciseListViewModel
    let onSelect: (ExerciseSearchItem) -> Void
    
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
    let item: ExerciseSearchItem
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                
                if let url = item.imageUrl {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "dumbbell")
                                .foregroundColor(AppTheme.secondaryText.opacity(0.7))
                        }
                    }
                    .clipped()
                } else {
                    Image(systemName: "dumbbell")
                        .foregroundColor(AppTheme.secondaryText.opacity(0.7))
                }
            }
            .frame(width: 56, height: 56)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text("Shoulder")
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText)
            }
            
            Spacer()
        }
        .padding(14)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct ShoulderWorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ShoulderWorkoutDetailView()
    }
}
