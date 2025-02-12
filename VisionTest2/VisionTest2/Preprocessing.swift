//
//  Preprocessing.swift
//  VisionTest2
//
//  Created by Minhyeok Kim on 2/6/25.
//

import UIKit
import CoreImage

/// 주어진 이미지를 임계값(threshold)을 기준으로 이진화(검/흰) 처리하는 함수.
/// - Parameters:
///   - image: 원본 UIImage.
///   - threshold: 임계값 (0.0 ~ 1.0). 기본값은 0.5.
/// - Returns: 이진화 처리된 UIImage.
func binarizeImage(_ image: UIImage, threshold: Float = 0.5) -> UIImage? {
    // CIImage로 변환
    guard let ciImage = CIImage(image: image) else { return nil }
    
    // 커스텀 CIColorKernel을 정의합니다.
    // 각 픽셀의 밝기(luma)를 계산한 후 임계값보다 크면 흰색, 그렇지 않으면 검정색으로 처리합니다.
    let kernelString = """
    kernel vec4 thresholdFilter(__sample image, float threshold) {
        // 픽셀의 밝기를 계산 (표준 NTSC 계수 사용)
        float luma = dot(image.rgb, vec3(0.299, 0.587, 0.114));
        float binary = luma > threshold ? 1.0 : 0.0;
        return vec4(vec3(binary), 1.0);
    }
    """
    
    guard let kernel = CIColorKernel(source: kernelString) else {
        print("Error: Unable to create CIColorKernel")
        return nil
    }
    
    // 커널 적용: 이미지 전체 영역(extent)에서 지정된 임계값을 사용합니다.
    let arguments: [Any] = [ciImage, threshold]
    guard let outputCIImage = kernel.apply(extent: ciImage.extent, arguments: arguments) else {
        return nil
    }
    
    // CIContext를 사용해 결과 CIImage를 CGImage로 변환한 뒤 UIImage로 반환합니다.
    let context = CIContext(options: nil)
    if let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
        return UIImage(cgImage: outputCGImage)
    }
    
    return nil
}
