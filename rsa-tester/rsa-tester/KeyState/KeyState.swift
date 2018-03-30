//
//  GameStates.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

/// possible states that a key can be in
public class KeyState: GKState {
	
	// MARK: - Statics
	
	public static let pickupKeySound = SKAction.playSoundFileNamed("pickup.caf", waitForCompletion: false)
	public static let dropKeySound = SKAction.playSoundFileNamed("drop.caf", waitForCompletion: false)
	
	// MARK: - Properties
	
	/// unowned key as it is always present, but we do not want a reference cycle
	public unowned let key: KeySprite
	
	/// the point that we stop moving the key at, to allow the key to calculate a correct 'fling'
	public var stopMovingPoint:CGPoint?
	
	// MARK: - Lifecycle
	
	required public init(key: KeySprite) {
		self.key = key
	}
	
	// MARK: - Methods
	
	public func fadeKeyDown(to alpha:CGFloat, time:TimeInterval) {
		let fadeDown = SKAction.fadeAlpha(to: alpha, duration: time)
		key.run(fadeDown, withKey: "fadeDown")
	}
	
	public func fadeKeyUp(time:TimeInterval) {
		let fadeUp = SKAction.fadeIn(withDuration: time)
		key.run(fadeUp, withKey: "fadeUp")
	}
	
}
