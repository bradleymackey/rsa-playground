//
//  DraggingKey.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit

public final class KeyDragState: KeyState {
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		// if we were previously waiting, play the key pickup sound
		if let state = previousState, state.isKind(of: KeyWaitState.self) {
			self.key.run(self.pickupKeySound, withKey: "pickupKeySound")
		}
	}
	
	public override func willExit(to nextState: GKState) {
		super.willExit(to: nextState)
	}
	
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		// we can only wait after we drag
		switch stateClass {
		case is KeyWaitState.Type:
			return true
		default:
			return false
		}
	}
	
}
