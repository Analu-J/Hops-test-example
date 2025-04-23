//
//  ParallaxLayer.swift
//  Hops test example
//
//  Created by Analu Jahi on 4/21/25.
//

// ParallaxLayer.swift
import SpriteKit

/// A single layer of parallax content
class ParallaxLayer {
    let speed: CGFloat
    let spacing: CGFloat
    private let generator: () -> SKNode
    private(set) var tiles: [SKNode] = []

    init(speed: CGFloat, spacing: CGFloat, generator: @escaping ()->SKNode) {
        self.speed = speed
        self.spacing = spacing
        self.generator = generator
    }

    /// Fill the screen with tiles at setup
    func populate(in frame: CGRect) {
        tiles.removeAll()
        var y = frame.minY
        while y < frame.maxY + spacing {
            let tile = generator()
            tile.position = CGPoint(
                x: CGFloat.random(in: frame.minX...frame.maxX),
                y: y
            )
            tiles.append(tile)
            y += spacing
        }
    }

    /// Add tiles as children of the given node
    func addTo(scene: SKNode) {
        for tile in tiles {
            scene.addChild(tile)
        }
    }

    /// Scroll tiles down and recycle when offscreen
    func update(deltaTime dt: CGFloat, in frame: CGRect) {
        for tile in tiles {
            tile.position.y -= speed * dt
            if tile.position.y < frame.minY - spacing {
                tile.position.y = frame.maxY + spacing
                tile.position.x = CGFloat.random(in: frame.minX...frame.maxX)
            }
        }
    }
}

/// Manages multiple parallax layers
class ParallaxBackground: SKNode {
    private var layers: [(layer: ParallaxLayer, z: CGFloat)] = []

    func addLayer(_ layer: ParallaxLayer, zPosition: CGFloat) {
        guard let sceneFrame = scene?.frame else { return }
        layer.populate(in: sceneFrame)
        layer.addTo(scene: self)
        layer.tiles.forEach { $0.zPosition = zPosition }
        layers.append((layer, zPosition))
    }

    /// Call from your scene’s update(_:) method
    func update(deltaTime dt: CGFloat) {
        guard let sceneFrame = scene?.frame else { return }
        for (layer, _) in layers {
            layer.update(deltaTime: dt, in: sceneFrame)
        }
    }

    /// Shift everything down by a custom offset
    func shift(by offset: CGFloat) {
        guard let f = scene?.frame else { return }
        for (layer, _) in layers {
            for tile in layer.tiles {
                tile.position.y -= offset
                if tile.position.y < f.minY - layer.spacing {
                    tile.position.y = f.maxY + layer.spacing
                    tile.position.x = CGFloat.random(in: f.minX...f.maxX)
                }
            }
        }
    }
}

