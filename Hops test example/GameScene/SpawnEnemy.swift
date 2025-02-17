//
//  SpawnEnemy.swift
//  Hops test example
//
//  Created by Analu Jahi on 2/17/25.
//

import Foundation
import SpriteKit

extension GameScene {
    func spawnEnemy() {
        // only spawn if the game is running and enemy count is below the limit.
        guard isGameStarted, enemies.count < maxEnemiesOnScreen else { return }
        
        let enemySize = CGSize(width: 5, height: 5)
        let enemy = SKSpriteNode(imageNamed: "birdEnemy")
        
        // spawn enemy off-screen above the top.
        let spawnY = frame.maxY + enemySize.height
        let minX = frame.minX + enemySize.width / 2
        let maxX = frame.maxX - enemySize.width / 2
        let spawnX = CGFloat.random(in: minX...maxX)
        enemy.position = CGPoint(x: spawnX, y: spawnY)
        enemy.xScale = 0.2
        enemy.yScale = 0.2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemySize)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        enemy.physicsBody?.collisionBitMask = 0
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.character
        
        addChild(enemy)
        enemies.append(enemy)
        
        // randomize movement: horizontal or vertical.
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
}
