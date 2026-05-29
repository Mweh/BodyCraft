import Foundation
import Combine

class UserProfileStore: ObservableObject {
    static let shared = UserProfileStore()
    
    @Published private(set) var profile: UserProfile = UserProfile()

    private let key = "userProfile"

    init() {
        load()
    }

    // MARK: - Public API

    func save(_ profile: UserProfile) {
        self.profile = profile
        persist()
    }

    func update(_ block: (inout UserProfile) -> Void) {
        block(&profile)
        persist()
    }

    func clear() {
        profile = UserProfile()
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - Private

    private func persist() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode(UserProfile.self, from: data)
        else { return }
        self.profile = saved
    }
}
