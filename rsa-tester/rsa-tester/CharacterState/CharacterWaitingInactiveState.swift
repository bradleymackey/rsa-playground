//
//  CharacterWaitingInactiveState.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit

/// character is inactive
public final class CharacterWaitingInactiveState: CharacterState {
	
	/// for fading items up that come into focus
	private let fadeUp:SKAction = {
		let action = SKAction.fadeAlpha(to: 1, duration: InteractiveScene.fadeTime)
		action.timingMode = .easeOut
		return action
	}()
	
	/// for fading items down that lose focus
	private let fadeDown:SKAction = {
		let action = SKAction.fadeAlpha(to: InteractiveScene.fadedDown, duration: InteractiveScene.fadeTime)
		action.timingMode = .easeOut
		return action
	}()
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		self.character.removeAllActions() // remove any prior actions that may affect the state
		self.character.run(fadeDown)
	}
	
	public override func willExit(to nextState: GKState) {
		super.willExit(to: nextState)
		self.character.removeAllActions() // remove any prior actions that may affect the state
		self.character.run(fadeUp)
	}
	
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		return stateClass is CharacterInRangeState.Type || stateClass is CharacterWaitingState.Type
	}

}
