//
//  DCConnectionManager.m
//  DaydreamSample-iOS
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import "DCConnectionManager.h"

NSString * _Nonnull DCConnectionManagerErrorDomain = @"DCConnectionManagerErrorDomain";

@interface DCConnectionManager () <CBCentralManagerDelegate>
@property(nonatomic, strong)NSMutableArray <DCController *> * _Nonnull controllers;

@property(nonatomic, strong)CBCentralManager * _Nonnull bluetoothManager;
@property(nonatomic, assign)BOOL shouldSearchForDevices;
@end

@implementation DCConnectionManager

- (instancetype)init {
    if((self = [super init])) {
        self.controllers = [[NSMutableArray alloc] init];
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    return self;
}

// MARK: - Controller Discovery
- (void)startDaydreamControllerDiscovery {
    if (@available(macOS 10.13, *)) {
        if(self.bluetoothManager.state == CBManagerStatePoweredOff) {
            return;
        }
    } else {
        // Fallback on earlier versions
        return;
    }
    
    self.shouldSearchForDevices = YES;
}
- (void)stopDaydreamControllerDiscovery {
    self.shouldSearchForDevices = NO;
    if (@available(macOS 10.13, *)) {
        if(self.bluetoothManager.isScanning) {
            [self.bluetoothManager stopScan];
        }
    } else {
        // Fallback on earlier versions
        NSLog(@"CoreBluetooth scanning not available before macos 10.13!");
        return;
    }
}

/// MARK: - CBCentralManagerDelegate
/// Called when the Bluetooth manager updates its state.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (@available(macOS 10.13, *)) {
        if(central.state != CBManagerStatePoweredOn) {
            // Bluetooth isn't on
            return;
        }
    } else {
        // Fallback on earlier versions
        return;
    }
    
    if(self.shouldSearchForDevices) {
        [central scanForPeripheralsWithServices:[DCController serviceUUIDs] options:nil];
    }
}

/// Called when a Bluetooth peripheral is discovered.
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    NSString *const name = peripheral.name;
    if(![name containsString:@"Daydream controller"]) {
        return;
    }
    
    // Create a `DCController` instance, add it to `controllers`, and connect to it.
    DCController *const newController = [[DCController alloc] initWithPeripheral:peripheral];
    [self.controllers addObject:newController];
    [central connectPeripheral:peripheral options:nil];
}

/// Called when a Daydream View controller connects.
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    const NSUInteger controllerIndex = [self.controllers indexOfObjectPassingTest:^BOOL(DCController * _Nonnull controller, NSUInteger idx, BOOL * _Nonnull stop) {
        return controller.peripheral == peripheral;
    }];
    if(controllerIndex == NSNotFound) {
        return;
    }
    
    DCController *const controller = self.controllers[controllerIndex];
    [controller didConnect];
    [self.delegate didConnectTo:controller];
}

/// Called when a Daydream View controller fails to connect.
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    const NSUInteger controllerIndex = [self.controllers indexOfObjectPassingTest:^BOOL(DCController * _Nonnull controller, NSUInteger idx, BOOL * _Nonnull stop) {
        return controller.peripheral == peripheral;
    }];
    if(controllerIndex == NSNotFound) {
        return;
    }
    
    [self.controllers removeObjectAtIndex:controllerIndex];
}

/// Called when a Daydream View controller disconnects.
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    const NSUInteger controllerIndex = [self.controllers indexOfObjectPassingTest:^BOOL(DCController * _Nonnull controller, NSUInteger idx, BOOL * _Nonnull stop) {
        return controller.peripheral == peripheral;
    }];
    if(controllerIndex == NSNotFound) {
        return;
    }
    
    DCController *const controller = self.controllers[controllerIndex];
    [self.delegate didDisconnectFrom:controller];
    [self.controllers removeObjectAtIndex:controllerIndex];
}

@end
