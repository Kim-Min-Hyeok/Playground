//
//  MoviesModel.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 12/23/24.
//

import Foundation

struct MoviesModel: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String?
    let posterPath: String?
    let backdropPath: String?
    let genreIds: [Int]?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
    }
    
    var posterImageURL: URL? {
        guard let posterPath = posterPath else {
            print("No poster path available for movie: \(title)")
            return nil
        }
        let urlString = "https://image.tmdb.org/t/p/w500\(posterPath)"
        print("Constructed URL for \(title): \(urlString)")
        return URL(string: urlString)
    }
    
    var backdropImageURL: URL? {
        guard let backdropPath = backdropPath else {
            print("No poster path available for movie: \(title)")
            return nil
        }
        let urlString = "https://image.tmdb.org/t/p/w500\(backdropPath)"
        print("Constructed URL for \(title): \(urlString)")
        return URL(string: urlString)
    }
}

struct TMDBResponse: Codable {
    let results: [MoviesModel]
}
