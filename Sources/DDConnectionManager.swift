//
//  DDConnectionManager.swift
//  DaydreamSample
//
//  Created by David Cairns on 12/28/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: - DDConnectionManager
// An internal class that handles connecting to Daydream View controllers using `CoreBluetooth`.
final class DDConnectionManager: NSObject, CBCentralManagerDelegate {
    /// Whether we should start searching for devices the next time the `bluetoothManager` has a `state` of `poweredOn`.
    var shouldSearchForDevices: Bool
    
    var bluetoothManager: CBCentralManager?
    
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
