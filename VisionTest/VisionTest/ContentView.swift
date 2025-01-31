//
//  ContentView.swift
//  VisionTest
//
//  Created by Minhyeok Kim on 1/29/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var detectedTexts: [(String, CGRect)] = []

    var body: some View {
        VStack {
            if let image = selectedImage {
                GeometryReader { geometry in
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .overlay(
                                OCROverlayView(
                                    detectedTexts: detectedTexts,
                                    imageSize: image.size,
                                    geometrySize: geometry.size
                                )
                            )
                    }
                }
                .frame(height: 650) // 이미지 크기를 조정할 때 필요
            }

            Button("Select Image") {
                ImagePicker.shared.pickImage { image in
                    self.selectedImage = image
                    VisionProcessor.extractText(from: image) { results in
                        self.detectedTexts = results
                    }
                }
            }
            .padding()

            List(detectedTexts.indices, id: \.self) { index in
                Text("\(index + 1): \(detectedTexts[index].0)")
            }
        }
    }
}

#Preview {
    ContentView()
}
