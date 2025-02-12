import UIKit
import Vision
import SwiftUI

/// 감지된 영역 정보를 담는 구조체.
struct RecognizedArea: Identifiable {
    let id = UUID()
    let boundingBox: CGRect
}

/// VNRecognizeTextRequest를 사용하여 이미지 내 텍스트 영역(여러 텍스트 블록)을 감지하는 구조체.
/// (boundingBox 값을 설정하기 위해 EstimatedTextObservation을 사용)
class EstimatedTextObservation: VNRecognizedTextObservation {
    init(boundingBox: CGRect) {
        super.init()
        // Private API 접근 없이 boundingBox 설정을 위한 우회 방법
        setValue(boundingBox, forKey: "boundingBox")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// 텍스트 영역 감지를 위한 구조체
struct TextAreaDetector {
    static let verticalToleranceThreshold: CGFloat = 0.02
    static let horizontalGapThreshold: CGFloat = 0.1
    
    /// 이미지 내 텍스트 영역(감지된 영역 및 누락된 영역 추정)을 조사하여 RecognizedArea 배열로 전달.
    static func detectTextAreas(in image: UIImage, completion: @escaping ([RecognizedArea]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion([])
                return
            }
            
            var allAreas: [VNRecognizedTextObservation] = []
            
            // 1. 수직 위치(행)별로 그룹화
            let groups = groupByVerticalPosition(observations)
            
            // 2. 각 그룹에서 감지된 영역과 누락된 영역(좌측/우측 여백 포함)을 조사
            for group in groups {
                // 좌측부터 우측으로 정렬
                let sortedGroup = group.sorted { $0.boundingBox.minX < $1.boundingBox.minX }
                allAreas.append(contentsOf: sortedGroup)
                
                // 그룹 내 누락 영역 추정 (텍스트 블록 사이, 좌측, 우측 여백)
                if !sortedGroup.isEmpty {
                    let estimatedAreas = findMissingAreas(in: sortedGroup)
                    allAreas.append(contentsOf: estimatedAreas)
                }
            }
            
            // 3. RecognizedArea로 변환 (각 영역의 boundingBox 사용)
            let recognizedAreas = allAreas.map { observation in
                RecognizedArea(boundingBox: observation.boundingBox)
            }
            
            completion(recognizedAreas)
        }
        
        request.recognitionLevel = .accurate
        request.minimumTextHeight = 0.01
        
        try? requestHandler.perform([request])
    }
    
    /// Y좌표(수직 위치)를 기준으로 텍스트 블록들을 그룹(행)으로 묶는 함수.
    private static func groupByVerticalPosition(_ observations: [VNRecognizedTextObservation]) -> [[VNRecognizedTextObservation]] {
        var groups: [[VNRecognizedTextObservation]] = []
        var currentGroup: [VNRecognizedTextObservation] = []
        
        let sortedObs = observations.sorted { $0.boundingBox.midY > $1.boundingBox.midY }
        
        for obs in sortedObs {
            if let lastObs = currentGroup.last {
                if abs(obs.boundingBox.midY - lastObs.boundingBox.midY) <= verticalToleranceThreshold {
                    currentGroup.append(obs)
                } else {
                    groups.append(currentGroup)
                    currentGroup = [obs]
                }
            } else {
                currentGroup = [obs]
            }
        }
        
        if !currentGroup.isEmpty {
            groups.append(currentGroup)
        }
        
        return groups
    }
    
    /// 각 행 내에서 누락된 영역을 추정하는 함수.
    /// 좌측 여백, 텍스트 블록 사이의 간격, 우측 여백을 모두 고려합니다.
    private static func findMissingAreas(in group: [VNRecognizedTextObservation]) -> [VNRecognizedTextObservation] {
        var estimatedAreas: [VNRecognizedTextObservation] = []
        // 그룹 내 텍스트 블록들의 평균 너비 계산 (normalized 좌표 기준)
        let avgWidth = group.map { $0.boundingBox.width }.reduce(0, +) / CGFloat(group.count)
        
        // 1. 좌측 여백 확인: 이미지 왼쪽(0)부터 첫 텍스트 블록까지의 간격
        let leftGap = group.first!.boundingBox.minX - 0
        if leftGap > horizontalGapThreshold {
            let missingCount = Int(leftGap / avgWidth)
            for i in 0..<missingCount {
                // 좌측 여백 내에서 누락된 영역의 중앙 위치 추정
                let estimatedX = (avgWidth * CGFloat(i)) + (avgWidth / 2)
                let estimatedRect = CGRect(
                    x: estimatedX - avgWidth / 2,
                    y: group.first!.boundingBox.minY,
                    width: avgWidth,
                    height: group.first!.boundingBox.height
                )
                estimatedAreas.append(EstimatedTextObservation(boundingBox: estimatedRect))
            }
        }
        
        // 2. 텍스트 블록 사이의 간격 확인 (기존 로직)
        for i in 0..<(group.count - 1) {
            let gap = group[i + 1].boundingBox.minX - group[i].boundingBox.maxX
            if gap > horizontalGapThreshold {
                let possibleMissingCount = Int(gap / avgWidth) - 1
                if possibleMissingCount > 0 {
                    for j in 0..<possibleMissingCount {
                        let estimatedX = group[i].boundingBox.maxX + (gap / CGFloat(possibleMissingCount + 1)) * CGFloat(j + 1)
                        let estimatedRect = CGRect(
                            x: estimatedX,
                            y: group[i].boundingBox.minY,
                            width: avgWidth,
                            height: group[i].boundingBox.height
                        )
                        estimatedAreas.append(EstimatedTextObservation(boundingBox: estimatedRect))
                    }
                }
            }
        }
        
        // 3. 우측 여백 확인: 마지막 텍스트 블록의 끝부터 이미지 오른쪽(1)까지의 간격
        let rightGap = 1 - group.last!.boundingBox.maxX
        if rightGap > horizontalGapThreshold {
            let missingCount = Int(rightGap / avgWidth)
            for i in 0..<missingCount {
                let estimatedX = group.last!.boundingBox.maxX + (avgWidth * CGFloat(i)) + (avgWidth / 2)
                let estimatedRect = CGRect(
                    x: estimatedX - avgWidth / 2,
                    y: group.last!.boundingBox.minY,
                    width: avgWidth,
                    height: group.last!.boundingBox.height
                )
                estimatedAreas.append(EstimatedTextObservation(boundingBox: estimatedRect))
            }
        }
        
        return estimatedAreas
    }
}
