//
//  Main.swift
//  Hops test example
//
//  Created by Analu Jahi on 1/27/25.
//

import SwiftUI
import GameplayKit
import SpriteKit

// Make the bottoms of the platoforms "transparent"

    
class GameScene: SKScene {
    var character: SKSpriteNode!
    var platforms: [SKSpriteNode] = []
    var touchLocation: CGFloat?
    var isGameStarted = false
    var startLabel: SKLabelNode!
    var lastPlatformY: CGFloat = 0  // Tracks the highest platform's Y position

    override func didMove(to view: SKView) {
        // Background
        let background = SKSpriteNode (imageNamed: "grassBackground")
        addChild(background)
        background.position = CGPoint(x: 175, y: 160)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        // (Placeholder character)
        character = SKSpriteNode(imageNamed: "Hops")
        character.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        character.physicsBody = SKPhysicsBody(rectangleOf: character.size)
        character.physicsBody?.allowsRotation = false
        character.physicsBody?.restitution = 1.0
        character.physicsBody?.friction = 0.0
        character.physicsBody?.linearDamping = 0.0
        character.physicsBody?.affectedByGravity = true
        character.physicsBody?.isDynamic = false
        character.xScale = 0.2
        character.yScale = 0.2
        addChild(character)

        // Create initial platforms
        for i in 0..<10 {
            let yPosition = frame.minY + CGFloat(i * 100)
            createPlatform(at: CGPoint(x: CGFloat.random(in: frame.minX + 50...frame.maxX - 70), y: yPosition))
        }
    }

    func createPlatform(at position: CGPoint) {
        let platform = SKSpriteNode(imageNamed: "grassPlatform")
        platform.position = position
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.friction = 0.0
        platform.xScale = 0.5
        platform.yScale = 0.5
        addChild(platform)
        platforms.append(platform)

        lastPlatformY = max(lastPlatformY, position.y) // Keep track of highest platform
    }


    func gameOver() {
        character.removeFromParent() // Remove the character from the scene
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(gameOverLabel)

    }


        override func update(_ currentTime: TimeInterval) {
            guard isGameStarted else { return }
            
            if character.position.y - (character.size.height * character.yScale / 2) <= self.frame.minY + 60 {
                gameOver()
                 isGameStarted = false
                
              }

          
            if character.position.x < self.frame.minX {
                character.position.x = self.frame.maxX
            } else if character.position.x > self.frame.maxX {
                character.position.x = self.frame.minX
            }

           
            if let touchLocation = touchLocation {
                let dx = touchLocation - character.position.x
                character.physicsBody?.velocity.dx = dx * 5
            }

          
            for platform in platforms {
                if platform.position.y < self.frame.minY + 20 {
                    platform.position.y = self.frame.minY + 20

                }
            }
        }

        // **Spawn new platforms when player reaches a certain height**
    func newPlatform(){
        if character.position.y > lastPlatformY - (size.height / 2) {
            let newPlatformY = lastPlatformY + CGFloat.random(in: 100...200)
            let randomX = CGFloat.random(in: frame.minX + 50...frame.maxX - 50)
            createPlatform(at: CGPoint(x: randomX, y: newPlatformY))
        }
    }
        

        // **Allow player to jump on platforms**
    func jumpPlatforms(){
        if character.physicsBody?.velocity.dy ?? 0 <= 0 {
            for platform in platforms {
                if character.frame.intersects(platform.frame) {
                    character.physicsBody?.velocity.dy = 600
                    break
                }
            }
        }
    }


        // Limit max jump speed
    func jumpSpeed(){
        if character.physicsBody?.velocity.dy ?? 0 > 900 {
            character.physicsBody?.velocity.dy = 900
        }
        }
    

   

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        if !isGameStarted {
            // Game start
            isGameStarted = true
            character.physicsBody?.isDynamic = true
            character.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 170))
            startLabel?.removeFromParent()
        } else {
            touchLocation = touch.location(in: self).x
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchLocation = touch.location(in: self).x
    }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil
    }
}

struct ContentView: View {
   
    var body: some View {
        VStack{
            
            SpriteView(scene: GameScene(size: CGSize(width: 500, height: 800 )) //options: [.ignoresSiblingOrder, .allowsTransparency]
            )
              //  .frame(width: 500, height: 900)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
      
}
