//
//  ParallaxGenerators.swift
//  Hops test example
//
//  Created by Analu Jahi on 4/21/25.
//

import SpriteKit

/// Code‑drawn “tree” with a trunk and leafy crown
func generateTree() -> SKNode {
    let tree = SKNode()
    // Trunk
    let trunk = SKShapeNode(rectOf: CGSize(width: 20, height: 60), cornerRadius: 5)
    trunk.fillColor = .brown
    trunk.strokeColor = .clear
    trunk.position = CGPoint(x: 0, y: 30)
    tree.addChild(trunk)
    // Crown
    let crown = SKShapeNode(circleOfRadius: 30)
    crown.fillColor = .green
    crown.strokeColor = .clear
    crown.position = CGPoint(x: 0, y: 75)
    tree.addChild(crown)
    return tree
}

/// Simple cloud made from overlapping circles
func generateCloud() -> SKNode {
    let cloud = SKNode()
    let radii: [CGFloat] = [20, 30, 25]
    let offsets: [CGPoint] = [
        CGPoint(x: -25, y: 0),
        CGPoint(x:   0, y: 10),
        CGPoint(x:  25, y:  0)
    ]
    for (r, o) in zip(radii, offsets) {
        let circle = SKShapeNode(circleOfRadius: r)
        circle.fillColor = .lightGray
        circle.strokeColor = .clear
        circle.position = o
        cloud.addChild(circle)
    }
    return cloud
}
