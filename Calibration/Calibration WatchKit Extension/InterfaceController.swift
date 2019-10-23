//
//  InterfaceController.swift
//  Calibration WatchKit Extension
//
//  Created by Prashuk Ajmera on 9/19/19.
//  Copyright © 2019 Prashuk Ajmera. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion

class InterfaceController: WKInterfaceController {

    let manager = CMMotionManager()
    var refAttitide = CMAttitude()
    
    var userDisplacementX: Double = 0.00
    var userDisplacementY: Double = 0.00
    var userDisplacementZ: Double = 0.00
    
    var totalUserDisplacementX: Double = 0.00
    var totalUserDisplacementY: Double = 0.00
    var totalUserDisplacementZ: Double = 0.00

    var userInitialVelocityX: Double = 0.00
    var userInitialVelocityY: Double = 0.00
    var userInitialVelocityZ: Double = 0.00
    
    var currentTime = 0.0
    
    let armLength: Double = 10.00 // assume
    
    var totalTime = 0.00
    var deltaTime = 0.00
    var accYWRTBody = 0.00
    var accZWRTBody = 0.00
    var flag = 0
    
    var timer = Timer()
        
    var filterX = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 0.01)
    var filterY = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 0.01)
    var filterZ = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 0.01)
    
    var t3 = Double(), t2 = Double(), t1 = Double(), t0 = Double()
    var a2 = vector3(0.00, 0.00, 0.00), a1 = vector3(0.00, 0.00, 0.00), a0 = vector3(0.00, 0.00, 0.00), v3 = vector3(0.00, 0.00, 0.00), v2 = vector3(0.00, 0.00, 0.00), v1 = vector3(0.00, 0.00, 0.00), d = vector3(0.00, 0.00, 0.00)
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        deviceMotionData()
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    func deviceMotionData() {
        
        if manager.isDeviceMotionAvailable {
            self.manager.deviceMotionUpdateInterval = 1.0 / 100.0
            self.manager.showsDeviceMovementDisplay = true
            self.manager.startDeviceMotionUpdates(using: .xArbitraryZVertical)
            
            self.timer = Timer(fire: Date(), interval: (1.0 / 100.0), repeats: true, block: { (timer) in
                if let data = self.manager.deviceMotion {
                    let a = simd_double3(x: data.attitude.rotationMatrix.m11, y: data.attitude.rotationMatrix.m12, z: data.attitude.rotationMatrix.m13)
                    let b = simd_double3(x: data.attitude.rotationMatrix.m21, y: data.attitude.rotationMatrix.m22, z: data.attitude.rotationMatrix.m23)
                    let c = simd_double3(x: data.attitude.rotationMatrix.m31, y: data.attitude.rotationMatrix.m32, z: data.attitude.rotationMatrix.m33)

                    let rm = simd_double3x3(rows: [a,b,c])
                    let accel = simd_double3(x: data.userAcceleration.x, y: data.userAcceleration.y, z: data.userAcceleration.z)
                    let mutli = simd_mul(accel, rm)
                    print("\(data.attitude.pitch),\(data.attitude.roll),\(data.attitude.yaw),\(data.gravity.x),\(data.gravity.y),\(data.gravity.z),\(mutli.x),\(mutli.y),\(mutli.z),\(data.userAcceleration.x),\(data.userAcceleration.y),\(data.userAcceleration.z),\(data.rotationRate.x),\(data.rotationRate.y),\(data.rotationRate.z)")
                }
            })
            
            RunLoop.current.add(self.timer, forMode: RunLoop.Mode.default)
        }
    }
    
    @IBAction func getImu() {
        deviceMotionData()
    }
    
    @IBAction func stopMotion() {
        manager.stopDeviceMotionUpdates()

        let distX = totalUserDisplacementX
        let distY = totalUserDisplacementY
        let distZ = totalUserDisplacementZ
        print("FX= \(distX), FY= \(distY), FZ= \(distZ)")
        
        // Net Distance in x & z direction
        let netDist = (distX*distX + distZ*distZ).squareRoot()
        print(netDist)

//        // Angle calculation
//        let angleX = distX / armLength
//        let angleY = distY / armLength
//        let angleZ = distZ / armLength
//        print(angleX, angleY, angleZ)

        // Data Reset
        userDisplacementX = 0.00
        userDisplacementY = 0.00
        userDisplacementZ = 0.00
        
        totalUserDisplacementX = 0.00
        totalUserDisplacementY = 0.00
        totalUserDisplacementZ = 0.00

        userInitialVelocityX = 0.00
        userInitialVelocityY = 0.00
        userInitialVelocityZ = 0.00

        filterX = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 0.01)
        filterY = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 0.01)
        filterZ = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 0.01)
        
        flag = 0
    }

}
