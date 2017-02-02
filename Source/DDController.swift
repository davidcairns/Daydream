//
//  DDController.swift
//  Daydream
//
//  Created by Sachin Patel on 1/18/17.
//  Copyright © 2017 Sachin Patel. All rights reserved.
//

import UIKit
import CoreBluetooth

enum DDControllerError: Error {
	case unknown
	case bluetoothOff
}

extension NSNotification.Name {
	public static let DDControllerDidConnect = NSNotification.Name(rawValue: "DDControllerDidConnect")
	public static let DDControllerDidUpdateBatteryLevel = NSNotification.Name(rawValue: "DDControllerDidUpdateBatteryLevel")
	public static let DDControllerDidDisconnect = NSNotification.Name("DDControllerDidDisconnect")
}

class DDController: NSObject {	
	// MARK:
	static fileprivate(set) var controllers = [DDController]()
	static fileprivate let manager = DDConnectionManager()
	static fileprivate let serviceUUIDs = ["FE55", "180F", "180A"].map({ CBUUID(string: $0) })
	
	// MARK: Device Information
	fileprivate(set) var batteryLevel: Float?
	fileprivate(set) var manufacturer: String?
	fileprivate(set) var firmwareVersion: String?
	fileprivate(set) var serialNumber: String?
	fileprivate(set) var hardwareVersion: String?
	fileprivate(set) var modelNumber: String?
	fileprivate(set) var softwareVersion: String?
	
	// MARK: Internal
	fileprivate var peripheral: CBPeripheral?
	fileprivate var services: [CBService]
	
	// MARK: Input Devices
	fileprivate(set) var touchpad: DDControllerTouchpad
	fileprivate(set) var appButton: DDControllerButton
	fileprivate(set) var homeButton: DDControllerButton
	fileprivate(set) var volumeUpButton: DDControllerButton
	fileprivate(set) var volumeDownButton: DDControllerButton
	
	// MARK: - Initializers
	override init() {
		self.services = []
		self.touchpad = DDControllerTouchpad()
		self.appButton = DDControllerButton()
		self.homeButton = DDControllerButton()
		self.volumeUpButton = DDControllerButton()
		self.volumeDownButton = DDControllerButton()
	}
	
	fileprivate convenience init(peripheral: CBPeripheral) {
		self.init()
		self.peripheral = peripheral
	}
	
	fileprivate func didConnect() {
		peripheral?.delegate = self
		peripheral?.discoverServices(DDController.serviceUUIDs)
	}
	
	// MARK: - Controller Discovery
	class func startDaydreamControllerDiscovery() throws {
		guard let bluetoothManager = manager.bluetoothManager else {
			throw DDControllerError.unknown
		}
		
		// Bluetooth isn't on, return an error
		guard bluetoothManager.state == .poweredOn else {
			throw DDControllerError.bluetoothOff
		}
		
		// We're already scanning, return
		guard !bluetoothManager.isScanning else { return }
	}
	
	class func stopDaydreamControllerDiscovery() {
		guard let bluetoothManager = manager.bluetoothManager else { return }
		bluetoothManager.stopScan()
	}
}

