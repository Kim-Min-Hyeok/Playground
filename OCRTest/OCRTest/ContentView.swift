import SwiftUI
import UIKit

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var detectedTexts: [(String, CGRect)] = []
    
    var body: some View {
        HStack {
            // 왼쪽: 원본 이미지와 전처리 이미지를 나란히 표시
            VStack {
                if let selectedImage = selectedImage,
                   let processedImage = processedImage {
                    HStack(spacing: 20) {
                        // 원본 이미지
                        VStack {
                            Text("Original")
                                .font(.headline)
                            GeometryReader { geometry in
                                ZStack {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                    
                                    // OCR 결과 오버레이 (원본 이미지에 표시)
                                    ForEach(detectedTexts.indices, id: \.self) { index in
                                        let box = convertBoundingBox(
                                            detectedTexts[index].1,
                                            imageSize: selectedImage.size,
                                            geometrySize: geometry.size
                                        )
                                        // ZStack 내부의 alignment를 .topLeading으로 설정하여 내용물이 좌측 상단부터 배치되도록 함
                                        ZStack(alignment: .topLeading) {
                                            // 바운딩 박스 그리기
                                            Rectangle()
                                                .stroke(Color.red, lineWidth: 2)
                                                .frame(width: box.width, height: box.height)
                                            // 번호를 바운딩 박스 내부의 왼쪽 상단에 배치
                                            Text("\(index + 1)")
                                                .font(.caption)
                                                .bold()
                                                .foregroundColor(.yellow)
                                                .padding(4)
                                                .background(Color.red.opacity(0.8))
                                                .clipShape(Circle())
                                                // 만약 번호가 텍스트를 가린다면 아래와 같이 약간의 오프셋(예: 위쪽 또는 왼쪽으로)을 줄 수 있음
                                                .offset(x: -10, y: -10)
                                        }
                                        // ZStack 전체를 바운딩 박스의 중앙에 위치시킴
                                        .position(x: box.midX, y: box.midY)
                                    }

                                }
                            }
                            .frame(height: 600)
                        }
                        
                        // 전처리한 이미지
                        VStack {
                            Text("Processed")
                                .font(.headline)
                            GeometryReader { geometry in
                                ZStack {
                                    Image(uiImage: processedImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                    
                                    // OCR 결과 오버레이 (전처리 이미지에 표시)
                                    ForEach(detectedTexts.indices, id: \.self) { index in
                                        let box = convertBoundingBox(
                                            detectedTexts[index].1,
                                            imageSize: processedImage.size,
                                            geometrySize: geometry.size
                                        )
                                        ZStack {
                                            Rectangle()
                                                .stroke(Color.blue, lineWidth: 2)
                                                .frame(width: box.width, height: box.height)
                                            
                                            Text("\(index + 1)")
                                                .font(.caption)
                                                .bold()
                                                .foregroundColor(.yellow)
                                                .padding(4)
                                                .background(Color.blue.opacity(0.8))
                                                .clipShape(Circle())
                                        }
                                        .position(x: box.minX + 15, y: box.minY + 15)
                                    }
                                }
                            }
                            .frame(height: 600)
                        }
                    }
                    .padding()
                }
                
                Button("Select Image") {
                    ImagePicker.shared.pickImage { image in
                        self.selectedImage = image
                        // 전처리 수행 (예: 대비 조정, 노이즈 제거 등)
                        let preprocessed = PreProcessing.processImage(image)
                        self.processedImage = preprocessed
                        
                        // 전처리한 이미지에서 OCR 실행
                        VisionProcessor.extractText(from: preprocessed) { results in
                            self.detectedTexts = results
                        }
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            
            // 오른쪽: 인식된 텍스트 목록
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
                                        .foregroundColor(.red)
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

/// normalized boundingBox를 실제 이미지 표시 좌표로 변환하는 함수
func convertBoundingBox(_ boundingBox: CGRect, imageSize: CGSize, geometrySize: CGSize) -> CGRect {
    let scaleX = geometrySize.width / imageSize.width
    let scaleY = geometrySize.height / imageSize.height
    let scale = min(scaleX, scaleY)
    
    // 실제 표시된 이미지 크기 계산
    let scaledWidth = imageSize.width * scale
    let scaledHeight = imageSize.height * scale
    
    // 이미지가 geometry 내 중앙에 위치하도록 오프셋 계산
    let xOffset = (geometrySize.width - scaledWidth) / 2
    let yOffset = (geometrySize.height - scaledHeight) / 2
    
    // 필요 시 보정값 (예시: x보정 -5, y보정 -5)
    let correctionX: CGFloat = 0  // 오른쪽으로 밀리는 경우 왼쪽으로 이동하려면 양수
    let correctionY: CGFloat = 0  // 아래로 밀리는 경우 위로 이동하려면 양수
    
    return CGRect(
        x: boundingBox.origin.x * scaledWidth + xOffset - correctionX,
        y: (1 - boundingBox.origin.y - boundingBox.height) * scaledHeight + yOffset - correctionY,
        width: boundingBox.width * scaledWidth,
        height: boundingBox.height * scaledHeight
    )
}

#Preview {
    ContentView()
}
