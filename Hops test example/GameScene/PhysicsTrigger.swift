//
//  PhysicsTrigger.swift
//  Hops test example
//
//  Created by Analu Jahi on 2/17/25.
//

import Foundation
import SpriteKit

extension GameScene {
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
        
        // bounce logic for platforms.
        if firstBody.categoryBitMask == PhysicsCategory.character,
           (secondBody.categoryBitMask == PhysicsCategory.bounceTrigger ||
            (secondBody.categoryBitMask == PhysicsCategory.platform &&
             contact.contactPoint.y >= (secondBody.node!.position.y + (secondBody.node!.frame.size.height / 2) - 5))) {
            firstBody.velocity = CGVector(dx: firstBody.velocity.dx, dy: jumpVelocity)
        }
        
        // enemy collision logic.
        if firstBody.categoryBitMask == PhysicsCategory.character &&
           secondBody.categoryBitMask == PhysicsCategory.enemy {
            gameOver()
            isGameStarted = false
        }
    }
}
