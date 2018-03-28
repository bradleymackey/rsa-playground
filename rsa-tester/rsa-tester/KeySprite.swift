
//
//  KeySprite.swift
//  nothing
//
//  Created by Bradley Mackey on 19/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit

public final class KeySprite: SKSpriteNode, MoveableSprite {
	
	// MARK: Properties
	
	private let pickupKeySound = SKAction.playSoundFileNamed("pickup.caf", waitForCompletion: false)
	private let dropKeySound = SKAction.playSoundFileNamed("drop.caf", waitForCompletion: false)
	
	/// whether the user is dragging this key around or not
	public var isBeingMoved = false
	/// the previous point that the key was at
	public var lastPoint:CGPoint?
	
	/// who owns the key
	public let owner: KeyOwner
	/// what type of key is this?
	public let type: KeyType
	
	/// the size of the key
	private let keyWidth:CGFloat
	/// dimensions of the key
	private var dimensions:CGSize {
		return CGSize(width: self.keyWidth, height: self.keyWidth)
	}
	
	var publicKeyAlice:Bool {
		return owner == .alice && type == .`public`
	}
	
	var publicKeyBob:Bool {
		return owner == .bob && type == .`public`
	}
	
	var privateKeyAlice:Bool {
		return owner == .alice && type == .`private`
	}
	
	var privateKeyBob:Bool {
		return owner == .bob && type == .`private`
	}
	
	var categoryMask:UInt32 {
		if publicKeyAlice {
			return PhysicsCategory.publicKeyA
		} else if publicKeyBob {
			return PhysicsCategory.publicKeyB
		} else if privateKeyAlice {
			return PhysicsCategory.privateKeyA
		} else {
			return PhysicsCategory.privateKeyB
		}
	}
    
    private lazy var cageOverlay:SKSpriteNode = {
        let cage = SKSpriteNode(imageNamed: "cage.png")
        cage.size = CGSize(width: keyWidth+50, height: keyWidth+50)
        cage.position = CGPoint(x: 0, y: 10)
        cage.zRotation = -0.1
        cage.alpha = 0
        return cage
    }()
    
    private var insideCage = false
	
	// MARK: Lifecycle
	
    public init(texture: SKTexture, color: UIColor, owner: KeyOwner, type: KeyType, size:CGFloat) {
		self.owner = owner
		self.type = type
        self.keyWidth = size
		super.init(texture: texture, color: color, size: self.dimensions)
		// setup the sprite
		self.physicsBody = self.physicsBody(texture: texture, mask: categoryMask)
		self.colorBlendFactor = 1
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Methods
	
	public class func textureForKey() -> SKTexture {
		guard let path = Bundle.main.path(forResource: "key", ofType: "png") else {
			fatalError("ERROR: could not find key texture")
		}
		guard let data = FileManager.default.contents(atPath: path) else {
			fatalError("ERROR: could not load key texture")
		}
		guard let image = UIImage(data: data) else {
			fatalError("ERROR: could not interpret key texture image")
		}
		let texture = SKTexture(image: image)
		return texture
	}
	
	private func physicsBody(texture:SKTexture,mask:UInt32) -> SKPhysicsBody {
		let body = SKPhysicsBody(texture: texture, size: self.dimensions)
		body.categoryBitMask = mask // assign correct category for this specific key
		body.affectedByGravity = true
		body.collisionBitMask = PhysicsCategory.all ^ (PhysicsCategory.box|PhysicsCategory.chainLink) // collide with all but box and chain link
		body.contactTestBitMask = PhysicsCategory.box
		body.allowsRotation = true
		body.restitution = 0.15
		body.mass = 0.5
		return body
	}
	
	public func startMoving(initialPoint:CGPoint) {
		self.isBeingMoved = true
		self.removeAllActions()
		let moveAnimation = SKAction.move(to: initialPoint, duration: 0.04)
		self.run(moveAnimation)
		self.physicsBody?.affectedByGravity = false
		self.lastPoint = initialPoint
		// play the pickup sound
		self.run(pickupKeySound)
	}
	
	public func updatePositionIfNeeded(to point: CGPoint) {
		guard isBeingMoved else { return }
		let moveAnimation = SKAction.move(to: point, duration: 0.02)
		self.run(moveAnimation)
		self.lastPoint = point
	}
	
	public func stopMoving(at lastPoint:CGPoint) {
		defer { self.isBeingMoved = false }
		guard isBeingMoved else { return }
		self.removeAllActions()
		self.physicsBody?.affectedByGravity = true
		guard let previousPoint = self.lastPoint else { return }
		let moveX = lastPoint.x - previousPoint.x
		var moveY = lastPoint.y - previousPoint.y
		// extra y velocity to fight gravity
		if moveY > 0 { moveY *= 2 }
		let vec = CGVector(dx: moveX*25, dy: moveY*25)
		// fling the key based on the last 2 movement points
		let fling = SKAction.applyImpulse(vec, duration: 0.005)
		self.run(fling)
		// play the drop sound
		self.run(dropKeySound)
	}
    
    public func putInCage() {
        guard !insideCage else { return }
        defer {
            self.insideCage = true
        }
        self.addChild(cageOverlay)
        let fadeIn = SKAction.fadeIn(withDuration: InteractiveScene.fadeTime)
        self.cageOverlay.run(fadeIn)
    }
    
    public func hideCage() {
        guard insideCage else { return }
        defer {
            self.insideCage = false
        }
        let fadeOut = SKAction.fadeOut(withDuration: InteractiveScene.fadeTime)
        let remove = SKAction.removeFromParent()
        let hideRemoveSequence = SKAction.sequence([fadeOut,remove])
        self.cageOverlay.run(hideRemoveSequence)
    }
	
}
