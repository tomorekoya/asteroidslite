//
//  GameScene.swift
//  Asteroids
//
//  Created by Debora Miyashiro on 5/3/20.
//  Copyright © 2020 deb. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    enum CollisionType: UInt32 {
        case player = 1
        case playerBullet = 2
        case alien = 4
        case alienBullet = 8
    }

    let player = SKSpriteNode(imageNamed: "ship")

    override func didMove(to view: SKView) {
        if let starParts = SKEmitterNode(fileNamed: "SpaceField") {
            starParts.position = CGPoint(x: 700, y: 0)      // Off screen, centered vertically
            starParts.advanceSimulationTime(120)            // Start with filled screen
            starParts.zPosition = -1                        // Behind elems in game
            addChild(starParts)
        }

        // MARK:PLAYER
        player.name = "player"
        player.position.x = frame.minX + 375                // Centered horizontally
        player.zPosition = 1
        addChild(player)
        // MARK:Player physics
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        // What kind in physics world
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        // What it collides with
        player.physicsBody?.collisionBitMask = CollisionType.alien.rawValue | CollisionType.alienBullet.rawValue
        // What is being told when they collide
        player.physicsBody?.contactTestBitMask = CollisionType.alien.rawValue | CollisionType.alienBullet.rawValue
        player.physicsBody?.isDynamic = false           // Gravity doesnt affect
    }
}