//
//  HomeMovieListView.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 12/23/24.
//

import SwiftUI

struct HomeMovieListView: View {
    let category: String
    let movies: [MoviePreview]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(category)
                .font(.system(size: 20.92, weight: .bold))
                .lineSpacing(15.64 - 20.92)
                .kerning(-0.05740566551685333)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
               
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 7) {
                    ForEach(movies) { movie in
                        Button(action: {}) {
                            AsyncImage(url: movie.posterImageURL) { phase in
                                switch phase {
                                case .empty:
                                    Color.gray
                                        .overlay(
                                            ProgressView()
                                                .tint(.white)
                                        )
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure(let error):
                                    Color.red
                                        .overlay(
                                            Text("Error: \(error.localizedDescription)")
                                                .foregroundColor(.white)
                                                .font(.caption)
                                        )
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 103, height: 161)
                            .cornerRadius(2)
                            .clipped()
                        }
                    }
                }
                .padding(.leading, 10)
            }
        }
        .background(.black)
    }
}

#Preview {
    HomeMovieListView(
        category: "Popular on Netflix",
        movies: [
            MoviePreview(id: 1, category: "Popular on Netflix", posterImageURL: URL(string: "https://via.placeholder.com/103x161")!),
            MoviePreview(id: 2, category: "Popular on Netflix", posterImageURL: URL(string: "https://via.placeholder.com/103x161")!)
        ]
    )
}
