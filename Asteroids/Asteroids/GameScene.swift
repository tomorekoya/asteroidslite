//
//  GameScene.swift
//  Asteroids
//
//  Created by Debora Miyashiro on 5/3/20.
//  Copyright © 2020 deb. All rights reserved.
//

import SpriteKit
import GameplayKit

enum CollisionType: UInt32 {
    case player = 1
    case bullet = 2
    case alien = 4
    case asteroid = 8
}

class GameScene: SKScene {

    let player = SKSpriteNode(imageNamed: "ship")
    let waves = Bundle.main.decode([Wave].self, from: "enemyWaves.json")
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemyTypes.json")
    
    var isGameOver = false
    var playerShield = 1
    var level = 0
    var waveNum = 0
    
    let pos = Array(stride(from: -320, through: 320, by: 80))

    override func didMove(to view: SKView) {
        // World Physics
        physicsWorld.gravity = .zero

        // MARK:PLAYER
        player.name = "player"
        player.position.x = 0              // Centered horizontally
        player.zPosition = 1
        addChild(player)
        // MARK:Player physics
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        // What kind in physics world
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        // What it collides with
        player.physicsBody?.collisionBitMask = CollisionType.alien.rawValue | CollisionType.bullet.rawValue | CollisionType.asteroid.rawValue
        // What is being told when they collide
        player.physicsBody?.contactTestBitMask = CollisionType.alien.rawValue | CollisionType.bullet.rawValue | CollisionType.asteroid.rawValue
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.isDynamic = false           // Gravity doesnt affect
    }
    
    override func update(_ currentTime: TimeInterval) {
        for child in children {
            if child.frame.maxX < -700 {
                child.removeFromParent()            // Remove if way off screen
            }
        }
        let activeEnemies = children.compactMap{ $0 as? AsteroidNode }
        if activeEnemies.isEmpty {
            createWave()
        }
    }
    
    // MARK: CREATE WAVE
    func createWave() {
        guard !isGameOver else { return }
        if waveNum == waves.count {
            level += 1
            waveNum = 0
        }
        
        let curWave = waves[waveNum]
        waveNum += 1
        
        let maxEnemyType = min(enemyTypes.count, level + 1)
        let enemyType = Int.random(in: 0..<maxEnemyType)
        let enemyOffsetX: CGFloat = 100
        let enemyStartX = 600
        
        if curWave.enemies.isEmpty {
            for (index, position) in pos.shuffled().enumerated() {
                let enemy = AsteroidNode(type: enemyTypes[enemyType], startPos: CGPoint(x: enemyStartX, y: position), xOffset: enemyOffsetX * CGFloat(index * 3))
                addChild(enemy)
            }
        } else {
            for enemy in curWave.enemies {
                let node = AsteroidNode(type: enemyTypes[enemyType], startPos: CGPoint(x: enemyStartX, y: pos[enemy.position]), xOffset: enemyOffsetX * enemy.xOffset)
                addChild(node)
            }
        }
    }
    
    // MARK: BULLET
    func setBulletPhysics(bullet: SKSpriteNode) {
        bullet.name = "bullet"
        bullet.position = player.position
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.categoryBitMask = CollisionType.bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = CollisionType.asteroid.rawValue | CollisionType.alien.rawValue | CollisionType.bullet.rawValue
        bullet.physicsBody?.collisionBitMask = CollisionType.asteroid.rawValue | CollisionType.alien.rawValue | CollisionType.bullet.rawValue
//        bullet.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        let bullet = SKSpriteNode(imageNamed: "bullet")
        setBulletPhysics(bullet: bullet)
        addChild(bullet)
        
        let movement = SKAction.move(to: CGPoint(x: 1900, y: bullet.position.y), duration: 5)
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        bullet.run(sequence)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]

        if secondNode.name == "player" {
            guard isGameOver else { return }

            if let boom = SKEmitterNode(fileNamed: "Boom") {
                boom.position = firstNode.position
                addChild(boom)
            }

            playerShield -= 1

            if playerShield == 0 {
                gameOver()
                secondNode.removeFromParent()
            }

            firstNode.removeFromParent()
        } else if let asteroid = firstNode as? AsteroidNode {
            asteroid.shields -= 1

            if asteroid.shields == 0 {
                if let boom = SKEmitterNode(fileNamed: "Boom") {
                    boom.position = asteroid.position
                    addChild(boom)
                }

                asteroid.removeFromParent()
            }

            if let boom = SKEmitterNode(fileNamed: "Boom") {
                boom.position = asteroid.position
                addChild(boom)
            }

            secondNode.removeFromParent()
        } else {
            if let boom = SKEmitterNode(fileNamed: "Boom") {
                boom.position = secondNode.position
                addChild(boom)
            }

            firstNode.removeFromParent()
            secondNode.removeFromParent()
        }
    }
    
    // MARK: GAME OVER
    func gameOver() {
        isGameOver = true

        // show boom
        if let boom = SKEmitterNode(fileNamed: "Boom") {
            boom.position = player.position
            addChild(boom)
        }
    }
}
