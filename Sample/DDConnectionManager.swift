//
//  DDConnectionManager.swift
//  DaydreamSample
//
//  Created by David Cairns on 12/28/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

import Foundation
import CoreBluetooth

public enum DDConnectionManagerError: Error {
    case bluetoothOff
}

public protocol DDConnectionManagerDelegate {
    func didConnect(to controller: DCController)
    func didDisconnect(from controller: DCController)
}

public final class DDConnectionManager: NSObject, CBCentralManagerDelegate {
    var controllers: [DCController] = []
    var delegate: DDConnectionManagerDelegate? = nil
    
    var bluetoothManager: CBCentralManager!
    var shouldSearchForDevices: Bool = false
    
    override init() {
        super.init()
        bluetoothManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    // MARK: - Controller Discovery
    
    /// Starts discovery of Daydream View controllers.
    /// This function throws a `DDConnectionManagerError` if Bluetooth is turned off.
    public func startDaydreamControllerDiscovery() throws {
        // Bluetooth is off, return an error
        if bluetoothManager.state == .poweredOff {
            throw DDConnectionManagerError.bluetoothOff
        }
        
        // Start searching the next time we encounter a state change
        shouldSearchForDevices = true
    }
    
    /// Stops discovery of Daydream View controllers.
    public func stopDaydreamControllerDiscovery() {
        shouldSearchForDevices = false
        
        if bluetoothManager.isScanning {
            bluetoothManager.stopScan()
        }
    }
    

    // MARK: - CBCentralManagerDelegate
    /// Called when the Bluetooth manager updates its state.
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            // Bluetooth isn't on
            return
        }
        
        if shouldSearchForDevices {
            central.scanForPeripherals(withServices: DCController.serviceUUIDs(), options: nil)
        }
    }
    
    /// Called when a Bluetooth peripheral is discovered.
    public func centralManager(_ central: CBCentralManager,
                               didDiscover peripheral: CBPeripheral,
                               advertisementData: [String : Any],
                               rssi RSSI: NSNumber) {
        guard let name = peripheral.name, name.contains("Daydream controller") else { return }
        
        // Create a `DCController` instance, add it to `controllers`, and connect to it.
        let newController = DCController(peripheral: peripheral)
        controllers.append(newController)
        central.connect(peripheral, options: nil)
    }
    
    /// Called when a Daydream View controller connects.
    public func centralManager(_ central: CBCentralManager,
                               didConnect peripheral: CBPeripheral) {
        // Get the controller that matches the peripheral that just connected.
        guard let controllerIndex = controllers.index(where: { (controller) -> Bool in
            return controller.peripheral == peripheral
        }) else { return }
        let controller = controllers[controllerIndex]
        
        // Notify the controller and our delegate that we're connected.
        controller.didConnect()
        delegate?.didConnect(to: controller)
    }
    
    /// Called when a Daydream View controller fails to connect.
    public func centralManager(_ central: CBCentralManager,
                               didFailToConnect peripheral: CBPeripheral,
                               error: Error?) {
        // Get the controller that matches the peripheral that just failed to connect.
        guard let controllerIndex = controllers.index(where: { (controller) -> Bool in
            return controller.peripheral == peripheral
        }) else { return }
        
        // Remove the controller from `controllers`.
        controllers.remove(at: controllerIndex)
    }
    
    /// Called when a Daydream View controller disconnects.
    public func centralManager(_ central: CBCentralManager,
                               didDisconnectPeripheral peripheral: CBPeripheral,
                               error: Error?) {
        // Get the controller that matches the peripheral that just failed to connect.
        guard let controllerIndex = controllers.index(where: { (controller) -> Bool in
            return controller.peripheral == peripheral
        }) else { return }
        
        // Notify the controller and our delegate that the controller is no longer connected.
        let controller = controllers[controllerIndex]
        delegate?.didDisconnect(from: controller)
        controllers.remove(at: controllerIndex)
    }
}
