
//
//  MotionKit.swift
//  MotionKit
//

import Foundation
import CoreMotion
import UIKit

//CMMotionManager       传感器管理类，用来启动和停止服务及获得当前传感器数据
//CMAccelerometerData   加速度传感器数据封装类
//CMAcceleration        是CMAccelerometerData的一个属性，类型是一个结构体，用x、y、z三个变量表示三个方向的重力加速度
//CMMagnetometerData    磁力传感器数据封装类
//CMMagneticField       是CMMagnetometerData的一个属性，类型是一个结构体，用x、y、z三个变量表示三个方向的磁力
//CMGyroData            陀螺仪数据封装类
//CMRotationRate        是CMGyroData的一个属性，类型是一个结构体，用x、y、z三个变量表示三个方向的角速度旋转量
//CMDeviceMotion        检测设备移动的属性的封装类，可以测量设备的加速度，角速度和设备当前姿势等
//CMAttitude            设备当前方向的测量值，分别使用roll、pitch和yaw来表示设备的旋转量、左右倾斜量和上下偏移量

/// 注意：在一般情况下，一个App仅可以创建一个CMMotionManager对象，因为此类的多个实例化之后，可能会影响从加速度计和陀螺仪接收数据的速率。


@objc protocol MotionKitDelegate {
    @objc optional  func retrieveAccelerometerValues (x: Double, y:Double, z:Double, absoluteValue: Double)
    @objc optional  func retrieveGyroscopeValues     (x: Double, y:Double, z:Double, absoluteValue: Double)
    @objc optional  func retrieveDeviceMotionObject  (deviceMotion: CMDeviceMotion)
    @objc optional  func retrieveMagnetometerValues  (x: Double, y:Double, z:Double, absoluteValue: Double)
    
    @objc optional  func getAccelerationValFromDeviceMotion        (x: Double, y:Double, z:Double)
    @objc optional  func getGravityAccelerationValFromDeviceMotion (x: Double, y:Double, z:Double)
    @objc optional  func getRotationRateFromDeviceMotion           (x: Double, y:Double, z:Double)
    @objc optional  func getMagneticFieldFromDeviceMotion          (x: Double, y:Double, z:Double)
    @objc optional  func getAttitudeFromDeviceMotion               (attitude: CMAttitude)
}

let motionKit = MotionKit()

@objc(MotionKit) public class MotionKit :NSObject{
    
    let manager = CMMotionManager()
    var delegate: MotionKitDelegate?
    
    /*
    *  init:void:
    *
    *  Discussion:
    *   Initialises the MotionKit class and throw a Log with a timestamp.
    */
    public override init(){
        NSLog("MotionKit has been initialised successfully")
    }
    
