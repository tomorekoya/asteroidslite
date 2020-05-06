//
//  GameScene.swift
//  Asteroids
//
//  Created by Debora Miyashiro on 5/3/20.
//  Copyright © 2020 deb. All rights reserved.
//

import SpriteKit

enum CollisionType: UInt32 {
    case player = 1
    case bullet = 2
    case alien = 4
    case asteroid = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    let player = SKSpriteNode(imageNamed: "ship")
    let waves = Bundle.main.decode([Wave].self, from: "enemyWaves.json")
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemyTypes.json")
    
    var isGameOver = false
    var playerShield = 1
    var level = 0
    var waveNum = 0
    var screenMaxX: CGFloat = 0
    var screenMaxY: CGFloat = 0
    
    let pos = Array(stride(from: -320, through: 320, by: 80))
    

    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero    // World Physics
        physicsWorld.contactDelegate = self
        
        screenMaxX = view.frame.maxX / 2
        screenMaxY = view.frame.maxY / 2
        
        initShip(player)
        spawnNewAsteroid()
    }
    
    // MARK: Player
    func initShip(_ ship: SKSpriteNode) {
        ship.name = "player"
        ship.position.x = 0    // Centered horizontally
        ship.position.y = 0
        ship.zPosition = 1
        addChild(ship)
        setUpShipPhysics(ship)
    }

    // MARK: Player Physics
    func setUpShipPhysics(_ ship: SKSpriteNode) {
        ship.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        // What kind in physics world
        ship.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        // What it collides with
        ship.physicsBody?.collisionBitMask = CollisionType.alien.rawValue | CollisionType.asteroid.rawValue
        // What is being told when they collide
        ship.physicsBody?.contactTestBitMask = CollisionType.alien.rawValue | CollisionType.asteroid.rawValue
//        ship.physicsBody?.allowsRotation = false
        ship.physicsBody?.isDynamic = false    // Gravity doesn't affect the ship.
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        for child in children {
            if let sprite = child as? SKSpriteNode {  // Wrap around to the other side of the screen.
                if sprite.frame.maxX < -screenMaxX - 40 {
                    sprite.position.x = screenMaxX + 30 + (sprite.texture?.size().width)! / 2
                }
                
                if sprite.frame.maxY < -screenMaxY - 40 {
                    sprite.position.y = screenMaxY + 30 + (sprite.texture?.size().height)! / 2
                }
                
                if sprite.frame.minX > screenMaxX + 40 {
                    sprite.position.x = -screenMaxX - 30 - (sprite.texture?.size().width)! / 2
                }
                
                if sprite.frame.minY > screenMaxY + 40 {
                    sprite.position.y = -screenMaxY - 30 - (sprite.texture?.size().height)! / 2
                }
            }
        }
        
        let activeEnemies = children.compactMap{ $0 as? AsteroidNode }
        
        if activeEnemies.isEmpty {
//            createWave()
            level += 1
            
            for _ in 0..<level+1 {
                spawnNewAsteroid()
            }
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
    
    // MARK: Testing asteroid spawning
    func spawnNewAsteroid() {
        let startX = CGFloat.random(in: -screenMaxX..<screenMaxX)
        let startY = CGFloat.random(in: -screenMaxY..<screenMaxY)
        let startPosition = CGPoint(x: startX, y: startY)
        let newAsteroid = AsteroidNode(type: enemyTypes[0], startPos: startPosition, xOffset: 0)
        addChild(newAsteroid)
    }
    
    
    // MARK: BULLET
    func setBulletPhysics(bullet: SKSpriteNode) {
        bullet.name = "bullet"
        bullet.position = player.position
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.categoryBitMask = CollisionType.bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = CollisionType.asteroid.rawValue | CollisionType.alien.rawValue | CollisionType.bullet.rawValue
        bullet.physicsBody?.collisionBitMask = CollisionType.asteroid.rawValue | CollisionType.alien.rawValue | CollisionType.bullet.rawValue
        // bullet.physicsBody?.usesPreciseCollisionDetection = true
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
//            guard isGameOver else { return }

            if let boom = SKEmitterNode(fileNamed: "Boom") {
                boom.position = firstNode.position
                addChild(boom)
            }

            playerShield -= 1

            if playerShield == 0 {
//                gameOver()
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
