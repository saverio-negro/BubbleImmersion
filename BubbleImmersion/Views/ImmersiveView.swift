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
    @State private var floor = Entity()
    var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.001)
            .targetedToEntity(bubbleSky)
            .onEnded { event in
                // Get a hold of the touched entity via the `event` object
                if let touchedBubble = event.entity as? ModelEntity {
                    // Add `PhysicsBodyComponent` to the entity to let it fall
                    touchedBubble.physicsBody = PhysicsBodyComponent(
                        massProperties: .default,
                        material: .generate(
                            friction: 0.1,
                            restitution: 0.5
                        ),
                        mode: .dynamic
                    )
                }
            }
    }
    
    var body: some View {
        RealityView { content in
            floor = generateFloor()
            bubbleSky = generateBubbleSky(height: 1.8)
            
            content.add(floor)
            content.add(bubbleSky)
        }
        .gesture(
            longPressGesture
        )
    }
    
    // Generate floor entity
    func generateFloor() -> ModelEntity {
        
        // Create a box that is 5 meters wide, 0.0001 meters thick, and 5 meters deep.
        let floor = ModelEntity(mesh: .generateBox(size: [5.0, 0.0001, 5.0]))
        floor.position.z = -3
        
        // Center the plane at x=0. By default, the generated primitive centers itself at the supplied position.
        floor.position.x = 0
        floor.position.y = 0
        
        // Make the entity invisible
        floor.components.set(OpacityComponent(opacity: 0))
        floor.components.set(PhysicsBodyComponent(
            massProperties: .default,
            material: .generate(
                friction: 0.1,
                restitution: 1.0
            ),
            mode: .static
        ))
        
        floor.generateCollisionShapes(recursive: true)
        
        return floor
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
