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
    
    @State private var bubbleSky = Entity()
    
    var body: some View {
        RealityView { content in
            
        }
    }
    
    // Generate grid of bubbles
    func generateBubbleSky(height: Float) -> Entity {
        
        // Entity containing all sphere (bubble) model entities
        let sphereCollection = Entity()
        
        let zValues = stride(from: -2.5, through: -1.25, by: 0.25)
        let xValues = stride(from: -0.75, through: 0.75, by: 0.25)
        
        for z in zValues {
            for x in xValues {
                let bubble = generateRandomSphere()
                bubble.position.x = Float(x)
                bubble.position.y = height
                bubble.position.z = Float(z)
                
                sphereCollection.addChild(bubble)
            }
        }
        return sphereCollection
    }
    
    // Generate random colors for the bubbles
    func getRandomColor() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        let alpha = CGFloat.random(in: 0.5...1)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // Generate random sphere representing the bubble
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
