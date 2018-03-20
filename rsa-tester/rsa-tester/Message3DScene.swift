//
//  Message3DScene.swift
//  nothing
//
//  Created by Bradley Mackey on 19/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SceneKit

fileprivate extension UIImage {
	/// generates a UIImage from a CALayer
	class func image(from layer: CALayer) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(layer.bounds.size,
											   layer.isOpaque, UIScreen.main.scale)
		defer { UIGraphicsEndImageContext() }
		// Don't proceed unless we have context
		guard let context = UIGraphicsGetCurrentContext() else {
			return nil
		}
		layer.render(in: context)
		return UIGraphicsGetImageFromCurrentImageContext()
	}
}

/// used for specifying the size of objects in the scene
fileprivate struct ObjectDimensions {
	let height:CGFloat
	let width:CGFloat
	let length:CGFloat
}

/// The 3D SceneKit scene that renders the message
public final class Message3DScene: SCNScene {
	
	public enum PaperState {
		case unencrypted
		case encrypted
	}
	
	// MARK: Constants
	public static let surfaceFontSize:CGFloat = 23
	public static var paperColors:(text:UIColor,background:UIColor) = ( #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),  #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
	public static var encryptedColors:(text:UIColor,background:UIColor) = ( #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
	
	// MARK: Properties
	
	/// the message that will appear on the 3D message
	public let message: String
	/// the current state of the paper
	public var paperState = PaperState.unencrypted
	
	/// the paper/encrypted box object
	private var paper: SCNNode!
	/// the geometry of the paper. this gets animated to change the dimensions of the box
	private var paperGeometry: SCNBox!
	/// the dimensions of the unencrypted paper
	private let paperSize = ObjectDimensions(height: 8, width: 5, length: 0.4)
	/// the dimensions of the encrypted cube
	private let cubeSize = ObjectDimensions(height: 6, width: 6, length: 6)
	/// the time of the last morph, so that we don't prematurley pulse the message
	private var lastMorph = Date(timeIntervalSince1970: 0)
	
	/// blank white material to show on sides of the paper without text
	private let whiteMaterial: SCNMaterial = {
		let material = SCNMaterial()
		material.diffuse.contents = Message3DScene.paperColors.background
		material.locksAmbientWithDiffuse = true
		return material
	}()
	
	/// the regular text surface on the unencrypted box
	private lazy var messageMaterial: SCNMaterial = {
		// create the surface image
		let paperSize = CGSize(width: 200, height: 300)
		let textColor = Message3DScene.paperColors.text
		let backgroundColor = Message3DScene.paperColors.background
		let surfaceImage = Message3DScene.renderedTextImage(message: self.message, size: paperSize, textColor: textColor, backgroundColor: backgroundColor)
		// create the material
		let textMaterial = SCNMaterial()
		textMaterial.diffuse.contents = surfaceImage
		textMaterial.locksAmbientWithDiffuse = true
		return textMaterial
	}()
	
	/// the encrypted text on the ciper block (same material all sides)
	private lazy var encryptedMaterial: SCNMaterial = {
		// create the surface image
		let encryptedMessage = "kuhit67683o aiyefgo6217tyg8£^&Rkjdnf &cisudfyg8&^ uvisudgf87t*F&%Rgiusgdfg8i g8r7r3sr2q3trdz iuishug08y9 7g&^R&^Giusid bfiyg87tgiwubfo776r 737tf^$Euhir  g97hiu87IGI &T8ugoeihrgo8h iy89ywieufiuiYGYTFI Uiusd97fiw uebiufg87ts87f wouefiuwfuyc a98y8w7egf ihoih891729347tewgdf9guiw"
		let encryptedSize = CGSize(width: 200, height: 200)
		let textColor = Message3DScene.encryptedColors.text
		let backgroundColor = Message3DScene.encryptedColors.background
		let surfaceImage = Message3DScene.renderedTextImage(message: encryptedMessage, size: encryptedSize, textColor: textColor, backgroundColor: backgroundColor)
		// create the material
		let textMaterial = SCNMaterial()
		textMaterial.diffuse.contents = surfaceImage
		textMaterial.locksAmbientWithDiffuse = true
		return textMaterial
	}()
	
	// MARK: Lifecycle
	
	public init(message:String) {
		// initialise scene
		self.message = message
		super.init()
		// create the geometry and paper object
		paperGeometry = SCNBox(width: paperSize.width, height: paperSize.height, length: paperSize.length, chamferRadius: 0.1)
		paperGeometry.materials = [messageMaterial, whiteMaterial, messageMaterial, whiteMaterial, whiteMaterial, whiteMaterial]
		paper = SCNNode(geometry: paperGeometry)
		self.rootNode.addChildNode(paper)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Methods
	
	private class func renderedTextImage(message:String, size:CGSize, textColor:UIColor, backgroundColor:UIColor) -> UIImage? {
		let layer = CALayer()
		layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		layer.backgroundColor = backgroundColor.cgColor
		// create the text layer and add as a sublayer
		let textLayer = CATextLayer()
		textLayer.frame = layer.bounds.insetBy(dx: 10, dy: 10)
		textLayer.string = message
		textLayer.isWrapped = true
		textLayer.truncationMode = kCATruncationNone
		textLayer.contentsGravity = kCAGravityCenter
		textLayer.alignmentMode = kCAAlignmentLeft
		textLayer.font = CTFontCreateWithName("Courier" as CFString, 35, nil)
		textLayer.foregroundColor = textColor.cgColor
		textLayer.fontSize = Message3DScene.surfaceFontSize
		textLayer.display()
		layer.addSublayer(textLayer)
		// create the image and return
		return UIImage.image(from: layer)
	}
	
	public func morphToCrypto(duration:TimeInterval) {
		lastMorph = Date()
		// update the surface materials
		self.paperGeometry.materials = [encryptedMaterial, encryptedMaterial, encryptedMaterial, encryptedMaterial, encryptedMaterial, encryptedMaterial]
		// animate to new size
		SCNTransaction.begin()
		SCNTransaction.animationDuration = duration
		paperGeometry.height = cubeSize.height
		paperGeometry.length = cubeSize.length
		paperGeometry.width = cubeSize.width
		SCNTransaction.commit()
	}
	
	public func morphToPaper(duration:TimeInterval) {
		lastMorph = Date()
		// update the surface materials
		self.paperGeometry.materials = [messageMaterial, whiteMaterial, messageMaterial, whiteMaterial, whiteMaterial, whiteMaterial]
		// animate to new size
		SCNTransaction.begin()
		SCNTransaction.animationDuration = duration
		paperGeometry.height = paperSize.height
		paperGeometry.width = paperSize.width
		paperGeometry.length = paperSize.length
		SCNTransaction.commit()
	}
	
	public func pulsePaper() {
		// only pulse if enough time has passed
		if Date().timeIntervalSince(lastMorph) < 0.8 {
			return
		}
		lastMorph = Date()
		let grow = SCNAction.scale(to: 1.2, duration: 0.1)
		let shrink = SCNAction.scale(to: 1, duration: 0.1)
		let pulse = SCNAction.sequence([grow,shrink])
		paper.runAction(pulse)
	}
	
	public func rotatePaper(dx: CGFloat, dy: CGFloat) {
		let rotate = SCNAction.rotateBy(x: dx, y: dy, z: 0, duration: 0.03)
		paper.runAction(rotate)
	}
	
}



