//
//  CreatePlatform.swift
//  Hops test example
//
//  Created by Analu Jahi on 2/17/25.
//

import Foundation
import SpriteKit

extension GameScene {
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
        
        // create a bounce trigger on top of the platform.
        let bounceTrigger = SKNode()
        bounceTrigger.position = CGPoint(x: 0, y: platform.size.height)
        bounceTrigger.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform.size.width, height: platform.size.height))
        bounceTrigger.physicsBody?.isDynamic = false
        bounceTrigger.physicsBody?.categoryBitMask = PhysicsCategory.bounceTrigger
        bounceTrigger.physicsBody?.contactTestBitMask = PhysicsCategory.character
        bounceTrigger.physicsBody?.collisionBitMask = 0
        bounceTrigger.alpha = 0.0  // invisible trigger.
        platform.addChild(bounceTrigger)
        
        addChild(platform)
        platforms.append(platform)
        lastPlatformY = max(lastPlatformY, position.y)
    }
}
