//
//  HomeView.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 12/23/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel // ViewModel 접근
    @EnvironmentObject var router: Router // 라우팅 관리
    
    var body: some View {
        ZStack (alignment: .top){
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Image("movie_image")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 415)
                        .clipped()
                    
                    HStack {
                        Button(action: {}) {
                            VStack {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                Text("My List")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                        Spacer()
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "play.fill")
                                    .foregroundColor(.black)
                                Text("Play")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(5.63)
                        }
                        Spacer()
                        Button(action: {}) {
                            VStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.white)
                                Text("Info")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 62)
                    
                    if homeViewModel.isLoading {
                        ProgressView("Loading...")
                            .padding()
                    } else if let errorMessage = homeViewModel.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ForEach(homeViewModel.categories, id: \.self) { category in
                            if let movies = homeViewModel.moviesByCategory[category] {
                                HomeMovieListView(category: category, movies: movies)
                            }
                        }
                    }
                }
            }
            .background(Color.black)
            .ignoresSafeArea()
            .onAppear() {
                homeViewModel.fetchAllMovies()
            }
            
            HStack {
                Button(action: {}) {
                    Image("netflix_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 57)
                }
                Spacer()
                Button(action: {}) {
                    Text("TV Shows")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                Spacer()
                Button(action: {}) {
                    Text("Movies")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                Spacer()
                Button(action: {}) {
                    Text("My List")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 24))
            }
        }
    }
}


#Preview {
    HomeView()
}
