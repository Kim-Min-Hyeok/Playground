//
//  ContentView.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 12/17/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: Tab = .Home
    @StateObject private var router: Router
    @StateObject private var homeViewModel: HomeViewModel
    
    
    init() {
        let routerInstance = Router()
        _router = StateObject(wrappedValue: routerInstance)
        
        // router를 사용하여 homeViewModel 초기화
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(router: routerInstance))
        
        
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
        NavigationStack(path: $router.path) {
            TabView(selection: $selection) {
                HomeView()
                    .environmentObject(router)
                    .environmentObject(homeViewModel)
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
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .inital:
                    ContentView()
                case .detail(_, let viewModel):
                    DetailView(viewModel: viewModel)
                        .environmentObject(router)
                }
            }
        }
    }
    
}
#Preview {
    ContentView()
}
