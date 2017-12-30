//
//  DCControllerState.m
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import "DCControllerState.h"
#import <math.h>
#import "OrientationDataParsing.h"

DCControllerButtons DCControllerButtonsFromData(NSData *data) {
    uint8_t *const bytes = (uint8_t *const)data.bytes;
    uint8_t *const offset = bytes + 18;
    return *(int*)offset;
}

DCControllerState DCControllerStateMake(NSData *data) {
    DCControllerState state;
    state.gyro = AdjustedGyroFromData(data);
    state.magnetometer = AdjustedMagnetometerFromData(data);
    state.acceleration = AdjustedAccelerometerFromData(data);
    state.touchPoint = CGPointMake(TouchPointX(data), TouchPointY(data));
    state.buttons = DCControllerButtonsFromData(data);
    return state;
}

Quaternion DCControllerStateGetOrientation(DCControllerState state) {
    const double angle = sqrt(state.magnetometer.x * state.magnetometer.x
                              + state.magnetometer.y * state.magnetometer.y
                              + state.magnetometer.z * state.magnetometer.z);
    if(angle > 0) {
        const Vect3 axis = Vect3Make(state.magnetometer.x / angle,
                                     state.magnetometer.y / angle,
                                     state.magnetometer.z / angle);
        return QuaternionMakeFromAxisAngle(axis, angle);
    }
    return QuaternionMake(0, 0, 0, 1);
}
