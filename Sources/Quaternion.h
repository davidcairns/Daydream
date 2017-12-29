//
//  Quaternion.h
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import "Vect3.h"

typedef struct Quaternion {
    double x, y, z, w;
} Quaternion;

Quaternion QuaternionMake(double x, double y, double z, double w);
Quaternion QuaternionMakeFromAxisAngle(Vect3 axis, double angle);

double QuaternionMagnitude(Quaternion q);
Quaternion QuaternionConjugate(Quaternion q);
Quaternion QuaternionNormalized(Quaternion q);
Quaternion QuaternionInverse(Quaternion q);
Quaternion QuaternionTimesQuaternion(Quaternion q1, Quaternion q2);


typedef struct Matrix3x3 {
    double m11, m12, m13, m14;
    double m21, m22, m23, m24;
    double m31, m32, m33, m34;
    double m41, m42, m43, m44;
} Matrix3x3;

Matrix3x3 QuaternionGetMatrix (Quaternion q);
