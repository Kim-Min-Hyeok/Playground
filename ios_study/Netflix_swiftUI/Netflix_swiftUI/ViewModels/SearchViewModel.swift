//
//  SearchViewModel.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 12/29/24.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchResults: [MoviesModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private var apiClient = MoviesAPIClient.shared
    private var allMovies: [MoviesModel] = []
    
    init() {
        isLoading = true
        loadAllMovies()
    }
    
    private func loadAllMovies() {
        let categories = [
            "Popular Movies",
            "Now Playing Movies",
            "Upcoming Movies",
            "Top Rated Movies",
            "Trending Movies"
        ]
        
        let publishers = categories.map { category in
            apiClient.fetchMovies(for: category)
        }
        
        Publishers.MergeMany(publishers)
            .collect()
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] moviesArrays in
                self?.allMovies = Array(Set(moviesArrays.flatMap { $0 }))
                self?.searchResults = self?.allMovies ?? []
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func search(query: String) {
        if query.isEmpty {
            searchResults = allMovies
            return
        }
        
        isLoading = true
        
        let lowercasedQuery = query.lowercased()
        searchResults = allMovies.filter {
            $0.title.lowercased().contains(lowercasedQuery)
        }
        
        isLoading = false
    }
}
