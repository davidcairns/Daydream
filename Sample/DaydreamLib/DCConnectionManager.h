//
//  DCConnectionManager.h
//  DaydreamSample-iOS
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCController.h"

extern NSString * _Nonnull DCConnectionManagerErrorDomain;
const NSInteger DCConnectionManagerErrorCodeBluetoothOff = 2017;

@class DCConnectionManager;
@protocol DCConnectionManagerDelegate
- (void)didConnectTo:(DCController * _Nonnull)controller;
- (void)didDisconnectFrom:(DCController * _Nonnull)controller;
@end

@interface DCConnectionManager : NSObject

@property(nonatomic, weak)id<DCConnectionManagerDelegate> _Nullable delegate;

- (void)startDaydreamControllerDiscovery;
- (void)stopDaydreamControllerDiscovery;

@end
