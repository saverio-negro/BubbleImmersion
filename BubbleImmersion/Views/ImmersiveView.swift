//
//  ImmersiveView.swift
//  BubbleImmersion
//
//  Created by Saverio Negro on 18/05/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    
    // Entity containing all sphere model entities
    let sphereCollection = Entity()
    
    var body: some View {
        RealityView { content in
            
        }
    }
    
    func getRandomColor() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        let alpha = CGFloat.random(in: 0.5...1)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func generateRandomSphere() -> ModelEntity {
        let randomRadius = Float.random(in: 0.05...0.1)
        let mesh = MeshResource.generateSphere(radius: randomRadius)
        let material = SimpleMaterial(
            color: getRandomColor(),
            roughness: .float(Float.random(in: 0...1)),
            isMetallic: Bool.random()
        )
        let sphere = ModelEntity(mesh: mesh, materials: [material])
        sphere.generateCollisionShapes(recursive: true)
        sphere.components.set(HoverEffectComponent())
        sphere.components.set(InputTargetComponent(allowedInputTypes: [.direct, .indirect]))
        return sphere
    }
}

#Preview {
    ImmersiveView()
}
