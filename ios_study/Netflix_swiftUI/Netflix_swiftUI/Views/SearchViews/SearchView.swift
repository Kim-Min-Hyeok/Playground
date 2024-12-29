//
//  SearchView.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 12/23/24.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            SearchBarView(text: $searchText)
                .onChange(of: searchText) { oldValue, newValue in
                    viewModel.search(query: newValue)
                }
            
            Text("Top Searchs")
                .font(.system(size: 26.75, weight: .bold, design: .default))
                .kerning(-0.07339449226856232)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .lineSpacing(20 - 20)
            
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.searchResults) { movie in
                            SearchResultRowView(movie: movie)
                        }
                    }
                }
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    SearchView()
}
