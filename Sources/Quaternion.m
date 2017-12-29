//
//  Quaternion.m
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import "Quaternion.h"

Quaternion QuaternionMake(double x, double y, double z, double w) {
    Quaternion q;
    q.x = x;
    q.y = y;
    q.z = z;
    q.w = w;
    return q;
}

//Quaternion QuaternionFromAxisAngle(Vect3 axis, double angle) {
//    const Vect3 n = Vect3Normalize(axis);
//    const double halfAngle = angle / 2.0;
//    const double sin_a = sin(halfAngle);
//    const double cos_a = cos(halfAngle);
//    return QuaternionMake(x: n.x * sin_a,
//                        y: n.y * sin_a,
//                        z: n.z * sin_a,
//                        w: cos_a)
//}

