//
//  ContentView.swift
//  MacLandmarks
//
//  Created by Minhyeok Kim on 12/19/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LandmarkList()
            .frame(minWidth: 700, minHeight: 300)
    }
}


#Preview {
    ContentView()
        .environment(ModelData())
}
