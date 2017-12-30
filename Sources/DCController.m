//
//  DCController.m
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import "DCController.h"

NSString *const DCControllerDidConnectNotification = @"";
NSString *const DCControllerDidUpdateBatteryLevelNotification = @"";
NSString *const DCControllerDidDisconnectNotification = @"";

@interface DCController() <CBPeripheralDelegate>
/// The internal `CBPeripheral` represented by this controller instance.
@property(nonatomic, strong)CBPeripheral * _Nonnull peripheral;
/// The `CBService`s that `peripheral` provides.
@property(nonatomic, copy)NSArray<CBService *> * _Nonnull services;
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

@end
