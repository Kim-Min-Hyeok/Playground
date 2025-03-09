// ImageUtil.swift
import UIKit

struct ImageUtil {
    static func scaledDimensions(for image: UIImage, containerSize: CGSize) -> (displayWidth: CGFloat, displayHeight: CGFloat, scale: CGFloat) {
        let originalSize = image.size
        // AspectFit 방식: 가로와 세로 중 작은 비율을 사용
        let scale = min(containerSize.width / originalSize.width, containerSize.height / originalSize.height)
        let displayWidth = originalSize.width * scale
        let displayHeight = originalSize.height * scale
        return (displayWidth, displayHeight, scale)
    }
}
