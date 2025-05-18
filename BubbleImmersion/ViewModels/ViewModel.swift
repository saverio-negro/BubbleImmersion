//
//  ViewModel.swift
//  BubbleImmersion
//
//  Created by Saverio Negro on 18/05/25.
//

import SwiftUI

enum ImmersiveSpaceState {
    case closed
    case open
    case transition
}

class ViewModel: ObservableObject {
    @Published var immersiveSpaceState = ImmersiveSpaceState.transition
}
