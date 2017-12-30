//
//  DaydreamLib.m
//  DaydreamLib
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import "DaydreamLib.h"
#import "DCConnectionManager.h"
#import <CoreGraphics/CoreGraphics.h>

// This is the interface for sending messages back to Unity.
extern void UnitySendMessage(const char *object, const char *method, const char *value);

@interface ConnectionClientImp: NSObject <DCConnectionManagerDelegate>
@property(nonatomic, copy)NSString *unityObjectName;
@property(nonatomic, copy)NSString *unityObjectConnectHandlerName;
@property(nonatomic, copy)NSString *unityObjectDisconnectHandlerName;
@property(nonatomic, copy)NSString *unityObjectStateChangedHandlerName;
@property(nonatomic, assign)CGPoint touchPoint;
@end

@implementation ConnectionClientImp
- (void)didConnectTo:(DCController * _Nonnull)controller {
    [self callUnityDidConnectCallback];
    
    [controller setStateChangedHandler:^(DCControllerState state) {
        [self callUnityStateChangedCallbackWithState:state];
    }];
}
- (void)didDisconnectFrom:(DCController * _Nonnull)controller {
    [self callUnityDidDisconnectCallback];
}

- (void)_invokeUnityMethod:(NSString *)method value:(NSString *)value {
    // TODO: Are these the right macros? Does this work?
#if UNITY_IOS || UNITY_OSX
    UnitySendMessage(self.unityObjectName.UTF8String, method.isAbsolutePath, value.UTF8String);
#endif
}
- (void)callUnityDidConnectCallback {
    [self _invokeUnityMethod:self.unityObjectConnectHandlerName value:@""];
}
- (void)callUnityDidDisconnectCallback {
    [self _invokeUnityMethod:self.unityObjectDisconnectHandlerName value:@""];
}
- (void)callUnityStateChangedCallbackWithState:(DCControllerState)state {
    // Serialize the state!
    NSDictionary *const touchPointDict = @{@"x": [NSNumber numberWithDouble:state.touchPoint.x],
                                           @"y": [NSNumber numberWithDouble:state.touchPoint.y]};
    const Quaternion orientation = DCControllerStateGetOrientation(state);
    NSDictionary *const orientationDict = @{@"x": [NSNumber numberWithDouble:orientation.x],
                                            @"y": [NSNumber numberWithDouble:orientation.y],
                                            @"z": [NSNumber numberWithDouble:orientation.z],
                                            @"w": [NSNumber numberWithDouble:orientation.w]};
    NSDictionary *const stateDict = @{@"touchPadPoint": touchPointDict,
                                      @"touchPadButton": [NSNumber numberWithBool:state.buttons & DCControllerButtonsClick],
                                      @"appButton": [NSNumber numberWithBool:state.buttons & DCControllerButtonsApp],
                                      @"homeButton": [NSNumber numberWithBool:state.buttons & DCControllerButtonsHome],
                                      @"volumeUpButton": [NSNumber numberWithBool:state.buttons & DCControllerButtonsVolumeUp],
                                      @"volumeDownButton": [NSNumber numberWithBool:state.buttons & DCControllerButtonsVolumeDown],
                                      @"orientation": orientationDict};
    NSError *serializationError = nil;
    NSData *const jsonData = [NSJSONSerialization dataWithJSONObject:stateDict
                                                             options:0
                                                               error:&serializationError];
    if(!jsonData || serializationError) {
        NSLog(@"JSON serialization failed, with error: %@", serializationError);
    }
    NSString *const stateString = [jsonData base64EncodedStringWithOptions:0];
    [self _invokeUnityMethod:self.unityObjectStateChangedHandlerName value:stateString];
}
@end

static DCConnectionManager *connectionManager = nil;
static ConnectionClientImp *connectionDelegate = nil;

extern "C" {
    void _DaydreamStartDiscovery(const char *objectName,
                                 const char *connectHandlerName,
                                 const char *disconnectHandlerName,
                                 const char *stateChangedHandlerName) {
        if(!connectionManager) {
            connectionManager = [[DCConnectionManager alloc] init];
        }
        if(!connectionDelegate) {
            connectionDelegate = [[ConnectionClientImp alloc] init];
        }
        
        connectionDelegate.unityObjectName = [NSString stringWithUTF8String:objectName];
        connectionDelegate.unityObjectConnectHandlerName = [NSString stringWithUTF8String:connectHandlerName];
        connectionDelegate.unityObjectDisconnectHandlerName = [NSString stringWithUTF8String:disconnectHandlerName];
        connectionDelegate.unityObjectStateChangedHandlerName = [NSString stringWithUTF8String:stateChangedHandlerName];
        
        connectionManager.delegate = connectionDelegate;
        [connectionManager startDaydreamControllerDiscovery];
    }
    
    void _DaydreamStopDiscovery() {
        [connectionManager stopDaydreamControllerDiscovery];
    }
}
