//
//  CoreBluetooth+Extensions.h
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/// A `CBService` extension to easily identify services based on UUID.
typedef NS_ENUM(NSUInteger, CBServiceKind) {
    CBServiceKindUnknown,
    CBServiceKindState,
    CBServiceKindDeviceInfo,
    CBServiceKindBattery,
};

@interface CBService(DCExtensions)
@property(nonatomic, readonly)CBServiceKind kind;
@end


// MARK: -
typedef NS_ENUM(NSUInteger, CBCharacteristicKind) {
    CBCharacteristicKindUnknown,
    CBCharacteristicKindState,
    CBCharacteristicKindBatteryLevel,
    CBCharacteristicKindManufacturer,
    CBCharacteristicKindFirmwareVersion,
    CBCharacteristicKindSerialNumber,
    CBCharacteristicKindHardwareVersion,
    CBCharacteristicKindModelNumber,
    CBCharacteristicKindSoftwareVersion,
};

@interface CBCharacteristic(DCExtensions)
@property(nonatomic, readonly)CBCharacteristicKind kind;
@end
