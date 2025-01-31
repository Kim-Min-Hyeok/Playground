//
//  ImagePicker.swift
//  VisionTest
//
//  Created by Minhyeok Kim on 1/29/25.
//

import UIKit
import SwiftUI

class ImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    static let shared = ImagePicker()

    private var completion: ((UIImage) -> Void)?

    func pickImage(completion: @escaping (UIImage) -> Void) {
        self.completion = completion
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            completion?(image)
        }
    }
}
