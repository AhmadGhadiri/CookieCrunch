//
//  GameViewController.swift
//  CookieCrunch
//
//  Created by Ahmad Ghadiri on 4/8/15.
//  Copyright (c) 2015 Ahmad Ghadiri. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var scene: GameScene!
    var level: Level!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        // For swapping 
        scene.swipeHandler = handleSwipe
        
        // Create the level and add it to scene
        level = Level(filename: "Level_3")
        scene.level = level
        
        // Adding background for tiles
        scene.addTiles()
        
        // Present the scene.
        skView.presentScene(scene)
        
        beginGame()
    }
    
    func beginGame() {
        shuffle()
    }
    
    func shuffle() {
        let newCookies = level.shuffle()
        scene.addSpritesForCookies(newCookies)
    }
    
    
    // This function handles the swaps in the GameScence
    // It had one parameter and it returns void
    // Same as the swipeHandler type in GameScene class
    func handleSwipe(swap: Swap) {
        view.userInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            // Performs swap and wait for removing to be completed
            scene.animateSwap(swap, completion: handleMatches)
        } else {
            scene.animateInvalidSwap(swap){
            self.view.userInteractionEnabled = true
            }
        }
    }
    
    // Handling the matches in the game map
    func handleMatches() {
        let chains = level.removeMatches()
        scene.animateMatchedCookies(chains) {
            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies(columns) {
                let columns = self.level.topUpCookies()
                self.scene.animateNewCookies(columns) {
                    self.view.userInteractionEnabled = true
                }
            }
        }
    }
    
    
    
}