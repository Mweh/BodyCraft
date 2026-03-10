import SwiftUI

struct AnalysisView: View {
    let image: UIImage
    let results: [FoodResult]
    let onConfirm: (FoodResult) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
            
            Text("Top Predictions")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                ForEach(results) { result in
                    Button(action: {
                        onConfirm(result)
                    }) {
                        HStack {
                            Text(result.name)
                                .font(.headline)
                            Spacer()
                            Text(result.formattedConfidence)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button("Cancel") {
                onCancel()
            }
            .foregroundColor(.red)
            .padding(.bottom)
        }
    }
}
