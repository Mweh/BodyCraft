import SwiftUI
import AVKit

// MARK: - Detail View

struct ExerciseDetailView: View {
    let exerciseId: String

    @State private var detail: ExerciseDetail?
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        Group {
            if let detail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Video or Image Header
                        headerMediaView(detail: detail)

                        VStack(alignment: .leading, spacing: 16) {
                            // Title and Tags
                            VStack(alignment: .leading, spacing: 12) {
                                Text(detail.name)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)

                                VStack(alignment: .leading, spacing: 12) {
                                    // Body Parts & Targets wrapping tags
                                    FlowLayout(spacing: 8) {
                                        if let bodyParts = detail.bodyParts {
                                            ForEach(bodyParts, id: \.self) { part in
                                                BadgeView(text: part, color: .blue)
                                            }
                                        }
                                        
                                        if let targetMuscles = detail.targetMuscles {
                                            ForEach(targetMuscles, id: \.self) { muscle in
                                                BadgeView(text: muscle, color: AppTheme.primary)
                                            }
                                        }
                                    }
                                    
                                    // Equipment sub-info
                                    if let equipments = detail.equipments, !equipments.isEmpty {
                                        HStack(alignment: .top, spacing: 6) {
                                            Image(systemName: "dumbbell.fill")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(AppTheme.secondaryText)
                                            Text(equipments.joined(separator: ", ").capitalized)
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundColor(AppTheme.secondaryText)
                                        }
                                        .padding(.leading, 2)
                                    }
                                }
                            }

                            // Instructions Section
                            if let instructions = detail.instructions, !instructions.isEmpty {
                                section(title: "Instructions") {
                                    VStack(alignment: .leading, spacing: 16) {
                                        ForEach(Array(instructions.enumerated()), id: \.offset) { index, step in
                                            HStack(alignment: .top, spacing: 16) {
                                                Text("\(index + 1)")
                                                    .font(.system(.subheadline, design: .monospaced).bold())
                                                    .foregroundColor(.white)
                                                    .frame(width: 28, height: 28)
                                                    .background(AppTheme.primary)
                                                    .clipShape(Circle())
                                                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 4, x: 0, y: 2)
                                                
                                                Text(step)
                                                    .font(.system(.subheadline, design: .rounded))
                                                    .foregroundColor(.white.opacity(0.8))
                                                    .lineSpacing(4)
                                                    .padding(.top, 4)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                }
                .background(AppTheme.background.ignoresSafeArea())
            } else if let errorMessage {
                errorView(message: errorMessage)
            } else {
                ProgressView()
                    .tint(AppTheme.primary)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(detail?.name ?? "Exercise Detail")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .task {
            await loadDetail()
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func headerMediaView(detail: ExerciseDetail) -> some View {
        Group {
            if let videoString = detail.videoUrl, !videoString.isEmpty, let videoUrl = URL(string: videoString) {
                LoopingVideoPlayer(url: videoUrl)
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            } else {
                ZStack {
                    if let urlString = detail.imageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                ZStack {
                                    AppTheme.surface
                                    Image(systemName: "dumbbell")
                                        .font(.largeTitle)
                                        .foregroundColor(AppTheme.secondaryText)
                                }
                            }
                        }
                        .frame(height: 240)
                        .clipped()
                    }
                }
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.warning)
            
            Text("Something went wrong")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.white)
            
            Text(message)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
            
            Button(action: { Task { await loadDetail() } }) {
                Text("Try Again")
                    .font(.system(.subheadline, design: .rounded).bold())
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(AppTheme.primary)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background.ignoresSafeArea())
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            content()
        }
        .padding(.top, 12)
    }

    @MainActor
    private func loadDetail() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            detail = try await ExerciseDBService.shared.getExerciseDetail(id: exerciseId)
        } catch {
            if let localData = try? loadLocalFallback(id: exerciseId) {
                detail = localData
            } else {
                errorMessage = "Gagal memuat detail latihan. Silakan periksa koneksi internet Anda."
            }
        }
        isLoading = false
    }
    
    private func loadLocalFallback(id: String) throws -> ExerciseDetail {
        guard let url = Bundle.main.url(forResource: id, withExtension: "json") else {
            throw NSError(domain: "LocalFallback", code: 404)
        }
        let data = try Data(contentsOf: url)
        struct LegacyResponse: Decodable {
            struct LegacyData: Decodable {
                let exerciseId: String
                let name: String
                let imageUrl: String
                let videoUrl: String?
                let instructions: [String]
                let bodyParts: [String]
                let targetMuscles: [String]
                let equipments: [String]
            }
            let success: Bool
            let data: LegacyData
        }
        
        let legacy = try JSONDecoder().decode(LegacyResponse.self, from: data)
        return ExerciseDetail(
            exerciseId: legacy.data.exerciseId,
            name: legacy.data.name,
            imageUrl: legacy.data.imageUrl,
            videoUrl: legacy.data.videoUrl,
            instructions: legacy.data.instructions,
            bodyParts: legacy.data.bodyParts,
            targetMuscles: legacy.data.targetMuscles,
            equipments: legacy.data.equipments
        )
    }
}

// MARK: - Components

struct BadgeView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text.capitalized)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(color.opacity(0.12))
            .foregroundColor(color)
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.35), lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}

// MARK: - Looping Video Player

struct LoopingVideoPlayer: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> UIView { PlayerUIView(url: url) }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

class PlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?

    init(url: URL) {
        super.init(frame: .zero)
        let playerItem = AVPlayerItem(url: url)
        self.queuePlayer = AVQueuePlayer(playerItem: playerItem)
        self.playerLayer.player = queuePlayer
        self.playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        if let player = queuePlayer {
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
            player.play()
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
