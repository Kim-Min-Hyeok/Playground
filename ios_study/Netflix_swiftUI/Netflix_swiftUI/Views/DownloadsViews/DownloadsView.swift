//
//  DownloadViews.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 12/23/24.
//

import SwiftUI

struct DownloadsView: View {
    var body: some View {
        VStack(alignment: .center){
            Spacer()
            Image("download")
                .resizable()
                .scaledToFit()
                .frame(height: 194)
            Text("Movies and TV shows that you\ndownload appear here.")
                .font(.system(size: 19, weight: .bold, design: .default))
                .foregroundColor(.white)
                    .opacity(0.66)
                .padding(.top, 32)
            Button(action: {}) {
                Text("Find Something to Download")
                    .font(.system(size: 15, weight: .bold, design: .default))
                    .foregroundColor(.black)
            }
            .frame(width: 280, height: 42)
            .background(Color.white)
            .cornerRadius(6)
            .padding(.top, 184)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
    }
}

#Preview {
    DownloadsView()
}
