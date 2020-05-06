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
    
    let roid_speed = 50
    
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
        
        drift()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("HELP")
    }
    
    func drift() {
        let delta_x = Float.random(in: 0.2..<1) * Float(roid_speed) * (Int.random(in: 0..<10) < 5 ? 1 : -1)
        let delta_y = Float.random(in: 0.2..<1) * Float(roid_speed) * (Int.random(in: 0..<10) < 5 ? 1 : -1)
        let drift = SKAction.move(by: CGVector(dx: CGFloat(delta_x), dy: CGFloat(delta_y)), duration: TimeInterval(CGFloat(1.0)))
        run(SKAction.repeatForever(drift))
    }
}
