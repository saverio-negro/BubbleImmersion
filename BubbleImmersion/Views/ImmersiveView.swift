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
    
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var bubbleSky = Entity()
    @State private var bubbleCount = 0
    @State private var floor = Entity()
    let headAnchor = {
        let anchorEntity = AnchorEntity(.head)
        anchorEntity.position = SIMD3<Float>(0.7, -0.2, -1.0)
        
        return anchorEntity
    }()
    @State private var inputText = "Touch as many bubbles as you can!"
    @State private var remainingTime = 60
    @State private var score = 0
    @State private var hasGameStarted = false
    @State private var hasGameEnded = false
    @State private var isFirstRound = true
    
    // SwiftUI Attachment
    var playAttachment: some View {
        VStack {
            
            if hasGameStarted {
                Text("Time left: \(remainingTime)")
                    .font(.extraLargeTitle)
                    .fontWeight(.regular)
                    .padding(30)
                
                Text("Score: \(score)")
                    .font(.extraLargeTitle2)
                    .fontWeight(.regular)
                    .padding(30)
                
                Text("Hint: Touch the bubbles!")
                    .font(.largeTitle)
            } else {
                
                Text(inputText)
                    .lineLimit(.max)
                    .font(.extraLargeTitle2)
                    .fontWeight(.regular)
                    .padding(30)
                
                if isFirstRound {
                    Button {
                        hasGameStarted = true
                        isFirstRound = false
                    } label: {
                        Text("Ready")
                            .font(.largeTitle)
                            .padding()
                    }
                }
            }
            
            if hasGameEnded {
                retryAttachment
            }
        }
        .padding(50)
        .glassBackgroundEffect()
    }
    
    // SwiftUI Attachment
    var retryAttachment: some View {
        VStack {
            Button {
                hasGameEnded = false
                hasGameStarted = true
            } label: {
                Text("Play Again")
                    .font(.largeTitle)
                    .padding()
            }
            
            Button {
                Task {
                    await dismissImmersiveSpace()
                }
            } label: {
                Text("Exit")
                    .font(.largeTitle)
                    .padding()
            }
        }
        .padding(50)
    }
    
    // Long press gesture
    var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.001)
            .targetedToEntity(bubbleSky)
            .onEnded { event in
                // Get a hold of the touched entity via the `event` object
                if let touchedBubble = event.entity as? ModelEntity, hasGameStarted {
                    // Increase Score
                    score += 1
                    
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
        RealityView { content, attachments in
            floor = generateFloor()
            bubbleSky = generateBubbleSky(height: 1.8)
            
            if let attachment = attachments.entity(for: "attachment") {
                headAnchor.addChild(attachment)
            }
            
            content.add(floor)
            content.add(bubbleSky)
            content.add(headAnchor)
        } attachments: {
            Attachment(id: "attachment") {
                playAttachment
                    .frame(
                        minWidth: 500,
                        maxWidth: 1000,
                        alignment: .center
                    )
            }
        }
        .gesture(
            longPressGesture
        )
        .onChange(of: hasGameStarted) { _, newValue in
            if newValue {
                reset()
                Task {
                    await startCountdown()
                }
            }
        }
        .onChange(of: hasGameEnded) { _, newValue in
            if newValue {
                hasGameStarted = false
            }
        }
    }
    
    func getNanosecondsFromSeconds(seconds: Float) -> UInt64 {
        return UInt64(seconds * pow(10, 9))
    }
    
    func reset() {
        remainingTime = 60
        score = 0
    }
    
    func startCountdown() async {
        while (remainingTime > 0 && score < bubbleCount) {
            try! await Task.sleep(nanoseconds: getNanosecondsFromSeconds(seconds: 1))
            remainingTime -= 1
            inputText = String(remainingTime)
        }
        
        inputText = (score == bubbleCount) ?
            "Congrats!\n\nYou touched all the \(bubbleCount) bubbles in time!"
                :
            "Time Over!\n\nYou touched \(score) bubbles."
        hasGameEnded = true
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
                bubbleCount += 1
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
