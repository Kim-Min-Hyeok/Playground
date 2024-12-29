//
//  SearchBarView.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 12/29/24.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ColorUtil.colorFromHex("#C4C4C4"))
            
            TextField("", text: $text, prompt: Text("Search for a show, movie, genre, e.t.c.")
                .foregroundColor(ColorUtil.colorFromHex("#C4C4C4")))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ColorUtil.colorFromHex("#C4C4C4"))
                }
            }
            
            Image(systemName: "mic.fill")
                .foregroundColor(ColorUtil.colorFromHex("#C4C4C4"))
        }
        .padding(13)
        .background(ColorUtil.colorFromHex("#424242"))
        .cornerRadius(5)
    }
}
