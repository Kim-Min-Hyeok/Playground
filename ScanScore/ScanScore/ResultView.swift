//
//  ResultView.swift
//  ScanScore
//
//  Created by Minhyeok Kim on 1/28/25.
//

import SwiftUI
import PhotosUI

struct ResultView: View {
    @State private var selectedImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var staves: [NSNumber] = [] // 오선 좌표 저장
    @State private var detectedObjects: [NSDictionary] = []
    @State private var isPickerPresented = false
    let standardSpacing: CGFloat = 10.0  // 기준 오선 간격
    
    var body: some View {
        VStack {
            if let image = processedImage ?? selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 600)
            } else {
                Text("이미지를 선택하세요.")
                    .font(.headline)
            }
            
            HStack {
                Button("앨범에서 이미지 선택") {
                    isPickerPresented = true
                }
                .padding()
                .sheet(isPresented: $isPickerPresented) {
                    PhotoPicker(selectedImage: $selectedImage)
                }
                
                Button("OpenCV - 이진화") {
                    if let image = selectedImage {
                        processedImage = PreProcessing.threshold(image)
                    }
                }
                .padding()
                
                Button("OpenCV - 보표 추출") {
                    if let image = selectedImage {
                        processedImage = PreProcessing.removeNoise(image)
                    }
                }
                .padding()
                
                Button("OpenCV - 오선 제거") {
                    if let image = processedImage {
                        var stavesArray: NSArray = [] // ✅ NSArray로 선언
                        processedImage = PreProcessing.removeStaves(image, staves: &stavesArray)

                        if let convertedStaves = stavesArray as? [NSNumber] { // ✅ Swift 배열로 변환
                            staves = convertedStaves
                            print("[DEBUG] 검출된 오선 개수: \(staves.count)")
                        } else {
                            print("[ERROR] 오선 감지 실패: staves 변환 오류")
                        }
                    }
                }
                .padding()

                Button("OpenCV - 악보 정규화") {
                    if let image = processedImage, !staves.isEmpty {
                        processedImage = PreProcessing.normalizeImage(image, staves: staves, standard: standardSpacing)
                    } else {
                        print("[ERROR] 악보 정규화 실패: 오선 좌표가 없습니다.")
                    }
                }
                .padding()
                
                Button("OpenCV - 객체 검출") {
                    if let image = processedImage {
                        if let result = ObjectDetection.detectObjects(image, staves: staves) as? [String: Any],
                           let updatedImage = result["image"] as? UIImage,
                           let detectedObjectsArray = result["objects"] as? [NSDictionary] {
                            processedImage = updatedImage
                            detectedObjects = detectedObjectsArray
                            print("[DEBUG] 검출된 객체 개수: \(detectedObjects.count)")
                        } else {
                            print("[ERROR] 객체 검출 실패")
                        }
                    }
                }
                
                Button("OpenCV - 객체 분석") {
                    if let image = processedImage {
                        print("[DEBUG] 객체 분석 시작")
                        // NSDictionary를 [AnyHashable: Any]로 변환
                        let convertedObjects: [[AnyHashable: Any]] = detectedObjects.map { $0 as? [AnyHashable: Any] ?? [:] }
                        processedImage = ObjectAnalysis.analyzeObjects(image, objects: convertedObjects)
                    }
                }
                .padding()
                
                Button("OpenCV - 조표 인식") {
                    if let image = processedImage {
                        let convertedObjects: [[AnyHashable: Any]] = detectedObjects.map { $0 as? [AnyHashable: Any] ?? [:] }
                        processedImage = ObjectRecognition.recognition(image, staves: staves, objects: convertedObjects)
                    }
                }
                .padding()
            }
        }
    }
}

// 📌 `PhotoPicker` 뷰 추가: 사진 라이브러리에서 이미지 선택
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            if let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

#Preview {
    ResultView()
}
