// PDFProcessor.swift
import UIKit
import PDFKit

struct PDFProcessor {
    static func extractPages(from pdfURL: URL) -> [UIImage] {
        guard let pdfDocument = PDFDocument(url: pdfURL) else { return [] }
        var images: [UIImage] = []
        for i in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: i) {
                let pageRect = page.bounds(for: .mediaBox)
                UIGraphicsBeginImageContext(pageRect.size)
                if let context = UIGraphicsGetCurrentContext() {
                    // 흰색 배경 채우기
                    context.setFillColor(UIColor.white.cgColor)
                    context.fill(pageRect)
                    context.saveGState()
                    // 좌표계를 뒤집어 올바른 방향으로 렌더링
                    context.translateBy(x: 0, y: pageRect.size.height)
                    context.scaleBy(x: 1.0, y: -1.0)
                    page.draw(with: .mediaBox, to: context)
                    context.restoreGState()
                }
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                if let image = image {
                    images.append(image)
                }
            }
        }
        return images
    }
}
