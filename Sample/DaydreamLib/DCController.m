//
//  DCController.m
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import "DCController.h"
#import "CoreBluetooth+Extensions.h"
#import "NSData+Extensions.h"

NSString *const DCControllerDidConnectNotification = @"";
NSString *const DCControllerDidUpdateBatteryLevelNotification = @"";
NSString *const DCControllerDidDisconnectNotification = @"";

@interface DCController() <CBPeripheralDelegate>
/// The `CBService`s that `peripheral` provides.
@property(nonatomic, strong)NSMutableArray<CBService *> * _Nonnull services;
@end

@implementation DCController

+ (NSArray<CBUUID*> *)serviceUUIDs {
    /// The services offered by the Daydream View controller, representing:
    /// - FE55: Controller state
    /// - 180F: Battery level
    /// - 180A: Device information
    return @[[CBUUID UUIDWithString:@"FE55"],
             [CBUUID UUIDWithString:@"180F"],
             [CBUUID UUIDWithString:@"180A"]];
}

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    if((self = [super init])) {
        self.services = [[NSMutableArray alloc] init];
        
        self.touchpad = [[DCTouchpad alloc] init];
        self.appButton = [[DCControllerButton alloc] init];
        self.homeButton = [[DCControllerButton alloc] init];
        self.volumeUpButton = [[DCControllerButton alloc] init];
        self.volumeDownButton = [[DCControllerButton alloc] init];
        
        self.peripheral = peripheral;
    }
    return self;
}

// TODO: Implement this accepting a callback!
- (void)updateBatteryLevel {
//    guard let batteryServiceIndex = services.index(where: { $0.kind == .battery }) else { return }
//    let batteryService = services[batteryServiceIndex]
//    guard let batteryLevel = batteryService.characteristics?[0] else { return }
//    peripheral.readValue(for: batteryLevel)
}

- (void)didConnect {
    self.peripheral.delegate = self;
    [self.peripheral discoverServices:DCController.serviceUUIDs];
}

- (BOOL)_isInterestingService:(CBService *)service {
    NSString *const serviceUuid = service.UUID.UUIDString;
    for(CBUUID *const uuid in DCController.serviceUUIDs) {
        if([uuid.UUIDString isEqualToString:serviceUuid]) {
            return YES;
        }
    }
    return NO;
}

/// MARK: - CBPeripheralDelegate
/// Called when services are discovered on the `peripheral`.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSArray *const peripheralServices = peripheral.services;
    if(!peripheralServices) {
        return;
    }
    
    [self.services removeAllObjects];
    
    for(CBService *const service in peripheralServices) {
        // Check if the service is a member of `DDController.serviceUUIDs` (which represents
        // device services that we care about), otherwise, continue to the next service.
        if(![self _isInterestingService:service]) {
            continue;
        }
        
        // Append the service to our array of services.
        [self.services addObject:service];
        
        // Discover the characteristics of that service.
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

/// Called when characteristics are discovered for one of the elements of `services`, which represents
/// the services (whose UUIDs are members of `DDController.serviceUUIDs`) of the `peripheral`.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSArray<CBCharacteristic *> *const serviceCharacteristics = service.characteristics;
    if(!serviceCharacteristics) {
        return;
    }
    
    for(CBCharacteristic *const characteristic in serviceCharacteristics) {
        switch([service kind]) {
            // If the characteristic represents the device state, register for notifications whenever
            // the value changes so that we can update the state of the touchpad, buttons, and motion.
            case CBServiceKindState:
                if(characteristic.kind == CBCharacteristicKindState) {
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
            
            // The battery and device info services don't support notifications, so simply read their value once.
            // To get the latest battery level of the controller, call `updateBatteryLevel`.
            case CBServiceKindBattery:
            case CBServiceKindDeviceInfo:
                if(characteristic.kind != CBCharacteristicKindUnknown) {
                    [peripheral readValueForCharacteristic:characteristic];
                }
            
            default: continue;
        }
    }
}

/// Called when a characteristic value is read and returned by the device.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSData *const data = characteristic.value;
    if(!data) {
        return;
    }
    
    switch(characteristic.kind) {
        // Update the device state based on the hex string representation of the `characteristic`'s value.
        case CBCharacteristicKindState:
            if(characteristic.service.kind == CBServiceKindState) {
                [self updateFromData:data];
            }
        
        // The device returns the battery level as an integer out of 100.
        // Convert it to a float and post the battery update notification.
        case CBCharacteristicKindBatteryLevel:
            if(characteristic.service.kind == CBServiceKindBattery) {
//                self.batteryLevel = Float(data.intValue) / Float(100);
                break;
            }
        
        // Device info characteristics
        case CBCharacteristicKindManufacturer:
            self.manufacturer = data.stringValue;
        
        case CBCharacteristicKindFirmwareVersion:
            self.firmwareVersion = data.stringValue;
        
        case CBCharacteristicKindSerialNumber:
            self.serialNumber = data.stringValue;
        
        case CBCharacteristicKindHardwareVersion:
            self.hardwareVersion = data.stringValue;
        
        case CBCharacteristicKindModelNumber:
            self.modelNumber = data.stringValue;
        
        case CBCharacteristicKindSoftwareVersion:
            self.softwareVersion = data.stringValue;
            
        default:
//            NSLog(@"Other characteristic: %d", (int)characteristic.kind);
            break;
    }
}

/// Updates the state of the controller's touchpad and buttons based on the hex string from the device.
- (void)updateFromData:(NSData * _Nonnull)data {
    const DCControllerState state = DCControllerStateMake(data);
    
    // Update touchpad and buttons
    self.touchpad.point = state.touchPoint;
    
    const DCControllerButtons buttons = state.buttons;
    self.touchpad.button.pressed = buttons & DCControllerButtonsClick;
    self.appButton.pressed = buttons & DCControllerButtonsApp;
    self.homeButton.pressed = buttons & DCControllerButtonsHome;
    self.volumeUpButton.pressed = buttons & DCControllerButtonsVolumeUp;
    self.volumeDownButton.pressed = buttons & DCControllerButtonsVolumeDown;
    
    if(self.orientationChangedHandler) {
        self.orientationChangedHandler(DCControllerStateGetOrientation(state));
    }
    
    if(self.stateChangedHandler) {
        self.stateChangedHandler(state);
    }
}

@end
