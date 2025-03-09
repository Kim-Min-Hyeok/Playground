// ScoreView.swift
import SwiftUI

struct ScoreView: View {
    let scorePages: [ScorePageData]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 20) {
                ForEach(scorePages) { pageData in
                    ZStack {
                        Image(uiImage: pageData.originalImage)
                            .resizable()
                            .scaledToFit()
                        
                        ForEach(pageData.chords) { chord in
                            GeometryReader { geo in
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
                    .clipped()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                }
                
                Divider()
                    .frame(height: 400)
                
                ForEach(scorePages) { pageData in
                    if let processed = pageData.processedImage {
                        Image(uiImage: processed)
                            .resizable()
                            .scaledToFit()
                            .clipped()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    }
                }
            }
            .padding()
        }
    }
}