extension DDController: CBPeripheralDelegate {
	public func updateBatteryLevel() {
		guard let batteryServiceIndex = services.index(where: { $0.kind == .battery }) else { return }
		let batteryService = services[batteryServiceIndex]
		guard let batteryLevel = batteryService.characteristics?[0] else { return }
		peripheral?.readValue(for: batteryLevel)
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		guard let peripheralServices = peripheral.services else { return }
		
		services.removeAll()
		for service in peripheralServices {
			guard DDController.serviceUUIDs.map({ $0.uuidString }).contains(service.uuid.uuidString) else { continue }
			services.append(service)
			peripheral.discoverCharacteristics(nil, for: service)
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		guard let characteristics = service.characteristics else { return }
		
		for c in characteristics {
			switch service.kind {
			case .state where c.kind == .state:
				peripheral.setNotifyValue(true, for: c)
				
			case .battery,
			     .deviceInfo where c.kind != .unknown:
				peripheral.readValue(for: c)
				
			default: continue
			}
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		guard let data = characteristic.value else { return }
		
		switch characteristic.kind {
		case .state where characteristic.service.kind == .state:
			update(from: data.hexStringValue)
		case .batteryLevel where characteristic.service.kind == .battery:
			batteryLevel = Float(data.intValue) / Float(100)
			NotificationCenter.default.post(name: NSNotification.Name.DDControllerDidUpdateBatteryLevel, object: self)
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
		default: return
		}
	}
	
	private func update(from hexString: String) {
		guard let state = DDControllerState(data: hexString) else { return }
		
		touchpad.point = state.touchPoint
		
		let buttons = state.buttons
		touchpad.button.pressed = buttons.contains(.click)
		appButton.pressed = buttons.contains(.app)
		homeButton.pressed = buttons.contains(.home)
		volumeUpButton.pressed = buttons.contains(.volumeUp)
		volumeDownButton.pressed = buttons.contains(.volumeDown)
	}
}

// MARK: - DDConnectionManager
private class DDConnectionManager: NSObject, CBCentralManagerDelegate {
	fileprivate var bluetoothManager: CBCentralManager?
	
	override init() {
		super.init()
		
		bluetoothManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
	}
	
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		guard central.state == .poweredOn else {
			// Bluetooth isn't on
			return
		}
		
		central.scanForPeripherals(withServices: DDController.serviceUUIDs, options: nil)
	}
	
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		guard let name = peripheral.name, name.contains("Daydream controller") else { return }
		
		let newController = DDController(peripheral: peripheral)
		DDController.controllers.append(newController)
		central.connect(peripheral, options: nil)
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		guard let controllerIndex = DDController.controllers.index(where: { (controller) -> Bool in
			return controller.peripheral == peripheral
		}) else { return }
		
		let controller = DDController.controllers[controllerIndex]
		controller.peripheral?.delegate = controller
		controller.didConnect()
		
		NotificationCenter.default.post(name: Notification.Name.DDControllerDidConnect, object: controller)
	}
	
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		guard let controllerIndex = DDController.controllers.index(where: { (controller) -> Bool in
			return controller.peripheral == peripheral
		}) else { return }
		DDController.controllers.remove(at: controllerIndex)
	}
	
	func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		guard let controllerIndex = DDController.controllers.index(where: { (controller) -> Bool in
			return controller.peripheral == peripheral
		}) else { return }
		
		NotificationCenter.default.post(name: Notification.Name.DDControllerDidDisconnect, object: DDController.controllers[controllerIndex])
		DDController.controllers.remove(at: controllerIndex)
	}
}

// MARK: - Convenience
fileprivate extension CBService {
	enum Kind {
		case unknown
		case state
		case deviceInfo
		case battery
	}
	
	var kind: CBService.Kind {
		switch uuid.uuidString {
		case "FE55":
			return .state
		case "180F":
			return .battery
		case "180A":
			return .deviceInfo
		default:
			return .unknown
		}
	}
}

fileprivate extension CBCharacteristic {
	enum Kind {
		case unknown
		case state
		case batteryLevel
		case manufacturer
		case firmwareVersion
		case serialNumber
		case hardwareVersion
		case modelNumber
		case softwareVersion
	}
	
	var kind: CBCharacteristic.Kind {
		switch uuid.uuidString {
		case "00000001-1000-1000-8000-00805F9B34FB":
			return .state
		case "2A29":
			return .manufacturer
		case "2A19":
			return .batteryLevel
		case "2A26":
			return .firmwareVersion
		case "2A25":
			return .serialNumber
		case "2A27":
			return .hardwareVersion
		case "2A24":
			return .modelNumber
		case "2A28":
			return .softwareVersion
		default:
			return .unknown
		}
	}
}

fileprivate extension Data {
	var hexStringValue: String {
		return map { String(format: "%02hhx", $0) }.joined()
	}
	
	var stringValue: String {
		guard let result = String(data: self, encoding: String.Encoding.utf8) else { return "" }
		return result
	}
	
	var intValue: Int {
		guard let result = Int(hexStringValue, radix: 16) else {
			return -1
		}
		return result
	}
}
