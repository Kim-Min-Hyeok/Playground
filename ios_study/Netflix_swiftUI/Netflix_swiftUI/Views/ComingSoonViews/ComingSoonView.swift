//
//  CommingSoonView.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 12/23/24.
//

import SwiftUI

struct ComingSoonView: View {
    @StateObject private var viewModel = ComingSoonViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Image("notification")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 19)
                Text("Notifications")
                    .font(.system(size: 16.91, weight: .bold, design: .default))
                    .padding(.leading, 7)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(15)
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(2.0)
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ForEach(viewModel.movies) { movie in
                            ComingSoonRowView(movie: movie, genres: viewModel.genres)
                        }
                    }
                }
            }
        }.background(Color.black)
    }
}
