//
//  GameViewController.swift
//  CookieCrunch
//
//  Created by Ahmad Ghadiri on 4/8/15.
//  Copyright (c) 2015 Ahmad Ghadiri. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    var scene: GameScene!
    var level: Level!
    
    // For scores
    var movesLeft = 0
    var score = 0
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    // For finishing a level
    @IBOutlet weak var gameOverPanel: UIImageView!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    // The power to shuffle
    @IBOutlet weak var shuffleButton: UIButton!
    
    
    // Music Button
    @IBOutlet weak var musicButton: UIButton!
    let image = UIImage(named: "musicButton") as UIImage?
    
    // For music
    lazy var backgroundMusic: AVAudioPlayer = {
        let url = NSBundle.mainBundle().URLForResource("Mining by Moonlight", withExtension: "mp3")
        let player = AVAudioPlayer(contentsOfURL: url, error: nil)
        player.numberOfLoops = -1
        return player
        }()
    
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
        
        // Hiding the shuffle button
        shuffleButton.hidden = true
        musicButton.hidden = true
        
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
        level = Level(filename: "Level_1")
        scene.level = level
        
        // Adding background for tiles
        scene.addTiles()
        
        // Hide the Image view for finishing the level
        gameOverPanel.hidden = true
        
        // Present the scene.
        skView.presentScene(scene)
        
        
        //Start the game and music
        backgroundMusic.play()
        beginGame()
    }
    
    func beginGame() {
        movesLeft = level.maximumMoves
        score = 0
        updateLabels()
        level.resetComboMultiplier()
        scene.animateBeginGame() {
            self.shuffleButton.hidden = false
            self.musicButton.hidden = false
        }
        shuffle()
    }
    
    func shuffle() {
        // Remove old cookies
        scene.removeAllCookieSprites()
        
        
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
        let resultCookies = level.removeandReplaceMatches()
        if resultCookies.remove.count == 0 {
            beginNextTurn()
            return
        }
        scene.animateMatchedCookies(resultCookies.remove,replaceCookies: resultCookies.replace) {
            // To handle the score
            for chain in resultCookies.remove {
                self.score += chain.score
            }
            self.updateLabels()
            
            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies(columns) {
                let columns = self.level.topUpCookies()
                self.scene.animateNewCookies(columns) {
                    self.handleMatches()
                }
            }
        }
    }
    
    // Very interesting: calling detectPossibleSwaps from here solves the problem
    func beginNextTurn() {
        level.detectPossibleSwaps()
        view.userInteractionEnabled = true
        level.resetComboMultiplier()
        decrementMoves()
    }
    
    // Initiate the labels
    func updateLabels() {
        targetLabel.text = String(format: "%ld", level.targetScore)
        movesLabel.text = String(format: "%ld", movesLeft)
        scoreLabel.text = String(format: "%ld", score)
    }
    
    
    func decrementMoves() {
        --movesLeft
        updateLabels()
        
        // To detect the end of the game
        if score >= level.targetScore {
            gameOverPanel.image = UIImage(named: "LevelComplete")
            showGameOver()
        } else if movesLeft == 0 {
            gameOverPanel.image = UIImage(named: "GameOver")
            showGameOver()
        }
    }
    
    func showGameOver() {
        gameOverPanel.hidden = false
        scene.userInteractionEnabled = false
        
        shuffleButton.hidden = true
        
        scene.animateGameOver() {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideGameOver")
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    
    func hideGameOver() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        
        gameOverPanel.hidden = true
        scene.userInteractionEnabled = true
        
        beginGame()
    }
    
    @IBAction func shuffleButtonPressed(AnyObject) {
        shuffle()
        decrementMoves()
    }
    
    @IBAction func musicButtonPressed(AnyObject) {
        if backgroundMusic.playing {
            backgroundMusic.stop()
        } else {
            backgroundMusic.play()
        }
    }


}