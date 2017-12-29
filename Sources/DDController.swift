//
//  DDController.swift
//  Daydream
//
//  Created by Sachin Patel on 1/18/17.
//  Copyright © 2017 Sachin Patel. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreMotion

enum DDControllerError: Error {
	case bluetoothOff
}

extension NSNotification.Name {
	public static let DDControllerDidConnect = NSNotification.Name(rawValue: "DDControllerDidConnect")
	public static let DDControllerDidUpdateBatteryLevel = NSNotification.Name(rawValue: "DDControllerDidUpdateBatteryLevel")
	public static let DDControllerDidDisconnect = NSNotification.Name("DDControllerDidDisconnect")
}

/// An instance of a Daydream View controller.
public class DDController: NSObject {	
	/// An array of currently connected controllers.
	static var controllers = [DDController]()
	
	/// The internal `DDConnectionManager`, which manages connected devices.
	static fileprivate let manager = DDConnectionManager()
	
	/// The services offered by the Daydream View controller, representing:
	/// - FE55: Controller state
	/// - 180F: Battery level
	/// - 180A: Device information
	static let serviceUUIDs = ["FE55", "180F", "180A"].map({ CBUUID(string: $0) })
	
	// MARK: Device Information
	/// The battery level of the controller.
	/// Note: Call `updateBatteryLevel` on the controller object periodically to update this value.
	fileprivate(set) var batteryLevel: Float?
	
	/// The manufacturer of the controller.
	fileprivate(set) var manufacturer: String?
	
	/// The firmware version of the controller.
	fileprivate(set) var firmwareVersion: String?
	
	/// The serial number of the controller.
	fileprivate(set) var serialNumber: String?
	
	/// The model number of the controller.
	fileprivate(set) var modelNumber: String?
	
	/// The hardware version of the controller.
	fileprivate(set) var hardwareVersion: String?
	
	/// The software version of the controller.
	fileprivate(set) var softwareVersion: String?
	
	// MARK: Internal
	/// The internal `CBPeripheral` represented by this controller instance.
	var peripheral: CBPeripheral?
	
	/// The `CBService`s that `peripheral` provides.
	fileprivate var services: [CBService]
	
	// MARK: Input Devices
	/// The touch pad of the device.
	fileprivate(set) var touchpad: DDControllerTouchpad
	
	/// The "app" button, which is the top button on the front of the controller.
	fileprivate(set) var appButton: DDControllerButton
	
	/// The home button, which is the bottom button on the front of the controller.
	fileprivate(set) var homeButton: DDControllerButton
	
	/// The volume up button on the right side of the controller.
	fileprivate(set) var volumeUpButton: DDControllerButton
	
	/// The volume down button on the right side of the controller.
	fileprivate(set) var volumeDownButton: DDControllerButton
    
    typealias OrientationChangeHandler = (CMQuaternion) -> Void
    var orientationChangedHandler: OrientationChangeHandler? = nil
    
	
	// MARK: - Initializers
	
	/// Warning: Use the convenience initializer and provide a valid `CBPeripheral` instead.
	override init() {
		self.services = []
		self.touchpad = DDControllerTouchpad()
		self.appButton = DDControllerButton()
		self.homeButton = DDControllerButton()
		self.volumeUpButton = DDControllerButton()
		self.volumeDownButton = DDControllerButton()
	}
	
	/// Warning: Call `DDController.startDaydreamControllerDiscovery()` rather than instantiating this class directly.
	public convenience init(peripheral: CBPeripheral) {
		self.init()
		self.peripheral = peripheral
	}
	
	// MARK: - Controller Discovery
	
	/// Starts discovery of Daydream View controllers.
	///
	/// To be notified when a controller connects, subscribe to the `DDControllerDidConnect` notification.
	/// To be notified when a controller disconnects, subscribe to the `DDControllerDidDisconnect` notification.
	/// The `object` on the notification will be the newly connected or disconnected `DDController`.
	///
	/// This function throws a `DDControllerError` if Bluetooth is turned off.
	class func startDaydreamControllerDiscovery() throws {
		guard let bluetoothManager = manager.bluetoothManager else { return }
		
		// Bluetooth is off, return an error
		if bluetoothManager.state == .poweredOff {
			throw DDControllerError.bluetoothOff
		}
		
		// Start searching the next time we encounter a state change
		manager.shouldSearchForDevices = true
		
		// We're already scanning, return
		guard !bluetoothManager.isScanning else { return }
	}
	
	/// Stops discovery of Daydream View controllers.
	class func stopDaydreamControllerDiscovery() {
		guard let bluetoothManager = manager.bluetoothManager else { return }
		manager.shouldSearchForDevices = false
		
		if bluetoothManager.isScanning {
			bluetoothManager.stopScan()
		}
	}
	
