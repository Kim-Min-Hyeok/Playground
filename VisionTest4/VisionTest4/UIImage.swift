// UIImage+PDF.swift
import UIKit

extension UIImage {
    /// UIImage를 PDF 파일로 변환하는 함수
    func convertToPDF() -> URL {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: self.size))
        let pdfData = pdfRenderer.pdfData { context in
            context.beginPage()
            self.draw(in: CGRect(origin: .zero, size: self.size))
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let pdfURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf")
        do {
            try pdfData.write(to: pdfURL)
        } catch {
            print("PDF 변환 실패: \(error)")
        }
        return pdfURL
    }
}
