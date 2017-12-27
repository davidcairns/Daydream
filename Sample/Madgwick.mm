//
//  Madgwick.m
//  DaydreamSample
//
//  Created by David Cairns on 12/26/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import "Madgwick.h"
#import "MadgwickAHRS.h"

@interface Madgwick () {
    MadgwickAHRS madgwick_;
}
@end

@implementation Madgwick

- (instancetype)initWithFrequency:(double)sampleFrequency {
    if((self = [super init])) {
        madgwick_.begin(sampleFrequency);
    }
    return self;
}

- (void)updateWithGx:(double)gx gy:(double)gy gz:(double)gz
                  ax:(double)ax ay:(double)ay az:(double)az
                  mx:(double)mx my:(double)my mz:(double)mz {
    madgwick_.update(gx, gy, gz, ax, ay, az, mx, my, mz);
}

- (void)updateWithGyro:(CMAcceleration)gyro
          acceleration:(CMAcceleration)acceleration
          magnetometer:(CMAcceleration)magnetometer {
    [self updateWithGx:gyro.x gy:gyro.y gz:gyro.z
                    ax:acceleration.x ay:acceleration.y az:acceleration.z
                    mx:magnetometer.x my:magnetometer.y mz:magnetometer.z];
}



- (double)roll {
    return madgwick_.getRoll();
}

- (double)pitch {
    return madgwick_.getPitch();
}

- (double)yaw {
    return madgwick_.getYaw();
}

- (double)rollRadians {
    return madgwick_.getRollRadians();
}

- (double)pitchRadians {
    return madgwick_.getPitchRadians();
}

- (double)yawRadians {
    return madgwick_.getYawRadians();
}

@end
