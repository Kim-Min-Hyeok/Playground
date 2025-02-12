import UIKit
import Vision

class TextExtractionManager {
    
    static func extractText(from image: UIImage, completion: @escaping (UIImage?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("텍스트 인식 에러: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            let resultImage = drawTextObservations(observations, on: image)
            completion(resultImage)
        }
        request.recognitionLanguages = ["en", "ko"]
        request.recognitionLevel = .accurate
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("텍스트 인식 요청 수행 실패: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    /// Vision의 정규화 좌표를 UIKit 좌표계로 변환한 후, 바운딩 박스와 인식된 텍스트를 그려 새 이미지를 반환합니다.
    private static func drawTextObservations(_ observations: [VNRecognizedTextObservation], on image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        // 컨텍스트 생성 후, 원본 이미지 그리기
        image.draw(in: CGRect(origin: .zero, size: image.size))
        guard let context = UIGraphicsGetCurrentContext() else { return image }
        
        // 바운딩 박스 색상과 두께를 명시적으로 설정
//        context.setStrokeColor(UIColor.red.cgColor)
//        context.setLineWidth(2.0)
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        // 모든 observation에 대해
        for observation in observations {
            guard let candidate = observation.topCandidates(1).first else { continue }
            let recognizedText = candidate.string
            
            // 좌표 변환 (Vision의 정규화 좌표 → UIKit 좌표)
            let boundingBox = observation.boundingBox
            let x = boundingBox.origin.x * imageWidth
            let y = (1 - boundingBox.origin.y - boundingBox.size.height) * imageHeight
            let w = boundingBox.size.width * imageWidth
            let h = boundingBox.size.height * imageHeight
            let rect = CGRect(x: x, y: y, width: w, height: h)
            
            // 빨간색 바운딩 박스 그리기
//            context.stroke(rect)
            
            // 텍스트 속성은 항상 파란색으로 설정
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.blue
            ]
            let textOrigin = CGPoint(x: rect.origin.x, y: max(rect.origin.y - 20, 0))
            let textRect = CGRect(origin: textOrigin, size: CGSize(width: rect.width, height: 20))
            recognizedText.draw(in: textRect, withAttributes: textAttributes)
        }
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        return resultImage ?? image
    }

}
