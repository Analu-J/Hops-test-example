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
    var lastPlatformY: CGFloat = 0  // tracks the highest platform's Y position
    let jumpVelocity: CGFloat = 600.0
    
    // MARK: - Score Properties
    var score: Int = 0
    var scoreLabel: SKLabelNode!
    
    // MARK: - Scene Life Cycle
    override func didMove(to view: SKView) {
        setupPhysicsWorld()
        setupBackground()
        setupCharacter()
        setupInitialPlatforms()
        setupScoreLabel()  // <-- Set up the score label when the scene loads.
    }
    
    // MARK: - Score Setup
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        // Position in the top left (adding a small margin)
        scoreLabel.position = CGPoint(x: frame.minX + 20, y: frame.maxY - 20)
        scoreLabel.zPosition = 10  // Ensure it appears above other nodes.
        addChild(scoreLabel)
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
        character.physicsBody?.restitution = 0.0
        character.physicsBody?.friction = 1.0
        character.physicsBody?.linearDamping = 0.0
        character.physicsBody?.affectedByGravity = true
        // Start as non-dynamic until the game begins.
        character.physicsBody?.isDynamic = false
        
        character.xScale = 0.2
        character.yScale = 0.2
        
        // Set physics categories.
        character.physicsBody?.categoryBitMask = PhysicsCategory.character
        // Collide only with platforms.
        character.physicsBody?.collisionBitMask = PhysicsCategory.platform
        // Notify us when contacting a bounce trigger.
        character.physicsBody?.contactTestBitMask = PhysicsCategory.bounceTrigger
        
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
        platformBody.isDynamic = false
        platformBody.friction = 0.0
        // Set restitution to 0 so that the bounce comes only from our trigger.
        platformBody.restitution = 0.2
        platformBody.categoryBitMask = PhysicsCategory.platform
        platformBody.collisionBitMask = PhysicsCategory.character
        
        platform.physicsBody = platformBody
        
        // Create a bounce trigger on top of the platform.
        let bounceTrigger = SKNode()
        bounceTrigger.position = CGPoint(x: 0, y: platform.size.height)
        bounceTrigger.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform.size.width, height: platform.size.height))
        bounceTrigger.physicsBody?.isDynamic = false
        bounceTrigger.physicsBody?.categoryBitMask = PhysicsCategory.bounceTrigger
        bounceTrigger.physicsBody?.contactTestBitMask = PhysicsCategory.character
        bounceTrigger.physicsBody?.collisionBitMask = 0
        bounceTrigger.alpha = 0.0  // Keep it invisible.
        platform.addChild(bounceTrigger)
        
        addChild(platform)
        platforms.append(platform)
        lastPlatformY = max(lastPlatformY, position.y)
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        guard isGameStarted else { return }
        
        scrollPlatforms()
        checkGameOverCondition()
        applyScreenWrap()
        updateCharacterMovement()
        updatePlatformsPhysics()
    }
    
    /// Scrolls the platforms downward when the character climbs high.
    func scrollPlatforms() {
        // Define the threshold (here, the vertical midpoint of the scene).
        let thresholdY = frame.midY
        if character.position.y > thresholdY {
            // Calculate how far above the threshold the character is.
            let offset = character.position.y - thresholdY
            
            // Bring the character back to the threshold.
            character.position.y = thresholdY
            
            // **Update the score based on upward movement**
            score += Int(offset)
            scoreLabel.text = "Score: \(score)"
            
            // Move each platform downward by the same offset.
            for platform in platforms {
                platform.position.y -= offset
                
                // If a platform has moved off-screen at the bottom, reposition it at the top.
                if platform.position.y < frame.minY - platform.size.height {
                    let newX = CGFloat.random(in: 50...(size.width - 50))
                    platform.position.y = frame.maxY + platform.size.height
                    platform.position.x = newX
                }
            }
        }
    }
    
    /// Checks if the character has fallen too low and triggers game over.
    func checkGameOverCondition() {
        let characterBottom = character.position.y - (character.size.height * character.yScale / 2)
        if characterBottom <= self.frame.minY + 60 {
            gameOver()
            isGameStarted = false
        }
    }
    
    /// Wraps the character around the screen edges.
    func applyScreenWrap() {
        if character.position.x < self.frame.minX {
            character.position.x = self.frame.maxX
        } else if character.position.x > self.frame.maxX {
            character.position.x = self.frame.minX
        }
    }
    
    /// Moves the character horizontally toward the touch location.
    func updateCharacterMovement() {
        if let targetX = touchLocation {
            let dx = targetX - character.position.x
            character.physicsBody?.velocity.dx = dx * 5
        }
    }
    
    /// Updates the physics bodies for platforms based on the character's position.
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
        let gameOverLabel = SKLabelNode(text: "Game Over\nTap to Restart")
        gameOverLabel.name = "gameOverLabel" // Assign a name for detection.
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .black
        gameOverLabel.numberOfLines = 2
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.verticalAlignmentMode = .center
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(gameOverLabel)
        
        isGameStarted = false
    }
    
    // MARK: - Restart Function
    func restartGame() {
        guard let view = self.view else { return }
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = self.scaleMode
        let transition = SKTransition.fade(withDuration: 1.0)
        view.presentScene(newScene, transition: transition)
    }
    
    // MARK: - SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        var characterBody: SKPhysicsBody?
        var otherBody: SKPhysicsBody?
        
        if contact.bodyA.categoryBitMask == PhysicsCategory.character {
            characterBody = contact.bodyA
            otherBody = contact.bodyB
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.character {
            characterBody = contact.bodyB
            otherBody = contact.bodyA
        }
        
        guard let charBody = characterBody, let other = otherBody else { return }
        
        // Bounce only when falling.
        if charBody.velocity.dy <= 0 {
            if other.categoryBitMask == PhysicsCategory.bounceTrigger {
                charBody.velocity = CGVector(dx: charBody.velocity.dx, dy: jumpVelocity)
            } else if other.categoryBitMask == PhysicsCategory.platform,
                      let platformNode = other.node as? SKSpriteNode {
                let platformTopY = platformNode.position.y + (platformNode.size.height * platformNode.yScale / 2)
                if contact.contactPoint.y >= platformTopY - 5 {
                    charBody.velocity = CGVector(dx: charBody.velocity.dx, dy: jumpVelocity)
                }
            }
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // If the game over label is present and tapped, restart the game.
        if let gameOverLabel = self.childNode(withName: "gameOverLabel") {
            if gameOverLabel.contains(location) {
                restartGame()
                return
            }
        }
        
        // Start the game if it hasn't started yet.
        if !isGameStarted {
            startGame()
        } else {
            touchLocation = location.x
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
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true  // Show physics outlines for debugging.
        skView.presentScene(scene)
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // Update the view if needed.
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
