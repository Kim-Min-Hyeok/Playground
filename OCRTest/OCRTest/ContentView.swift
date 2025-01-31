import SwiftUI

struct ContentView: View {
    // 전처리 있는 버전
//        @State private var selectedImage: UIImage?
//        @State private var processedImage: UIImage?
//        @State private var detectedTexts: [(String, CGRect)] = []
//    
//        var body: some View {
//            HStack {
//                // Left side: Original and Processed Images
//                VStack {
//                    if let selectedImage = selectedImage,
//                       let processedImage = processedImage {
//                        HStack(spacing: 20) {
//                            // Original Image
//                            VStack {
//                                Text("Original")
//                                    .font(.headline)
//                                Image(uiImage: selectedImage)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(maxWidth: .infinity)
//                                    .frame(height: 600)
//                            }
//    
//                            // Processed Image with Overlay
//                            VStack {
//                                Text("Processed")
//                                    .font(.headline)
//                                GeometryReader { geometry in
//                                    ZStack {
//                                        Image(uiImage: processedImage)
//                                            .resizable()
//                                            .scaledToFit()
//                                            .frame(maxWidth: .infinity)
//    
//                                        // OCR Results Overlay
//                                        ForEach(detectedTexts.indices, id: \.self) { index in
//                                            let text = detectedTexts[index].0
//                                            let box = convertBoundingBox(
//                                                detectedTexts[index].1,
//                                                imageSize: processedImage.size,
//                                                geometrySize: geometry.size
//                                            )
//    
//                                            ZStack {
//                                                Rectangle()
//                                                    .stroke(Color.red, lineWidth: 2)
//                                                    .frame(width: box.width, height: box.height)
//    
//                                                VStack {
//                                                    Text("\(index + 1)")
//                                                        .font(.caption)
//                                                        .bold()
//                                                        .foregroundColor(.yellow)
//                                                        .background(Color.red.opacity(0.8))
//                                                        .clipShape(Circle())
//                                                        .frame(width: 20, height: 20)
//                                                }
//                                            }
//                                            .position(x: box.midX, y: box.midY)
//                                        }
//                                    }
//                                }
//                                .frame(height: 600)
//                            }
//                        }
//                        .padding()
//                    }
//    
//                    Button("Select Image") {
//                        ImagePicker.shared.pickImage { image in
//                            self.selectedImage = image
//                            let preprocessed = PreProcessing.processImage(image)
//                            self.processedImage = preprocessed
//    
//                            VisionProcessor.extractText(from: preprocessed) { results in
//                                self.detectedTexts = results
//                            }
//                        }
//                    }
//                    .padding()
//                }
//                .frame(maxWidth: .infinity)
//    
//                // Right side: Detected Text List
//                if !detectedTexts.isEmpty {
//                    VStack {
//                        Text("Detected Texts")
//                            .font(.headline)
//                            .padding(.bottom)
//    
//                        ScrollView {
//                            VStack(alignment: .leading, spacing: 10) {
//                                ForEach(detectedTexts.indices, id: \.self) { index in
//                                    HStack {
//                                        Text("\(index + 1).")
//                                            .foregroundColor(.red)
//                                            .bold()
//                                        Text(detectedTexts[index].0)
//                                    }
//                                    .padding(.horizontal)
//                                }
//                            }
//                        }
//                    }
//                    .frame(width: 200)
//                    .padding()
//                    .background(Color.gray.opacity(0.1))
//                }
//            }
//        }
    
    // 전처리 없는 버전
    @State private var selectedImage: UIImage?
    @State private var detectedTexts: [(String, CGRect)] = []
    
    var body: some View {
        HStack {
            // Left side: Original Image and OCR Overlay
            VStack {
                if let selectedImage = selectedImage {
                    VStack {
                        Text("Original Image")
                            .font(.headline)
                        
                        GeometryReader { geometry in
                            ZStack {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                
                                // OCR Results Overlay
                                ForEach(detectedTexts.indices, id: \.self) { index in
                                    let text = detectedTexts[index].0
                                    let box = convertBoundingBox(
                                        detectedTexts[index].1,
                                        imageSize: selectedImage.size,
                                        geometrySize: geometry.size
                                    )
                                    
                                    ZStack {
                                        Rectangle()
                                            .stroke(Color.blue, lineWidth: 2)
                                            .frame(width: box.width, height: box.height)
                                        
                                        VStack {
                                            Text("\(index + 1)")
                                                .font(.caption)
                                                .bold()
                                                .foregroundColor(.yellow)
                                                .background(Color.blue.opacity(0.8))
                                                .clipShape(Circle())
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                    .position(x: box.midX, y: box.midY)
                                }
                            }
                        }
                        .frame(height: 600)
                    }
                }
                
                Button("Select Image") {
                    ImagePicker.shared.pickImage { image in
                        self.selectedImage = image
                        
                        // ✅ 전처리 없이 OCR 실행
                        VisionProcessor.extractText(from: image) { results in
                            self.detectedTexts = results
                        }
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            
            // Right side: Detected Text List
            if !detectedTexts.isEmpty {
                VStack {
                    Text("Detected Texts")
                        .font(.headline)
                        .padding(.bottom)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(detectedTexts.indices, id: \.self) { index in
                                HStack {
                                    Text("\(index + 1).")
                                        .foregroundColor(.blue)
                                        .bold()
                                    Text(detectedTexts[index].0)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .frame(width: 200)
                .padding()
                .background(Color.gray.opacity(0.1))
            }
        }
    }
}

func convertBoundingBox(_ boundingBox: CGRect, imageSize: CGSize, geometrySize: CGSize) -> CGRect {
    let scaleX = geometrySize.width / imageSize.width
    let scaleY = geometrySize.height / imageSize.height
    let scale = min(scaleX, scaleY)
    
    // Calculate the actual size of the image after scaling
    let scaledWidth = imageSize.width * scale
    let scaledHeight = imageSize.height * scale
    
    // Calculate offsets to center the image
    let xOffset = (geometrySize.width - scaledWidth) / 2
    let yOffset = (geometrySize.height - scaledHeight) / 2
    
    return CGRect(
        x: boundingBox.origin.x * scaledWidth + xOffset,
        y: (1 - boundingBox.origin.y - boundingBox.height) * scaledHeight + yOffset,
        width: boundingBox.width * scaledWidth,
        height: boundingBox.height * scaledHeight
    )
}

#Preview {
    ContentView()
}
