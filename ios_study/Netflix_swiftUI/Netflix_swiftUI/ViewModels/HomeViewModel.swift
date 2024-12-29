//
//  HomeViewModel.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 12/23/24.
//

import Foundation
import Combine

struct MoviePreview: Identifiable {
    let id: Int
    let category: String
    let posterImageURL: URL
}

class HomeViewModel: ObservableObject {
    @Published var moviesByCategory: [String: [MoviePreview]] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()
    private let apiClient = MoviesAPIClient.shared

    let categories = [
        "Popular Movies",
        "Now Playing Movies",
        "Upcoming Movies",
        "Top Rated Movies",
        "Trending Movies"
    ]

    func fetchAllMovies() {
        isLoading = true
        errorMessage = nil

        let publishers = categories.map { category in
            apiClient.fetchMovies(for: category)
                .map { movies in
                        print("Processing category: \(category)")
                        return (category, movies.compactMap { movie in
                            if let posterURL = movie.posterImageURL {
                                print("Movie: \(movie.title), Poster URL: \(posterURL)")
                                return MoviePreview(id: movie.id,
                                                  category: category,
                                                  posterImageURL: posterURL)
                            }
                            print("No poster URL for movie: \(movie.title)")
                            return nil
                        })
                    }
        }

        Publishers.MergeMany(publishers)
            .collect()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Final error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                }
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }, receiveValue: { results in
                var moviesDict: [String: [MoviePreview]] = [:]
                results.forEach { category, previews in
                    moviesDict[category] = previews
                }
                DispatchQueue.main.async {
                    self.moviesByCategory = moviesDict
                    print("Updated moviesByCategory: \(self.moviesByCategory.keys)")
                }
            })
            .store(in: &cancellables)
    }
}
