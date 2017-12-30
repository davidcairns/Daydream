//
//  Vect3.m
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import "Vect3.h"
#import <math.h>

Vect3 Vect3Make(double x, double y, double z) {
    Vect3 v;
    v.x = x;
    v.y = y;
    v.z = z;
    return v;
}

double Vect3Magnitude(Vect3 v) {
    return sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

Vect3 Vect3Normalize(Vect3 v) {
    const double m = Vect3Magnitude(v);
    return Vect3Make(v.x / m,
                     v.y / m,
                     v.z / m);
}

double Vect3Dot(Vect3 u, Vect3 v) {
    return u.x * v.x + u.y * v.y + u.z * v.z;
}

Vect3 Vect3Cross(Vect3 u, Vect3 v) {
    return Vect3Make(u.y * v.z - u.z * v.y,
                     u.z * v.x - u.x * v.z,
                     u.x * v.y - u.y * v.x);
}
