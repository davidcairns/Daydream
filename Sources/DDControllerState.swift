//
//  DDControllerState.swift
//  Daydream
//
//  Created by Sachin Patel on 1/17/17.
//  Copyright © 2017 Sachin Patel. All rights reserved.
//

import UIKit
import CoreMotion

/// Represents the state of a controller at a given time.
///
/// Note: `DDControllerState` is intended for use internally within `DDController`. To interface with controllers,
/// please call `DDController.startDaydreamControllerDiscovery()` and subscribe to the `DDControllerDidConnect`
/// notification. Then, access the touchpad and buttons from their associated values on `DDController`.
///
/// Note: Getting the `gyro`, `acceleration`, and `magnetometer` values are currently unsupported.
/// With some tweaks to the implementation of `getSignedDouble`, it may be possible to get correct values.
///
/// This class wouldn't be possible without Matteo Pisani's fantastic reverse engineering of the Daydream View controller:
/// https://hackernoon.com/how-i-hacked-google-daydream-controller-c4619ef318e4#.yjtxmhmec
///
internal class DDControllerState: CustomStringConvertible {
	/// The current point on the touchpad.
	/// Note: This value is equivalent to `CGPoint.zero` if the user's finger is not currently on the touchpad.
	private(set) var touchPoint: CGPoint
	
	/// The buttons currently being pressed on the controller.
	private(set) var buttons: Buttons
	
    /// The current values of the gyroscope.
    /// Bug: Gyroscope values are not currently parsed correctly.
    private(set) var gyro: CMAcceleration
    
    /// The current acceleration of the controller.
    /// Bug: Accelerometer values are not currently parsed correctly.
    private(set) var acceleration: CMAcceleration
    
    // The current values of the magnetometer.
    /// Bug: Magnetometer values are not currently parsed correctly.
    private(set) var magnetometer: CMAcceleration
	
	public var description: String {
		var result = "State: {"
        result += "\n\tGyro: (\(gyro.x), \(gyro.y), \(gyro.z))"
        result += "\n\tAcceleration: (\(acceleration.x), \(acceleration.y), \(acceleration.z))"
        result += "\n\tMagnetometer: (\(magnetometer.x), \(magnetometer.y), \(magnetometer.z))"
		result += "\n\tTouch: (\(touchPoint.x), \(touchPoint.y))"
		result += "\n\tButtons: \(buttons)"
		result += "\n}"
		return result
	}
	
	/// A `OptionSet` used for representing which buttons are currently being pressed.
	struct Buttons: OptionSet {
		let rawValue: Int
		
		init(rawValue: Int) {
			self.rawValue = rawValue
		}
        init(data: Data) {
            self.rawValue = data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) -> Int in
                return Int(pointer.advanced(by: 18).pointee)
            }
        }
		
		static let click = Buttons(rawValue: 1 << 0)
		static let home = Buttons(rawValue: 1 << 1)
		static let app = Buttons(rawValue: 1 << 2)
		static let volumeDown = Buttons(rawValue: 1 << 3)
		static let volumeUp = Buttons(rawValue: 1 << 4)
	}
	
	/// The initializer for `DDControllerState`.
	/// - parameter data: A hex string from the Daydream View controller representing the state.
    init(data: Data) {
        gyro = AdjustedGyroFromData(data)
        magnetometer = AdjustedMagnetometerFromData(data)
        acceleration = AdjustedAccelerometerFromData(data)
        touchPoint = CGPoint(x: TouchPointX(data), y: TouchPointY(data))
        buttons = Buttons(data: data)
	}
}

extension DDControllerState {
    var orientation: Quaternion {
        let angle = sqrt(magnetometer.x * magnetometer.x + magnetometer.y * magnetometer.y + magnetometer.z * magnetometer.z)
        if angle > 0 {
            let axis = Vect3(x: magnetometer.x / angle,
                             y: magnetometer.y / angle,
                             z: magnetometer.z / angle)
            return QuaternionMakeFromAxisAngle(axis, angle)
        }
        return QuaternionMake(0, 0, 0, 1)
    }
}
