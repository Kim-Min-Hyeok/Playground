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
            guard error == nil else {
                completion([]) // ✅ 오류 발생 시 빈 배열 반환
                return
            }
            
            // OCR 결과가 없을 경우 빈 배열 반환
            guard let recognizedTexts = request.results as? [VNRecognizedTextObservation] else {
                completion([]) // ✅ nil 대신 빈 배열 반환
                return
            }
            
            var detectedTextsWithPositions: [(String, CGRect)] = []
            
            for observation in recognizedTexts {
                guard let text = observation.topCandidates(1).first?.string else { continue }
                
                // 🎯 **코드 필터링 적용 (유효한 코드만 선택)**
                let wordsWithBoundingBoxes = splitTextWithBoundingBoxes(text, boundingBox: observation.boundingBox)
                    .filter { isValidChord($0.0) } // ✅ 유효한 코드만 남김
                
                detectedTextsWithPositions.append(contentsOf: wordsWithBoundingBoxes)
            }
            
            // ✅ OCR 결과 정렬 (위→아래, 좌→우 순)
            let sortedResults = sortByVerticalThenHorizontal(detectedTextsWithPositions)
            
            // ✅ 콘솔 출력 (정렬된 결과)
            for (index, (text, box)) in sortedResults.enumerated() {
                print("🎸 코드 [\(index + 1)]: '\(text)', 위치: \(box)")
            }
            
            DispatchQueue.main.async {
                completion(sortedResults)
            }
        }
        
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("⚠️ OCR 오류:", error)
                DispatchQueue.main.async {
                    completion([]) // ✅ 오류 발생 시 빈 배열 반환
                }
            }
        }
    }

    /// 🎸 유효한 코드인지 확인하는 함수 (정규식 적용)
    private static func isValidChord(_ text: String) -> Bool {
        let pattern = #"^[A-G][#b]?(m|maj|min|dim|aug|sus|add)?[0-9]*/?[A-G]?[#b]?$"#
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    /// 📌 띄어쓰기가 포함된 텍스트를 개별 단어로 분리하고, 적절한 Bounding Box 할당
    private static func splitTextWithBoundingBoxes(_ text: String, boundingBox: CGRect) -> [(String, CGRect)] {
        let words = text.split(separator: " ").map { String($0) }
        
        if words.count == 1 {
            return [(words.first!, boundingBox)]
        }
        
        let wordWidth = boundingBox.width / CGFloat(words.count)
        var wordBoxes: [(String, CGRect)] = []
        
        for (index, word) in words.enumerated() {
            let wordBox = CGRect(
                x: boundingBox.origin.x + CGFloat(index) * wordWidth,
                y: boundingBox.origin.y,
                width: wordWidth,
                height: boundingBox.height
            )
            wordBoxes.append((word, wordBox))
        }
        
        return wordBoxes
    }
    
    /// 🏷 OCR 결과를 수직 위치로 그룹화하고 각 그룹 내에서 수평 정렬하는 함수
    private static func sortByVerticalThenHorizontal(_ texts: [(String, CGRect)]) -> [(String, CGRect)] {
        guard !texts.isEmpty else { return texts }
        
        // ✅ OCR Bounding Box의 평균 높이 계산 (동적 threshold 적용)
        let averageHeight = texts.map { $0.1.height }.reduce(0, +) / CGFloat(texts.count)
        let verticalThreshold: CGFloat = averageHeight * 1.5 // 코드 높이 기준으로 설정
        
        var groups: [[(String, CGRect)]] = [[]]
        var currentGroupY = texts[0].1.midY
        
        for text in texts.sorted(by: { $0.1.midY > $1.1.midY }) {
            if abs(text.1.midY - currentGroupY) > verticalThreshold {
                groups.append([])
                currentGroupY = text.1.midY
            }
            groups[groups.count - 1].append(text)
        }
        
        var sortedResults: [(String, CGRect)] = []
        for var group in groups {
            group.sort { $0.1.midX < $1.1.midX }
            sortedResults.append(contentsOf: group)
        }
        
        return sortedResults
    }
}

/// 📏 CGRect 확장: midX, midY 계산
extension CGRect {
    var midX: CGFloat { origin.x + width / 2 }
    var midY: CGFloat { origin.y + height / 2 }
}
