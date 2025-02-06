//
//  Main.swift
//  Hops test example
//
//  Created by Analu Jahi on 1/27/25.
//
import SwiftUI
import SpriteKit
import GameplayKit

// MARK: - Physics Categories
struct PhysicsCategory {
    static let character: UInt32     = 0x1 << 0  // 1
    static let platform: UInt32      = 0x1 << 1  // 2
    static let bounceTrigger: UInt32 = 0x1 << 2  // 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Properties
    var character: SKSpriteNode!
    var platforms: [SKSpriteNode] = []
    var touchLocation: CGFloat?
    var isGameStarted = false
    var startLabel: SKLabelNode?
    var lastPlatformY: CGFloat = 0  // Tracks the highest platform's Y position
    let jumpVelocity: CGFloat = 600.0

    // MARK: - Scene Life Cycle
    override func didMove(to view: SKView) {
        setupPhysicsWorld()
        setupBackground()
        setupCharacter()
        setupInitialPlatforms()
    }
    
    // MARK: - Setup Functions
    func setupPhysicsWorld() {
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "grassBackground")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
    }
    
    func setupCharacter() {
        character = SKSpriteNode(imageNamed: "Hops")
        character.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        character.physicsBody = SKPhysicsBody(rectangleOf: character.size)
        character.physicsBody?.allowsRotation = false
//        // Set restitution to 0 so extra bounciness doesn’t interfere
        character.physicsBody?.restitution = 0.0
        character.physicsBody?.friction = 1.0
        character.physicsBody?.linearDamping = 0.0
       character.physicsBody?.affectedByGravity = true
////        // Start as non-dynamic until the game begins
        character.physicsBody?.isDynamic = false
        character.xScale = 0.2
        character.yScale = 0.2
//        let jumpUpAction = SKAction.moveBy(x: 0, y: 70, duration: 0.2)
//        let jumpDownAction = SKAction.moveBy(x: 0, y: -70, duration: 0.2)
//        let jumpSequence = SKAction.sequence([jumpUpAction, jumpDownAction])
//        let repeatAction = SKAction.repeatForever(SKAction.sequence([jumpUpAction, jumpDownAction]))
//        let new = SKAction.sequence([repeatAction])
      //  character.run(new)
        
//        // Assign physics categories and contact test mask
        character.physicsBody?.categoryBitMask = PhysicsCategory.character
//        // Collide only with platforms
        character.physicsBody?.collisionBitMask = PhysicsCategory.platform
//        // Notify us when contacting a bounce trigger
        character.physicsBody?.contactTestBitMask = PhysicsCategory.bounceTrigger
//        
        addChild(character)
    }
    
    func setupInitialPlatforms() {
        for i in 0..<10 {
            let yPosition = frame.minY + CGFloat(i * 100)
            let xPosition = CGFloat.random(in: 50...(size.width - 50))
            createPlatform(at: CGPoint(x: xPosition, y: yPosition))
        }
    }
    
    // MARK: - Platform Creation
    func createPlatform(at position: CGPoint) {
        let platform = SKSpriteNode(imageNamed: "grassPlatform")
        platform.position = position
        platform.xScale = 0.5
        platform.yScale = 0.3
        
        
        // Create the physics body for the platform.
        let platformBody = SKPhysicsBody(rectangleOf: platform.size)
        platformBody.node?.xScale = 1.0
        platformBody.node?.yScale = 1.0
        platformBody.isDynamic = false
        platformBody.friction = 0.0
        // Set restitution to 0 so that the bounce comes only from our trigger
        platformBody.restitution = 0.2
        platformBody.categoryBitMask = PhysicsCategory.platform
        platformBody.collisionBitMask = PhysicsCategory.character
      //  platform.physicsBody = platformBody
        
       
        let bounceTrigger = SKNode()
        // Place the trigger at the top of the platform.
        bounceTrigger.position = CGPoint(x: 0, y: platform.size.height )
        bounceTrigger.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform.size.width, height: platform.size.height))
        bounceTrigger.physicsBody?.isDynamic = false
        bounceTrigger.physicsBody?.categoryBitMask = PhysicsCategory.bounceTrigger
        bounceTrigger.physicsBody?.contactTestBitMask = PhysicsCategory.character
        // No collision so it won’t interfere with the character’s movement.
        bounceTrigger.physicsBody?.collisionBitMask = 0
        bounceTrigger.alpha = 0.0  // Keep it invisible
        platform.addChild(bounceTrigger)
        
        //
        
        addChild(platform)
        platforms.append(platform)
        lastPlatformY = max(lastPlatformY, position.y)
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        guard isGameStarted else { return }
        
        checkGameOverCondition()
        applyScreenWrap()
        updateCharacterMovement()
        updatePlatformsPhysics()
    }
    
    func checkGameOverCondition() {
        let characterBottom = character.position.y - (character.size.height * character.yScale / 2)
        if characterBottom <= self.frame.minY + 60 {
            gameOver()
            isGameStarted = false
        }
    }
    
    func applyScreenWrap() {
        if character.position.x < self.frame.minX {
            character.position.x = self.frame.maxX
        } else if character.position.x > self.frame.maxX {
            character.position.x = self.frame.minX
        }
    }
    
    func updateCharacterMovement() {
        if let targetX = touchLocation {
            let dx = targetX - character.position.x
            character.physicsBody?.velocity.dx = dx * 5
        }
    }
    
    func updatePlatformsPhysics() {
        for platform in platforms {
            let platformBottom = platform.position.y - (platform.size.height - 500)
            let characterTop = character.position.y + (character.size.height + 300)
            
            // Remove the physics body if the character is far below the platform.
            if characterTop < platformBottom {
                platform.physicsBody = nil
            } else {
                // Restore the physics body if needed.
                if platform.physicsBody == nil {
                    let restoredBody = SKPhysicsBody(rectangleOf: platform.size)
                    restoredBody.isDynamic = false
                    restoredBody.friction = 0.0
                    restoredBody.restitution = 0.0
                    restoredBody.categoryBitMask = PhysicsCategory.platform
                    restoredBody.collisionBitMask = PhysicsCategory.character
                    platform.physicsBody = restoredBody
                }
            }
        }
    }
    
    // MARK: - Game Over Handling
    func gameOver() {
        character.removeFromParent()
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(gameOverLabel)
    }
    
    // MARK: - SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        // Identify the character and the other object.
        var characterBody: SKPhysicsBody?
        var otherBody: SKPhysicsBody?
        
        if contact.bodyA.categoryBitMask == PhysicsCategory.character {
            characterBody = contact.bodyA
            otherBody = contact.bodyB
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.character {
            characterBody = contact.bodyB
            otherBody = contact.bodyA
        }
        
        guard let charBody = characterBody, let other = otherBody else {
            return
        }
        
        // We only want to bounce when the character is falling.
        if charBody.velocity.dy <= 0 {
            // Case 1: The contact is with the bounce trigger.
            if other.categoryBitMask == PhysicsCategory.bounceTrigger {
                charBody.velocity = CGVector(dx: charBody.velocity.dx, dy: jumpVelocity)
            }
            // Case 2: The contact is with a platform’s main body.
            else if other.categoryBitMask == PhysicsCategory.platform,
                    let platformNode = other.node as? SKSpriteNode {
                // Convert the platform’s top edge into scene coordinates.
                let platformTopY = platformNode.position.y + (platformNode.size.height * platformNode.yScale / 2)
                // Check the contact point.
                if contact.contactPoint.y >= platformTopY - 5 {
                    // The contact is near the top of the platform.
                    charBody.velocity = CGVector(dx: charBody.velocity.dx, dy: jumpVelocity)
                }
            }
        }
    }

    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if !isGameStarted {
            startGame()
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
    
    func startGame() {
        isGameStarted = true
        character.physicsBody?.isDynamic = true
     character.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
        startLabel?.removeFromParent()
    }
}

struct SpriteKitView: UIViewRepresentable {
    let scene: SKScene
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        
        // Enable debug info
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        // Enable physics outlines!
        skView.showsPhysics = true
        
        // Present the scene
        skView.presentScene(scene)
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // If you need to update the scene or SKView
    }
}

struct ContentView: View {
    var body: some View {
        SpriteKitView(scene: GameScene(size: CGSize(width: 500, height: 800)))
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
