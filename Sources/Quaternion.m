//
//  Quaternion.m
//  DaydreamSample
//
//  Created by David Cairns on 12/29/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

#import "Quaternion.h"
#import <math.h>

Quaternion QuaternionMake(double x, double y, double z, double w) {
    Quaternion q;
    q.x = x;
    q.y = y;
    q.z = z;
    q.w = w;
    return q;
}

Quaternion QuaternionMakeFromAxisAngle(Vect3 axis, double angle) {
    const Vect3 n = Vect3Normalize(axis);
    const double halfAngle = angle / 2.0;
    const double sin_a = sin(halfAngle);
    const double cos_a = cos(halfAngle);
    return QuaternionMake(n.x * sin_a,
                          n.y * sin_a,
                          n.z * sin_a,
                          cos_a);
}


double QuaternionMagnitude(Quaternion q) {
    return sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w);
}

Quaternion QuaternionConjugate(Quaternion q) {
    return QuaternionMake(-q.x, -q.y, -q.z, q.w);
}

Quaternion QuaternionNormalized(Quaternion q) {
    const double m = QuaternionMagnitude(q);
    return QuaternionMake(q.x / m, q.y / m, q.z / m, q.w / m);
}

Quaternion QuaternionInverse(Quaternion q) {
    return QuaternionNormalized(QuaternionConjugate(q));
}

Quaternion QuaternionTimesQuaternion(Quaternion q1, Quaternion q2) {
    return QuaternionMake(q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y,
                          q1.w * q2.y + q1.y * q2.w + q1.z * q2.x - q1.x * q2.z,
                          q1.w * q2.z + q1.z * q2.w + q1.x * q2.y - q1.y * q2.x,
                          q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z);
}

//var roll: Double {
//    let sinr = 2.0 * (w * x + y * z)
//    let cosr = 1.0 - 2.0 * (x * x + y * y)
//    return atan2(sinr, cosr)
//}
//var pitch: Double {
//    let sinp = 2.0 * (w * y - z * x)
//    if fabs(sinp) >= 1.0 {
//        return copysign(Double.pi / 2.0, sinp)
//    }
//    else {
//        return asin(sinp)
//    }
//}
//var yaw: Double {
//    let siny = 2.0 * (w * z + x * y)
//    let cosy = 1.0 - 2.0 * (y * y + z * z)
//    return atan2(siny, cosy)
//}
//
//public var description: String {
//    let x_ = Double(Int(x * 100.0)) / 100.0
//    let y_ = Double(Int(y * 100.0)) / 100.0
//    let z_ = Double(Int(z * 100.0)) / 100.0
//    let w_ = Double(Int(w * 100.0)) / 100.0
//    return "(\(x_),\t\(y_),\t\(z_),\t\(w_))"
//}


Matrix3x3 Matrix3x3Make(double m11, double m12, double m13, double m14,
                        double m21, double m22, double m23, double m24,
                        double m31, double m32, double m33, double m34,
                        double m41, double m42, double m43, double m44) {
    Matrix3x3 m;
    m.m11 = m11;
    m.m12 = m12;
    m.m13 = m13;
    m.m14 = m14;
    m.m21 = m21;
    m.m22 = m22;
    m.m23 = m23;
    m.m24 = m24;
    m.m31 = m31;
    m.m32 = m32;
    m.m33 = m33;
    m.m34 = m34;
    m.m41 = m41;
    m.m42 = m42;
    m.m43 = m43;
    m.m44 = m44;
    return m;
}


Matrix3x3 QuaternionGetMatrix(Quaternion q) {
    const double x2 = q.x + q.x;
    const double y2 = q.y + q.y;
    const double z2 = q.z + q.z;
    const double xx = q.x * x2;
    const double xy = q.x * y2;
    const double xz = q.x * z2;
    const double yy = q.y * y2;
    const double yz = q.y * z2;
    const double zz = q.z * z2;
    const double wx = q.w * x2;
    const double wy = q.w * y2;
    const double wz = q.w * z2;
    
//    let t = CATransform3D(m11: CGFloat(1 - (yy + zz)),  m12: CGFloat(xy + wz),          m13: CGFloat(xz - wy),          m14: CGFloat(0),
//                          m21: CGFloat(xy - wz),        m22: CGFloat(1 - (xx + zz)),    m23: CGFloat(yz + wx),          m24: CGFloat(0),
//                          m31: CGFloat(xz + wy),        m32: CGFloat(yz - wx),          m33: CGFloat(1 - (xx + yy)),    m34: CGFloat(0),
//                          m41: CGFloat(0),              m42: CGFloat(0),                m43: CGFloat(0),                m44: CGFloat(1))
    return Matrix3x3Make((double)(1 - (yy + zz)),  (double)(xy - wz),          (double)(xz + wy),          (double)(0),
                         (double)(xy + wz),        (double)(1 - (xx + zz)),    (double)(yz - wx),          (double)(0),
                         (double)(xz - wy),        (double)(yz + wx),          (double)(1 - (xx + yy)),    (double)(0),
                         (double)(0),              (double)(0),                (double)(0),                (double)(1));
}
