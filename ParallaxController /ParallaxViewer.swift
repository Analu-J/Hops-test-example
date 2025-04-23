//
//  ParallaxViewer.swift
//  Hops test example
//
//  Created by Analu Jahi on 4/21/25.
//

import SpriteKit

extension GameScene {
    /// Create & register your layers
    func setupParallax() {
        let cloudLayer = ParallaxLayer(
            speed:   10,
            spacing: 300,
            generator: generateCloud
        )
        parallaxBG.addLayer(cloudLayer, zPosition: -5)
        
    }
}

