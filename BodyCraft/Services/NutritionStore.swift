import Foundation
import Combine

// MARK: - FoodLogEntry

struct FoodLogEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var iconName: String        // SF Symbol name, e.g. "fork.knife"
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var time: Date
    var servings: Double = 1.0

    var timeString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "hh:mm a"
        return fmt.string(from: time)
    }
}

// MARK: - DayLog

struct DayLog: Identifiable, Codable {
    var id: String          // "yyyy-MM-dd"
    var entries: [FoodLogEntry]

    var totalCalories: Double { entries.reduce(0) { $0 + $1.calories * $1.servings } }
    var totalProtein:  Double { entries.reduce(0) { $0 + $1.protein  * $1.servings } }
    var totalCarbs:    Double { entries.reduce(0) { $0 + $1.carbs    * $1.servings } }
    var totalFat:      Double { entries.reduce(0) { $0 + $1.fat      * $1.servings } }

    var displayDate: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        guard let date = fmt.date(from: id) else { return id }
        let display = DateFormatter()
        display.dateStyle = .medium
        return display.string(from: date)
    }
}

// MARK: - NutritionStore

class NutritionStore: ObservableObject {

    /// All days, keyed by "yyyy-MM-dd". Today's log + all past logs.
    @Published private(set) var allLogs: [String: DayLog] = [:]

    private let key = "nutritionAllLogs_v2"

    init() { load() }

    // MARK: - Convenience: Today

    private var todayKey: String { dateKey(for: Date()) }

    var todayEntries: [FoodLogEntry] {
        allLogs[todayKey]?.entries ?? []
    }

    var totalCalories: Double { todayEntries.reduce(0) { $0 + $1.calories * $1.servings } }
    var totalProtein:  Double { todayEntries.reduce(0) { $0 + $1.protein  * $1.servings } }
    var totalCarbs:    Double { todayEntries.reduce(0) { $0 + $1.carbs    * $1.servings } }
    var totalFat:      Double { todayEntries.reduce(0) { $0 + $1.fat      * $1.servings } }

    // MARK: - Past Days (excludes today, sorted newest first)

    var pastLogs: [DayLog] {
        allLogs.values
            .filter { $0.id != todayKey && !$0.entries.isEmpty }
            .sorted { $0.id > $1.id }
    }

    // MARK: - Public API

    func add(entry: FoodLogEntry) {
        var day = allLogs[todayKey] ?? DayLog(id: todayKey, entries: [])
        day.entries.append(entry)
        allLogs[todayKey] = day
        persist()
    }

    func update(entry: FoodLogEntry) {
        guard var day = allLogs[todayKey],
              let idx = day.entries.firstIndex(where: { $0.id == entry.id }) else { return }
        day.entries[idx] = entry
        allLogs[todayKey] = day
        persist()
    }

    func deleteByID(_ id: UUID) {
        guard var day = allLogs[todayKey] else { return }
        day.entries.removeAll { $0.id == id }
        allLogs[todayKey] = day
        persist()
    }

    // MARK: - Persistence

    private func persist() {
        if let data = try? JSONEncoder().encode(allLogs) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode([String: DayLog].self, from: data)
        else { return }
        allLogs = saved
    }

    // MARK: - Helpers

    private func dateKey(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }
}
