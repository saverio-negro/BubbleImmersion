//
//  BubbleImmersionApp.swift
//  BubbleImmersion
//
//  Created by Saverio Negro on 18/05/25.
//

import SwiftUI

@main
struct BubbleImmersionApp: App {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .windowResizability(.contentSize)
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .onAppear {
                    viewModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    viewModel.immersiveSpaceState = .closed
                }
        }
    }
}
