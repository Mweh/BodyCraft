import SwiftUI
import PhotosUI

// MARK: - Food Icon Categories

struct FoodIcon: Identifiable {
    let id: String          // SF Symbol name
    let label: String       // Display color accent
    let color: Color
}

let foodIconOptions: [FoodIcon] = [
    FoodIcon(id: "fork.knife",           label: "Meal",    color: .orange),
    FoodIcon(id: "fork.knife.circle",    label: "Dish",    color: .yellow),
    FoodIcon(id: "takeoutbag.and.cup.and.straw.fill", label: "Fast Food", color: .red),
    FoodIcon(id: "cup.and.saucer.fill",  label: "Drink",   color: .cyan),
    FoodIcon(id: "mug.fill",             label: "Hot Drink",color: .brown),
    FoodIcon(id: "carrot.fill",          label: "Veggie",  color: Color(red:1,green:0.5,blue:0)),
    FoodIcon(id: "leaf.fill",            label: "Salad",   color: .green),
    FoodIcon(id: "fish.fill",            label: "Fish",    color: .blue),
    FoodIcon(id: "birthday.cake.fill",   label: "Cake",    color: .pink),
    FoodIcon(id: "popcorn.fill",         label: "Snack",   color: Color(red:1,green:0.85,blue:0)),
    FoodIcon(id: "wineglass.fill",       label: "Beverage",color: .purple),
    FoodIcon(id: "bolt.heart.fill",      label: "Protein", color: .red),
    FoodIcon(id: "flame.fill",           label: "Spicy",   color: .orange),
    FoodIcon(id: "pills.fill",           label: "Supplement",color: .cyan),
    FoodIcon(id: "drop.fill",            label: "Water",   color: .blue),
    FoodIcon(id: "star.fill",            label: "Other",   color: .yellow),
]

// MARK: - Add Food Manually Sheet

