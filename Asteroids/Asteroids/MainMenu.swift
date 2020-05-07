//
//  MainMenu.swift
//  Asteroids
//
//  Created by Tomiwa Orekoya on 5/6/20.
//  Copyright © 2020 deb. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    
    let gameTitleLabel = SKLabelNode(text: "Asteroids")
    let newgameButton = SKLabelNode(text: "New Game")
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        
        gameTitleLabel.name = "title"
        gameTitleLabel.fontName = "Monaco"
        gameTitleLabel.position.x = 0
        gameTitleLabel.position.y = view.frame.maxY / 4
        gameTitleLabel.zPosition = 1
        addChild(gameTitleLabel)
        
        newgameButton.name = "NewGameButton"
        newgameButton.position.x = 0
        newgameButton.position.y = -view.frame.maxY / 4
        newgameButton.zPosition = 1
        addChild(newgameButton)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if touchedNode.name == "NewGameButton" {
                // Move to the game scene.
                loadGame()
            }
        }
    }
    
    func loadGame() {
        let scene = SKScene(fileNamed: "GameScene")
        view?.presentScene(scene)
    }
}
