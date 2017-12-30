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
class DDController: NSObject {	
	/// An array of currently connected controllers.
	static fileprivate(set) var controllers = [DDController]()
	
	/// The internal `DDConnectionManager`, which manages connected devices.
	static fileprivate let manager = DDConnectionManager()
	
	/// The services offered by the Daydream View controller, representing:
	/// - FE55: Controller state
	/// - 180F: Battery level
	/// - 180A: Device information
	static fileprivate let serviceUUIDs = ["FE55", "180F", "180A"].map({ CBUUID(string: $0) })
	
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
	fileprivate var peripheral: CBPeripheral?
	
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
	fileprivate override init() {
		self.services = []
		self.touchpad = DDControllerTouchpad()
		self.appButton = DDControllerButton()
		self.homeButton = DDControllerButton()
		self.volumeUpButton = DDControllerButton()
		self.volumeDownButton = DDControllerButton()
	}
	
	/// Warning: Call `DDController.startDaydreamControllerDiscovery()` rather than instantiating this class directly.
	fileprivate convenience init(peripheral: CBPeripheral) {
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
	fileprivate func didConnect() {
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
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
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
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
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
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		guard let data = characteristic.value else { return }
		
		switch characteristic.kind {
		
		// Update the device state based on the hex string representation of the `characteristic`'s value.
		case .state where characteristic.service.kind == .state:
            update(from: data.hexStringValue, data: data)
		
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
    private func update(from hexString: String, data: Data) {
		// Create an instance of DDControllerState from the hex string.
        guard let state = DDControllerState(hexString: hexString, data: data) else { return }
        
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

extension DDControllerState {
    var orientation: CMQuaternion {
        let angle = sqrt(magnetometer.x * magnetometer.x + magnetometer.y * magnetometer.y + magnetometer.z * magnetometer.z)
        if angle > 0 {
            let axis = Vect3(x: magnetometer.x / angle,
                             y: magnetometer.y / angle,
                             z: magnetometer.z / angle)
            return CMQuaternion.from(axis: axis, angle: angle)
        }
        return CMQuaternion(x: 0, y: 0, z: 0, w: 1)
    }
}

typealias Vect3 = (x: Double, y: Double, z: Double)
func Vect3Dot(_ u: Vect3, _ v: Vect3) -> Double {
    return u.x * v.x + u.y * v.y + u.z * v.z
}
func Vect3Cross(_ u: Vect3, _ v: Vect3) -> Vect3 {
    return (x: u.y * v.z - u.z * v.y,
            y: u.z * v.x - u.x * v.z,
            z: u.x * v.y - u.y * v.x)
}
func Vect3Magnitude(_ v: Vect3) -> Double {
    return sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
}
func Vect3Normalize(_ v: Vect3) -> Vect3 {
    let m = Vect3Magnitude(v)
    return (x: v.x / m,
            y: v.y / m,
            z: v.z / m)
}

extension CMQuaternion: CustomStringConvertible {
    static func from(axis: Vect3, angle: Double) -> CMQuaternion {
        let n = Vect3Normalize(axis)
        let halfAngle = angle / 2.0
        let sin_a = sin(halfAngle)
        let cos_a = cos(halfAngle)
        return CMQuaternion(x: n.x * sin_a,
                            y: n.y * sin_a,
                            z: n.z * sin_a,
                            w: cos_a)
    }
    
    var matrix: CATransform3D {
        let x2 = x + x
        let y2 = y + y
        let z2 = z + z
        let xx = x * x2
        let xy = x * y2
        let xz = x * z2
        let yy = y * y2
        let yz = y * z2
        let zz = z * z2
        let wx = w * x2
        let wy = w * y2
        let wz = w * z2
        
//        let t = CATransform3D(m11: CGFloat(1 - (yy + zz)),  m12: CGFloat(xy + wz),          m13: CGFloat(xz - wy),          m14: CGFloat(0),
//                              m21: CGFloat(xy - wz),        m22: CGFloat(1 - (xx + zz)),    m23: CGFloat(yz + wx),          m24: CGFloat(0),
//                              m31: CGFloat(xz + wy),        m32: CGFloat(yz - wx),          m33: CGFloat(1 - (xx + yy)),    m34: CGFloat(0),
//                              m41: CGFloat(0),              m42: CGFloat(0),                m43: CGFloat(0),                m44: CGFloat(1))
        let t = CATransform3D(m11: CGFloat(1 - (yy + zz)),  m12: CGFloat(xy - wz),          m13: CGFloat(xz + wy),          m14: CGFloat(0),
                              m21: CGFloat(xy + wz),        m22: CGFloat(1 - (xx + zz)),    m23: CGFloat(yz - wx),          m24: CGFloat(0),
                              m31: CGFloat(xz - wy),        m32: CGFloat(yz + wx),          m33: CGFloat(1 - (xx + yy)),    m34: CGFloat(0),
                              m41: CGFloat(0),              m42: CGFloat(0),                m43: CGFloat(0),                m44: CGFloat(1))
        
        return t
    }
    
    var magnitude: Double {
        return sqrt(x * x + y * y + z * z + w * w)
    }
    
    var conjugate: CMQuaternion {
        return CMQuaternion(x: -x, y: -y, z: -z, w: w)
    }
    
    var normalized: CMQuaternion {
        let m = self.magnitude
        return CMQuaternion(x: x / m, y: y / m, z: z / m, w: w / m)
    }
    
    var inverse: CMQuaternion {
        return self.conjugate.normalized
    }
    
    func times(quaternion q2: CMQuaternion) -> CMQuaternion {
        let q1 = self
        return CMQuaternion(x: q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y,
                            y: q1.w * q2.y + q1.y * q2.w + q1.z * q2.x - q1.x * q2.z,
                            z: q1.w * q2.z + q1.z * q2.w + q1.x * q2.y - q1.y * q2.x,
                            w: q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z) 
    }
    
    var roll: Double {
        let sinr = 2.0 * (w * x + y * z)
        let cosr = 1.0 - 2.0 * (x * x + y * y)
        return atan2(sinr, cosr)
    }
    var pitch: Double {
        let sinp = 2.0 * (w * y - z * x)
        if fabs(sinp) >= 1.0 {
            return copysign(Double.pi / 2.0, sinp)
        }
        else {
            return asin(sinp)
        }
    }
    var yaw: Double {
        let siny = 2.0 * (w * z + x * y)
        let cosy = 1.0 - 2.0 * (y * y + z * z)
        return atan2(siny, cosy)
    }
    
    public var description: String {
        let x_ = Double(Int(x * 100.0)) / 100.0
        let y_ = Double(Int(y * 100.0)) / 100.0
        let z_ = Double(Int(z * 100.0)) / 100.0
        let w_ = Double(Int(w * 100.0)) / 100.0
        return "(\(x_),\t\(y_),\t\(z_),\t\(w_))"
    }
}

// MARK: - DDConnectionManager
// An internal class that handles connecting to Daydream View controllers using `CoreBluetooth`.
private final class DDConnectionManager: NSObject, CBCentralManagerDelegate {
	/// Whether we should start searching for devices the next time the `bluetoothManager` has a `state` of `poweredOn`.
	fileprivate var shouldSearchForDevices: Bool
	
	fileprivate var bluetoothManager: CBCentralManager?
	
	override init() {
		shouldSearchForDevices = false
		super.init()
		bluetoothManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
	}
	
	/// Called when the Bluetooth manager updates its state.
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		guard central.state == .poweredOn else {
			// Bluetooth isn't on
			return
		}
		
		if shouldSearchForDevices {
			central.scanForPeripherals(withServices: DDController.serviceUUIDs, options: nil)
		}
	}
	
	/// Called when a Bluetooth peripheral is discovered.
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		guard let name = peripheral.name, name.contains("Daydream controller") else { return }
		
		// Create a `DDController` instance, add it to `DDController.controllers`, and connect to it.
		let newController = DDController(peripheral: peripheral)
		DDController.controllers.append(newController)
		central.connect(peripheral, options: nil)
	}
	
	/// Called when a Daydream View controller connects.
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		// Get the controller that matches the peripheral that just connected.
		guard let controllerIndex = DDController.controllers.index(where: { (controller) -> Bool in
			return controller.peripheral == peripheral
		}) else { return }
		let controller = DDController.controllers[controllerIndex]
		
		// Notify the controller that it's connected and post the `DDControllerDidConnect` notification.
		controller.didConnect()
		NotificationCenter.default.post(name: Notification.Name.DDControllerDidConnect, object: controller)
	}
	
	/// Called when a Daydream View controller fails to connect.
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		// Get the controller that matches the peripheral that just failed to connect.
		guard let controllerIndex = DDController.controllers.index(where: { (controller) -> Bool in
			return controller.peripheral == peripheral
		}) else { return }
		
		// Remove the controller from `DDController.controllers`.
		DDController.controllers.remove(at: controllerIndex)
	}
	
	/// Called when a Daydream View controller disconnects.
	func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		// Get the controller that matches the peripheral that just failed to connect.
		guard let controllerIndex = DDController.controllers.index(where: { (controller) -> Bool in
			return controller.peripheral == peripheral
		}) else { return }
		
		// Notify the controller that it's connected and post the `DDControllerDidDisconnect` notification.
		NotificationCenter.default.post(name: Notification.Name.DDControllerDidDisconnect, object: DDController.controllers[controllerIndex])
		DDController.controllers.remove(at: controllerIndex)
	}
}

// MARK: - Convenience
/// A `CBService` extension to easily identify services based on UUID within `DDController` and associated classes.
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

/// A `CBCharacteristic` extension to easily identify characteristics based on UUID within `DDController` and associated classes.
fileprivate extension CBCharacteristic {
    enum Kind: String {
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

/// A `Data` extension for conveniently transforming `Data` into a hex string, string, or integer.
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
