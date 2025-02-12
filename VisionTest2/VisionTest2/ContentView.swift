import SwiftUI
import UIKit
import Vision

struct ContentView: View {
    @State private var image: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var recognizedAreas: [RecognizedArea] = []
    @State private var isProcessing = false
    @State private var processedImage: UIImage? = nil  // 전처리(이진화)된 이미지
    
    var body: some View {
        VStack {
            ZStack {
                if let uiImage = processedImage ?? image {
                    // GeometryReader를 사용해 실제 이미지가 표시되는 frame 정보를 가져옴.
                    GeometryReader { geo in
                        let imageFrame = geo.frame(in: .local)
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 400)
                            .overlay(
                                ZStack {
                                    // 감지된 영역들을 순서대로 오버레이함.
                                    ForEach(Array(recognizedAreas.enumerated()), id: \.element.id) { index, area in
                                        // normalized boundingBox를 실제 이미지 좌표로 변환.
                                        let convertedRect = convert(rect: area.boundingBox, in: uiImage.size, to: imageFrame)
                                        
                                        // 빨간 경계 박스.
                                        Rectangle()
                                            .stroke(Color.red, lineWidth: 2)
                                            .frame(width: convertedRect.width, height: convertedRect.height)
                                            .position(x: convertedRect.midX, y: convertedRect.midY)
                                        
                                        // 왼쪽 상단에 영역 번호 표시.
                                        Text("\(index + 1)")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(4)
                                            .background(Color.black.opacity(0.7))
                                            .cornerRadius(4)
                                            .position(x: convertedRect.minX + 15, y: convertedRect.minY + 15)
                                    }
                                }
                            )
                    }
                    .frame(height: 400)
                } else {
                    // 이미지 미선택 시 플레이스홀더.
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(height: 400)
                        .overlay(
                            Text("Please select an image")
                                .foregroundColor(.white)
                                .font(.headline)
                        )
                }
            }
            
            // 감지된 영역 목록 (번호만 표시)
            if !recognizedAreas.isEmpty {
                Text("Detected Areas:")
                    .font(.headline)
                    .padding(.top)
                List(recognizedAreas.indices.map { "Area \($0 + 1)" }, id: \.self) { areaLabel in
                    Text(areaLabel)
                }
                .frame(height: 200)
            }
            
            if isProcessing {
                ProgressView("Processing and detecting text areas...")
                    .padding()
            }
            
            HStack(spacing: 16) {
                Button(action: {
                    isShowingImagePicker = true
                }) {
                    Text("Select Image")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button(action: {
                    guard let uiImage = image else { return }
                    isProcessing = true
                    recognizedAreas = []
                    
                    // 먼저 이미지 전처리(이진화) 수행
                    if let binarized = binarizeImage(uiImage, threshold: 0.5) {
                        processedImage = binarized
                        // 이진화된 이미지를 대상으로 텍스트 영역 감지 수행
                        TextAreaDetector.detectTextAreas(in: binarized) { areas in
                            DispatchQueue.main.async {
                                recognizedAreas = areas
                                isProcessing = false
                            }
                        }
                    } else {
                        // 이진화 실패 시 원본 이미지를 대상으로 진행
                        processedImage = uiImage
                        TextAreaDetector.detectTextAreas(in: uiImage) { areas in
                            DispatchQueue.main.async {
                                recognizedAreas = areas
                                isProcessing = false
                            }
                        }
                    }
                }) {
                    Text("Detect Text Areas")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            
            Spacer()
        }
        // ImagePicker.swift 파일의 ImagePicker를 사용.
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $image)
        }
    }
}

/// Vision의 normalized 좌표(rect)를 실제 이미지 표시 좌표로 변환하는 함수.
func convert(rect: CGRect, in imageSize: CGSize, to imageFrame: CGRect) -> CGRect {
    // scaledToFit 사용 시 실제 표시된 이미지 크기를 계산.
    let scale = min(imageFrame.width / imageSize.width, imageFrame.height / imageSize.height)
    let displayedImageSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    // 이미지가 imageFrame 내 중앙에 위치하도록 오프셋 계산.
    let xOffset = (imageFrame.width - displayedImageSize.width) / 2
    let yOffset = (imageFrame.height - displayedImageSize.height) / 2
    
    // Vision의 boundingBox는 (0,0)이 왼쪽 아래이므로, SwiftUI 좌표계로 변환 (0,0이 왼쪽 위).
    let x = rect.origin.x * displayedImageSize.width + xOffset + imageFrame.minX
    let y = (1 - rect.origin.y - rect.height) * displayedImageSize.height + yOffset + imageFrame.minY
    let width = rect.width * displayedImageSize.width
    let height = rect.height * displayedImageSize.height
    return CGRect(x: x, y: y, width: width, height: height)
}
