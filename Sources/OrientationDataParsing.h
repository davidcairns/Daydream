//
//  OrientationDataParsing.h
//  DaydreamSample
//
//  Created by David Cairns on 12/26/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

int MagnetometerXFromData(NSData *data);
int MagnetometerYFromData(NSData *data);
int MagnetometerZFromData(NSData *data);

int AccelerationXFromData(NSData *data);
int AccelerationYFromData(NSData *data);
int AccelerationZFromData(NSData *data);

int GyroXFromData(NSData *data);
int GyroYFromData(NSData *data);
int GyroZFromData(NSData *data);

CMAcceleration DCMakeVec3(double x, double y, double z);

CMAcceleration NormalizedMagnetometerFromData(NSData *data);
CMAcceleration NormalizedAccelerometerFromData(NSData *data);
CMAcceleration NormalizedGyroFromData(NSData *data);
