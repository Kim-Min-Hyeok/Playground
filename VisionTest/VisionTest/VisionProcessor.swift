//
//  VisionProcessor.swift
//  VisionTest
//
//  Created by Minhyeok Kim on 1/29/25.
//

import Vision
import UIKit

class VisionProcessor {
    static func extractText(from image: UIImage, completion: @escaping ([(String, CGRect)]) -> Void) {
        guard let cgImage = image.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            guard error == nil else { return }
            
            let recognizedTexts = request.results as? [VNRecognizedTextObservation]
            let detectedTextsWithPositions = recognizedTexts?.compactMap { observation -> (String, CGRect)? in
                guard let text = observation.topCandidates(1).first?.string else { return nil }
                return (text, observation.boundingBox)
            } ?? []
            
            // ✅ 콘솔 출력
            for (index, (text, box)) in detectedTextsWithPositions.enumerated() {
                print("📜 [\(index + 1)] 텍스트: '\(text)', 위치: \(box)")
            }
            
            DispatchQueue.main.async {
                completion(detectedTextsWithPositions)
            }
        }
        
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("⚠️ OCR 오류:", error)
            }
        }
    }
}
