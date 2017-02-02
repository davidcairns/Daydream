//
//  DDControllerButton.swift
//  Daydream
//
//  Created by Sachin Patel on 1/18/17.
//  Copyright © 2017 Sachin Patel. All rights reserved.
//

import UIKit

typealias DDControllerButtonValueChangedHandler = (DDControllerButton, Bool) -> Void

class DDControllerButton: NSObject {
	public var valueChangedHandler: DDControllerButtonValueChangedHandler?
	public var pressedChangedHandler: DDControllerButtonValueChangedHandler?
	public var longPressHandler: DDControllerButtonValueChangedHandler?
	private var consecutivelyPressedCount: Int
	
	public var pressed: Bool {
		didSet {
			if oldValue != pressed {
				pressedChangedHandler?(self, pressed)
			}
			
			consecutivelyPressedCount = pressed ? (consecutivelyPressedCount + 1) : 0
			if consecutivelyPressedCount > 60 {
				longPressHandler?(self, pressed)
			}
			
			valueChangedHandler?(self, pressed)
		}
	}
	
	override init() {
		pressed = false
		consecutivelyPressedCount = 0
		super.init()
	}
}
