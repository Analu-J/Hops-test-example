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
        // remove the character.
        character.removeFromParent()
        
        // create a white background with opacity for the game over screen.
        let gameOverBG = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: CGSize(width: frame.width, height: frame.height))
        gameOverBG.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverBG.zPosition = 5
        addChild(gameOverBG)
        
        // place the game over asset (an image asset named "Gameover") over the white background.
        let gameOverAsset = SKSpriteNode(imageNamed: "Gameover")
        gameOverAsset.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverAsset.xScale = 0.15
        gameOverAsset.yScale = 0.15
        gameOverAsset.zPosition = 6
        gameOverAsset.name = "gameOverAsset"
        addChild(gameOverAsset)
        
         // add a "Tap to Restart" label below the asset.
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
