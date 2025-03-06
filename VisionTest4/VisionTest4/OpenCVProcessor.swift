//
//  OpenCVProcessor.swift
//  VisionTest4
//
//  Created by Minhyeok Kim on 3/6/25.
//

import UIKit

struct OpenCVProcessor {
    static func processScore(_ image: UIImage) -> UIImage {
        return CVWrapper.processScore(image)
    }
}
