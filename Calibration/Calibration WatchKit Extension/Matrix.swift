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
    
    public let roll: Double
    public let pitch: Double
    public let yaw: Double
    
    public init(roll: Double, pitch: Double, yaw: Double) {
        self.roll = roll
        self.pitch = pitch
        self.yaw = yaw
    }
    
    private func makeRotationMatrixRoll(roll: Double) -> simd_double3x3 {
        let rows = [
            simd_double3(   1,            0,           0 ),
            simd_double3(   0,    cos(roll),   sin(roll) ),
            simd_double3(   0,   -sin(roll),   cos(roll) )
        ]
        
        return double3x3(rows: rows)
    }
    
    private func makeRotationMatrixPitch(pitch: Double) -> simd_double3x3 {
        let rows = [
            simd_double3(   cos(pitch),   0,   -sin(pitch) ),
            simd_double3(            0,   1,             0 ),
            simd_double3(   sin(pitch),   0,    cos(pitch) )
        ]
        
        return double3x3(rows: rows)
    }
    
    private func makeRotationMatrixYaw(yaw: Double) -> simd_double3x3 {
        let rows = [
            simd_double3(    cos(yaw),   sin(yaw),   0 ),
            simd_double3(   -sin(yaw),   cos(yaw),   0 ),
            simd_double3(           0,          0,   1 )
        ]
        
        return double3x3(rows: rows)
    }
    
    
    public func rotation(roll: Double, pitch: Double, yaw: Double) {
        
    }
}
