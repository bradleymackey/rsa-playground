//
//  InteractiveScene.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 22/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

/*
PEOPLE SOUNDS:
https://freesound.org/people/marcello777
https://freesound.org/people/AderuMoro
*/

import Foundation
import SpriteKit
import GameplayKit

/// the interactive scene used to display the real scenario
/// - note: the aim of this scene is to give the user a real understanding of RSA and how it is really used
public final class InteractiveScene: RSAScene  {
    
    public enum SceneCharacters: String {
        case alice = "aliceCharacter"
        case bob = "bobCharacter"
        case eve = "eveCharacter"
    }
	
	// MARK: - Properties
	
	// MARK: Constants
    
    public static var fadedDown:CGFloat = 0.25
    public static var fadeTime:TimeInterval = 0.2
    public static var invalidPulseTime:TimeInterval = 0.2
    public static var cubeChangeTime:TimeInterval = 0.5
    
    public static var aliceMessage = "Hi Bob! How are you doing? Nice weather we're having."
    public static var bobMessage = "Hi Alice! I'm great. It's cool that our we can chat in private!"
    public static var eveMessage = "Don't mind me, I'm just trying to EVEsdrop. Haha. Get it guys?"
	
	public static var aliceCharacterDetails = CharacterSprite(characterName: "Alice", waiting: "💁🏽‍♀️", inRange: "👩🏽‍💻", success: "🙆🏽‍♀️", fail: "🤦🏽‍♀️")
	public static var bobCharacterDetails = CharacterSprite(characterName: "Bob", waiting: "💁🏼‍♂️", inRange: "👨🏼‍💻", success: "🙆🏼‍♂️", fail: "🤦🏼‍♂️")
	public static var eveCharacterDetails = CharacterSprite(characterName: "Eve", waiting: "💁🏻‍♀️", inRange: "👩🏻‍💻", success: "🙆🏻‍♀️", fail: "🤦🏻‍♀️")
	
	// MARK: Instance Variables
	
	public static var paperScene = Message3DScene(message: InteractiveScene.aliceMessage)

	private lazy var encryptSound = SKAction.playSoundFileNamed("encrypt.caf", waitForCompletion: false)
	private lazy var decryptSound = SKAction.playSoundFileNamed("decrypt.caf", waitForCompletion: false)
	private lazy var failSound = SKAction.playSoundFileNamed("fail.caf", waitForCompletion: false)

    /// for fading items up that come into focus
	/// - note: to be used within state machines
    public static let fadeUp:SKAction = {
        let action = SKAction.fadeAlpha(to: 1, duration: InteractiveScene.fadeTime)
        action.timingMode = .easeOut
        return action
    }()
    
    /// for fading items down that lose focus
	/// - note: to be used within state machines
    public static let fadeDown:SKAction = {
        let action = SKAction.fadeAlpha(to: InteractiveScene.fadedDown, duration: InteractiveScene.fadeTime)
        action.timingMode = .easeOut
        return action
    }()
	
	private lazy var messageNode:Message3DNode = {
		let sceneSize = CGSize(width: 140, height: 140)
		let sceneNode = Message3DNode(viewportSize: sceneSize, messageScene: InteractiveScene.paperScene)
		sceneNode.position = CGPoint(x: aliceCharacter.position.x, y: aliceCharacter.position.y + 140)
		sceneNode.name = "messageNode"
		return sceneNode
	}()
	
	private lazy var aliceCharacter:CharacterSprite = {
        let alice = InteractiveScene.aliceCharacterDetails
		alice.name = "aliceCharacter"
        alice.position = CGPoint(x: self.size.width/4, y: 40)
		return alice
	}()
	
	private lazy var bobCharacter:CharacterSprite = {
        let bob = InteractiveScene.bobCharacterDetails
		bob.name = "bobCharacter"
        bob.position = CGPoint(x: 3*self.size.width/4, y: 40)
		return bob
	}()
	
	private lazy var eveCharacter:CharacterSprite = {
        let eve = InteractiveScene.eveCharacterDetails
		eve.name = "eveCharacter"
        eve.position = CGPoint(x: 2*self.size.width/4, y: 3*self.size.height/4)
		return eve
	}()
	
