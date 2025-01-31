//
//  OCROverlayView.swift
//  VisionTest
//
//  Created by Minhyeok Kim on 1/29/25.
//

import SwiftUI

struct OCROverlayView: View {
    let detectedTexts: [(String, CGRect)]
    let imageSize: CGSize
    let geometrySize: CGSize
    
    var body: some View {
        ForEach(detectedTexts.indices, id: \.self) { index in
            let text = detectedTexts[index].0
            let boundingBox = detectedTexts[index].1
            let convertedRect = convertBoundingBox(boundingBox, imageSize: imageSize, geometrySize: geometrySize)
            
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .stroke(Color.red, lineWidth: 2)
                    .frame(width: convertedRect.width, height: convertedRect.height)
                    .position(x: convertedRect.midX, y: convertedRect.midY)
                
                Text("\(index + 1)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.7))
                    .position(x: convertedRect.minX, y: convertedRect.minY)
            }
        }
    }
    
    // OCR 좌표를 이미지 크기에 맞게 변환하는 함수
    private func convertBoundingBox(_ boundingBox: CGRect, imageSize: CGSize, geometrySize: CGSize) -> CGRect {
        let imageAspectRatio = imageSize.width / imageSize.height
        let viewAspectRatio = geometrySize.width / geometrySize.height
        
        let scaleX: CGFloat
        let scaleY: CGFloat
        let offsetX: CGFloat = 0
        let offsetY: CGFloat = 0
        
        // 이미지가 View보다 가로로 길 경우
        if imageAspectRatio > viewAspectRatio {
            scaleX = geometrySize.width
            scaleY = scaleX / imageAspectRatio
        } else { // 이미지가 View보다 세로로 긴 경우
            scaleY = geometrySize.height
            scaleX = scaleY * imageAspectRatio
        }
        
        let minX = boundingBox.minX * scaleX + offsetX
        let maxX = boundingBox.maxX * scaleX + offsetX
        let minY = (1 - boundingBox.maxY) * scaleY + offsetY
        let maxY = (1 - boundingBox.minY) * scaleY + offsetY
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}
