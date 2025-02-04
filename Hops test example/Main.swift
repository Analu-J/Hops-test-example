//
//  Main.swift
//  Hops test example
//
//  Created by Analu Jahi on 1/27/25.
//

import SwiftUI
import GameplayKit
import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    var character: SKSpriteNode!
    var platforms: [SKSpriteNode] = []
    var touchLocation: CGFloat?
    var isGameStarted = false
    var startLabel: SKLabelNode!
    var lastPlatformY: CGFloat = 0  // tracks the highest platform's Y position

    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self

        // background
        let background = SKSpriteNode(imageNamed: "grassBackground")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        // character setup
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
        character.physicsBody?.categoryBitMask = 1
        character.physicsBody?.collisionBitMask = 1
        addChild(character)

        // creates initial platforms
        for i in 0..<10 {
            let yPosition = frame.minY + CGFloat(i * 100)
            createPlatform(at: CGPoint(x: CGFloat.random(in: 50...(size.width - 50)), y: yPosition))
        }
    }

    func createPlatform(at position: CGPoint) {
        let platform = SKSpriteNode(imageNamed: "grassPlatform")
        platform.position = position
        platform.xScale = 0.5
        platform.yScale = 0.5

        // create a physics body (this will be removed when the player is below)
        let platformBody = SKPhysicsBody(rectangleOf: platform.size)
        platformBody.isDynamic = false
        platformBody.friction = 0.0
        platformBody.restitution = 0.8
        platformBody.categoryBitMask = 1
        platformBody.collisionBitMask = 1
        platform.physicsBody = platformBody

        addChild(platform)
        platforms.append(platform)

        lastPlatformY = max(lastPlatformY, position.y)
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

        // **Dynamic Collision Handling**
        for platform in platforms {
            let platformBottom = platform.position.y - (platform.size.height - 500)
            let characterTop = character.position.y + (character.size.height + 300)

            // **if the character is below the platform, remove the physics body**
          
            if characterTop < platformBottom  {
                platform.physicsBody = nil
            } else {
                // **re-enable the physics body when the character moves above**
                if platform.physicsBody == nil {
                    let restoredBody = SKPhysicsBody(rectangleOf: platform.size)
                    restoredBody.isDynamic = false
                    restoredBody.friction = 0.0
                    restoredBody.restitution = 0.8
                    restoredBody.categoryBitMask = 1
                    restoredBody.collisionBitMask = 1
                    platform.physicsBody = restoredBody
                }
            }
        }
    }

    func gameOver() {
        character.removeFromParent()
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(gameOverLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        if !isGameStarted {
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
        VStack {
            SpriteView(scene: GameScene(size: CGSize(width: 500, height: 800)))
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}

