//
//  DDControllerTouchpad.swift
//  Daydream
//
//  Created by Sachin Patel on 1/18/17.
//  Copyright © 2017 Sachin Patel. All rights reserved.
//

import UIKit

typealias DDControllerTouchpadPointChangedHandler = (DDControllerTouchpad, CGPoint) -> Void

class DDControllerTouchpad: NSObject {
	public var pointChangedHandler: DDControllerTouchpadPointChangedHandler?
	public var point: CGPoint {
		didSet {
			pointChangedHandler?(self, point)
		}
	}
	
	private(set) var button: DDControllerButton
	
	override init() {
		point = CGPoint.zero
		button = DDControllerButton()
		
		super.init()
	}
}
