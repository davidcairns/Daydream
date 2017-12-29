//
//  CoreBluetooth+Extensions.swift
//  DaydreamSample
//
//  Created by David Cairns on 12/28/17.
//  Copyright © 2017 Daydream. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: - Convenience
/// A `CBService` extension to easily identify services based on UUID within `DDController` and associated classes.
extension CBService {
    enum Kind {
        case unknown
        case state
        case deviceInfo
        case battery
    }
    
    var kind: CBService.Kind {
        switch uuid.uuidString {
        case "FE55":
            return .state
        case "180F":
            return .battery
        case "180A":
            return .deviceInfo
        default:
            return .unknown
        }
    }
}

/// A `CBCharacteristic` extension to easily identify characteristics based on UUID within `DDController` and associated classes.
extension CBCharacteristic {
    enum Kind: String {
        case unknown
        case state
        case batteryLevel
        case manufacturer
        case firmwareVersion
        case serialNumber
        case hardwareVersion
        case modelNumber
        case softwareVersion
    }
    
    var kind: CBCharacteristic.Kind {
        switch uuid.uuidString {
        case "00000001-1000-1000-8000-00805F9B34FB":
            return .state
        case "2A29":
            return .manufacturer
        case "2A19":
            return .batteryLevel
        case "2A26":
            return .firmwareVersion
        case "2A25":
            return .serialNumber
        case "2A27":
            return .hardwareVersion
        case "2A24":
            return .modelNumber
        case "2A28":
            return .softwareVersion
        default:
            return .unknown
        }
    }
}
