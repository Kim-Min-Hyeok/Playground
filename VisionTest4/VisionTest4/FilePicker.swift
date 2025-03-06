// FilePicker.swift
import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct FilePicker: UIViewControllerRepresentable {
    var onPicked: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf, UTType.png, UTType.jpeg], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onPicked: (URL) -> Void
        
        init(onPicked: @escaping (URL) -> Void) {
            self.onPicked = onPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let originalURL = urls.first else { return }
            
            let ext = originalURL.pathExtension.lowercased()
            
            if ext == "pdf" {
                onPicked(originalURL)
            } else if ext == "png" || ext == "jpg" || ext == "jpeg" {
                if let image = UIImage(contentsOfFile: originalURL.path) {
                    let pdfURL = image.convertToPDF()
                    onPicked(pdfURL)
                } else {
                    print("이미지 로드 실패")
                }
            } else {
                print("지원되지 않는 파일 타입입니다.")
            }
        }
    }
}
