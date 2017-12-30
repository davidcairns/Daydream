//
//  CoreBluetooth+Extensions.h
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

// MARK: - Convenience
/// A `CBService` extension to easily identify services based on UUID within `DDController` and associated classes.

typedef NS_OPTIONS(NSUInteger, CBServiceKind) {
    CBServiceKindUnknown = 1 << 0,
    CBServiceKindState = 1 << 1,
    CBServiceKindDeviceInfo = 1 << 2,
    CBServiceKindBattery = 1 << 2,
};

@interface CBService(DCExtensions)
@property(nonatomic, readonly)CBServiceKind kind;
@end

typedef NS_OPTIONS(NSUInteger, CBCharacteristicKind) {
    CBCharacteristicKindUnknown = 1 << 0,
    CBCharacteristicKindState = 1 << 1,
    CBCharacteristicKindBatteryLevel = 1 << 2,
    CBCharacteristicKindManufacturer = 1 << 3,
    CBCharacteristicKindFirmwareVersion = 1 << 4,
    CBCharacteristicKindSerialNumber = 1 << 5,
    CBCharacteristicKindHardwareVersion = 1 << 6,
    CBCharacteristicKindModelNumber = 1 << 7,
    CBCharacteristicKindSoftwareVersion = 1 << 8,
};

@interface CBCharacteristic(DCExtensions)
@property(nonatomic, readonly)CBCharacteristicKind kind;
@end
