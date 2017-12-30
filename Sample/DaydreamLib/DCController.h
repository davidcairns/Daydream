//
//  DCController.h
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DCTouchpad.h"
#import "DCControllerButton.h"
#import "Quaternion.h"

extern NSString * _Nonnull const DCControllerDidConnectNotification;
extern NSString * _Nonnull const DCControllerDidUpdateBatteryLevelNotification;
extern NSString * _Nonnull const DCControllerDidDisconnectNotification;

@interface DCController : NSObject

/// The services offered by the Daydream View controller
+ (NSArray<CBUUID *> * _Nonnull)serviceUUIDs;

/// The internal `CBPeripheral` represented by this controller instance.
@property(nonatomic, strong)CBPeripheral * _Nonnull peripheral;

// MARK: Input Devices
/// The touch pad of the device.
@property(nonatomic, strong)DCTouchpad * _Nonnull touchpad;
/// The "app" button, which is the top button on the front of the controller.
@property(nonatomic, strong)DCControllerButton * _Nonnull appButton;
/// The home button, which is the bottom button on the front of the controller.
@property(nonatomic, strong)DCControllerButton * _Nonnull homeButton;
/// Volume buttons are on the side.
@property(nonatomic, strong)DCControllerButton * _Nonnull volumeUpButton;
@property(nonatomic, strong)DCControllerButton * _Nonnull volumeDownButton;

typedef void(^OrientationChangedHandler)(Quaternion);
@property(nonatomic, strong)OrientationChangedHandler _Nullable orientationChangedHandler;


/// MARK: Device Information
/// The battery level of the controller.
/// Note: Call `updateBatteryLevel` on the controller object periodically to update this value.
@property(nonatomic, assign)double batteryLevel;
/// The manufacturer of the controller.
@property(nonatomic, copy)NSString * _Nonnull manufacturer;
/// The firmware version of the controller.
@property(nonatomic, copy)NSString * _Nonnull firmwareVersion;
/// The serial number of the controller.
@property(nonatomic, copy)NSString * _Nonnull serialNumber;
/// The model number of the controller.
@property(nonatomic, copy)NSString * _Nonnull modelNumber;
/// The hardware version of the controller.
@property(nonatomic, copy)NSString * _Nonnull hardwareVersion;
/// The software version of the controller.
@property(nonatomic, copy)NSString * _Nonnull softwareVersion;


/// Warning: Call `DCConnectionmanager.startDaydreamControllerDiscovery()` rather than instantiating this class directly.
- (_Nonnull instancetype)initWithPeripheral:(CBPeripheral * _Nonnull)peripheral;
- (void)updateBatteryLevel;
- (void)didConnect;

@end
