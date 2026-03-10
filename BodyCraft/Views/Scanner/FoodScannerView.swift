//
//  ContentView.swift
//  BodyCraft
//
//  Created by Muhammad Fahmi on 10/03/26.
//

import SwiftUI
import CoreImage
import Combine

struct FoodScannerView: View {
    @StateObject private var viewModel = FoodScannerViewModel()
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                VStack(spacing: 30) {
                    Text("Diet Tracker")
                        .font(.largeTitle)
                        .bold()
                    
                    Image(systemName: "camera.viewfinder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 16) {
                        Button("Take a Photo") {
                            sourceType = .camera
                            showingImagePicker = true
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Button("Choose from Library") {
                            sourceType = .photoLibrary
                            showingImagePicker = true
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
                .padding()
                
            case .processingImage:
                VStack {
                    ProgressView("Analyzing Image...")
                        .scaleEffect(1.5)
                }
                
            case .analysisComplete(let results):
                if let image = viewModel.selectedImage {
                    AnalysisView(
                        image: image,
                        results: results,
                        onConfirm: { food in
                            viewModel.confirmFood(food)
                        },
                        onCancel: {
                            viewModel.reset()
                        }
                    )
                }
                
            case .fetchingNutrition:
                VStack {
                    ProgressView("Fetching Nutrition Data...")
                        .scaleEffect(1.5)
                }
                
            case .resultCalculated(let nutritionInfo):
                NutritionResultView(
                    nutritionInfo: nutritionInfo,
                    onReset: {
                        viewModel.reset()
                    }
                )
                
            case .error(let message):
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.largeTitle)
                    
                    Text("Error")
                        .font(.title)
                        .padding(.vertical, 8)
                    
                    Text(message)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Try Again") {
                        viewModel.reset()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            CameraCaptureView(selectedImage: Binding(
                get: { viewModel.selectedImage },
                set: { image in
                    if let img = image {
                        viewModel.processImage(img)
                    }
                }
            ), sourceType: sourceType)
        }
    }
}

// Reusable Button Styles for Cleaner UI
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct FoodScannerView_Previews: PreviewProvider {
    static var previews: some View {
        FoodScannerView()
    }
}
