import SwiftUI

// MARK: - Body Fat Step View

struct BodyFatStepView: View {
    @Binding var bodyFat: Double   // stored as a Double, e.g. 15.0
    var nextAction: () -> Void

    // Range limits
    private let minFat: Double = 5
    private let maxFat: Double = 45

    private var category: BodyFatCategory {
        BodyFatCategory.category(for: bodyFat)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // ── Header ─────────────────────────────────────────────────────
            Text("Body Fat %")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)

            Text("Drag the slider to match your current body fat percentage.")
                .font(.subheadline)
                .foregroundColor(AppTheme.secondaryText)

            // ── Compact Horizontal Preview Card ───────────────────────────
            HStack(spacing: 14) {
                BodySilhouetteView(category: category)
                    .frame(width: 80, height: 118)
                    .animation(.spring(response: 0.4), value: category.id)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 0) {
                        Text(String(format: "%.0f", bodyFat))
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())
                        Text("%")
                            .font(.title2).fontWeight(.bold).foregroundColor(.white)
                            .padding(.top, 4)
                    }
                    Text(category.label)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(category.color)
                        .padding(.horizontal, 10).padding(.vertical, 3)
                        .background(category.color.opacity(0.15))
                        .clipShape(Capsule())
                    Text(category.description)
                        .font(.caption2)
                        .foregroundColor(AppTheme.secondaryText)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .background(
                LinearGradient(colors: [category.color.opacity(0.18), AppTheme.surface],
                               startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(category.color.opacity(0.35), lineWidth: 1.5))

            // ── Slider ─────────────────────────────────────────────────────
            VStack(spacing: 8) {
                Slider(value: $bodyFat, in: minFat...maxFat, step: 1)
                    .accentColor(category.color)

                HStack {
                    Text("5%")
                    Spacer()
                    Text("45%")
                }
                .font(.caption2)
                .foregroundColor(AppTheme.secondaryText)

                GeometryReader { geo in
                    HStack(spacing: 0) {
                        ForEach(BodyFatCategory.allCases) { cat in
                            cat.color.frame(width: geo.size.width * cat.widthFraction)
                        }
                    }
                    .frame(height: 5).clipShape(Capsule())
                }
                .frame(height: 5)
            }
            .padding(12)
            .background(AppTheme.surface)
            .cornerRadius(14)

            // ── Category chips (3 columns) ─────────────────────────────────
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                ForEach(BodyFatCategory.allCases) { cat in
                    HStack(spacing: 4) {
                        Circle().fill(cat.color).frame(width: 6, height: 6)
                        Text(cat.rangeLabel)
                            .font(.caption2)
                            .foregroundColor(cat.id == category.id ? .white : AppTheme.secondaryText)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 7).padding(.vertical, 5)
                    .background(cat.id == category.id ? cat.color.opacity(0.18) : AppTheme.surface)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(cat.id == category.id ? cat.color.opacity(0.5) : Color.clear, lineWidth: 1))
                }
            }

            Spacer()

            PrimaryButton(title: "Continue", action: nextAction)
        }
        .padding()
        .animation(.easeInOut(duration: 0.25), value: category.id)
    }
}

// MARK: - Body Fat Category

enum BodyFatCategory: String, CaseIterable, Identifiable {
    case essential    // 5-9 %
    case athletic     // 10-14 %
    case fitness      // 15-19 %
    case average      // 20-24 %
    case aboveAverage // 25-29 %
    case obese        // 30-45 %

    var id: String { rawValue }

    static func category(for fat: Double) -> BodyFatCategory {
        switch fat {
        case ..<10:   return .essential
        case ..<15:   return .athletic
        case ..<20:   return .fitness
        case ..<25:   return .average
        case ..<30:   return .aboveAverage
        default:      return .obese
        }
    }

    var label: String {
        switch self {
        case .essential:    return "Essential Fat"
        case .athletic:     return "Athletic"
        case .fitness:      return "Fitness"
        case .average:      return "Average"
        case .aboveAverage: return "Above Average"
        case .obese:        return "High Body Fat"
        }
    }

    var rangeLabel: String {
        switch self {
        case .essential:    return "5–9%"
        case .athletic:     return "10–14%"
        case .fitness:      return "15–19%"
        case .average:      return "20–24%"
        case .aboveAverage: return "25–29%"
        case .obese:        return "30%+"
        }
    }

    var description: String {
        switch self {
        case .essential:    return "Extremely lean — necessary for basic physiological functions. Suitable for elite competitors."
        case .athletic:     return "Competition-ready physique. Visible muscle separation and vascularity."
        case .fitness:      return "Lean and defined look. Abs visible, ideal for most fitness goals."
        case .average:      return "Healthy range for most adults. Some muscle definition visible."
        case .aboveAverage: return "Slightly above healthy range. Consider fat loss as a secondary goal."
        case .obese:        return "Higher risk range. Progressive fat loss recommended alongside training."
        }
    }

    var color: Color {
        switch self {
        case .essential:    return .cyan
        case .athletic:     return .blue
        case .fitness:      return .green
        case .average:      return .yellow
        case .aboveAverage: return .orange
        case .obese:        return .red
        }
    }

    /// Fraction of 40% total range (5–45) each category occupies
    var widthFraction: CGFloat {
        switch self {
        case .essential:    return 5.0 / 40.0
        case .athletic:     return 5.0 / 40.0
        case .fitness:      return 5.0 / 40.0
        case .average:      return 5.0 / 40.0
        case .aboveAverage: return 5.0 / 40.0
        case .obese:        return 15.0 / 40.0
        }
    }
}

// MARK: - Body Silhouette (SwiftUI drawn)

