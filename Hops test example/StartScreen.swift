//
//  StartScreen.swift
//  Hops test example
//
//  Created by Analu Jahi on 2/18/25.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        // set up background image.
        let background = SKSpriteNode(imageNamed: "MainScreenBackground")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = 0
        background.size = self.size  // fill the entire scene 
        addChild(background)
        
        // set up start button image.
        let startButton = SKSpriteNode(imageNamed: "StartButton")
        startButton.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        startButton.zPosition = 1
        startButton.xScale = 0.6
        startButton.yScale = 0.6
        startButton.name = "startButton" // So we can detect taps on it.
        addChild(startButton)
    }
    
    // MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)
        
        // if the user tapped the start button, present the game scene.
        if node.name == "startButton" {
            presentGameScene()
        }
    }
    
    private func presentGameScene() {
        // create existing GameScene (the one with your game logic).
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = .resizeFill
        
        // present it with a nice transition.
        let transition = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(gameScene, transition: transition)
    }
}
