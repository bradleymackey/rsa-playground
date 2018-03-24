//
//  CharacterSprite.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 23/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit

/// an emoji character within the interactive scene
public final class CharacterSprite: SKLabelNode {
	
	/// the possible states that a character can be in
	public enum State {
		case waiting
		case acting
		case success
		case fail
	}
	
	// MARK: - Properties
	
	/// the state that the character is currently in
	/// - note: we are initially waiting
	public var currentState = State.waiting
    /// the name of the character
    public let characterName:String
	/// the expression the character gives when waiting
	private let waiting:String
	/// the expression the character gives when encrypting a message or reading
	private let acting:String
	/// the expression after a success event
	private let success:String
	/// the expression after a fail event
	private let fail:String
	
	private var textForCurrentState:String {
		switch self.currentState {
		case .waiting:
			return self.waiting
		case .acting:
			return self.acting
		case .success:
			return self.success
		case .fail:
			return self.fail
		}
	}
	
	// MARK: - Setup
	
    public init(characterName:String, waiting:String, acting:String, success:String, fail:String) {
        self.characterName = characterName
		self.waiting = waiting
		self.acting = acting
		self.success = success
		self.fail = fail
		super.init() // font does not matter, we are using emoji
		self.setup()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Methods
    
    private func setup() {
        self.text = self.waiting // we are initially waiting
        self.setupLabelProperties()
        self.physicsBody = CharacterSprite.physicsBody(ofRadius: self.frame.size.width/2)
        self.addNameAboveCharacter()
        self.startToCycle()
    }
	
    private class func physicsBody(ofRadius radius:CGFloat) -> SKPhysicsBody {
		let body = SKPhysicsBody(circleOfRadius: radius)
        body.categoryBitMask = PhysicsCategory.character
        body.contactTestBitMask = PhysicsCategory.none
        body.collisionBitMask = PhysicsCategory.all
        body.allowsRotation = false
        body.pinned = true // the character is fixed to the canvas
        return body
	}
    
    private func addNameAboveCharacter() {
        let nameLabel = SKLabelNode(fontNamed: "SanFranciscoText-Regular")
        nameLabel.text = self.characterName
        nameLabel.fontSize = 17
        nameLabel.fontColor = .black
        nameLabel.position = CGPoint(x: 0, y: 60)
        nameLabel.horizontalAlignmentMode = .center
        nameLabel.verticalAlignmentMode = .center
        self.addChild(nameLabel)
    }
	
	/// sets up properties of the label
	private func setupLabelProperties() {
		self.fontSize = 90
		self.horizontalAlignmentMode = .center
		self.verticalAlignmentMode = .center
	}
	
	public func setState(to state:State) {
		self.currentState = state
		self.text = self.textForCurrentState
	}
    
    private func startToCycle() {
        let waitingAction = SKAction.customAction(withDuration: 0) { (_, _) in
            self.text = self.waiting
        }
        let actingAction = SKAction.customAction(withDuration: 0) { (_, _) in
            self.text = self.acting
        }
        let successAction = SKAction.customAction(withDuration: 0) { (_, _) in
            self.text = self.success
        }
        let failAction = SKAction.customAction(withDuration: 0) { (_, _) in
            self.text = self.fail
        }
        let wait = SKAction.wait(forDuration: 0.2)
        let seq = SKAction.sequence([waitingAction,wait,actingAction,wait,successAction,wait,failAction,wait])
        let forever = SKAction.repeatForever(seq)
        self.run(forever)
    }
	
}
