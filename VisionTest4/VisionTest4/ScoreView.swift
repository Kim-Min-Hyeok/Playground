// ScoreView.swift
import SwiftUI

struct ScoreView: View {
    let scorePages: [ScorePageData]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                ForEach(scorePages) { pageData in
                    VStack(spacing: 10) {
                        // 원본 이미지와 코드 오버레이
                        ZStack {
                            Image(uiImage: pageData.originalImage)
                                .resizable()
                                .scaledToFit()
                            
                            ForEach(pageData.chords) { chord in
                                GeometryReader { geo in
                                    // 원본 이미지 기준 좌표를 스케일링 (GeometryReader의 크기를 이용)
                                    let scaleX = geo.size.width / pageData.originalImage.size.width
                                    let scaleY = geo.size.height / pageData.originalImage.size.height
                                    let x = CGFloat(chord.x) * scaleX
                                    let y = CGFloat(chord.y) * scaleY
                                    let width = CGFloat(chord.width) * scaleX
                                    let height = CGFloat(chord.height) * scaleY
                                    
                                    Text(chord.chord)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(2)
                                        .background(Color.white.opacity(0.7))
                                        .cornerRadius(4)
                                        .position(x: x + width / 2, y: y + height / 2)
                                }
                            }
                        }
                        .frame(width: 300, height: 400) // 원하는 크기로 조정
                        .clipped()
                        
                        // 전처리된 이미지 미리보기 (있을 경우)
                        if let processed = pageData.processedImage {
                            Text("전처리 결과")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Image(uiImage: processed)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 150)
                                .clipped()
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                }
            }
            .padding()
        }
    }
}
