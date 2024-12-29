//
//  CustomTabItem.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 12/23/24.
//

import SwiftUI

struct CustomTabItem: View {
    let label: String
    let systemImage: String
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(isSelected ? .white : .gray)
            Text(label)
                .font(.system(size: 8.2, weight: .medium))                 .foregroundColor(isSelected ? .white : .gray)
                .lineSpacing(30.4)
                .kerning(0.26)
                .multilineTextAlignment(.center)
        }
    }
}


#Preview {
    CustomTabItem(
        label: "Home",
        systemImage: "house.fill",
        isSelected: false
    )
}
