//
//  GameScene.swift
//  ETGame
//
//  Created by Adoofy on 2015/8/13.
//  Copyright (c) 2015年 irean's ios. All rights reserved.
//

import SpriteKit
enum BodyType: UInt32 {
    case player = 1
    case enemy = 2
    case ground = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "et_planet")
    
    var gameOver = false
    let endLabel = SKLabelNode(text: "GameOver")
    let endLabel2 = SKLabelNode(text: "Tap to restart!")
    let touchToBeginLabel = SKLabelNode(text: "Touch to begin!")
    let points = SKLabelNode(text: "0")
    var numPoints = 0
    
    override func didMoveToView(view: SKView) {
        setupLabels()
        // start et location
        player.position = CGPoint(x: frame.size.width * 0.1, y: frame.size.height * 0.5)
        addChild(player)

        physicsBody?.categoryBitMask = BodyType.ground.rawValue
        
        let collisionFrame = CGRectInset(frame, 0,  -self.size.height * 0.02)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: collisionFrame)
        // 上面兩行為主人翁活動範圍，避免消失在螢幕中
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.frame.size.width * 0.3)
        player.physicsBody?.allowsRotation = false
        // 下面spirite做連接
        player.physicsBody?.categoryBitMask = BodyType.player.rawValue
        player.physicsBody?.contactTestBitMask = BodyType.enemy.rawValue
        player.physicsBody?.collisionBitMask = BodyType.ground.rawValue
        // 主人翁在點擊前不動
        player.physicsBody?.dynamic = false
        // physic body（兩個物體碰撞） use our method
        physicsWorld.contactDelegate = self
    }
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    func makeEnemy() {
        let enemy = SKSpriteNode(imageNamed: "fire_planet-1")
        enemy.name = "enemy"
        enemy.position = CGPoint(x: frame.size.width + enemy.size.width / 2, y: frame.size.height * random(min: 0,max: 1))
        addChild(enemy)
        
        enemy.runAction(SKAction.moveByX(-size.width - enemy.size.width, y: 0.0, duration: NSTimeInterval(random(min: 1, max: 2))))
        // 敵物體碰撞大小
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width / 11)
        // 物理控制spirite
        enemy.physicsBody?.dynamic = false
        // 避免敵人受spirite物理干擾
        enemy.physicsBody?.affectedByGravity = false
        // 避免旋轉
        enemy.physicsBody?.allowsRotation = false
        // 設為之前敵人類別
        enemy.physicsBody?.categoryBitMask = BodyType.enemy.rawValue
        // 兩方接觸時提醒
        enemy.physicsBody?.contactTestBitMask = BodyType.player.rawValue
        // 接觸後不彈開＝0
        enemy.physicsBody?.collisionBitMask = 0
    }
    func jumpPlayer() {
        // 製造推力使彈跳
        let impulse = CGVector(dx: 0, dy: 365)
        player.physicsBody?.applyImpulse(impulse)
    }
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if (!gameOver) {
            if player.physicsBody?.dynamic == false {
                player.physicsBody?.dynamic = true
                touchToBeginLabel.hidden = true
                backgroundColor = SKColor.blackColor()
                
                runAction(SKAction.repeatActionForever(
                    SKAction.sequence([
                        SKAction.runBlock(makeEnemy),
                        SKAction.waitForDuration(1.0)])))
            }
            jumpPlayer()
            
        }
        else if (gameOver) {
            let newScene = GameScene(size: size)
            newScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontalWithDuration(0.65)
            view?.presentScene(newScene, transition: reveal)  
        }  
        
    }
    func didBeginContact(contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch(contactMask) {
        case BodyType.player.rawValue | BodyType.enemy.rawValue:
            let secondNode = contact.bodyB.node
            secondNode?.removeFromParent()
            endGame()
            let firstNode = contact.bodyA.node
            firstNode?.removeFromParent()
        default:
            return
        }
    }

    func setupLabels() {
        
        touchToBeginLabel.position = CGPoint(x: frame.size.width/2, y: frame.size.height / 2)
        touchToBeginLabel.fontColor = UIColor.whiteColor()
        touchToBeginLabel.fontSize = 50
        addChild(touchToBeginLabel)
        
        points.position = CGPoint(x: frame.size.width / 2, y: frame.size.height * 0.2)
        points.fontColor = UIColor.whiteColor()
        points.fontSize = 100
        addChild(points)
    }
    override func update(currentTime: CFTimeInterval) {
        
        if !gameOver {
            if player.position.y <= 0 {
                endGame()
            }
            enumerateChildNodesWithName("enemy") {
                enemy, _ in
                if enemy.position.x <= 0 {
                    self.updateEnemy(enemy)  
                }  
            }  
        }  
    }
    func updateEnemy(enemy: SKNode) {
        
        if enemy.position.x < 0 {
            enemy.removeFromParent()
            numPoints++
            points.text = "\(numPoints)" }
    }
    func endGame() {
        gameOver = true
        removeAllActions()
        endLabel.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        endLabel.fontColor = UIColor.whiteColor()
        endLabel.fontSize = 80
        endLabel2.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2 + endLabel.fontSize)
        endLabel2.fontColor = UIColor.yellowColor()
        endLabel2.fontSize = 40
        points.fontColor = UIColor.whiteColor()
        addChild(endLabel)  
        addChild(endLabel2)  
    }
}


