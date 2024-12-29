//
//  MoviesAPI.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 12/26/24.
//

import Combine
import Foundation

class MoviesAPIClient {
    private let apiKey = "a4776f352c238462bcca0dbbdd94e67e"
    private let baseURL = "https://api.themoviedb.org/3"
    static let shared = MoviesAPIClient()
    
    private init() {}
    
    func fetchMovies(for category: String) -> AnyPublisher<[MoviesModel], Error> {
        let endpoint: String
        switch category {
        case "Popular Movies":
            endpoint = "/movie/popular"
        case "Now Playing Movies":
            endpoint = "/movie/now_playing"
        case "Upcoming Movies":
            endpoint = "/movie/upcoming"
        case "Top Rated Movies":
            endpoint = "/movie/top_rated"
        case "Trending Movies":
            endpoint = "/trending/movie/week"
        default:
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "\(baseURL)\(endpoint)?api_key=\(apiKey)&language=en-US&region=US") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
                    .handleEvents(
                        receiveSubscription: { _ in print("Starting request for: \(url)") },
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                print("Request failed with error: \(error.localizedDescription)")
                            }
                        }
                    )
                    .map(\.data)
                    .decode(type: TMDBResponse.self, decoder: JSONDecoder())
                    .map { $0.results }
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
    }
    
    func fetchGenres() -> AnyPublisher<[Int: String], Error> {
        guard let url = URL(string: "\(baseURL)/genre/movie/list?api_key=\(apiKey)&language=en-US") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GenreResponse.self, decoder: JSONDecoder())
            .map { response in
                var genreDict = [Int: String]()
                response.genres.forEach { genre in
                    genreDict[genre.id] = genre.name
                }
                return genreDict
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

struct GenreResponse: Codable {
    let genres: [Genre]
}

struct Genre: Codable {
    let id: Int
    let name: String
}
