//
//  AsteroidNode.swift
//  Asteroids
//
//  Created by Debora Miyashiro on 5/4/20.
//  Copyright © 2020 deb. All rights reserved.
//

import SpriteKit

class AsteroidNode: SKSpriteNode {
    var type: EnemyType
    var shields: Int
    
    init(type: EnemyType, startPos: CGPoint, xOffset: CGFloat) {
        self.type = type
        shields = type.shields
        let texture = SKTexture(imageNamed: type.name)
        super.init(texture: texture, color: .white, size: texture.size())
        physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        name = "asteroid"
        physicsBody?.categoryBitMask = CollisionType.asteroid.rawValue
        physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.alien.rawValue
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.alien.rawValue
        position = CGPoint(x: startPos.x, y: startPos.y)
        
        confMove()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("HELP")
    }
    
    func confMove() {
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addCurve(to: CGPoint(x: -3500, y: 0), controlPoint1: CGPoint(x: 0, y: -position.y * 4), controlPoint2: CGPoint(x: -1000, y: -position.y))
        // Follow some path over time
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: type.speed)
        // Destroy as soon as movement is done
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        run(sequence)
    }
}
