//
//  ChordRecognitionView.swift
//  ScanChord
//
//  Created by Minhyeok Kim on 1/29/25.
//

import SwiftUI
import Vision
import PhotosUI

struct ChordRecognitionView: View {
    @State private var selectedImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var recognizedText: String = ""
    @State private var staves: [NSNumber] = []
    @State private var isPickerPresented = false
    
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
            
            Text("OCR 결과: \(recognizedText)")
                .padding()
            
            HStack {
                Button("앨범에서 이미지 선택") {
                    isPickerPresented = true
                }
                .padding()
                .sheet(isPresented: $isPickerPresented) {
                    PhotoPicker(selectedImage: $selectedImage)
                }
                
                Button("OpenCV - 코드 검출") {
                    if let image = selectedImage {
                        // 안전한 방식으로 오선 제거 및 정보 획득
                        let result = PreProcessing.removeStavesAndReturnInfo(image)
                        if let noStavesImage = result["image"] as? UIImage,
                           let stavesArray = result["staves"] as? [NSNumber] {
                            staves = stavesArray
                            processedImage = ChordRecognition.detectChords(noStavesImage, staves: staves)
                        }
                    }
                }
                .padding()

                Button("OCR 실행") {
                    if let image = processedImage ?? selectedImage {
                        recognizedText = ChordRecognition.recognizeText(image)
                    }
                }
                .padding()
            }
        }
    }
}

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
