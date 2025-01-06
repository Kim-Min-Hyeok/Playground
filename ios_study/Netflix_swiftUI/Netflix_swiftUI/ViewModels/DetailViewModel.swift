//
//  DetailViewModel.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 1/6/25.
//

import Foundation

class DetailViewModel: ObservableObject {
    @Published var movie: MoviePreview
    @Published var additionalInfo: String = "Fetching..."
    @Published var isFavorite: Bool = false

    init(movie: MoviePreview) {
        self.movie = movie
        fetchAdditionalInfo()
    }

    func fetchAdditionalInfo() {
        // Simulated API call (replace with real implementation)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.additionalInfo = "This is a thrilling movie in the \(self.movie.category) category!"
        }
    }

    func toggleFavorite() {
        isFavorite.toggle()
    }
}
