//
//  Data+Extensions.swift
//  DaydreamSample
//
//  Created by David Cairns on 12/28/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

import Foundation

/// A `Data` extension for conveniently transforming `Data` into a hex string, string, or integer.
extension Data {
    var hexStringValue: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    var stringValue: String {
        guard let result = String(data: self, encoding: String.Encoding.utf8) else { return "" }
        return result
    }
    
    var intValue: Int {
        guard let result = Int(hexStringValue, radix: 16) else {
            return -1
        }
        return result
    }
}
