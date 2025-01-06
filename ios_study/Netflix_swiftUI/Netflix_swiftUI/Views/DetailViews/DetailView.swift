//
//  DetailView.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 1/6/25.
//

import SwiftUI

struct DetailView: View {
    @ObservedObject var viewModel: DetailViewModel
    
    var body: some View {
        VStack {
            Text("DetailView")
                .font(.headline)
                .padding()
            
        }
    }
}


//#Preview {
//    DetailView(movie: <#MoviePreview#>)
//}
