//
//  GameLoop.swift
//  Hops test example
//
//  Created by Analu Jahi on 2/17/25.
//

import Foundation
import SpriteKit

extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        guard isGameStarted else { return }
        
        scrollPlatforms()
        checkGameOverCondition()
        applyScreenWrap()
        updateCharacterMovement()
        updatePlatformsPhysics()
        removeOffscreenEnemies()
    }
    
    // scrolls and shifts platfroms and enemies based on character's Y
    func scrollPlatforms() {
        let thresholdY = frame.midY
        if character.position.y > thresholdY {
            let offset = character.position.y - thresholdY
            character.position.y = thresholdY
            
            score += Int(offset)
            scoreLabel.text = "Score: \(score)"
            
            for platform in platforms {
                platform.position.y -= offset
                
                // reposition platforms that have moved off-screen.
                if platform.position.y < frame.minY - platform.size.height {
                    let newX = CGFloat.random(in: 50...(size.width - 50))
                    platform.position.y = frame.maxY + platform.size.height
                    platform.position.x = newX
                }
            }
            
            // shift enemies downward as well.
            for enemy in enemies {
                enemy.position.y -= offset
                
              //  only move your cloud layer when the player moves up
                        parallaxBG.shift(by: offset)
                
                    //  Shift ground and static trees
                    groundNode?.position.y -= offset
                    for tree in staticTrees {
                        tree.position.y -= offset
                    }
    
                
                   
            }
        }
    }
    
    // checks if the character has fallen too low.
    func checkGameOverCondition() {
        let characterBottom = character.position.y - (character.size.height * character.yScale / 2)
        if characterBottom <= frame.minY + 60 {
            gameOver()
            isGameStarted = false
        }
    }
    
    // wraps the character around the screen edges.
    func applyScreenWrap() {
        if character.position.x < frame.minX {
            character.position.x = frame.maxX
        } else if character.position.x > frame.maxX {
            character.position.x = frame.minX
        }
    }
    
    // moves the character horizontally toward the touch location.
    func updateCharacterMovement() {
        if let targetX = touchLocation {
            let dx = targetX - character.position.x
            character.physicsBody?.velocity.dx = dx * 5
        }
    }
    
    // restores or removes platform physics based on the character’s position.
    func updatePlatformsPhysics() {
        for platform in platforms {
            let platformBottom = platform.position.y - (platform.size.height - 475)
            let characterTop = character.position.y + (character.size.height + 300)
            /// character top < charatcer bottom 
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
    
    // removes enemies that have scrolled off-screen.
    func removeOffscreenEnemies() {
        for (index, enemy) in enemies.enumerated().reversed() {
            if enemy.position.y < frame.minY - enemy.size.height {
                enemy.removeFromParent()
                enemies.remove(at: index)
            }
        }
    }
}
