//
//  TouchHandling.swift
//  Hops test example
//
//  Created by Analu Jahi on 2/17/25.
//

import Foundation
import SpriteKit

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // if the game over asset or the restart label is tapped, restart the game.
        if let gameOverAsset = self.childNode(withName: "gameOverAsset"),
           gameOverAsset.contains(location) {
            restartGame()
            return
        }
        
        if let restartLabel = self.childNode(withName: "gameOverRestartLabel"),
           restartLabel.contains(location) {
            restartGame()
            return
        }
        
        // otherwise, if the game hasn't started, start it.
        if !isGameStarted {
            startGame()
        } else {
            touchLocation = location.x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchLocation = touch.location(in: self).x
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil
    }
}