	private lazy var alicePublicKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.publicColor, owner: .alice, type: .`public`, size: 45)
		keySprite.name = "alicePublicKeyNode"
		keySprite.position = CGPoint(x: (self.size.width/2)-40, y: (self.size.height/5)+10)
		keySprite.stateMachine = InteractiveScene.keyMachine(key: keySprite)
		return keySprite
	}()
	
	private lazy var alicePrivateKeyNode:KeySprite = {
        let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.privateColor, owner: .alice, type: .`private`, size: 45)
		keySprite.name = "alicePrivateKeyNode"
		keySprite.position = CGPoint(x: self.size.width/9, y: self.size.height/5)
		keySprite.stateMachine = InteractiveScene.keyMachine(key: keySprite)
		return keySprite
	}()
	
	private lazy var bobPublicKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.publicColor, owner: .bob, type: .`public`, size: 45)
		keySprite.name = "bobPublicKeyNode"
		keySprite.position = CGPoint(x: (self.size.width/2)+40, y: (self.size.height/5)+10)
		keySprite.stateMachine = InteractiveScene.keyMachine(key: keySprite)
		return keySprite
	}()
	
	private lazy var bobPrivateKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.privateColor, owner: .bob, type: .`private`, size: 45)
		keySprite.name = "bobPrivateKeyNode"
		keySprite.position = CGPoint(x: 8*self.size.width/9, y: self.size.height/5)
		keySprite.stateMachine = InteractiveScene.keyMachine(key: keySprite)
		return keySprite
	}()
    
    private lazy var alicePublicLabel:SKLabelNode = {
        let label = InteractiveScene.keyLabel(text: "Alice")
        self.updatePosition(forNode: label, aboveNode: alicePublicKeyNode)
		self.alicePublicKeyNode.stateMachine.state(forClass: KeyInactiveState.self)?.label = label
        return label
    }()
    
    private lazy var alicePrivateLabel:SKLabelNode = {
        let label = InteractiveScene.keyLabel(text: "Alice")
        self.updatePosition(forNode: label, aboveNode: alicePrivateKeyNode)
		self.alicePrivateKeyNode.stateMachine.state(forClass: KeyInactiveState.self)?.label = label
        return label
    }()
    
    private lazy var bobPublicLabel:SKLabelNode = {
        let label = InteractiveScene.keyLabel(text: "Bob")
		self.updatePosition(forNode: label, aboveNode: bobPublicKeyNode)
		self.bobPublicKeyNode.stateMachine.state(forClass: KeyInactiveState.self)?.label = label
        return label
    }()
    
    private lazy var bobPrivateLabel:SKLabelNode = {
        let label = InteractiveScene.keyLabel(text: "Bob")
		self.updatePosition(forNode: label, aboveNode: bobPrivateKeyNode)
		self.bobPrivateKeyNode.stateMachine.state(forClass: KeyInactiveState.self)?.label = label
        return label
    }()
	
	private lazy var messageLabel:SKLabelNode = {
		let label = InteractiveScene.keyLabel(text: "Alice's Message")
		label.fontSize = 12
		label.numberOfLines = 2
		label.lineBreakMode = .byWordWrapping
		self.updatePosition(forNode: label, aboveNode: messageNode, by: 60.0)
		return label
	}()
    
    private lazy var aliceCage:CageSprite = {
        let cageSize = CGSize(width: alicePrivateKeyNode.size.width+50, height: alicePrivateKeyNode.size.height+50)
        let cage = CageSprite(size: cageSize)
        return cage
    }()
    
    private lazy var bobCage:CageSprite = {
        let cageSize = CGSize(width: bobPrivateKeyNode.size.width+50, height: bobPrivateKeyNode.size.height+50)
        let cage = CageSprite(size: cageSize)
        return cage
    }()
    
    /// convenience property to get all characters
    private lazy var allCharacters:[CharacterSprite] = {
        return [aliceCharacter, bobCharacter, eveCharacter]
    }()
    
    /// convenience property to get all keys
    public override var allKeys:[KeySprite] {
        return [alicePublicKeyNode, alicePrivateKeyNode, bobPublicKeyNode, bobPrivateKeyNode]
	}
    
    private lazy var keyToKeyLabel:[KeySprite:SKLabelNode] = {
        return [alicePublicKeyNode:alicePublicLabel, alicePrivateKeyNode:alicePrivateLabel, bobPublicKeyNode:bobPublicLabel, bobPrivateKeyNode:bobPrivateLabel]
    }()
	
	// MARK: Tracking variables
    
    /// the character that is currently in range of the message
    private weak var characterInRange:CharacterSprite?
	/// the label that says whos message this was before it gets locked
	private var previousLockedMessage:String?
	/// keeps track of if no characters are currently focused (for efficiency)
	private var noCharactersFocused = false
	/// keeps track of if no keys are currently focused (for efficiency)
	private var noKeysFocused = false

	
	// MARK: - Setup
	
	public override func sceneDidLoad() {
		super.sceneDidLoad()
		self.backgroundColor = .white
        self.addNodesToScene()
		// focus on alice, our first character
		self.setCharacterFocusIfNeeded(character: self.aliceCharacter)
	}
    
    private func addNodesToScene() {
        // characters
        for character in allCharacters {
            self.addChild(character)
        }
        // the 3d message
        self.addChild(messageNode)
		self.addChild(messageLabel)
        // keys and labels
        for (key,keyLabel) in keyToKeyLabel {
            // add the key before the label so it can be positioned above it
            self.addChild(key)
            self.addChild(keyLabel)
        }
		
		let point = CGPoint(x: self.size.width/9, y: self.size.height)
        let aliceRope = ChainSprite(attachmentPoint: point, attachedElement: self.aliceCage, length: 65)
        aliceRope.addChainElementsToScene(self)
		let otherPoint = CGPoint(x: 8*self.size.width/9, y: self.size.height)
		let bobRope = ChainSprite(attachmentPoint: otherPoint, attachedElement: self.bobCage, length: 65)
        bobRope.addChainElementsToScene(self)
    }
	
	// MARK: - Methods
    
    private class func keyLabel(text:String) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Courier")
        label.text = text
        label.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.fontSize = 12
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        return label
    }
	

	/// machine for public key, where the key is not caged, but just made inactive
	private class func keyMachine(key: KeySprite) -> GKStateMachine {
		let machine = GKStateMachine(states: [KeyDragState(key: key),
											  KeyWaitState(key: key),
											  KeyInactiveState(key: key)])
		machine.enter(KeyInactiveState.self)
		return machine
	}
	
	override public func touchDown(atPoint point: CGPoint) {
		super.touchDown(atPoint: point)
        // get the node that we have just touched
        let node = self.atPoint(point)
        // ensure that the node has a name
        guard let nodeName = node.name else { return }
		// start moving message node
		if nodeName == "messageNode" {
			self.messageNode.stateMachine.state(forClass: MessageDraggingState.self)?.startMovingPoint = point
			self.messageNode.stateMachine.enter(MessageDraggingState.self)
		}
		// start moving the key node once we set the start point
		if nodeName.contains("KeyNode") {
			guard let keyNode = node as? KeySprite else { return }
			keyNode.stateMachine.state(forClass: KeyDragState.self)?.startMovingPoint = point
			keyNode.stateMachine.enter(KeyDragState.self)
		}
	}
	
	override public func touchMoved(toPoint point: CGPoint) {
		super.touchMoved(toPoint: point)
	}
	
	override public func touchUp(atPoint point: CGPoint) {
		super.touchUp(atPoint: point)
		// mark that all moveables are no longer being moved by the user
		self.stopKeysMovingIfNeeded(at: point)
		self.messageNode.stopMoving()
	}
	
	public override func bodyContact(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody) {
		super.bodyContact(firstBody: firstBody, secondBody: secondBody)
        // we only care about contact when the second item is the box
        guard secondBody.categoryBitMask == PhysicsCategory.box else { return }
        // determine which item collided with the box
        switch firstBody.categoryBitMask {
        case PhysicsCategory.publicKeyA:
			guard let state = alicePublicKeyNode.stateMachine.currentState, state.isKind(of: KeyDragState.self) else { return }
			self.publicKeyContact(keyOwner: .alice)
        case PhysicsCategory.privateKeyA:
			guard let state = alicePrivateKeyNode.stateMachine.currentState, state.isKind(of: KeyDragState.self) else { return }
            self.privateKeyContact(keyOwner: .alice)
        case PhysicsCategory.publicKeyB:
			guard let state = bobPublicKeyNode.stateMachine.currentState, state.isKind(of: KeyDragState.self) else { return }
            self.publicKeyContact(keyOwner: .bob)
        case PhysicsCategory.privateKeyB:
			guard let state = bobPrivateKeyNode.stateMachine.currentState, state.isKind(of: KeyDragState.self) else { return }
            self.privateKeyContact(keyOwner: .bob)
        default:
            return
        }
	}
    
    private func publicKeyContact(keyOwner: KeyOwner) {
		guard let state = sceneStateMachine.currentState, state.isKind(of: SceneWaitState.self) else { return }
		sceneStateMachine.enter(SceneAnimatingState.self)
        switch (InteractiveScene.paperScene.paperState) {
        case .unencrypted:
            // mark who has encrypted this
            InteractiveScene.paperScene.encryptedBy = keyOwner
            // mark the new state
            InteractiveScene.paperScene.paperState = .encrypted
            // perform the maths animation if enabled, otherwise just morph
            InteractiveScene.paperScene.morphToCrypto(duration: InteractiveScene.cubeChangeTime)
            // inform that we are no longer animating after the animation when we are not using maths animations
            DispatchQueue.main.asyncAfter(deadline: .now() + InteractiveScene.cubeChangeTime) {
                self.sceneStateMachine.enter(SceneWaitState.self)
            }
			// the character success animation
            self.characterInRange?.successAnimation()
			// update the label above the message
			if let messageText = self.messageLabel.text {
				let lockedMessage = keyOwner == .alice ? aliceCharacter.lockedByMessage : bobCharacter.lockedByMessage
				self.messageLabel.text = messageText + "\n" + lockedMessage
				// the previous message before we lock the message
				self.previousLockedMessage = messageText
			}
			// play the ecnrypt sound
			self.messageNode.run(encryptSound)
        case .encrypted:
            // do the question mark animation
            self.invalidContactAnimation(forState: .encrypted)
            self.characterInRange?.failAnimation()
			// play the fail sound
			self.messageNode.run(failSound)
        }
    }
    
    private func privateKeyContact(keyOwner: KeyOwner) {
		guard let state = sceneStateMachine.currentState, state.isKind(of: SceneWaitState.self) else { return }
		sceneStateMachine.enter(SceneAnimatingState.self)
        switch (InteractiveScene.paperScene.paperState) {
        case .unencrypted:
            // do the question mark animation
            self.invalidContactAnimation(forState: .unencrypted)
            self.characterInRange?.failAnimation()
			// play the fail sound
			self.messageNode.run(failSound)
        case .encrypted:
            // the decryptor key must be owned by same as encryptor
            guard let encryptor = InteractiveScene.paperScene.encryptedBy, keyOwner == encryptor else {
                self.invalidContactAnimation(forState: .encrypted)
                self.characterInRange?.failAnimation()
				// play the fail sound
				self.messageNode.run(failSound)
                return
            }
            // mark the new state
            InteractiveScene.paperScene.paperState = .unencrypted
            // perform the maths animation if enabled, otherwise just morph
            InteractiveScene.paperScene.morphToPaper(duration: InteractiveScene.cubeChangeTime)
            // inform that we are no longer animating after the animation when we are not using maths animations
            DispatchQueue.main.asyncAfter(deadline: .now() + InteractiveScene.cubeChangeTime) {
                self.sceneStateMachine.enter(SceneWaitState.self)
            }
            self.characterInRange?.successAnimation()
			// set the label above the message back to before it was encrypted
			if let message = self.previousLockedMessage {
				self.messageLabel.text = message
			}
			// play the decrypt sound
			self.messageNode.run(decryptSound)
        }
    }

    /// the animation that should run when the incorrect key is brought to the box
	/// - important:  this function should be called with `currentlyAnimating` already set to `true`
    private func invalidContactAnimation(forState state:Message3DScene.PaperState) {
        let wait = SKAction.wait(forDuration: IntroScene.invalidPulseTime)
        let questionMark = SKAction.customAction(withDuration: 0) { _, _ in
            InteractiveScene.paperScene.morphToQuestionMark(duration: IntroScene.invalidPulseTime)
        }
        let backToPaper = SKAction.customAction(withDuration: 0) { _, _ in
            state == .encrypted ? InteractiveScene.paperScene.morphToCrypto(duration: InteractiveScene.invalidPulseTime) : InteractiveScene.paperScene.morphToPaper(duration: IntroScene.invalidPulseTime)
        }
        let notAnimating = SKAction.customAction(withDuration: 0) { _, _ in
            self.sceneStateMachine.enter(SceneWaitState.self)
        }
        let invalidContactSequence = SKAction.sequence([questionMark,wait,backToPaper,wait,notAnimating])
        self.messageNode.run(invalidContactSequence)
    }
    
    public override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        // update caged key positions if needed
        // position key labels above the keys
        for (key,keyLabel) in keyToKeyLabel {
            if let cage = key.insideCage, key.animationInCage {
                key.position = CGPoint(x: cage.position.x, y: cage.position.y-10)
            }
            updatePosition(forNode: keyLabel, aboveNode: key)
        }
		updatePosition(forNode: messageLabel, aboveNode: messageNode, by: 60.0)
        // update finger position or exit
        guard let point = currentFingerPosition else { return }
        // determine which character is in range of message
        self.determineCharacterInRangeOfMessage()
        // ignore movement if position is outside scene
        if RSAScene.insideEdgeMargin(scene: self, point: point) {
            // stop moving keys or message node if the touch is outside the margin
            self.stopKeysMovingIfNeeded(at: point)
			self.messageNode.stateMachine.enter(MessageWaitingState.self)
        } else {
			for key in allKeys {
				if let state = key.stateMachine.currentState, state.isKind(of: KeyDragState.self) {
					key.updatePosition(to: point)
				}
			}
			if let state = self.messageNode.stateMachine.currentState, state.isKind(of: MessageDraggingState.self) {
				self.messageNode.updatePosition(to: point)
			}
        }
    }
	
	/// updates the position of one node above another
	private func updatePosition(forNode node:SKNode, aboveNode mainNode:SKNode, by amount:CGFloat=30.0) {
        node.position = CGPoint(x: mainNode.position.x, y: mainNode.position.y + amount)
    }
    
    private func determineCharacterInRangeOfMessage() {
        // calculate message position to each character
        for char in allCharacters {
            // use pythagoras to get distance to message
            let x = messageNode.position.x - char.position.x
            let y = messageNode.position.y - char.position.y
            let dist = sqrt(x*x + y*y)
            if dist < 170 {
                self.setCharacterFocusIfNeeded(character: char)
                // exit after this
                return
            }
        }
        // we are not near a character, set none in focus
        self.setNoCharacterFocusIfNeeded()
        self.setNoKeyFocusIfNeeded()
    }
    
    /// sets the focus on a single character, and focuses the possible keys that can be used by them
    private func setCharacterFocusIfNeeded(character:CharacterSprite) {
        guard let nodeName = character.name else { return }
        if let existingFocus = characterInRange {
            guard let existingName = existingFocus.name else { return }
			// only focus on this new character if we are not already focused on them
            guard existingName != nodeName else { return }
        }
        guard let characterType = SceneCharacters(rawValue: nodeName) else { return }
		if InteractiveScene.paperScene.paperState == .unencrypted {
			// update the message shown on the paper (if unencrypted)
			InteractiveScene.paperScene.updateMessageIfUnencrypted(toPerson: characterType)
			// update the text above the message if unencrypted
			self.messageLabel.text = character.labelForMessage
		}
        // set the correct focus on the character and keys
        switch characterType {
        case .alice:
            self.focus(character: aliceCharacter, defocus: [bobCharacter, eveCharacter])
            self.focus(keys: [alicePublicKeyNode, alicePrivateKeyNode, bobPublicKeyNode], defocus: [bobPrivateKeyNode])
        case .bob:
            self.focus(character: bobCharacter, defocus: [aliceCharacter, eveCharacter])
            self.focus(keys: [alicePublicKeyNode, bobPrivateKeyNode, bobPublicKeyNode], defocus: [alicePrivateKeyNode])
        case .eve:
            self.focus(character: eveCharacter, defocus: [aliceCharacter, bobCharacter])
            self.focus(keys: [alicePublicKeyNode, bobPublicKeyNode], defocus: [alicePrivateKeyNode, bobPrivateKeyNode])
        }
    }
    
    private func focus(character:CharacterSprite, defocus:[CharacterSprite]) {
		self.noCharactersFocused = false // we are now focused on a character
        self.characterInRange = character
        character.stateMachine.enter(CharacterInRangeState.self)
        for other in defocus {
			other.stateMachine.enter(CharacterWaitingInactiveState.self)
        }
    }
    
    private func focus(keys:[KeySprite], defocus:[KeySprite]) {
		self.noKeysFocused = false // we are now focused on a certain key
        for key in keys {
			key.stateMachine.enter(KeyWaitState.self)
            self.removeKeyFromCageIfNeeded(key: key)
        }
        for key in defocus {
			key.stateMachine.enter(KeyInactiveState.self)
            self.putKeyInsideCorrectCageIfNeeded(key: key)
        }
    }
    
    private func setNoCharacterFocusIfNeeded() {
		// check that we are not already defocused from all characters (for efficiency)
		guard !self.noCharactersFocused else { return }
		self.noCharactersFocused = true // we are now not focused on a character
        // set our local variable to be nil
        self.characterInRange = nil
        // no characters in range, set all waiting with full alpha
        for character in allCharacters {
			character.stateMachine.enter(CharacterWaitingState.self)
        }
    }
    
    private func setNoKeyFocusIfNeeded() {
		// check that we are not already defocused from all keys (for efficiency)
		guard !self.noKeysFocused else { return }
		self.noKeysFocused = true
		// defocus all the keys if we need to
        for key in allKeys {
			key.stateMachine.enter(KeyInactiveState.self)
            // put the private keys in a cage
            self.putKeyInsideCorrectCageIfNeeded(key: key)
        }
    }
    
    private func putKeyInsideCorrectCageIfNeeded(key:KeySprite) {
        if key === alicePrivateKeyNode {
            self.putInsideCage(key: key, cage: self.aliceCage)
        } else if key === bobPrivateKeyNode {
            self.putInsideCage(key: key, cage: self.bobCage)
        }
    }
	
    private func putInsideCage(key:KeySprite, cage:CageSprite) {
        guard key.insideCage == nil else { return }
        key.insideCage = cage
        key.animationInCage = false
        key.removeAction(forKey: "removingFromCage")
        key.removeAction(forKey: "puttingInCage")
        key.physicsBody?.isDynamic = false
        key.physicsBody?.collisionBitMask = PhysicsCategory.all ^ (PhysicsCategory.box | PhysicsCategory.chainLink)
        let moveToCage = SKAction.move(to: cage.position, duration: 0.3)
        moveToCage.timingMode = .easeOut
        let confirmInCage = SKAction.customAction(withDuration: 0) { (_, _) in
            key.animationInCage = true
        }
        let moveSequence = SKAction.sequence([moveToCage,confirmInCage])
        key.run(moveSequence, withKey: "puttingInCage")
    }
    
    private func removeKeyFromCageIfNeeded(key:KeySprite) {
        guard let _ = key.insideCage else { return }
        key.insideCage = nil
        key.animationInCage = false
        key.removeAction(forKey: "puttingInCage")
        key.removeAction(forKey: "removingFromCage")
        key.physicsBody?.isDynamic = true
        let enableFullCollisions = SKAction.customAction(withDuration: 0) { (_, _) in
            // ensure that when the block is run we are still outside of the cage
            guard key.insideCage == nil else { return }
            key.physicsBody?.collisionBitMask = PhysicsCategory.all ^ (PhysicsCategory.box)
        }
        key.run(enableFullCollisions, withKey: "removingFromCage")
    }
}
