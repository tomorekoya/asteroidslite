//
//  EnemyType.swift
//  Asteroids
//
//  Created by Debora Miyashiro on 5/3/20.
//  Copyright © 2020 deb. All rights reserved.
//

import SpriteKit

struct EnemyType : Codable {
    let name: String
    let shields: Int
    let speed: CGFloat
}
