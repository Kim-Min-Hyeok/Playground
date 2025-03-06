//
//  ScoreProcessor.swift
//  VisionTest4
//
//  Created by Minhyeok Kim on 3/6/25.
//

import UIKit

struct ScoreProcessor {
    /// OpenCV 전처리와 Vision OCR을 순차적으로 호출하여, 전처리된 이미지와 인식된 ScoreChordModel 배열을 반환합니다.
    /// - Parameters:
    ///   - image: 원본 UIImage (악보 이미지)
    ///   - completion: (전처리된 이미지, 인식된 ScoreChordModel 배열) 반환 (메인 스레드 호출)
    static func processScore(_ image: UIImage, completion: @escaping ((UIImage, [ScoreChordModel]) -> Void)) {
        // 1. OpenCV 전처리 수행 (예: 그레이스케일, 이진화, 오선 제거 등)
        let preprocessedImage = OpenCVProcessor.processScore(image)
        // 2. 전처리된 이미지에 대해 Vision OCR 수행
        VisionProcessor.recognizeScoreChords(in: preprocessedImage) { chords in
            completion(preprocessedImage, chords)
        }
    }
}
