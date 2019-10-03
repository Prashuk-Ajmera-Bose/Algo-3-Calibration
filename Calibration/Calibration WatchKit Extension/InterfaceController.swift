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
        
    var filterX = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 0.01)
    var filterY = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 0.01)
    var filterZ = KalmanFilter(stateEstimatePrior: 0.0, errorCovariancePrior: 0.01)
    
    var t3 = Double(), t2 = Double(), t1 = Double(), t0 = Double()
    var a2 = vector3(0.00, 0.00, 0.00), a1 = vector3(0.00, 0.00, 0.00), a0 = vector3(0.00, 0.00, 0.00), v3 = vector3(0.00, 0.00, 0.00), v2 = vector3(0.00, 0.00, 0.00), v1 = vector3(0.00, 0.00, 0.00), d = vector3(0.00, 0.00, 0.00)
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
//        let x = Matrix(x: 1, y: 0, z: 0)
//        print(x)
//        print(x.makeRotationMatrixYaw(yaw: .pi/2))
        
//        print("User Acc X,User Acc Y,User Acc Z,Grav X,Grav Y,Grav Z,Pitch,Roll,Yaw")
        
        deviceMotionData()
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    func deviceMotionData() {
        
//        if manager.isDeviceMotionAvailable {
//
//            manager.deviceMotionUpdateInterval = 1.0 / 60.0
//            manager.showsDeviceMovementDisplay = true
//            manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { (data, error) in
//                guard let data = data, error == nil else {
//                    return
//                }
//
//                let ua = data.userAcceleration
//                let rm = data.attitude.rotationMatrix
//
////                print(self.t0, self.t1, self.t2, self.t3)
//
//                self.a2 = self.a1
//                self.a1 = self.a0
//                let x = simd_double3(x: rm.m11, y: rm.m12, z: rm.m13)
//                let y = simd_double3(x: rm.m21, y: rm.m22, z: rm.m23)
//                let z = simd_double3(x: rm.m31, y: rm.m32, z: rm.m33)
//                let uav = simd_double3(x: ua.x, y: ua.y, z: ua.z)
//                self.a0 = simd_mul(uav, simd_double3x3(rows: [x,y,z]))
//
////                print(self.a1)
//
//                self.v3 = self.v2
//                self.v2 = self.v1
//
////                print(self.a0,self.a1,self.a2)
//
//                self.v1.x += (0.015) * (self.a2.x + (4.0 * self.a1.x) + self.a0.x)  * 9.8 / 6.0
//                self.v1.y += (0.015) * (self.a2.y + (4.0 * self.a1.y) + self.a0.y)  * 9.8 / 6.0
//                self.v1.z += (0.015) * (self.a2.z + (4.0 * self.a1.z) + self.a0.z)  * 9.8 / 6.0
//
//                self.d.x += (0.015) * self.v1.x
//                self.d.y += (0.015) * self.v1.y
//                self.d.z += (0.015) * self.v1.z
//
//                print(self.d.x, self.d.y, self.d.z)
//
////                print(self.d)
//            }
//        }
        
        if manager.isDeviceMotionAvailable {

            manager.deviceMotionUpdateInterval = 1.0 / 60.0
            manager.showsDeviceMovementDisplay = true
            manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: OperationQueue.main) { (data, error) in
                guard let data = data, error == nil else {
                    return
                }

                if self.flag == 0 {
                    self.deltaTime = 0.00
                    self.refAttitide = self.manager.deviceMotion!.attitude
                    self.flag = 1
                } else {
                    self.deltaTime = data.timestamp - self.currentTime
                }

//                // Kalman predict and update
//                let predictionX = self.filterX.predict(stateTransitionModel: 1, controlInputModel: 0, controlVector: 0, covarianceOfProcessNoise: 0)
//                let updateX = predictionX.update(measurement: data.userAcceleration.x, observationModel: 1, covarienceOfObservationNoise: 0.1)
//
//                let predictionY = self.filterY.predict(stateTransitionModel: 1, controlInputModel: 0, controlVector: 0, covarianceOfProcessNoise: 0)
//                let updateY = predictionY.update(measurement: data.userAcceleration.y, observationModel: 1, covarienceOfObservationNoise: 0.1)
//
//                let predictionZ = self.filterZ.predict(stateTransitionModel: 1, controlInputModel: 0, controlVector: 0, covarianceOfProcessNoise: 0)
//                let updateZ = predictionZ.update(measurement: data.userAcceleration.z, observationModel: 1, covarienceOfObservationNoise: 0.1)
//
//                // Updating filter value
//                self.filterX = updateX
//                self.filterY = updateY
//                self.filterZ = updateZ
                
                // Fixing the plane from the xyz plane from starting point
                let currAttitude: CMAttitude = self.manager.deviceMotion!.attitude
                currAttitude.multiply(byInverseOf: self.refAttitide)

                // Rotation of axes in xy plane 90 anti clockwise direction - new values - temp
                let newPitch = currAttitude.roll * -1
                let newRoll = currAttitude.pitch
                let newYaw = currAttitude.yaw
                
                print("\(data.attitude.pitch),\(data.attitude.roll),\(data.attitude.yaw),\(data.rotationRate.x),\(data.rotationRate.y),\(data.rotationRate.z)")
                
//                print("\(data.attitude.pitch),\(data.attitude.roll),\(data.attitude.yaw),\(currAttitude.pitch),\(currAttitude.roll),\(currAttitude.yaw),\(newPitch),\(newRoll),\(newYaw),\(data.gravity.x),\(data.gravity.y),\(data.gravity.z),\(data.userAcceleration.x),\(data.userAcceleration.y),\(data.userAcceleration.z)")

                // v_avg = (v_i + v_i-1) / 2
                // v_i = a_i * (t_i - t_i-1)
                // x_i = v_avg * (t_i - t_i-1)
                // x_t = x_t + x_i

//                // Acceleration components
//                self.accYWRTBody = data.userAcceleration.z * 9.8 * sin(newPitch)
//                self.accZWRTBody = data.userAcceleration.z * 9.8 * cos(newPitch)
//
//                // method2.csv
//                // Average Velocity  - graphs - actualNewData.csv
//                let avgVelocityY = ((self.accYWRTBody * self.deltaTime) + self.userInitialVelocityY) / 2
//                let avgVelocityZ = ((self.accZWRTBody * self.deltaTime) + self.userInitialVelocityZ) / 2
//
//                // New initial Velocities for next step
//                self.userInitialVelocityY = self.accYWRTBody * self.deltaTime
//                self.userInitialVelocityZ = self.accZWRTBody * self.deltaTime
//
//                // Displacements in Y and Z direction
//                self.userDisplacementY = (avgVelocityY * self.deltaTime)
//                self.userDisplacementZ = (avgVelocityZ * self.deltaTime)
//
//                // Total displacements
//                self.totalUserDisplacementY = self.totalUserDisplacementY + self.userDisplacementY
//                self.totalUserDisplacementZ = self.totalUserDisplacementZ + self.userDisplacementZ
//                print("\(avgVelocityY),\(avgVelocityZ),\(self.userInitialVelocityY),\(self.userInitialVelocityZ),\(self.userDisplacementY),\(self.userDisplacementZ),\(self.totalUserDisplacementY),\(self.totalUserDisplacementZ)")

                // s = (u2 - u1)(t2 - t1) + 1/2a(t2 - t1)^2
                // v = (u2 - u1) + a(t2 - t1)

                // method1.csv
//                // Displacements in Y and Z direction - graphs - actualNewData2.csv
//                self.userDisplacementY = (self.userInitialVelocityY * self.deltaTime) + (0.5 * self.accYWRTBody * self.deltaTime * self.deltaTime)
//                self.userDisplacementZ = (self.userInitialVelocityZ * self.deltaTime) + (0.5 * self.accZWRTBody * self.deltaTime * self.deltaTime)
//
//                // New initial Velocities
//                self.userInitialVelocityY = self.userInitialVelocityY + self.accYWRTBody * self.deltaTime
//                self.userInitialVelocityZ = self.userInitialVelocityZ + self.accZWRTBody * self.deltaTime
//
////                // Total displacements
//                self.totalUserDisplacementY = self.totalUserDisplacementY + self.userDisplacementY
//                self.totalUserDisplacementZ = self.totalUserDisplacementZ + self.userDisplacementZ
//
//                print("\(self.accYWRTBody),\(self.accZWRTBody),\(self.userInitialVelocityY),\(self.userInitialVelocityZ),\(self.userDisplacementY),\(self.userDisplacementZ),\(self.totalUserDisplacementY),\(self.totalUserDisplacementZ)")

                // s = (u2 - u1)(t2 - t1) + 1/2a(t2 - t1)^2
                // v = (u2 - u1) + a(t2 - t1)

//                // User displacements after deltaTime
//                self.userDisplacementX = (self.userInitialVelocityX * self.deltaTime) + (self.filterX.stateEstimatePrior * 9.8 * self.deltaTime * self.deltaTime / 2)
//                self.userDisplacementY = (self.userInitialVelocityY * self.deltaTime) + (self.filterY.stateEstimatePrior * 9.8 * self.deltaTime * self.deltaTime / 2)
//                self.userDisplacementZ = (self.userInitialVelocityZ * self.deltaTime) + (self.filterZ.stateEstimatePrior * 9.8 * self.deltaTime * self.deltaTime / 2)
//
//                // Replacing initial velocities with final velocities for the next step
//                self.userInitialVelocityX = self.userInitialVelocityX + self.filterX.stateEstimatePrior * 9.8 * self.deltaTime
//                self.userInitialVelocityY = self.userInitialVelocityY + self.filterY.stateEstimatePrior * 9.8 * self.deltaTime
//                self.userInitialVelocityZ = self.userInitialVelocityZ + self.filterZ.stateEstimatePrior * 9.8 * self.deltaTime
//
//                // Total displacement
//                self.totalUserDisplacementX = self.totalUserDisplacementX + self.userDisplacementX
//                self.totalUserDisplacementY = self.totalUserDisplacementY + self.userDisplacementY
//                self.totalUserDisplacementZ = self.totalUserDisplacementZ + self.userDisplacementZ

                // Time reset
                self.currentTime = data.timestamp

                // Calibration of sensors - multi point calibration
//                if (data.gravity.x > 0.85 && data.gravity.y < 0.1 && data.gravity.z < 0.1) {
//                    print("Device motion and data reseted")
//                    self.stopMotion()
//                    print("Stopped")
//                    print("Swing your arm")
//                    self.deviceMotionData()
//                }
            }
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
