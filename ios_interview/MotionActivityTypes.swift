//
//  ActivityTypes.swift
//  Ethica
//
//  Created by amin tavassolian on 2017-06-16.
//  Copyright © 2017 EthicaDataServices. All rights reserved.
//

import Foundation

enum MotionActivityTypes: Int {
    case UNKNOWN = 0
    case STILL = 1
    case WALKING = 4
    case RUNNING = 5
    case BIKING = 6
    case VEHICLE = 7

    static func getString(type: Int) -> String {
        switch type {
        case MotionActivityTypes.STILL.rawValue:
            return "stationary"
        case MotionActivityTypes.WALKING.rawValue:
            return "walking"
        case MotionActivityTypes.RUNNING.rawValue:
            return "running"
        case MotionActivityTypes.BIKING.rawValue:
            return "biking"
        case MotionActivityTypes.VEHICLE.rawValue:
            return "driving"
        case MotionActivityTypes.UNKNOWN.rawValue: fallthrough
        default:
            return "unknown"
        }
    }
}
