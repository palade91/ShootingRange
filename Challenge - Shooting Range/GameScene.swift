//
//  GameScene.swift
//  Challenge - Shooting Range
//
//  Created by Catalin Palade on 06/07/2018.
//  Copyright © 2018 Catalin Palade. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameTimer = Timer()
    var gameOver = Timer()
    var targets = [SKSpriteNode]()
    
    var bullets = [SKSpriteNode]()
    var numberOfBullets = 6
    
    let leftEdge = -30
    let rightEdge = 1334 + 30
    let bottomEdge = -30
    
    var gameOverImg = SKSpriteNode(imageNamed: "gameOver")
    var reloadImg: SKSpriteNode!
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    var highScoreLabel: SKLabelNode!
    var highScore = 0
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 667, y: 375)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        gameScore = SKLabelNode(fontNamed: "Courier-Bold")
        gameScore.text = "Score: 0"
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 40
        gameScore.fontColor = UIColor.red
        gameScore.position = CGPoint(x: 30, y: 70)
        addChild(gameScore)
        
        showBullets()
        startGame()
        
        gameOverImg.name = "newGame"
        gameOverImg.removeAllChildren()
        highScore = loadHighScore()
       
        highScoreLabel = SKLabelNode(fontNamed: "Courier-Bold")
        highScoreLabel.text = "Highscore: \(highScore)"
        highScoreLabel.horizontalAlignmentMode = .left
        highScoreLabel.fontSize = 40
        highScoreLabel.fontColor = .red
        highScoreLabel.position = CGPoint(x: 30, y: 30)
        addChild(highScoreLabel)
        
    }
    func startGame() {
        gameTimer = Timer.scheduledTimer(timeInterval: 0.5,
                                         target: self,
                                         selector: #selector(lunchTarget),
                                         userInfo: nil,
                                         repeats: true)
        gameOver = Timer.scheduledTimer(timeInterval: 60,
                                        target: self,
                                        selector: #selector(gameIsOver),
                                        userInfo: nil,
                                        repeats: true)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if checkBullets() {
            checkTouches(touches)
        } else {
            checkReload(touches)
        }
    }
    
    func createTarget(xMovement: CGFloat, x: Int, y:Int) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: xMovement, y: 0))
        
        switch GKRandomSource.sharedRandom().nextInt(upperBound: 3) {
        case 0:
            let targetLarge = SKSpriteNode(imageNamed: "target")
            targetLarge.position = CGPoint(x: x, y: y)
            targetLarge.name = "targetLarge"
            targetLarge.physicsBody = SKPhysicsBody(circleOfRadius: targetLarge.size.width)
            targetLarge.physicsBody?.isDynamic = false
            
            let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 300)
            targetLarge.run(move)
            targets.append(targetLarge)
            addChild(targetLarge)
        case 1:
            let targetSmall = SKSpriteNode(imageNamed: "targetSmall")
            targetSmall.position = CGPoint(x: x, y: y)
            targetSmall.name = "targetSmall"
            targetSmall.physicsBody = SKPhysicsBody(circleOfRadius: targetSmall.size.width)
            targetSmall.physicsBody?.isDynamic = false
            targetSmall.zPosition = 1
            
            let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 400)
            targetSmall.run(move)
            targets.append(targetSmall)
            addChild(targetSmall)
        case 2:
            let targetBad = SKSpriteNode(imageNamed: "target")
            targetBad.position = CGPoint(x: x, y: y)
            targetBad.name = "targetBad"
            targetBad.colorBlendFactor = 1
            targetBad.color = .green
            targetBad.physicsBody = SKPhysicsBody(circleOfRadius: targetBad.size.width)
            targetBad.physicsBody?.isDynamic = false
            
            let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 350)
            targetBad.run(move)
            targets.append(targetBad)
            addChild(targetBad)
        default:
            break
        }
    }
    
    @objc func lunchTarget() {
        let movementAmount: CGFloat = 1500
        switch GKRandomSource.sharedRandom().nextInt(upperBound: 3) {
        case 0:
            //first row - right to left
            createTarget(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 500)
        case 1:
            //second row - left to right
            createTarget(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 375)
        case 2:
            //third row - right to left
            createTarget(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 250)
        default:
            break
        }
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let targetsAtPoint = nodes(at: location)
        
        for node in targetsAtPoint {
            if node is SKSpriteNode {
                let target = node as! SKSpriteNode
                switch target.name {
                case "targetLarge":
                    score += 50
                    explode(target)
                case "targetSmall":
                    score += 100
                    explode(target)
                case "targetBad":
                    score -= 500
                    explode(target)
                default:
                    break
                }
            }
        }
        
    }
    
    func explode(_ target: SKSpriteNode) {
        let emitter = SKEmitterNode(fileNamed: "explode")!
        emitter.position = target.position
        addChild(emitter)

        target.removeFromParent()
        
        removeBullet()
    }
    
    func showBullets() {
        if numberOfBullets > 0 {
            for i in 1 ... numberOfBullets {
                let bulletImage = SKSpriteNode(imageNamed: "bullet")
                bulletImage.position = CGPoint(x: 900 + (i * 50), y: 70)
                bulletImage.colorBlendFactor = 1
                bulletImage.color = .black
                bullets.append(bulletImage)
                addChild(bulletImage)
            }
        }
    }
    func removeBullet() {
        let index = numberOfBullets - 1
        if index >= 0 {
            bullets[index].removeFromParent()
            bullets.remove(at: index)
            numberOfBullets -= 1
            if index == 0 {
                reloadImage()
            }
        }
    }
    
    @objc func gameIsOver() {
//        gameOverImg = SKSpriteNode(imageNamed: "gameOver")
        gameOverImg.name = "gameOver"
        gameOverImg.position = CGPoint(x: 667, y: 375)
        gameOverImg.zPosition = 2
        addChild(gameOverImg)
        //stop the game
        gameTimer.invalidate()
        gameOver.invalidate()
        for target in targets {
            target.removeFromParent()
        }
        for _ in 0 ... numberOfBullets {
            removeBullet()
        }
        saveHighScore()
    }
    func checkBullets() -> Bool {
        if numberOfBullets <= 0 {
            return false
        } else {
            return true
        }
        
    }
    func reloadImage() {
        reloadImg = SKSpriteNode(imageNamed: "reload")
        reloadImg.name = "reload"
        reloadImg.zPosition = 2
        reloadImg.position = CGPoint(x: 1050, y: 70)
        addChild(reloadImg)
    }
    func reloadBullets() {
        numberOfBullets = 6
        showBullets()
    }

    func checkReload(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if node is SKSpriteNode {
                let reload = node as! SKSpriteNode
                if reload.name == "reload" {
                    reloadImg.removeFromParent()
                    reloadBullets()
                    if gameOverImg.name == "gameOver" {
                        gameOverImg.removeFromParent()
                        gameOverImg.name = "newGame"
                        startGame()
                        score = 0
                        highScoreLabel.text = "Highscore: \(highScore)"
                        gameOverImg.removeAllChildren()
                    }
                }
            }
        }
    }
    
    func loadHighScore() -> Int {
        
        let defaults = UserDefaults.standard
        if let highScr = defaults.object(forKey: "highScore") as? Int {
            return highScr
        } else {
            return 0
        }
    }
    
    func saveHighScore() {
        if highScore < score {
            highScore = score
        }
        
        let defaults = UserDefaults.standard
        defaults.set(highScore, forKey: "highScore")
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }

}
