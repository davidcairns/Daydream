//
//  Vect3.swift
//  DaydreamSample
//
//  Created by David Cairns on 12/28/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

import Foundation

typealias Vect3 = (x: Double, y: Double, z: Double)
func Vect3Dot(_ u: Vect3, _ v: Vect3) -> Double {
    return u.x * v.x + u.y * v.y + u.z * v.z
}
func Vect3Cross(_ u: Vect3, _ v: Vect3) -> Vect3 {
    return (x: u.y * v.z - u.z * v.y,
            y: u.z * v.x - u.x * v.z,
            z: u.x * v.y - u.y * v.x)
}
func Vect3Magnitude(_ v: Vect3) -> Double {
    return sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
}
func Vect3Normalize(_ v: Vect3) -> Vect3 {
    let m = Vect3Magnitude(v)
    return (x: v.x / m,
            y: v.y / m,
            z: v.z / m)
}
