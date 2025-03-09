//
//  ScoreProcessor.swift
//  VisionTest4
//
//  Created by Minhyeok Kim on 3/6/25.
//

import UIKit

struct ScoreProcessor {
    static func processScore(_ image: UIImage, completion: @escaping ((UIImage, [ScoreChordModel]) -> Void)) {
        let preprocessedImage = OpenCVProcessor.processScore(image)
        VisionProcessor.recognizeScoreChords(in: preprocessedImage) { chords in
            completion(preprocessedImage, chords)
        }
    }
}
