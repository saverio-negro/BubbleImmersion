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
        VStack(alignment: .leading) {
            VStack(alignment: .center) {
                Text("Welcome to Bubble Immersion")
                    .font(.extraLargeTitle)
                    .padding(50)
            }
            .frame(maxWidth: .infinity)
            
            Text("Move around your space and touch each bubble to cause it to fall.")
                .font(.largeTitle)
            Text("Touch as many bubbles as you can to let them fall to the ground, in the least time possible.")
                .font(.largeTitle)
            Text("Be sure to start in a large open space.")
                .font(.largeTitle)
            
            VStack(alignment: .center) {
                Toggle(isOn: $showImmersiveSpace) {
                    Text("\(showImmersiveSpace ? "Exit" : "Enter") Bubble Immersion")
                        .font(.largeTitle)
                        .padding(35)
                }
                .toggleStyle(.button)
                .padding(50)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(50)
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
