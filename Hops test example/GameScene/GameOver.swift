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
        
        // Create a semi-transparent background.
        let gameOverBG = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: CGSize(width: frame.width, height: frame.height))
        gameOverBG.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverBG.zPosition = 5
        addChild(gameOverBG)
        
        // Display the Game Over asset.
        let gameOverAsset = SKSpriteNode(imageNamed: "Gameover")
        gameOverAsset.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverAsset.xScale = 0.15
        gameOverAsset.yScale = 0.15
        gameOverAsset.zPosition = 6
        gameOverAsset.name = "gameOverAsset"
        addChild(gameOverAsset)
        
        // Display the final score.
        let finalScoreLabel = SKLabelNode(text: "Score: \(score)")
        finalScoreLabel.fontName = "AvenirNext-Bold"
        finalScoreLabel.fontSize = 28
        finalScoreLabel.fontColor = .white
        finalScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY + gameOverAsset.size.height/2 + 30)
        finalScoreLabel.zPosition = 7
        addChild(finalScoreLabel)
        
        // Add a "Tap to Restart" label.
        let restartLabel = SKLabelNode(text: "Tap to Restart")
        restartLabel.fontName = "AvenirNext-Bold"
        restartLabel.fontSize = 24
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: frame.midX, y: frame.midY - gameOverAsset.size.height/2 - 40)
        restartLabel.zPosition = 7
        restartLabel.name = "gameOverRestartLabel"
        addChild(restartLabel)
        
        // submit the score using your leaderboard ID.
        GameCenterManager.shared.submitScore(score)
        
        let leaderboardButton = SKLabelNode(text: "View Leaderboard")
        // configure font, position, etc.
        leaderboardButton.name = "leaderboardButton"
        leaderboardButton.fontName = "AvenirNext-Bold"
        leaderboardButton.fontSize = 24
        leaderboardButton.position = CGPoint(x: frame.maxX - 20, y: frame.maxY - 50)
        leaderboardButton.zPosition = 999
        leaderboardButton.fontColor = .white
        leaderboardButton.verticalAlignmentMode = .top
        leaderboardButton.horizontalAlignmentMode = .right
        addChild(leaderboardButton)

        
        isGameStarted = false
    }
    
}