    /*
    *  getAccelerometerValues:interval:values:
    *
    *  Discussion:   原始的加速度计数据
    *   Starts accelerometer updates, providing data to the given handler through the given queue.
    *   Note that when the updates are stopped, all operations in the
    *   given NSOperationQueue will be cancelled. You can access the retrieved values either by a
    *   Trailing Closure or through a Delgate.
    */
    public func getAccelerometerValues (interval: TimeInterval = 0.1, values: ((_ x: Double, _ y: Double, _ z: Double) -> ())? ){
        var valX: Double!
        var valY: Double!
        var valZ: Double!
        if manager.isAccelerometerAvailable {
            manager.accelerometerUpdateInterval = interval
            manager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: {
                (data, error) in
                
                if let isError = error {
                    NSLog("Error: \(isError)")
                }
                valX = data!.acceleration.x
                valY = data!.acceleration.y
                valZ = data!.acceleration.z
                
                if values != nil{
                    values!(valX,valY,valZ)
                }
                
                let powX = valX * valX
                let powY = valY * valY
                let powZ = valZ * valZ

                
                let absoluteVal = sqrt(powX + powY + powZ)
                self.delegate?.retrieveAccelerometerValues!(x: valX, y: valY, z: valZ, absoluteValue: absoluteVal)
            })
        } else {
            NSLog("The Accelerometer is not available")
        }
    }
    
    /*
    *  getGyroValues:interval:values:
    *
    *  Discussion:     原始的陀螺仪数据
    *   Starts gyro updates, providing data to the given handler through the given queue.
    *   Note that when the updates are stopped, all operations in the
    *   given NSOperationQueue will be cancelled. You can access the retrieved values either by a
    *   Trailing Closure or through a Delegate.
    */
    public func getGyroValues (interval: TimeInterval = 0.1, values: ((_ x: Double, _ y: Double, _ z:Double) -> ())? ) {
        
        var valX: Double!
        var valY: Double!
        var valZ: Double!
        if manager.isGyroAvailable {
            manager.gyroUpdateInterval = interval
            manager.startGyroUpdates(to: OperationQueue.main, withHandler: {
                (data, error) in
                
                if let isError = error{
                    NSLog("Error: \(isError)")
                }
                valX = data!.rotationRate.x
                valY = data!.rotationRate.y
                valZ = data!.rotationRate.z
                
                if values != nil{
                    values!(valX, valY, valZ)
                }
                
                let powX = valX * valX
                let powY = valY * valY
                let powZ = valZ * valZ

                
                let absoluteVal = sqrt(powX + powY + powZ)
                self.delegate?.retrieveGyroscopeValues!(x: valX, y: valY, z: valZ, absoluteValue: absoluteVal)
            })
            
        } else {
            NSLog("The Gyroscope is not available")
        }
    }
    
    /*
    *  getMagnetometerValues:interval:values:
    *
    *  Discussion:     原始的磁力计数据
    *   Starts magnetometer updates, providing data to the given handler through the given queue.
    *   You can access the retrieved values either by a Trailing Closure or through a Delegate.
    */
    @available(iOS, introduced: 5.0)
    public func getMagnetometerValues (interval: TimeInterval = 0.1, values: ((_ x: Double, _ y:Double, _ z:Double) -> ())? ){
        
        var valX: Double!
        var valY: Double!
        var valZ: Double!
        if manager.isMagnetometerAvailable {
            manager.magnetometerUpdateInterval = interval
            manager.startMagnetometerUpdates(to: OperationQueue.main){
                (data, error) in
                
                if let isError = error{
                    NSLog("Error: \(isError)")
                }
                valX = data!.magneticField.x
                valY = data!.magneticField.y
                valZ = data!.magneticField.z
                
                if values != nil{
                    values!(valX, valY, valZ)
                }
                
                let powX = valX * valX
                let powY = valY * valY
                let powZ = valZ * valZ
                
                let absoluteVal = sqrt(powX + powY + powZ)
                
                self.delegate?.retrieveMagnetometerValues!(x: valX, y: valY, z: valZ, absoluteValue: absoluteVal)
            }
            
        } else {
            NSLog("Magnetometer is not available")
        }
    }
    
    /*  MARK :- DEVICE MOTION APPROACH STARTS HERE  */
    
    /*
    *  getDeviceMotionValues:interval:values:
    *
    *  Discussion:     设备运动数据   对基础的数据进行了传感器融合算法,原始加速度计和陀螺仪数据需要处理以消除其他因素（如重力）的偏差。
    *   Starts device motion updates, providing data to the given handler through the given queue.
    *   Uses the default reference frame for the device. Examine CMMotionManager's
    *   attitudeReferenceFrame to determine this. You can access the retrieved values either by a
    *   Trailing Closure or through a Delegate.
    */
    public func getDeviceMotionObject (interval: TimeInterval = 0.1, values: ((_ deviceMotion: CMDeviceMotion) -> ())? ) {
        
        if manager.isDeviceMotionAvailable{
            manager.deviceMotionUpdateInterval = interval
            manager.startDeviceMotionUpdates(to: OperationQueue.main){
                (data, error) in
                
                if let isError = error{
                    NSLog("Error: \(isError)")
                }
                if values != nil{
                    values!(data!)
                }
                self.delegate?.retrieveDeviceMotionObject!(deviceMotion: data!)
            }
            
        } else {
            NSLog("Device Motion is not available")
        }
    }
    
    
    /*  从 deviceMotion 获取用户嫁给设备的加速度 设备的总加速度为重力加速度叫上用户给的加速度
    *   getAccelerationFromDeviceMotion:interval:values:
    *   You can retrieve the processed user accelaration data from the device motion from this method.
    */
    public func getUserAccelerationFromDeviceMotion (interval: TimeInterval = 0.1, values: ((_ x:Double, _ y:Double, _ z:Double) -> ())? ) {
        
        var valX: Double!
        var valY: Double!
        var valZ: Double!
        if manager.isDeviceMotionAvailable{
            manager.deviceMotionUpdateInterval = interval
            manager.startDeviceMotionUpdates(to: OperationQueue.main){
                (data, error) in
                
                if let isError = error{
                    NSLog("Error: \(isError)")
                }
                valX = data!.userAcceleration.x
                valY = data!.userAcceleration.y
                valZ = data!.userAcceleration.z
                
                if values != nil{
                    values!(valX, valY, valZ)
                }
                
                self.delegate?.getAccelerationValFromDeviceMotion!(x: valX, y: valY, z: valZ)
            }
            
        } else {
            NSLog("Device Motion is unavailable")
        }
    }
    
    /*  从 deviceMotion 获取重力加速度
    *   getGravityAccelerationFromDeviceMotion:interval:values:
    *   You can retrieve the processed gravitational accelaration data from the device motion from this
    *   method.
    */
    public func getGravityAccelerationFromDeviceMotion (interval: TimeInterval = 0.1, values: ((_ x:Double, _ y:Double, _ z:Double) -> ())? ) {
        
        var valX: Double!
        var valY: Double!
        var valZ: Double!
        if manager.isDeviceMotionAvailable{
            manager.deviceMotionUpdateInterval = interval
            manager.startDeviceMotionUpdates(to: OperationQueue.main){
                (data, error) in
                
                if let isError = error{
                    NSLog("Error: \(isError)")
                }
                valX = data!.gravity.x
                valY = data!.gravity.y
                valZ = data!.gravity.z
                
                if values != nil{
                    values!(valX, valY, valZ)
                }
                
                self.delegate?.getGravityAccelerationValFromDeviceMotion!(x: valX, y: valY, z: valZ)
            }
            
        } else {
            NSLog("Device Motion is not available")
        }
    }
    
    
    /*  从 deviceMotion 获取设备姿态
    *   getAttitudeFromDeviceMotion:interval:values:
    *   You can retrieve the processed attitude data from the device motion from this
    *   method.
    */
    public func getAttitudeFromDeviceMotion (interval: TimeInterval = 0.1, values: ((_ attitude: CMAttitude) -> ())? ) {
        
        if manager.isDeviceMotionAvailable{
            manager.deviceMotionUpdateInterval = interval
            manager.startDeviceMotionUpdates(to: OperationQueue.main){
                 (data, error) in
                
                if let isError = error{
                    NSLog("Error: \(isError)")
                }
                if values != nil{
                    values!(data!.attitude)
                }
                
                self.delegate?.getAttitudeFromDeviceMotion!(attitude: data!.attitude)
            }
            
        } else {
            NSLog("Device Motion is not available")
        }
    }
    
    /*  从 deviceMotion 获取旋转速率
    *   getRotationRateFromDeviceMotion:interval:values:
    *   You can retrieve the processed rotation data from the device motion from this
    *   method.
    */
    public func getRotationRateFromDeviceMotion (interval: TimeInterval = 0.1, values: ((_ x:Double, _ y:Double, _ z:Double) -> ())? ) {
        
        var valX: Double!
        var valY: Double!
        var valZ: Double!
        if manager.isDeviceMotionAvailable{
            manager.deviceMotionUpdateInterval = interval
            manager.startDeviceMotionUpdates(to: OperationQueue.main){
                 (data, error) in
                
                if let isError = error{
                    NSLog("Error: \(isError)")
                }
                valX = data!.rotationRate.x
                valY = data!.rotationRate.y
                valZ = data!.rotationRate.z
                
                if values != nil{
                    values!(valX, valY, valZ)
                }
                
                //let absoluteVal = sqrt(valX * valX + valY * valY + valZ * valZ)
                self.delegate?.getRotationRateFromDeviceMotion!(x: valX, y: valY, z: valZ)
            }
            
        } else {
            NSLog("Device Motion is not available")
        }
    }
    
    
    /*  从 deviceMotion 获取磁场
    *   getMagneticFieldFromDeviceMotion:interval:values:
    *   You can retrieve the processed magnetic field data from the device motion from this
    *   method.
    */
    public func getMagneticFieldFromDeviceMotion (interval: TimeInterval = 0.1, values: ((_ x:Double, _ y:Double, _ z:Double, _ accuracy: Int32) -> ())? ) {
        
        var valX: Double!
        var valY: Double!
        var valZ: Double!
        var valAccuracy: Int32!
        if manager.isDeviceMotionAvailable{
            manager.deviceMotionUpdateInterval = interval
            manager.startDeviceMotionUpdates(to: OperationQueue.main){
                 (data, error) in
                
                if let isError = error{
                    NSLog("Error: \(isError)")
                }
                valX = data!.magneticField.field.x
                valY = data!.magneticField.field.y
                valZ = data!.magneticField.field.z
                valAccuracy = data!.magneticField.accuracy.rawValue
                
                if values != nil{
                    values!(valX, valY, valZ, valAccuracy)
                }
                
                self.delegate?.getMagneticFieldFromDeviceMotion!(x: valX, y: valY, z: valZ)
            }
            
        } else {
            NSLog("Device Motion is not available")
        }
    }
    
    /*  MARK :- DEVICE MOTION APPROACH ENDS HERE    */
    
    
    /*
    *   From the methods hereafter, the sensor values could be retrieved at
    *   a particular instant, whenever needed, through a trailing closure.
    */
    
    /*  MARK :- INSTANTANIOUS METHODS START HERE   获取此时的设备状态  */

    // 加速度
    public func getAccelerationAtCurrentInstant (values: @escaping (_ x:Double, _ y:Double, _ z:Double) -> ()){
        self.getUserAccelerationFromDeviceMotion(interval: 0.5) { (x, y, z) -> () in values(x,y,z)
            self.stopDeviceMotionUpdates()
        }
    }
    
    // 重力加速度
    public func getGravitationalAccelerationAtCurrentInstant (values: @escaping (_ x:Double, _ y:Double, _ z:Double) -> ()){
        self.getGravityAccelerationFromDeviceMotion(interval: 0.5) { (x, y, z) -> () in
            values(x,y,z)
            self.stopDeviceMotionUpdates()
        }
    }
    
    // 姿态
    public func getAttitudeAtCurrentInstant (values: @escaping (_ attitude: CMAttitude) -> ()){
        self.getAttitudeFromDeviceMotion(interval: 0.5) { (attitude) -> () in
            values(attitude)
            self.stopDeviceMotionUpdates()
        }
    
    }
    
    // 磁场
    public func getMageticFieldAtCurrentInstant (values: @escaping (_ x:Double, _ y:Double, _ z:Double) -> ()){
        self.getMagneticFieldFromDeviceMotion(interval: 0.5) { (x, y, z, accuracy) -> () in
            values(x,y,z)
            self.stopDeviceMotionUpdates()
        }
    }
    
    // 陀螺仪
    public func getGyroValuesAtCurrentInstant (values: @escaping (_ x:Double, _ y:Double, _ z:Double) -> ()){
        self.getRotationRateFromDeviceMotion(interval: 0.5) { (x, y, z) -> () in
            values(x,y,z)
            self.stopDeviceMotionUpdates()
        }
    }
    
    /*  MARK :- INSTANTANIOUS METHODS END HERE  */
    
    
    
    /*
    *  stopAccelerometerUpdates
    *
    *  Discussion:
    *   Stop accelerometer updates.
    */
    public func stopAccelerometerUpdates(){
        self.manager.stopAccelerometerUpdates()
        NSLog("Accelaration Updates Status - Stopped")
    }
    
    /*
    *  stopGyroUpdates
    *
    *  Discussion:
    *   Stops gyro updates.
    */
    public func stopGyroUpdates(){
        self.manager.stopGyroUpdates()
        NSLog("Gyroscope Updates Status - Stopped")
    }
    
    /*
    *  stopDeviceMotionUpdates
    *
    *  Discussion:
    *   Stops device motion updates.
    */
    public func stopDeviceMotionUpdates() {
        self.manager.stopDeviceMotionUpdates()
        NSLog("Device Motion Updates Status - Stopped")
    }
    
    /*
    *  stopMagnetometerUpdates
    *
    *  Discussion:
    *   Stops magnetometer updates.
    */
    @available(iOS, introduced: 5.0)
    public func stopmagnetometerUpdates() {
        self.manager.stopMagnetometerUpdates()
        NSLog("Magnetometer Updates Status - Stopped")
    }
    
}


