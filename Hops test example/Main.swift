//
//  Main.swift
//  Hops test example
//
//  Created by Analu Jahi on 1/27/25.
//

import SwiftUI
import GameplayKit
import SpriteKit



    
class GameScene: SKScene {
         var character: SKSpriteNode!
         var platforms: [SKSpriteNode] = []
         var touchLocation: CGFloat?
         var isGameStarted = false
         var startLabel: SKLabelNode!

        override func didMove(to view: SKView) {
            //background
            backgroundColor = .blue
            physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        //(placeholder character)
            character = SKSpriteNode(imageNamed: "Hops")
                    character.position = CGPoint(x: frame.midX, y: frame.minY + 100)
                    character.physicsBody = SKPhysicsBody(rectangleOf: character.size)
                    character.physicsBody?.allowsRotation = false
                    character.physicsBody?.restitution = 1.0
                    character.physicsBody?.friction = 0.0
                    character.physicsBody?.linearDamping = 0.0
                    character.physicsBody?.affectedByGravity = true
                    character.physicsBody?.isDynamic = false
                    character.xScale = 0.3
                    character.yScale = 0.3
                    addChild(character)

         
            createPlatform(at: CGPoint(x: frame.midX, y: frame.minY + 50))
            createPlatform(at: CGPoint(x: frame.midX - 100, y: frame.minY + 150))
            createPlatform(at: CGPoint(x: frame.midX + 100, y: frame.minY + 250))

          
            startLabel = SKLabelNode(text: "Tap to Start")
            startLabel.fontName = "AvenirNext-Bold"
            startLabel.fontSize = 40
            startLabel.fontColor = .white
            startLabel.position = CGPoint(x: frame.midX, y: frame.midY)
            addChild(startLabel)
        }

         func createPlatform(at position: CGPoint) {
            let platform = SKSpriteNode(color: .green, size: CGSize(width: 100, height: 20))
            platform.position = position
            platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
            platform.physicsBody?.isDynamic = false
            platform.physicsBody?.friction = 0.0
            addChild(platform)
            platforms.append(platform)
        }

    func gameOver() {
        character.removeFromParent() // Remove the character from the scene
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(gameOverLabel)

    }

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }

            if !isGameStarted {
               // game start
                isGameStarted = true
                character.physicsBody?.isDynamic = true
                character.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))
                startLabel.removeFromParent()
            } else {
                
                touchLocation = touch.location(in: self).x
            }
        }

        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            touchLocation = touch.location(in: self).x
        }

        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            touchLocation = nil
        }

        override func update(_ currentTime: TimeInterval) {
            guard isGameStarted else { return }
            
            if character.position.y - (character.size.height * character.yScale / 2) <= self.frame.minY + 60 {
                gameOver()
                 isGameStarted = false
                
              }

          
            if character.position.x < self.frame.minX {
                character.position.x = self.frame.maxX
            } else if character.position.x > self.frame.maxX {
                character.position.x = self.frame.minX
            }

           
            if let touchLocation = touchLocation {
                let dx = touchLocation - character.position.x
                character.physicsBody?.velocity.dx = dx * 5
            }

          
            for platform in platforms {
                if platform.position.y < self.frame.minY + 20 {
                    platform.position.y = self.frame.minY + 20
                }
            }

          
            for platform in platforms {
                if platform.position.y < self.frame.minY {
                    platform.removeFromParent()
                    if let index = platforms.firstIndex(of: platform) {
                        platforms.remove(at: index)
                    }

                    let newPlatformY = platforms.last?.position.y ?? self.frame.minY + 300
                    createPlatform(at: CGPoint(x: CGFloat.random(in: self.frame.minX...self.frame.maxX), y: newPlatformY + 100))
                }
            }

      
            if character.physicsBody?.velocity.dy ?? 0 <= 0 {
                for platform in platforms {
                    if character.frame.intersects(platform.frame) {
                        character.physicsBody?.velocity.dy = 600
                        break
                    }
                }
            }

            
            if character.physicsBody?.velocity.dy ?? 0 > 600 {
                character.physicsBody?.velocity.dy = 600
                
                
            }
        }
    }




struct ContentView: View {
   
    var body: some View {
        VStack{
            
            SpriteView(scene: GameScene(size: CGSize(width: 500, height: 800 )) //options: [.ignoresSiblingOrder, .allowsTransparency]
            )
              //  .frame(width: 500, height: 900)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
      
}
