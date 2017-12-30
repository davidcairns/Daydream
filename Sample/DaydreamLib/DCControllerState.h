//
//  DCControllerState.h
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "Vect3.h"
#import "Quaternion.h"

// "DCControllerState" is a snapshot of the Daydream remote’s state.
// 
// This class uses the parsing mechanisms from Matteo Pisani’s post(s):
// https://hackernoon.com/how-i-hacked-google-daydream-controller-c4619ef318e4
// and is based heavily on this project by Sachin Patel:
// https://github.com/gizmosachin/Daydream
//

#ifdef __cplusplus
extern "C" {
#endif

typedef NS_OPTIONS(int, DCControllerButtons) {
    DCControllerButtonsClick = 1 << 0,
    DCControllerButtonsHome = 1 << 1,
    DCControllerButtonsApp = 1 << 2,
    DCControllerButtonsVolumeDown = 1 << 3,
    DCControllerButtonsVolumeUp = 1 << 4,
};

typedef struct DCControllerState {
    CGPoint touchPoint;
    DCControllerButtons buttons;
    Vect3 gyro;
    Vect3 acceleration;
    Vect3 magnetometer;
} DCControllerState;

DCControllerState DCControllerStateMake(NSData *data);

Quaternion DCControllerStateGetOrientation(DCControllerState state);

#ifdef __cplusplus
}
#endif
