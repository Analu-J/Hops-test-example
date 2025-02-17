//
//  GameOver.swift
//  Hops test example
//
//  Created by Analu Jahi on 2/17/25.
//

import Foundation
import SpriteKit

extension GameScene {
    func gameOver() {
        // Remove the character.
        character.removeFromParent()
        
        // Create a semi-transparent background for the game over screen.
        let gameOverBG = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: CGSize(width: frame.width, height: frame.height))
        gameOverBG.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverBG.zPosition = 5
        addChild(gameOverBG)
        
        // Place the game over asset (an image asset named "Gameover") over the background.
        let gameOverAsset = SKSpriteNode(imageNamed: "Gameover")
        gameOverAsset.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverAsset.xScale = 0.15
        gameOverAsset.yScale = 0.15
        gameOverAsset.zPosition = 6
        gameOverAsset.name = "gameOverAsset"
        addChild(gameOverAsset)
        
        // Create and add a label to display the final score.
        let finalScoreLabel = SKLabelNode(text: "Score: \(score)")
        finalScoreLabel.fontName = "AvenirNext-Bold"
        finalScoreLabel.fontSize = 28
        finalScoreLabel.fontColor = .white
        // Position it above the game over asset (adjust the offset as needed).
        finalScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY + gameOverAsset.size.height/2 + 30)
        finalScoreLabel.zPosition = 7
        addChild(finalScoreLabel)
        
        // Add a "Tap to Restart" label below the asset.
        let restartLabel = SKLabelNode(text: "Tap to Restart")
        restartLabel.fontName = "AvenirNext-Bold"
        restartLabel.fontSize = 24
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: frame.midX, y: frame.midY - gameOverAsset.size.height/2 - 40)
        restartLabel.zPosition = 7
        restartLabel.name = "gameOverRestartLabel"
        addChild(restartLabel)
        
        isGameStarted = false
    }
}
