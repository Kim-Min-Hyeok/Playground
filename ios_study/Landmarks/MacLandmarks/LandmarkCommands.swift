//
//  File.swift
//  Landmarks
//
//  Created by Minhyeok Kim on 12/19/24.
//

import SwiftUI

struct LandmarkCommands: Commands {
    var body: some Commands {
        SidebarCommands()
    }
}

private struct SelectedLandmarkKey: FocusedValueKey {
    typealias Value = Binding<Landmark>
}

extension FocusedValues {
    var selectedLandmark: Binding<Landmark>? {
        get { self[SelectedLandmarkKey.self] }
        set { self[SelectedLandmarkKey.self] = newValue }
    }
}
