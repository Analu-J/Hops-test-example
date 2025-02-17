//
//  SceneLifeCycle.swift
//  Hops test example
//
//  Created by Analu Jahi on 2/17/25.
//

import Foundation
import SpriteKit

extension GameScene {
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
}
