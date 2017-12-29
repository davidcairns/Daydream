//
//  Quaternion.swift
//  DaydreamSample
//
//  Created by David Cairns on 12/28/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

import Foundation
import UIKit

extension CMQuaternion: CustomStringConvertible {
    static func from(axis: Vect3, angle: Double) -> CMQuaternion {
        let n = Vect3Normalize(axis)
        let halfAngle = angle / 2.0
        let sin_a = sin(halfAngle)
        let cos_a = cos(halfAngle)
        return CMQuaternion(x: n.x * sin_a,
                            y: n.y * sin_a,
                            z: n.z * sin_a,
                            w: cos_a)
    }
    
    var matrix: CATransform3D {
        let x2 = x + x
        let y2 = y + y
        let z2 = z + z
        let xx = x * x2
        let xy = x * y2
        let xz = x * z2
        let yy = y * y2
        let yz = y * z2
        let zz = z * z2
        let wx = w * x2
        let wy = w * y2
        let wz = w * z2
        
//        let t = CATransform3D(m11: CGFloat(1 - (yy + zz)),  m12: CGFloat(xy + wz),          m13: CGFloat(xz - wy),          m14: CGFloat(0),
//                              m21: CGFloat(xy - wz),        m22: CGFloat(1 - (xx + zz)),    m23: CGFloat(yz + wx),          m24: CGFloat(0),
//                              m31: CGFloat(xz + wy),        m32: CGFloat(yz - wx),          m33: CGFloat(1 - (xx + yy)),    m34: CGFloat(0),
//                              m41: CGFloat(0),              m42: CGFloat(0),                m43: CGFloat(0),                m44: CGFloat(1))
        let t = CATransform3D(m11: CGFloat(1 - (yy + zz)),  m12: CGFloat(xy - wz),          m13: CGFloat(xz + wy),          m14: CGFloat(0),
                              m21: CGFloat(xy + wz),        m22: CGFloat(1 - (xx + zz)),    m23: CGFloat(yz - wx),          m24: CGFloat(0),
                              m31: CGFloat(xz - wy),        m32: CGFloat(yz + wx),          m33: CGFloat(1 - (xx + yy)),    m34: CGFloat(0),
                              m41: CGFloat(0),              m42: CGFloat(0),                m43: CGFloat(0),                m44: CGFloat(1))
        
        return t
    }
    
    var magnitude: Double {
        return sqrt(x * x + y * y + z * z + w * w)
    }
    
    var conjugate: CMQuaternion {
        return CMQuaternion(x: -x, y: -y, z: -z, w: w)
    }
    
    var normalized: CMQuaternion {
        let m = self.magnitude
        return CMQuaternion(x: x / m, y: y / m, z: z / m, w: w / m)
    }
    
    var inverse: CMQuaternion {
        return self.conjugate.normalized
    }
    
    func times(quaternion q2: CMQuaternion) -> CMQuaternion {
        let q1 = self
        return CMQuaternion(x: q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y,
                            y: q1.w * q2.y + q1.y * q2.w + q1.z * q2.x - q1.x * q2.z,
                            z: q1.w * q2.z + q1.z * q2.w + q1.x * q2.y - q1.y * q2.x,
                            w: q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z) 
    }
    
    var roll: Double {
        let sinr = 2.0 * (w * x + y * z)
        let cosr = 1.0 - 2.0 * (x * x + y * y)
        return atan2(sinr, cosr)
    }
    var pitch: Double {
        let sinp = 2.0 * (w * y - z * x)
        if fabs(sinp) >= 1.0 {
            return copysign(Double.pi / 2.0, sinp)
        }
        else {
            return asin(sinp)
        }
    }
    var yaw: Double {
        let siny = 2.0 * (w * z + x * y)
        let cosy = 1.0 - 2.0 * (y * y + z * z)
        return atan2(siny, cosy)
    }
    
    public var description: String {
        let x_ = Double(Int(x * 100.0)) / 100.0
        let y_ = Double(Int(y * 100.0)) / 100.0
        let z_ = Double(Int(z * 100.0)) / 100.0
        let w_ = Double(Int(w * 100.0)) / 100.0
        return "(\(x_),\t\(y_),\t\(z_),\t\(w_))"
    }
}
