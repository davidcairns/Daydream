//
//  OrientationDataParsing.h
//  DaydreamSample
//
//  Created by David Cairns on 12/26/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "Vect3.h"

int MagnetometerXFromData(NSData *data);
int MagnetometerYFromData(NSData *data);
int MagnetometerZFromData(NSData *data);

int AccelerationXFromData(NSData *data);
int AccelerationYFromData(NSData *data);
int AccelerationZFromData(NSData *data);

int GyroXFromData(NSData *data);
int GyroYFromData(NSData *data);
int GyroZFromData(NSData *data);

Vect3 DCMakeVec3(double x, double y, double z);

Vect3 AdjustedMagnetometerFromData(NSData *data);
Vect3 AdjustedAccelerometerFromData(NSData *data);
Vect3 AdjustedGyroFromData(NSData *data);

// Touch Point
double TouchPointX(NSData *data);
double TouchPointY(NSData *data);
