import SwiftUI
import AVKit

// MARK: - Models

struct ExerciseDetailImageUrls: Decodable {
    let p360: String?
    let p480: String?
    let p720: String?
    let p1080: String?

    enum CodingKeys: String, CodingKey {
        case p360 = "360p"
        case p480 = "480p"
        case p720 = "720p"
        case p1080 = "1080p"
    }
}

struct ExerciseDetailData: Decodable {
    let exerciseId: String
    let name: String
    let imageUrl: String
    let imageUrls: ExerciseDetailImageUrls
    let equipments: [String]
    let bodyParts: [String]
    let exerciseType: String
    let targetMuscles: [String]
    let secondaryMuscles: [String]
    let videoUrl: String
    let keywords: [String]
    let overview: String
    let instructions: [String]
    let exerciseTips: [String]
    let variations: [String]
    let relatedExerciseIds: [String]
}

struct ExerciseDetailResponse: Decodable {
    let success: Bool
    let data: ExerciseDetailData
}

enum LocalExerciseDetailClient {
    static func loadDetail(exerciseId: String) throws -> ExerciseDetailData {
        guard let url = Bundle.main.url(forResource: exerciseId, withExtension: "json") else {
            throw NSError(domain: "ExerciseDetail", code: 1, userInfo: [NSLocalizedDescriptionKey: "Detail file not found for \(exerciseId)."])
        }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(ExerciseDetailResponse.self, from: data)
        return decoded.data
    }
}

// MARK: - Detail View

struct ExerciseDetailView: View {
    let exerciseId: String

    @State private var detail: ExerciseDetailData?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let detail {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if !detail.videoUrl.isEmpty, let videoUrl = URL(string: detail.videoUrl) {
                                LoopingVideoPlayer(url: videoUrl)
                                    .frame(height: 220)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            } else {
                                ZStack {
                                    if let url = URL(string: detail.imageUrl) {
                                        AsyncImage(url: url) { phase in
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            } else {
                                                ZStack {
                                                    AppTheme.surface
                                                    Image(systemName: "dumbbell")
                                                        .foregroundColor(AppTheme.secondaryText)
                                                }
                                            }
                                        }
                                        .frame(height: 220)
                                        .clipped()
                                    }
                                }
                                .frame(height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text(detail.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                HStack(spacing: 8) {
                                    ForEach(detail.bodyParts, id: \.self) { part in
                                        Text(part.capitalized)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Color.white.opacity(0.08))
                                            .foregroundColor(AppTheme.secondaryText)
                                            .clipShape(Capsule())
                                    }
                                }

                                Text(detail.overview)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            if !detail.instructions.isEmpty {
                                section(title: "Instructions") {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(Array(detail.instructions.enumerated()), id: \.offset) { index, step in
                                            HStack(alignment: .top, spacing: 8) {
                                                Text("\(index + 1).")
                                                    .font(.subheadline.bold())
                                                    .foregroundColor(AppTheme.secondaryText)
                                                Text(step)
                                                    .font(.subheadline)
                                                    .foregroundColor(AppTheme.secondaryText)
                                            }
                                        }
                                    }
                                }
                            }

                            if !detail.exerciseTips.isEmpty {
                                section(title: "Tips") {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(detail.exerciseTips, id: \.self) { tip in
                                            Text("• \(tip)")
                                                .font(.subheadline)
                                                .foregroundColor(AppTheme.secondaryText)
                                        }
                                    }
                                }
                            }

                            if !detail.variations.isEmpty {
                                section(title: "Variations") {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(detail.variations, id: \.self) { variation in
                                            Text("• \(variation)")
                                                .font(.subheadline)
                                                .foregroundColor(AppTheme.secondaryText)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(16)
                    }
                    .background(AppTheme.background.ignoresSafeArea())
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Text("Failed to load detail")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .padding()
                } else {
                    ProgressView()
                        .tint(AppTheme.primary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(detail?.name ?? "Exercise Detail")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .task {
                await loadDetailIfNeeded()
            }
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            content()
        }
    }

    @MainActor
    private func loadDetailIfNeeded() async {
        guard detail == nil, errorMessage == nil else { return }
        do {
            detail = try LocalExerciseDetailClient.loadDetail(exerciseId: exerciseId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Looping Video Player

struct LoopingVideoPlayer: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(url: url)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Handle URL changes if needed, but for our usecase the URL is static once loaded
    }
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
        
        // Setup Looper
        if let player = queuePlayer {
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
            player.play()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

