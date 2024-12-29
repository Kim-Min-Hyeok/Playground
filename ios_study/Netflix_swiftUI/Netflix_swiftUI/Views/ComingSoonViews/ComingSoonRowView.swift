//
//  ComingSoonRowView.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 12/29/24.
//

import SwiftUI

struct ComingSoonRowView: View {
    let movie: MoviesModel
    let genres: [Int: String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 이미지
            Button(action: {}) {
                AsyncImage(url: movie.backdropImageURL) { phase in
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
                .cornerRadius(2)
                .clipped()
            }
            
            // 날짜
            if let releaseDate = movie.releaseDate {
                Text(releaseDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // 제목
            Text(movie.title)
                .font(.headline)
                .foregroundColor(.white)

            // 설명
            Text(movie.overview)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)

            // 장르
            if let genreIds = movie.genreIds {
                HStack {
                    ForEach(genreIds.compactMap { genres[$0] }, id: \.self) { genreName in
                        Text(genreName)
                            .font(.caption)
                            .padding(5)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(5)
                            .foregroundColor(.white)
                    }
                }
            }

            Divider()
                .background(Color.gray)
        }
    }
}
