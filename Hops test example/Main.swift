//
//  Main.swift
//  Hops test example
//
//  Created by Analu Jahi on 1/27/25.
//
import SwiftUI
import SpriteKit

// MARK: - Physics Categories
struct PhysicsCategory {
    static let character: UInt32     = 0x1 << 0  // 1
    static let platform: UInt32      = 0x1 << 1  // 2
    static let bounceTrigger: UInt32 = 0x1 << 2  // 4
    static let enemy: UInt32         = 0x1 << 3  // 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Properties
    var character: SKSpriteNode!
    var platforms: [SKSpriteNode] = []
    var enemies: [SKSpriteNode] = []
    var touchLocation: CGFloat?
    var isGameStarted = false
    var startLabel: SKLabelNode?
    var lastPlatformY: CGFloat = 0  // tracks the highest platform's Y position
    let jumpVelocity: CGFloat = 600.0
    
    // limit the number of enemies on screen.
    let maxEnemiesOnScreen: Int = 5
    
    // MARK: - Score Properties
    var score: Int = 0
    var scoreLabel: SKLabelNode!
    
}

// MARK: - Screen View & Debug
struct SpriteKitView: UIViewRepresentable {
    let scene: SKScene
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.showsPhysics = false // for debugging make true to show boxes.
        skView.presentScene(scene)
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // update view if needed.
    }
}


import SwiftUI

struct ContentView: View {
    var body: some View {
        SpriteKitView(scene: MainMenuScene(size: CGSize(width: 500, height: 800)))
            .ignoresSafeArea()
            .onAppear {
                GameCenterManager.shared.authenticateLocalPlayer()
            }
    }
}




#Preview {
        ContentView()
}



