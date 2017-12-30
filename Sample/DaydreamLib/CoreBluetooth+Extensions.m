//
//  CoreBluetooth+Extensions.m
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import "CoreBluetooth+Extensions.h"

@implementation CBService(DCExtensions)

- (CBServiceKind)kind {
    NSString *const uuid = self.UUID.UUIDString;
    if([uuid isEqualToString:@"FE55"]) {
        return CBServiceKindState;
    }
    else if([uuid isEqualToString:@"180F"]) {
        return CBServiceKindBattery;
    }
    else if([uuid isEqualToString:@"180A"]) {
        return CBServiceKindDeviceInfo;
    }
    return CBServiceKindUnknown;
}

@end

@implementation CBCharacteristic(DCExtensions)
- (CBCharacteristicKind)kind {
    NSString *const uuid = self.UUID.UUIDString;
    if([uuid isEqualToString:@"00000001-1000-1000-8000-00805F9B34FB"]) {
        return CBCharacteristicKindState;
    }
    else if([uuid isEqualToString:@"2A29"]) {
        return CBCharacteristicKindManufacturer;
    }
    else if([uuid isEqualToString:@"2A19"]) {
        return CBCharacteristicKindBatteryLevel;
    }
    else if([uuid isEqualToString:@"2A26"]) {
        return CBCharacteristicKindFirmwareVersion;
    }
    else if([uuid isEqualToString:@"2A25"]) {
        return CBCharacteristicKindSerialNumber;
    }
    else if([uuid isEqualToString:@"2A27"]) {
        return CBCharacteristicKindHardwareVersion;
    }
    else if([uuid isEqualToString:@"2A24"]) {
        return CBCharacteristicKindModelNumber;
    }
    else if([uuid isEqualToString:@"2A28"]) {
        return CBCharacteristicKindSoftwareVersion;
    }
    return CBCharacteristicKindUnknown;
}
@end
