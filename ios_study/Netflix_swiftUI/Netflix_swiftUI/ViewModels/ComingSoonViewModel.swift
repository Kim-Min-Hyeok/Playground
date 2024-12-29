//
//  ComingSoonViewModel.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 12/29/24.
//

import Combine
import Foundation

class ComingSoonViewModel: ObservableObject {
    @Published var movies: [MoviesModel] = []
    @Published var genres: [Int: String] = [:] // Genre ID -> Name 매핑
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let apiClient = MoviesAPIClient.shared

    init() {
        fetchMoviesAndGenres()
    }

    func fetchMoviesAndGenres() {
        isLoading = true

        let moviesPublisher = apiClient.fetchMovies(for: "Upcoming Movies")
        let genresPublisher = apiClient.fetchGenres()

        Publishers.Zip(moviesPublisher, genresPublisher)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
                self?.isLoading = false
            }, receiveValue: { [weak self] movies, genres in
                self?.movies = movies
                self?.genres = genres
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }

    func genreNames(for genreIds: [Int]?) -> [String] {
        guard let genreIds = genreIds else { return [] }
        return genreIds.compactMap { genres[$0] }
    }
}
