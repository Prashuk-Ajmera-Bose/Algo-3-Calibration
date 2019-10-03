//
//  Matrix.swift
//  Calibration WatchKit Extension
//
//  Created by Prashuk Ajmera on 9/20/19.
//  Copyright © 2019 Prashuk Ajmera. All rights reserved.
//

import Foundation
import simd

class Matrix {
    
    public let x: Double
    public let y: Double
    public let z: Double
    public let matForm: [simd_double3]

    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
        
        matForm = [
            simd_double3( x ),
            simd_double3( y ),
            simd_double3( z )
        ]
    }
    
    public func makeRotationMatrixPitch(pitch: Double) -> simd_double3x3 {
        let rows = [
            simd_double3(   1,             0,             0 ),
            simd_double3(   0,    cos(pitch),   -sin(pitch) ),
            simd_double3(   0,    sin(pitch),    cos(pitch) )
        ]
        
        return double3x3(rows: rows)
    }
    
    public func makeRotationMatrixRoll(roll: Double) -> simd_double3x3 {
        let rows = [
            simd_double3(    cos(roll),   0,    sin(roll) ),
            simd_double3(            0,   1,            0 ),
            simd_double3(   -sin(roll),   0,    cos(roll) )
        ]
        
        return double3x3(rows: rows)
    }
    
    public func makeRotationMatrixYaw(yaw: Double) -> simd_double3x3 {
        let rows = [
            simd_double3(   cos(yaw),   -sin(yaw),   0 ),
            simd_double3(   sin(yaw),    cos(yaw),   0 ),
            simd_double3(           0,          0,   1 )
        ]
        
        return double3x3(rows: rows)
    }
    
    
    public func rotation(pitch: Double, roll: Double, yaw: Double) -> simd_double3x3 {
        return makeRotationMatrixPitch(pitch: pitch) * makeRotationMatrixRoll(roll: roll) * makeRotationMatrixYaw(yaw: yaw) * double3x3(rows: matForm)
    }
}

