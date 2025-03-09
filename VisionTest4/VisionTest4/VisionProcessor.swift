// VisionProcessor.swift
import Vision
import UIKit

class VisionProcessor {
    static func recognizeScoreChords(in image: UIImage, completion: @escaping ([ScoreChordModel]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }
        
        let imageSize = image.size
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("OCR 오류: \(error)")
                completion([])
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion([])
                return
            }
            
            var detectedChords: [(String, CGRect)] = []
            for observation in observations {
                guard let candidate = observation.topCandidates(1).first else { continue }
                let text = candidate.string
                
                let normalizedRect = observation.boundingBox
                let rect = CGRect(
                    x: normalizedRect.origin.x * imageSize.width,
                    y: (1 - normalizedRect.origin.y - normalizedRect.height) * imageSize.height,
                    width: normalizedRect.width * imageSize.width,
                    height: normalizedRect.height * imageSize.height
                )
                
                let wordsWithBoxes = Self.splitTextWithBoundingBoxes(text, boundingBox: rect)
                let validWords = wordsWithBoxes.filter { Self.isValidChord($0.0) }
                detectedChords.append(contentsOf: validWords)
            }
            
            let sortedResults = Self.sortByVerticalThenHorizontal(detectedChords)
            
            let chords: [ScoreChordModel] = sortedResults.map { (text, box) in
                return ScoreChordModel(
                    s_cid: UUID(),
                    chord: text,
                    x: Double(box.origin.x),
                    y: Double(box.origin.y),
                    width: Double(box.width),
                    height: Double(box.height)
                )
            }
            
            DispatchQueue.main.async {
                completion(chords)
            }
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("OCR 요청 실패: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    /// 유효한 코드인지 확인 (정규식 적용)
    private static func isValidChord(_ text: String) -> Bool {
        let pattern = #"^[A-G][#b]?(m|maj|min|dim|aug|sus|add)?[0-9]*/?[A-G]?[#b]?$"#
        return text.range(of: pattern, options: .regularExpression) != nil
    }
    
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
    
    private static func sortByVerticalThenHorizontal(_ texts: [(String, CGRect)]) -> [(String, CGRect)] {
        guard !texts.isEmpty else { return texts }
        
        let averageHeight = texts.map { $0.1.height }.reduce(0, +) / CGFloat(texts.count)
        let verticalThreshold: CGFloat = averageHeight * 1.5
        
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

extension CGRect {
    var midX: CGFloat { origin.x + width / 2 }
    var midY: CGFloat { origin.y + height / 2 }
}
