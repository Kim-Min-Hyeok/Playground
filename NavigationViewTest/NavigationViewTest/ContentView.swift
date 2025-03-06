import SwiftUI

struct ContentView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Text("Item 1")
                Text("Item 2")
            }
            .navigationTitle("Custom Sidebar")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        // 사용자 정의 액션
                        print("Custom Sidebar Button Tapped")
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle") // 원하는 아이콘
                    }
                }
            }
        }
    }
}

