//
//  ContentView.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 12/17/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: Tab = .Home
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor.black
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray
        ] 
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    enum Tab {
        case Home
        case Search
        case ComingSoon
        case Downloads
        case More
    }
    
    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    CustomTabItem(
                        label: "Home",
                        systemImage: "house.fill",
                        isSelected: selection == .Home
                    )
                }
                .tag(Tab.Home)
            
            SearchView()
                .tabItem {
                    CustomTabItem(
                        label: "Search",
                        systemImage: "magnifyingglass",
                        isSelected: selection == .Search
                    )
                }
                .tag(Tab.Search)
            
            ComingSoonView()
                .tabItem {
                    CustomTabItem(
                        label: "Coming Soon",
                        systemImage: "play.rectangle",
                        isSelected: selection == .ComingSoon
                    )
                }
                .tag(Tab.ComingSoon)
            
            DownloadsView()
                .tabItem {
                    CustomTabItem(
                        label: "Downloads",
                        systemImage: "arrow.down.to.line.alt",
                        isSelected: selection == .Downloads
                    )
                }
                .tag(Tab.Downloads)
            
            MoreView()
                .tabItem {
                    CustomTabItem(
                        label: "More",
                        systemImage: "line.horizontal.3",
                        isSelected: selection == .More
                    )
                }
                .tag(Tab.More)
        }
    }
}

#Preview {
    ContentView()
}
