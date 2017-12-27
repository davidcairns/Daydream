//
//  Madgwick.h
//  DaydreamSample
//
//  Created by David Cairns on 12/26/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface Madgwick : NSObject

- (instancetype)initWithFrequency:(double)sampleFrequency;

- (void)updateWithGx:(double)gx gy:(double)gy gz:(double)gz
                  ax:(double)ax ay:(double)ay az:(double)az
                  mx:(double)mx my:(double)my mz:(double)mz;

- (void)updateWithGyro:(CMAcceleration)gyro
          acceleration:(CMAcceleration)acceleration
          magnetometer:(CMAcceleration)magnetometer;

- (double)roll;
- (double)pitch;
- (double)yaw;
- (double)rollRadians;
- (double)pitchRadians;
- (double)yawRadians;

@end