	/// Sets up the `CBPeripheral` delegate and discovers its services.
	/// Called by the `DDConnectionManager` when a valid controller is discovered.
	func didConnect() {
		peripheral?.delegate = self
		peripheral?.discoverServices(DDController.serviceUUIDs)
	}
    
    var updates: Int = 0
    var updatesStart: TimeInterval = 0
}

/// An extension of `DDController` that handles incoming data.
extension DDController: CBPeripheralDelegate {
	/// Updates the controller's battery level.
	/// To be notified when the battery level update completes, subscribe to the `DDControllerDidUpdateBatteryLevel` notification.
	/// The `object` on the notification will be an instance of `DDController` with the updated `batteryLevel`.
	public func updateBatteryLevel() {
		guard let batteryServiceIndex = services.index(where: { $0.kind == .battery }) else { return }
		let batteryService = services[batteryServiceIndex]
		guard let batteryLevel = batteryService.characteristics?[0] else { return }
		peripheral?.readValue(for: batteryLevel)
	}
	
	/// Called when services are discovered on the `peripheral`.
	public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		guard let peripheralServices = peripheral.services else { return }
		
		services.removeAll()
		
		for service in peripheralServices {
			// Check if the service is a member of `DDController.serviceUUIDs` (which represents
			// device services that we care about), otherwise, continue to the next service.
			guard DDController.serviceUUIDs.map({ $0.uuidString }).contains(service.uuid.uuidString) else { continue }
			
			// Append the service to our array of services.
			services.append(service)
			
			// Discover the characteristics of that service.
			peripheral.discoverCharacteristics(nil, for: service)
		}
	}
	
	/// Called when characteristics are discovered for one of the elements of `services`, which represents
	/// the services (whose UUIDs are members of `DDController.serviceUUIDs`) of the `peripheral`.
	public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		guard let serviceCharacteristics = service.characteristics else { return }
		
		for characteristic in serviceCharacteristics {
			switch service.kind {
			
			// If the characteristic represents the device state, register for notifications whenever
			// the value changes so that we can update the state of the touchpad, buttons, and motion.
			case .state where characteristic.kind == .state:
				peripheral.setNotifyValue(true, for: characteristic)
				
			// The battery and device info services don't support notifications, so simply read their value once.
			// To get the latest battery level of the controller, call `updateBatteryLevel` and subscribe to the `DDControllerDidUpdateBatteryLevel` notification.
			case .battery,
			     .deviceInfo where characteristic.kind != .unknown:
				peripheral.readValue(for: characteristic)
				
			default: continue
			}
		}
	}
	
	/// Called when a characteristic value is read and returned by the device.
	public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		guard let data = characteristic.value else { return }
		
		switch characteristic.kind {
		
		// Update the device state based on the hex string representation of the `characteristic`'s value.
		case .state where characteristic.service.kind == .state:
            update(from: data)
		
		// The device returns the battery level as an integer out of 100.
		// Convert it to a float and post the battery update notification.
		case .batteryLevel where characteristic.service.kind == .battery:
			batteryLevel = Float(data.intValue) / Float(100)
			NotificationCenter.default.post(name: NSNotification.Name.DDControllerDidUpdateBatteryLevel, object: self)
			
		// Device info characteristics
		case .manufacturer:
			manufacturer = data.stringValue
			
		case .firmwareVersion:
			firmwareVersion = data.stringValue
			
		case .serialNumber:
			serialNumber = data.stringValue
			
		case .hardwareVersion:
			hardwareVersion = data.stringValue
			
		case .modelNumber:
			modelNumber = data.stringValue
			
		case .softwareVersion:
			softwareVersion = data.stringValue
			
		default:
            print("Other characteristic: \(characteristic.kind)")
            return
		}
	}
	
	/// Updates the state of the controller's touchpad and buttons based on the hex string from the device.
    private func update(from data: Data) {
        // Create an instance of DDControllerState from the hex string.
        let state = DDControllerState(data: data)
        
		// Update the touchpad's point
        if touchpad.point != state.touchPoint {
//            print("touchpad point changed: \(state.touchPoint)")
            touchpad.point = state.touchPoint
        }
        
        if let handler = orientationChangedHandler {
            // FIXME: Seems like yaw & pitch are flipped???
            let orientation = state.orientation
            handler(orientation)
        }
//        print("roll: \(orientation.roll)")
//        print("pitch: \(orientation.pitch)")
//        print("yaw: \(orientation.yaw)")
		
		// Update buttons
		let buttons = state.buttons
		touchpad.button.pressed = buttons.contains(.click)
		appButton.pressed = buttons.contains(.app)
		homeButton.pressed = buttons.contains(.home)
		volumeUpButton.pressed = buttons.contains(.volumeUp)
		volumeDownButton.pressed = buttons.contains(.volumeDown)
	}
}
