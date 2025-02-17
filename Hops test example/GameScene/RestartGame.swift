//
//  RestartGame.swift
//  Hops test example
//
//  Created by Analu Jahi on 2/17/25.
//

import Foundation
import SpriteKit

extension GameScene {
    func restartGame() {
        guard let view = self.view else { return }
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = self.scaleMode
        let transition = SKTransition.fade(withDuration: 1.0)
        view.presentScene(newScene, transition: transition)
    }
}
