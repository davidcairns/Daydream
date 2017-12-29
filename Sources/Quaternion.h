//
//  Quaternion.h
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

typedef struct Quaternion {
    double x, y, z, w;
} Quaternion;

Quaternion QuaternionMake(double x, double y, double z, double w);
//Quaternion QuaternionFromAxisAngle(Vect3 axis, double angle);
