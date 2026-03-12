import SwiftUI

// MARK: - Nutrition History View

struct NutritionHistoryView: View {
    @EnvironmentObject var nutritionStore: NutritionStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Navigation Bar ─────────────────────────────
                HStack {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Back")
                                .font(.subheadline)
                        }
                        .foregroundColor(AppTheme.primary)
                    }
                    Spacer()
                    Text("Nutrition History")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                    // Spacer for symmetry
                    Text("Back").opacity(0).font(.subheadline)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(AppTheme.background)

                Divider().background(AppTheme.secondaryText.opacity(0.15))

                if nutritionStore.pastLogs.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            ForEach(nutritionStore.pastLogs) { dayLog in
                                DayLogCard(dayLog: dayLog)
                            }
                        }
                        .padding(20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                Circle()
                    .fill(AppTheme.surface)
                    .frame(width: 80, height: 80)
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 34))
                    .foregroundColor(AppTheme.secondaryText.opacity(0.7))
            }
            Text("No History Yet")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("Your past food logs will appear here\nonce you start tracking your meals.")
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            Spacer()
        }
        .padding()
    }
}

// MARK: - DayLogCard

struct DayLogCard: View {
    let dayLog: DayLog
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // ── Header ─────────────────────────────────────
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    // Date icon
                    VStack(spacing: 2) {
                        Image(systemName: "calendar")
                            .font(.title3)
                            .foregroundColor(AppTheme.primary)
                    }
                    .frame(width: 40, height: 40)
                    .background(AppTheme.primary.opacity(0.12))
                    .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(dayLog.displayDate)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        HStack(spacing: 10) {
                            HStack(spacing: 3) {
                                Image(systemName: "flame.fill")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                Text("\(Int(dayLog.totalCalories)) kcal")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppTheme.primary)
                            }
                            Text("•").foregroundColor(AppTheme.secondaryText).font(.caption2)
                            Text("\(dayLog.entries.count) item\(dayLog.entries.count != 1 ? "s" : "")")
                                .font(.caption)
                                .foregroundColor(AppTheme.secondaryText)
                        }
                    }

                    Spacer()

                    // Macro mini-summary
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("P: \(Int(dayLog.totalProtein))g")
                            .font(.caption2).foregroundColor(.red)
                        Text("C: \(Int(dayLog.totalCarbs))g")
                            .font(.caption2).foregroundColor(Color(red:1,green:0.8,blue:0.1))
                        Text("F: \(Int(dayLog.totalFat))g")
                            .font(.caption2).foregroundColor(.cyan)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryText)
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            // ── Expanded Food Entries ──────────────────────
            if isExpanded {
                Divider()
                    .background(AppTheme.secondaryText.opacity(0.1))
                    .padding(.horizontal, 16)

                VStack(spacing: 0) {
                    ForEach(dayLog.entries) { entry in
                        HistoryEntryRow(entry: entry)
                        if entry.id != dayLog.entries.last?.id {
                            Divider()
                                .background(AppTheme.secondaryText.opacity(0.08))
                                .padding(.leading, 72)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(AppTheme.surface)
        .cornerRadius(16)
    }
}

// MARK: - HistoryEntryRow

struct HistoryEntryRow: View {
    let entry: FoodLogEntry

    private var iconColor: Color {
        foodIconOptions.first { $0.id == entry.iconName }?.color ?? AppTheme.secondaryText
    }

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: entry.iconName)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(entry.timeString)
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText)

                HStack(spacing: 8) {
                    Text("\(Int(entry.calories * entry.servings)) kcal")
                        .font(.caption).fontWeight(.bold).foregroundColor(AppTheme.primary)
                    macroChip("P", value: entry.protein * entry.servings, color: .red)
                    macroChip("C", value: entry.carbs   * entry.servings, color: Color(red:1,green:0.8,blue:0.1))
                    macroChip("F", value: entry.fat     * entry.servings, color: .cyan)
                }
            }

            Spacer()

            if entry.servings != 1.0 {
                Text("×\(entry.servings, specifier: "%.1f")")
                    .font(.caption2)
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(AppTheme.background)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func macroChip(_ prefix: String, value: Double, color: Color) -> some View {
        HStack(spacing: 1) {
            Text(prefix + ":")
                .font(.caption2)
                .foregroundColor(AppTheme.secondaryText)
            Text("\(Int(value))g")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Preview

struct NutritionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionHistoryView()
            .environmentObject(NutritionStore())
            .preferredColorScheme(.dark)
    }
}
