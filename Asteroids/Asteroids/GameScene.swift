//
//  GameScene.swift
//  Asteroids
//
//  Created by Debora Miyashiro on 5/3/20.
//  Copyright © 2020 deb. All rights reserved.
//

import CoreMotion
import SpriteKit

enum CollisionType: UInt32 {
    case player = 1
    case bullet = 2
    case alien = 4
    case asteroid = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    let motionManager = CMMotionManager()
    let ship = SKSpriteNode(imageNamed: "ship")
    let waves = Bundle.main.decode([Wave].self, from: "enemyWaves.json")
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemyTypes.json")
    let levelLabel = SKLabelNode()
    let RIGHT_ANGLE = CGFloat.pi * 0.5    // 90 degrees
    
    var isPlayerAlive = true
    var playerShield = 1
    var level = 0
    var waveNum = 0
    var screenMaxX: CGFloat = 0
    var screenMaxY: CGFloat = 0
    var shipAngle: CGFloat = CGFloat.pi * 0.5
    var fingerIsTouching: Bool = false
    var touchLocation: CGPoint? = nil
    
    let pos = Array(stride(from: -320, through: 320, by: 80))
    

    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero    // World Physics
        physicsWorld.contactDelegate = self
        
        screenMaxX = view.frame.maxX / 2
        screenMaxY = view.frame.maxY / 2
        
        levelLabel.name = "level"
        levelLabel.position.x = 0
        levelLabel.position.y = 0
        levelLabel.zPosition = 1
        levelLabel.alpha = 0.0    // Initially not visible.
        addChild(levelLabel)
        
        startNewGame()
        
        motionManager.startDeviceMotionUpdates()
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Rotate the ship
        handleShipRotation()
        // Move the ship
        handleShipMovement()
        // Wrap elements that have moved off-screen
        handleNodeWraparound()
        
        let activeEnemies = children.compactMap{ $0 as? AsteroidNode }
        
        if activeEnemies.isEmpty {
            level += 1
            
            for _ in 0..<level+1 {
                spawnNewAsteroid()
            }
            
            if isPlayerAlive {
                displayLevel()
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if isPlayerAlive {
                if location.x < 0 && location.y >= 0 {
                    fingerIsTouching = true
                    touchLocation = location
                }
                
                if location.x < -screenMaxX / 2 && location.y < 0 {
                    rotateShip(eulerAngle: 0.21)
                }
                
                if location.x < 0 && location.x >= -screenMaxX / 2 && location.y < 0 {
                    rotateShip(eulerAngle: -0.21)
                }
                
                if location.x >= 0 {
                    shootBullet()
                }
            } else {
                let touchedNode = atPoint(location)
                
                if touchedNode.name == "level" {
                    startNewGame()
                }
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fingerIsTouching = false
    }
    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        fingerIsTouching = false
    }
    
    
    func startNewGame() {
        // Hide the level label
        levelLabel.alpha = 0
        
        // Remove all asteroids on screen
        
        let activeEnemies = children.compactMap{ $0 as? AsteroidNode }
        
        for enemy in activeEnemies {
            enemy.removeFromParent()
        }
        
        level = 0
        
        isPlayerAlive = true
        initShip(ship: ship)
        shipAngle = RIGHT_ANGLE
        spawnNewAsteroid()
        
        if isPlayerAlive {
            // Show the level at the top of the screen
            displayLevel()
        }
    }
    
    func displayLevel() {
        levelLabel.position.y = screenMaxY / 2
        levelLabel.text = "Level \(level + 1)"
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let delay = SKAction.wait(forDuration: 2)
        
        levelLabel.run(.sequence([fadeIn, delay, fadeOut]))
    }
    
    
    // MARK: Player
    func initShip(ship: SKSpriteNode) {
        ship.name = "player"
        ship.position.x = 0    // Centered horizontally
        ship.position.y = 0
        ship.zPosition = 1
        ship.zRotation = CGFloat.pi * 0.23
        addChild(ship)
        playerShield = 1
        setUpShipPhysics(ship)
    }

    // MARK: Player Physics
    func setUpShipPhysics(_ ship: SKSpriteNode) {
        ship.physicsBody = SKPhysicsBody(texture: ship.texture!, size: ship.texture!.size())
        // What kind in physics world
        ship.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        // What it collides with
        ship.physicsBody?.collisionBitMask = CollisionType.alien.rawValue | CollisionType.asteroid.rawValue
        // What is being told when they collide
        ship.physicsBody?.contactTestBitMask = CollisionType.alien.rawValue | CollisionType.asteroid.rawValue
//        ship.physicsBody?.allowsRotation = false
        ship.physicsBody?.isDynamic = false    // Gravity doesn't affect the ship.
    }
    
    // MARK: BULLET
    func setBulletPhysics(bullet: SKSpriteNode) {
        bullet.name = "bullet"
        bullet.position = ship.position
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.categoryBitMask = CollisionType.bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = CollisionType.asteroid.rawValue | CollisionType.alien.rawValue | CollisionType.bullet.rawValue
        bullet.physicsBody?.collisionBitMask = CollisionType.asteroid.rawValue | CollisionType.alien.rawValue | CollisionType.bullet.rawValue
    }
    
    
    func handleShipRotation() {
        if let data = self.motionManager.deviceMotion {
            let z = data.rotationRate.z
            rotateShip(eulerAngle: CGFloat(z))
        }
    }
    
    
    func rotateShip(eulerAngle: CGFloat) {
        if eulerAngle > 0.1 {
            shipAngle += 0.05
            ship.zRotation += 0.05
        } else if eulerAngle < -0.1 {
            shipAngle += -0.05
            ship.zRotation -= 0.05
        }
    }
    
    
    // For testing purposes
    func rad2deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }
    
    
    func handleShipMovement() {
        if fingerIsTouching {
            moveShip()
        }
    }
    
    
    func moveShip() {
        let moveForward = SKAction.move(by: CGVector(dx: 5 * cos(shipAngle), dy: 5 * sin(shipAngle)), duration: 0.5)
        ship.run(moveForward)
    }
    
    
    func handleNodeWraparound() {
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
    }
    
    
    // MARK: Testing asteroid spawning
    func spawnNewAsteroid() {
        let startX = CGFloat.random(in: -screenMaxX..<screenMaxX)
        let startY = CGFloat.random(in: -screenMaxY..<screenMaxY)
        let startPosition = CGPoint(x: startX, y: startY)
        let newAsteroid = AsteroidNode(type: enemyTypes[0], startPos: startPosition, xOffset: 0)
        addChild(newAsteroid)
    }
    
    
    func shootBullet() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        setBulletPhysics(bullet: bullet)
        addChild(bullet)
        
        let movement = SKAction.move(by: CGVector(dx: screenMaxX * 1.5 * cos(shipAngle), dy: screenMaxX * 1.5 * sin(shipAngle)), duration: 2)
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
            guard isPlayerAlive else { return }

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
        isPlayerAlive = false

        // show boom
        if let boom = SKEmitterNode(fileNamed: "Boom") {
            boom.position = ship.position
            addChild(boom)
        }
        
        // Show Game Over
        levelLabel.text = "Game Over. New Game?"
        levelLabel.position.y = 0
        levelLabel.removeAllActions()
        
        let reveal = SKAction.fadeIn(withDuration: 0.5)
        levelLabel.run(reveal)
    }
    
    
    // MARK: CREATE WAVE
    func createWave() {
        guard isPlayerAlive else { return }
        
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
}
