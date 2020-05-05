//
//  EnemyWaves.swift
//  Asteroids
//
//  Created by Debora Miyashiro on 5/3/20.
//  Copyright © 2020 deb. All rights reserved.
//

import SpriteKit

struct Wave: Codable {
    struct WaveEnemy: Codable {
        let position: Int
        let xOffset: CGFloat
    }
    let name: String
    let enemies: [WaveEnemy]
}