struct BodySilhouetteView: View {
    let category: BodyFatCategory

    /// Waist width multiplier: lower fat = slimmer waist
    private var waistScale: CGFloat {
        switch category {
        case .essential:    return 0.32
        case .athletic:     return 0.38
        case .fitness:      return 0.44
        case .average:      return 0.52
        case .aboveAverage: return 0.60
        case .obese:        return 0.72
        }
    }

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let cx = w / 2

            // ── Colours ────────────────────────────────────
            let bodyFill   = category.color.opacity(0.35)
            let bodyStroke = category.color.opacity(0.85)

            // ── Head ───────────────────────────────────────
            let headR: CGFloat = w * 0.14
            let headY: CGFloat = headR + h * 0.02
            var headPath = Path()
            headPath.addEllipse(in: CGRect(x: cx - headR, y: h * 0.02,
                                           width: headR * 2, height: headR * 2.1))
            context.fill(headPath, with: .color(bodyFill))
            context.stroke(headPath, with: .color(bodyStroke), lineWidth: 2)

            // ── Neck ───────────────────────────────────────
            let neckW: CGFloat = w * 0.1
            let neckTop = headY + headR * 1.8
            let neckBot = neckTop + h * 0.05
            var neckPath = Path()
            neckPath.move(to: CGPoint(x: cx - neckW/2, y: neckTop))
            neckPath.addLine(to: CGPoint(x: cx + neckW/2, y: neckTop))
            neckPath.addLine(to: CGPoint(x: cx + neckW/2, y: neckBot))
            neckPath.addLine(to: CGPoint(x: cx - neckW/2, y: neckBot))
            neckPath.closeSubpath()
            context.fill(neckPath, with: .color(bodyFill))

            // ── Shoulders / Torso ──────────────────────────
            let shoulderW: CGFloat = w * 0.52
            let waistW:    CGFloat = w * waistScale
            let torsoTop  = neckBot
            let torsoBot  = torsoTop + h * 0.36

            var torsoPath = Path()
            torsoPath.move(to: CGPoint(x: cx - shoulderW/2, y: torsoTop))
            torsoPath.addLine(to: CGPoint(x: cx + shoulderW/2, y: torsoTop))
            // right side taper to waist then expand to hip
            torsoPath.addCurve(
                to: CGPoint(x: cx + waistW/2, y: torsoTop + (torsoBot - torsoTop) * 0.55),
                control1: CGPoint(x: cx + shoulderW/2 + 4, y: torsoTop + (torsoBot - torsoTop) * 0.25),
                control2: CGPoint(x: cx + waistW/2 + 4,    y: torsoTop + (torsoBot - torsoTop) * 0.4)
            )
            torsoPath.addCurve(
                to: CGPoint(x: cx + shoulderW * 0.45, y: torsoBot),
                control1: CGPoint(x: cx + waistW/2 + 4,        y: torsoTop + (torsoBot - torsoTop) * 0.7),
                control2: CGPoint(x: cx + shoulderW * 0.45 + 2, y: torsoTop + (torsoBot - torsoTop) * 0.85)
            )
            // left mirror
            torsoPath.addLine(to: CGPoint(x: cx - shoulderW * 0.45, y: torsoBot))
            torsoPath.addCurve(
                to: CGPoint(x: cx - waistW/2, y: torsoTop + (torsoBot - torsoTop) * 0.55),
                control1: CGPoint(x: cx - shoulderW * 0.45 - 2, y: torsoTop + (torsoBot - torsoTop) * 0.85),
                control2: CGPoint(x: cx - waistW/2 - 4,         y: torsoTop + (torsoBot - torsoTop) * 0.7)
            )
            torsoPath.addCurve(
                to: CGPoint(x: cx - shoulderW/2, y: torsoTop),
                control1: CGPoint(x: cx - waistW/2 - 4,    y: torsoTop + (torsoBot - torsoTop) * 0.4),
                control2: CGPoint(x: cx - shoulderW/2 - 4, y: torsoTop + (torsoBot - torsoTop) * 0.25)
            )
            torsoPath.closeSubpath()
            context.fill(torsoPath, with: .color(bodyFill))
            context.stroke(torsoPath, with: .color(bodyStroke), lineWidth: 2)

            // ── Arms ───────────────────────────────────────
            let armW: CGFloat = w * 0.12
            let armTop = torsoTop + h * 0.02
            let armBot = torsoBot - h * 0.02

            for side in [-1.0, 1.0] {
                let armX = cx + CGFloat(side) * (shoulderW / 2 + armW * 0.2)
                var armPath = Path()
                armPath.addRoundedRect(
                    in: CGRect(x: armX - (side > 0 ? armW : 0), y: armTop, width: armW, height: armBot - armTop),
                    cornerSize: CGSize(width: armW / 2, height: armW / 2)
                )
                context.fill(armPath, with: .color(bodyFill))
                context.stroke(armPath, with: .color(bodyStroke), lineWidth: 1.5)
            }

            // ── Legs ───────────────────────────────────────
            let legW: CGFloat = w * 0.22
            let legTop = torsoBot
            let legBot = h * 0.97
            let legGap: CGFloat = w * 0.04

            for side in [-1.0, 1.0] {
                let legX = cx + CGFloat(side) * legGap
                var legPath = Path()
                let lx = side > 0 ? legX : legX - legW
                legPath.addRoundedRect(
                    in: CGRect(x: lx, y: legTop, width: legW, height: legBot - legTop),
                    cornerSize: CGSize(width: legW / 2.5, height: legW / 2.5)
                )
                context.fill(legPath, with: .color(bodyFill))
                context.stroke(legPath, with: .color(bodyStroke), lineWidth: 1.5)
            }
        }
    }
}