struct AddFoodManuallySheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var nutritionStore: NutritionStore

    // Form state
    @State private var foodName: String = ""
    @State private var caloriesText: String = ""
    @State private var proteinText: String = "0"
    @State private var carbsText: String = "0"
    @State private var fatText: String = "0"
    @State private var servingSize: Double = 1.0
    @State private var entryTime: Date = Date()
    @State private var selectedIconID: String = "fork.knife"
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var photoImage: Image? = nil

    private let servingOptions: [(label: String, value: Double)] = [
        ("0.5 serving", 0.5),
        ("1 serving",   1.0),
        ("1.5 servings",1.5),
        ("2 servings",  2.0),
        ("3 servings",  3.0)
    ]

    private var isFormValid: Bool {
        !foodName.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(caloriesText) != nil
    }

    private var timeString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "hh:mm a"
        return fmt.string(from: entryTime)
    }

    private var selectedIcon: FoodIcon {
        foodIconOptions.first { $0.id == selectedIconID } ?? foodIconOptions[0]
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle bar
                Capsule()
                    .fill(AppTheme.secondaryText.opacity(0.4))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        // ── Header ───────────────────────────────
                        HStack {
                            Text("Add Manually")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Button { dismiss() } label: {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.surface)
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppTheme.secondaryText)
                                }
                            }
                        }

                        // ── Food Photo (optional) ─────────────────


                        // ── Food Icon ─────────────────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Food Icon")
                                .formLabel()

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(foodIconOptions) { icon in
                                        let isSelected = selectedIconID == icon.id
                                        Button {
                                            selectedIconID = icon.id
                                        } label: {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(isSelected ? icon.color.opacity(0.2) : AppTheme.surface)
                                                    .frame(width: 48, height: 48)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(isSelected ? icon.color : Color.clear, lineWidth: 1.5)
                                                    )
                                                Image(systemName: icon.id)
                                                    .font(.system(size: 20))
                                                    .foregroundColor(isSelected ? icon.color : AppTheme.secondaryText)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // ── Food Name ─────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            requiredLabel("Food Name")
                            TextField("e.g. Grilled Chicken Breast", text: $foodName)
                                .styledInputField()
                        }

                        // ── Calories ──────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            requiredLabel("Calories (kcal)")
                            TextField("e.g. 350", text: $caloriesText)
                                .keyboardType(.decimalPad)
                                .styledInputField()
                        }

                        // ── Macros ────────────────────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Macros (g)").formLabel()
                            HStack(spacing: 10) {
                                MacroInputField(label: "Protein", color: .red,  text: $proteinText)
                                MacroInputField(label: "Carbs",   color: Color(red:1,green:0.8,blue:0.1), text: $carbsText)
                                MacroInputField(label: "Fat",     color: .cyan, text: $fatText)
                            }
                        }

                        // ── Serving Size ──────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Serving Size").formLabel()
                            Menu {
                                ForEach(servingOptions, id: \.label) { option in
                                    Button(option.label) { servingSize = option.value }
                                }
                            } label: {
                                HStack {
                                    Text(servingOptions.first { $0.value == servingSize }?.label ?? "1 serving")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(AppTheme.secondaryText)
                                        .font(.caption)
                                }
                                .padding()
                                .background(AppTheme.surface)
                                .cornerRadius(12)
                            }
                        }

                        // ── Time ──────────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Time").formLabel()
                            HStack {
                                Text(timeString).foregroundColor(.white)
                                Spacer()
                                Image(systemName: "clock").foregroundColor(AppTheme.secondaryText)
                            }
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(12)
                        }

                        Spacer().frame(height: 8)
                    }
                    .padding(.horizontal, 20)
                }

                // ── Bottom Buttons ────────────────────────────
                HStack(spacing: 12) {
                    Button("Cancel") { dismiss() }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.surface)
                        .foregroundColor(.white)
                        .cornerRadius(14)

                    Button("Add to Log") { addEntry() }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isFormValid ? AppTheme.primary : AppTheme.primary.opacity(0.4))
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .cornerRadius(14)
                        .disabled(!isFormValid)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(AppTheme.background)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func requiredLabel(_ text: String) -> some View {
        HStack(spacing: 4) {
            Text(text).formLabel()
            Text("*").foregroundColor(.red).font(.subheadline)
        }
    }

    private func addEntry() {
        guard let cal = Double(caloriesText) else { return }
        let entry = FoodLogEntry(
            name:     foodName.trimmingCharacters(in: .whitespaces),
            iconName: selectedIconID,
            calories: cal,
            protein:  Double(proteinText) ?? 0,
            carbs:    Double(carbsText)   ?? 0,
            fat:      Double(fatText)     ?? 0,
            time:     entryTime,
            servings: servingSize
        )
        nutritionStore.add(entry: entry)
        dismiss()
    }
}

// MARK: - MacroInputField

struct MacroInputField: View {
    let label: String
    let color: Color
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Circle().fill(color).frame(width: 7, height: 7)
                Text(label).font(.caption2).foregroundColor(AppTheme.secondaryText)
            }
            TextField("0", text: $text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .font(.headline)
                .foregroundColor(.white)
                .tint(AppTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.surface)
                .cornerRadius(10)
        }
    }
}

// MARK: - ViewModifiers (local helpers)

private extension Text {
    func formLabel() -> some View {
        self.font(.subheadline).fontWeight(.medium).foregroundColor(AppTheme.secondaryText)
    }
}

private extension View {
    func formLabel() -> some View {
        // Wrapper for Text-returning modifiers on View
        self
    }
    func styledInputField() -> some View {
        self
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(12)
            .foregroundColor(Color.white)
            .tint(AppTheme.primary)
    }
}

// MARK: - Preview

struct AddFoodManuallySheet_Previews: PreviewProvider {
    static var previews: some View {
        AddFoodManuallySheet()
            .environmentObject(NutritionStore())
            .preferredColorScheme(.dark)
    }
}
