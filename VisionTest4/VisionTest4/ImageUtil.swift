// ImageUtil.swift
import UIKit

struct ImageUtil {
    /// 지정된 containerSize에 맞춰 원본 UIImage의 displayWidth, displayHeight, scale factor를 계산합니다.
    /// - Parameters:
    ///   - image: 원본 UIImage
    ///   - containerSize: 사용될 영역의 사이즈
    /// - Returns: displayWidth, displayHeight, scale factor (원본 대비 비율)
    static func scaledDimensions(for image: UIImage, containerSize: CGSize) -> (displayWidth: CGFloat, displayHeight: CGFloat, scale: CGFloat) {
        let originalSize = image.size
        // AspectFit 방식: 가로와 세로 중 작은 비율을 사용
        let scale = min(containerSize.width / originalSize.width, containerSize.height / originalSize.height)
        let displayWidth = originalSize.width * scale
        let displayHeight = originalSize.height * scale
        return (displayWidth, displayHeight, scale)
    }
}
