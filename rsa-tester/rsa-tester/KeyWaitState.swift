//
//  KeyWaitState.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

public final class KeyWaitState: KeyState {
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		// if we were previously dragging, play the drop sound
		if let state = previousState, state.isKind(of: KeyDragState.self) {
			self.key.removeAllActions()
			self.key.run(KeyState.dropKeySound, withKey: "dropKeySound")
		}
	}
	
	public override func willExit(to nextState: GKState) {
		super.willExit(to: nextState)
	}
	
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		// we can drag, become inactive or be caged after waiting.
		switch stateClass {
		case is KeyDragState.Type, is KeyInactiveState.Type, is KeyCagedState.Type:
			return true
		default:
			return false
		}
	}
	
}
