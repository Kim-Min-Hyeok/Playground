//
//  Route.swift
//  Netflix_swiftUI
//
//  Created by Minhyeok Kim on 1/6/25.
//

import Combine
import SwiftUI

enum Route: Hashable {
    case inital
    case detail(movie: MoviePreview, viewModel: DetailViewModel)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .inital:
            hasher.combine("initial")
        case .detail(let movie, _):
            hasher.combine("detail")
            hasher.combine(movie.id)
        }
    }
    
    static func == (lhs: Route, rhs: Route) -> Bool {
        switch (lhs, rhs) {
        case (.inital, .inital):
            return true
        case (.detail(let lhsMovie, _), .detail(let rhsMovie, _)):
            return lhsMovie.id == rhsMovie.id
        default:
            return false
        }
    }
}

class Router: ObservableObject {
    @Published var path: [Route] = []
    
    func navigate(to route: Route) {
        print("Navigating to route: \(route)")
        path.append(route)
        
    }
    
    func reset(to route: Route) {
        path = [route]
        
    }
    
    func pop() {
        path.removeLast()
    }
}
