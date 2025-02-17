//
//  GameSetup.swift
//  Hops test example
//
//  Created by Analu Jahi on 2/17/25.
//

import Foundation
import SpriteKit

extension GameScene {
    
    func startGame() {
        isGameStarted = true
        character.physicsBody?.isDynamic = true
        character.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
        startLabel?.removeFromParent()
    }
    
    func setupPhysicsWorld() {
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    // main game background.
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "grassBackground")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1  // behind everything.
        background.size = size    // stretch to fill the scene.
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
        // start as non-dynamic until the game begins.
        character.physicsBody?.isDynamic = false
        
        character.xScale = 0.2
        character.yScale = 0.2
        
        // set physics categories.
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
}
