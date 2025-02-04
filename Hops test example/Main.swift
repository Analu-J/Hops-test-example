//
//  Main.swift
//  Hops test example
//
//  Created by Analu Jahi on 1/27/25.
//
import SwiftUI
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Properties
    var character: SKSpriteNode!
    var platforms: [SKSpriteNode] = []
    var touchLocation: CGFloat?
    var isGameStarted = false
    var startLabel: SKLabelNode?
    var lastPlatformY: CGFloat = 0  // tracks the highest platform's Y position
    let jumpVelocity: CGFloat = 200.0

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
        character.physicsBody?.restitution = 1.0
        character.physicsBody?.friction = 1.0
        character.physicsBody?.linearDamping = 0.0
        character.physicsBody?.affectedByGravity = true
        character.physicsBody?.isDynamic = false
        character.xScale = 0.2
        character.yScale = 0.2
        character.physicsBody?.categoryBitMask = 1
        character.physicsBody?.collisionBitMask = 1
        character.physicsBody?.velocity = CGVector(dx: 0, dy: jumpVelocity)
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
        platform.yScale = 0.5
        
        // create the physics body for the platform.
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
            
            // remove the physics body if the character is far below the platform.
            if characterTop < platformBottom {
                platform.physicsBody = nil
            } else {
                // restore the physics body if needed.
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
        character.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 170))
        startLabel?.removeFromParent()
    }
}

struct ContentView: View {
    var body: some View {
        SpriteView(scene: GameScene(size: CGSize(width: 500, height: 800)))
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
