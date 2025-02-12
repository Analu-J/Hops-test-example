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
    static let enemy: UInt32         = 0x1 << 3  // 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Properties
    var character: SKSpriteNode!
    var platforms: [SKSpriteNode] = []
    var enemies: [SKSpriteNode] = []
    var touchLocation: CGFloat?
    var isGameStarted = false
    var startLabel: SKLabelNode?
    var lastPlatformY: CGFloat = 0  // tracks the highest platform's Y position
    let jumpVelocity: CGFloat = 600.0
    
    // Limit the number of enemies on screen.
    let maxEnemiesOnScreen: Int = 5
    
    // MARK: - Score Properties
    var score: Int = 0
    var scoreLabel: SKLabelNode!
    
    // MARK: - Scene Life Cycle
    override func didMove(to view: SKView) {
        setupPhysicsWorld()
        setupBackground()
        setupCharacter()
        setupInitialPlatforms()
        setupScoreLabel()
        
        // Schedule enemy spawns every 3 seconds.
        let spawnEnemyAction = SKAction.run { [weak self] in
            self?.spawnEnemy()
        }
        let waitAction = SKAction.wait(forDuration: 3.0)
        let spawnSequence = SKAction.sequence([spawnEnemyAction, waitAction])
        run(SKAction.repeatForever(spawnSequence))
    }
    
    // MARK: - Score Setup
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
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
        character.physicsBody?.collisionBitMask = PhysicsCategory.platform
        character.physicsBody?.contactTestBitMask = PhysicsCategory.bounceTrigger | PhysicsCategory.enemy
        
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
        
        let platformBody = SKPhysicsBody(rectangleOf: platform.size)
        platformBody.isDynamic = false
        platformBody.friction = 0.0
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
        bounceTrigger.alpha = 0.0  // Invisible trigger.
        platform.addChild(bounceTrigger)
        
        addChild(platform)
        platforms.append(platform)
        lastPlatformY = max(lastPlatformY, position.y)
    }
    
    // MARK: - Enemy Spawning
    func spawnEnemy() {
        // Only spawn if the game is running and the on-screen enemy count is below the limit.
        guard isGameStarted, enemies.count < maxEnemiesOnScreen else { return }
        
        let enemySize = CGSize(width: 40, height: 40)
        let enemy = SKSpriteNode(color: .red, size: enemySize)
        
        // Spawn the enemy off-screen above the top edge so it scrolls into view.
        let spawnY = frame.maxY + enemySize.height
        let minX = frame.minX + enemySize.width / 2
        let maxX = frame.maxX - enemySize.width / 2
        let spawnX = CGFloat.random(in: minX...maxX)
        enemy.position = CGPoint(x: spawnX, y: spawnY)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemySize)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        enemy.physicsBody?.collisionBitMask = 0
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.character
        
        addChild(enemy)
        enemies.append(enemy)
        
        // Choose horizontal or vertical movement for some additional animation.
        let moveDistance: CGFloat = 100.0
        let duration = Double.random(in: 1.5...3.0)
        if Bool.random() {
            let moveRight = SKAction.moveBy(x: moveDistance, y: 0, duration: duration)
            let moveLeft = SKAction.moveBy(x: -moveDistance, y: 0, duration: duration)
            let sequence = SKAction.sequence([moveRight, moveLeft])
            enemy.run(SKAction.repeatForever(sequence))
        } else {
            let moveDown = SKAction.moveBy(x: 0, y: -moveDistance, duration: duration)
            let moveUp = SKAction.moveBy(x: 0, y: moveDistance, duration: duration)
            let sequence = SKAction.sequence([moveDown, moveUp])
            enemy.run(SKAction.repeatForever(sequence))
        }
    }
    
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        guard isGameStarted else { return }
        
        scrollPlatforms()
        checkGameOverCondition()
        applyScreenWrap()
        updateCharacterMovement()
        updatePlatformsPhysics()
        removeOffscreenEnemies()
    }
    
    /// Scrolls the platforms downward when the character climbs high and shifts enemies accordingly.
    func scrollPlatforms() {
        let thresholdY = frame.midY
        if character.position.y > thresholdY {
            let offset = character.position.y - thresholdY
            character.position.y = thresholdY
            
            score += Int(offset)
            scoreLabel.text = "Score: \(score)"
            
            for platform in platforms {
                platform.position.y -= offset
                
                // Reposition platforms that have moved off-screen at the bottom.
                if platform.position.y < frame.minY - platform.size.height {
                    let newX = CGFloat.random(in: 50...(size.width - 50))
                    platform.position.y = frame.maxY + platform.size.height
                    platform.position.x = newX
                }
            }
            
            // Shift enemies downward as well.
            for enemy in enemies {
                enemy.position.y -= offset
            }
        }
    }
    
    /// Checks if the character has fallen too low and triggers game over.
    func checkGameOverCondition() {
        let characterBottom = character.position.y - (character.size.height * character.yScale / 2)
        if characterBottom <= frame.minY + 60 {
            gameOver()
            isGameStarted = false
        }
    }
    
    /// Wraps the character around the screen edges.
    func applyScreenWrap() {
        if character.position.x < frame.minX {
            character.position.x = frame.maxX
        } else if character.position.x > frame.maxX {
            character.position.x = frame.minX
        }
    }
    
    /// Moves the character horizontally toward the touch location.
    func updateCharacterMovement() {
        if let targetX = touchLocation {
            let dx = targetX - character.position.x
            character.physicsBody?.velocity.dx = dx * 5
        }
    }
    
    /// Updates platform physics based on the character's position.
    func updatePlatformsPhysics() {
        for platform in platforms {
            let platformBottom = platform.position.y - (platform.size.height - 500)
            let characterTop = character.position.y + (character.size.height + 300)
            if characterTop < platformBottom {
                platform.physicsBody = nil
            } else {
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
    
    /// Removes enemies that have scrolled off the bottom of the screen.
    func removeOffscreenEnemies() {
        for (index, enemy) in enemies.enumerated().reversed() {
            if enemy.position.y < frame.minY - enemy.size.height {
                enemy.removeFromParent()
                enemies.remove(at: index)
            }
        }
    }
    
    // MARK: - Game Over Handling
    func gameOver() {
        character.removeFromParent()
        let gameOverLabel = SKLabelNode(text: "Game Over\nTap to Restart")
        gameOverLabel.name = "gameOverLabel"
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
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Bounce logic for platforms.
        if firstBody.categoryBitMask == PhysicsCategory.character,
           (secondBody.categoryBitMask == PhysicsCategory.bounceTrigger ||
            (secondBody.categoryBitMask == PhysicsCategory.platform &&
             contact.contactPoint.y >= (secondBody.node!.position.y + (secondBody.node!.frame.size.height / 2) - 5))) {
            firstBody.velocity = CGVector(dx: firstBody.velocity.dx, dy: jumpVelocity)
        }
        
        // Enemy collision logic.
        if firstBody.categoryBitMask == PhysicsCategory.character &&
           secondBody.categoryBitMask == PhysicsCategory.enemy {
            gameOver()
            isGameStarted = false
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // If game over, restart.
        if let gameOverLabel = self.childNode(withName: "gameOverLabel"),
           gameOverLabel.contains(location) {
            restartGame()
            return
        }
        
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
        skView.showsPhysics = true  // For debugging.
        skView.presentScene(scene)
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // Update view if needed.
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
