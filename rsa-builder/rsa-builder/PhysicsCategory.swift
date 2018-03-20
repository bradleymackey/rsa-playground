//
//  PhysicsCategory.swift
//  nothing
//
//  Created by Bradley Mackey on 19/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation

/// physics categories for interpreting collisions
public struct PhysicsCategory {
	// MARK: GLOBAL
	static let none:UInt32         = 0
	static let all:UInt32          = UInt32.max
	// MARK: KEYS
	static let publicKeyA:UInt32   = 1 << 0
	static let privateKeyA:UInt32  = 1 << 1
	static let publicKeyB:UInt32   = 1 << 2
	static let privateKeyB:UInt32  = 1 << 3
	static let keys:UInt32 = publicKeyA | privateKeyA | publicKeyB | privateKeyB
	// MARK: MISC
	static let box:UInt32          = 1 << 4
	static let character:UInt32    = 1 << 5
	static let boundry:UInt32      = 1 << 6
}
