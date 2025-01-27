//
//  GameViewController.swift
//  Hops test example
//
//  Created by Analu Jahi on 1/15/25.
//

// GameViewController
import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as! SKView? {
            // Load the SKScene
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill

            // Present the scene
            view.presentScene(scene)

            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