extension UIView {
    
    /// view 跟随手机陀螺仪晃动
    /// - Parameters:
    ///   - interval: 采样间隔
    ///   - angle: 最大的旋转角度
    func startRotate3DWithDeviceMotion(interval: TimeInterval = 0.01,angle: CGFloat = 0.3) {
        var transform: CATransform3D = CATransform3DIdentity
        // 透视效果
        transform.m34 = -1 / 700
        motionKit.getAttitudeFromDeviceMotion(interval: interval) { [weak self] (atti) in
            guard let self = self else { return }
            print("roll:\(atti.roll)" + "  " + "pitch:\(atti.pitch)")
            var xRotate:CGFloat = CGFloat(-atti.roll)
            if xRotate >= 1 {
                xRotate = 1
            }else if xRotate <= -1 {
                xRotate = -1
            }
            var yRotate:CGFloat = CGFloat(atti.pitch - 0.5)
            if yRotate >= 1 {
                yRotate = 1
            }else if yRotate <= -1 {
                yRotate = -1
            }
            let xTransform = CATransform3DRotate(transform, angle * xRotate, 0, 1, 0)
            self.layer.transform = CATransform3DRotate(xTransform, angle * yRotate, 1, 0, 0)
        }
    }
    
    /// 停止采样
    func stopRotateWithDeviceMotion() {
        self.layer.transform = CATransform3DIdentity
        motionKit.stopDeviceMotionUpdates()
    }
}
