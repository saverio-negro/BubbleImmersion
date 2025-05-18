//
//  ContentView.swift
//  BubbleImmersion
//
//  Created by Saverio Negro on 18/05/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var showImmersiveSpace = false
    
    
    var body: some View {
        VStack {
            Text("Welcome to Bubble Immersion")
                .font(.largeTitle)
                .padding(50)
            Text("Move around your space and touch each bubble to cause it to fall.")
            Text("Be sure to start in a large open space.")
            
            Toggle("Enter Bubble Immersion", isOn: $showImmersiveSpace)
                .padding(50)
                .toggleStyle(.button)
        }
        .padding()
        .onChange(of: showImmersiveSpace) {
            Task {
                switch viewModel.immersiveSpaceState {
                case .closed:
                    viewModel.immersiveSpaceState = .transition
                    await openImmersiveSpace(id: "ImmersiveSpace")
                case .open:
                    viewModel.immersiveSpaceState = .transition
                    await dismissImmersiveSpace()
                case .transition:
                    break
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environmentObject(ViewModel())
}
