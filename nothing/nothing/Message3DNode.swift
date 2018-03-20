//
//  Message3DNode.swift
//  nothing
//
//  Created by Bradley Mackey on 19/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

/// the spritekit node that contains the 3D scene with the message object in
public final class Message3DNode: SK3DNode {
	
	public let messageScene:Message3DScene
	
	/// if we are rotating the message cube currently
	private var isBeingRotated = false
	/// the last point that was registered during the cube rotation
	private var lastRotationPoint:CGPoint?
	
	public init(viewportSize: CGSize, messageScene: Message3DScene) {
		self.messageScene = messageScene
		super.init(viewportSize: viewportSize)
		// setup
		self.setup()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setup() {
		// the scene that should be presented by this 3D node
		self.scnScene = messageScene
		// setup physics
		self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame.insetBy(dx: 20, dy: 20))
		self.physicsBody?.categoryBitMask = PhysicsCategory.box
		self.physicsBody?.contactTestBitMask = PhysicsCategory.keys | PhysicsCategory.character
		self.physicsBody?.collisionBitMask = PhysicsCategory.box | PhysicsCategory.boundry | PhysicsCategory.character
		self.physicsBody?.affectedByGravity = false
		self.physicsBody?.allowsRotation = false // we do not allow rotation, otherwise we will get nosense looking things
		// setup camera
		let camera = SCNCamera()
		camera.usesOrthographicProjection = true
		camera.orthographicScale = 6
		let cameraNode = SCNNode()
		cameraNode.camera = camera
		if let lookAtTarget = messageScene.rootNode.childNodes.first {
			let constraint = SCNLookAtConstraint(target: lookAtTarget)
			cameraNode.constraints = [ constraint ]
		}
		self.pointOfView = cameraNode
		self.pointOfView?.position = SCNVector3(x: 0, y: 0, z: 70)
		// rotate forever
		let rotate = SCNAction.rotate(by: .pi, around: SCNVector3(x: 0, y: .pi*2, z: 0), duration: 2.1)
		let rotateForever = SCNAction.repeatForever(rotate)
		messageScene.rootNode.runAction(rotateForever)
	}
	
	public func startRotating(at point:CGPoint) {
		isBeingRotated = true
		lastRotationPoint = point
	}
	
	public func updateRotationIfNeeded(newPoint point:CGPoint) {
		guard isBeingRotated else { return }
		// rotate the paper
		if let lastPoint = lastRotationPoint {
			messageScene.rotatePaper(dx: (lastPoint.y - point.y)/80, dy: (point.x - lastPoint.x)/80)
		}
		// update the last touched point
		lastRotationPoint = point
	}
	
	public func finishedRotating() {
		guard isBeingRotated else { return }
		isBeingRotated = false
	}
	
	
}
