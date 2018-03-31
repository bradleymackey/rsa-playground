//
//  PaperEncryptedState.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 31/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

public final class PaperEncryptedState: PaperState {
	
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		return stateClass is PaperErrorState.Type || stateClass is PaperNormalState.Type
	}
	
}
