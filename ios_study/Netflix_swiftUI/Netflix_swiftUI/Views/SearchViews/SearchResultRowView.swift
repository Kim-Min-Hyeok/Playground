//
//  SearchResultRowView.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 12/29/24.
//

import SwiftUI

struct SearchResultRowView: View {
    let movie: MoviesModel
    
    var body: some View {
        HStack {
            if let imageURL = movie.posterImageURL
            {
                AsyncImage(url: imageURL) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray)
                }
                .frame(width: 146, height: 76)
                .clipped()
            }
            
            Text(movie.title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading, 7)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "play.circle")
                    .foregroundColor(.white)
                    .font(.system(size: 28))
                    .padding(.trailing, 3)
            }
        }
        .background(ColorUtil.colorFromHex("#424242"))
        .padding(.bottom, 3)
    }
}

//#Preview {
//    SearchResultRowView()
//}
