//
//  DDControllerState.swift
//  Daydream
//
//  Created by Sachin Patel on 1/17/17.
//  Copyright © 2017 Sachin Patel. All rights reserved.
//

import UIKit
import CoreMotion

class DDControllerState: CustomStringConvertible {
	private(set) var gyro: CMAcceleration
	private(set) var acceleration: CMAcceleration
	private(set) var magnetometer: CMAcceleration
	private(set) var touchPoint: CGPoint
	private(set) var buttons: Buttons
	
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
	
	private var bitstring: String
	
	struct Buttons: OptionSet, CustomStringConvertible {
		let rawValue: Int
		
		init(rawValue: Int) {
			self.rawValue = rawValue
		}
		
		var description: String {
			return String(rawValue, radix: 2)
		}
		
		static let click = Buttons(rawValue: 1 << 0)
		static let home = Buttons(rawValue: 1 << 1)
		static let app = Buttons(rawValue: 1 << 2)
		static let volumeDown = Buttons(rawValue: 1 << 3)
		static let volumeUp = Buttons(rawValue: 1 << 4)
	}
	
	init?(data: String) {
		do {
			bitstring = try DDControllerState.parseHex(data: data)
			
			let gyroX = try DDControllerState.getSignedDouble(bitstring: bitstring, from: 14, to: 27)
			let gyroY = try DDControllerState.getSignedDouble(bitstring: bitstring, from: 27, to: 40)
			let gyroZ = try DDControllerState.getSignedDouble(bitstring: bitstring, from: 40, to: 53)
			gyro = CMAcceleration(x: gyroX, y: gyroY, z: gyroZ)
			
			let magX = try DDControllerState.getSignedDouble(bitstring: bitstring, from: 53, to: 66)
			let magY = try DDControllerState.getSignedDouble(bitstring: bitstring, from: 66, to: 79)
			let magZ = try DDControllerState.getSignedDouble(bitstring: bitstring, from: 79, to: 92)
			magnetometer = CMAcceleration(x: magX, y: magY, z: magZ)
			
			let accX = try DDControllerState.getSignedDouble(bitstring: bitstring, from: 92, to: 105)
			let accY = try DDControllerState.getSignedDouble(bitstring: bitstring, from: 105, to: 118)
			let accZ = try DDControllerState.getSignedDouble(bitstring: bitstring, from: 118, to: 131)
			acceleration = CMAcceleration(x: accX, y: accY, z: accZ)
			
			let touchX = try DDControllerState.getInt(bitstring: bitstring, from: 131, to: 139)
			let touchY = try DDControllerState.getInt(bitstring: bitstring, from: 139, to: 147)
			touchPoint = CGPoint(x: touchX, y: touchY)
			
			// app only: 10000
			// app and home: 11000
			let buttonsBits = try DDControllerState.getInt(bitstring: bitstring, from: 147, to: 152)
			buttons = Buttons(rawValue: buttonsBits)
			
		} catch _ {
			return nil
		}
	}
	
	// MARK: - Parsing
	private enum ParseError: Error {
		case failed
	}
	
	private class func getInt(bitstring: String, from: Int, to: Int) throws -> Int {
		let start = bitstring.index(bitstring.startIndex, offsetBy: from)
		let end = bitstring.index(bitstring.startIndex, offsetBy: to)
		let part = bitstring.substring(with: start..<end)
		guard let result = Int(part, radix: 2) else {
			throw ParseError.failed
		}
		return result
	}
	
	private class func getSignedDouble(bitstring: String, from: Int, to: Int) throws -> Double {
		let start = bitstring.index(bitstring.startIndex, offsetBy: from)
		let end = bitstring.index(bitstring.startIndex, offsetBy: to)
		let part = bitstring.substring(with: start..<end)
		
		guard let result = Int(part, radix: 2) else {
			throw ParseError.failed
		}
		
		// TODO: actually interpret the signed value. it's 13 bits, and the first is the sign.
		
		return Double(result)
	}
	
	private class func parseHex(data: String) throws -> String {
		var bitchain = ""
		for i in stride(from: 2, to: data.characters.count + 1, by: 2) {
			let start = data.index(data.startIndex, offsetBy: i-2)
			let end = data.index(data.startIndex, offsetBy: i)
			let part = data.substring(with: start..<end)
			guard let hexInt = Int(part, radix: 16) else {
				throw ParseError.failed
			}
			let binString = String(hexInt, radix: 2)
			bitchain += DDControllerState.zeroPad(string: binString, to: 8)
		}
		return bitchain
	}
	
	private class func zeroPad(string: String, to size: Int) -> String {
		var padded = string
		for _ in 0..<(size - string.characters.count) {
			padded = "0" + padded
		}
		return padded
	}
}
