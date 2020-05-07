//
//  MainMenu.swift
//  Asteroids
//
//  Created by Tomiwa Orekoya on 5/6/20.
//  Copyright © 2020 deb. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    
    let newgameButton = SKLabelNode(text: "New Game")
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        
        newgameButton.name = "NewGameButton"
        newgameButton.position.x = 0
        newgameButton.position.y = 0
        newgameButton.zPosition = 1
        addChild(newgameButton)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if touchedNode.name == "NewGameButton" {
                // Move to the game scene.
                print("Move to the Game Scene.")
            }
        }
    }
    
    func loadGame() {
        /* Grab a reference to our SpriteKit view */
        
        /* 2) Load Game Scene */
    }
}
