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
       // setupBackground()
        setupCharacter()
        setupInitialPlatforms()
        setupScoreLabel()
        
        /// Parallax Setup
           //  Custom sky‑blue background
        self.backgroundColor = SKColor(
                red:   135.0/255.0,
                green: 206.0/255.0,
                blue:  235.0/255.0,
                alpha: 1.0
            )
        
        /// Static Ground
         let groundHeight: CGFloat = 100
        let ground = SKShapeNode(rectOf: CGSize(width: frame.width, height: groundHeight)
         )
         ground.fillColor   = .green
         ground.strokeColor = .clear
         ground.position    = CGPoint(
           x: frame.midX,
           y: frame.minY + groundHeight/2
         )
         ground.zPosition = -2
         addChild(ground)
        
            // keep a reference so we can shift it later
            groundNode = ground
         

         // Static Trees
         let treeCount = 7
         let spacing   = frame.width / CGFloat(treeCount)
         for i in 0..<treeCount {
             let tree = generateTree()
             let x    = spacing * (CGFloat(i) + 0.5)
             // sit crown just above the ground
             let y    = ground.position.y + groundHeight/2
             tree.position = CGPoint(x: x, y: y)
             tree.zPosition = -1
             addChild(tree)
             
             // keep each tree so we can shift them later
            staticTrees.append(tree)
         }
        
              
  

         /// Parallax (clouds only)
         parallaxBG.zPosition = -10
         addChild(parallaxBG)
         setupParallax()

        
        // Schedule enemy spawns every 3 seconds.
        let spawnEnemyAction = SKAction.run { [weak self] in
            self?.spawnEnemy()
        }
        let waitAction = SKAction.wait(forDuration: 3.0)
        let spawnSequence = SKAction.sequence([spawnEnemyAction, waitAction])
        run(SKAction.repeatForever(spawnSequence))
    }
}
