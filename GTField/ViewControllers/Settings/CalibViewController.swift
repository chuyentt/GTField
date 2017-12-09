//
//  CalibViewController.swift
//  MotionGraphs
//
//  Created by Chuyen Trung Tran on 3/22/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation
import simd
import AVFoundation
import Surge

class CalibViewController: UIViewController, MotionContainer {
    
    @IBOutlet weak var acceGraphView: GraphView!
    @IBOutlet weak var gyroGraphView: GraphView!
    
    var motionManager: CMMotionManager?
    var locationManager: CLLocationManager?
    
    var updateIntervalLabel: UILabel!
    
    @IBOutlet weak var updateIntervalSlider: UISlider!
    
    let updateIntervalFormatter = MeasurementFormatter()
    
    var valueLabels: [UILabel]!
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    var ding:AVAudioPlayer = AVAudioPlayer()
    
    var lastNorm: Double = 0.0;
    
    
    // The gyroscope fixed bias label.
    @IBOutlet weak var _labelFBGX: UILabel!
    @IBOutlet weak var _labelFBGY: UILabel!
    @IBOutlet weak var _labelFBGZ: UILabel!
    
    // The accelerometer fixed bias label.
    @IBOutlet weak var _labelFBAX: UILabel!
    @IBOutlet weak var _labelFBAY: UILabel!
    @IBOutlet weak var _labelFBAZ: UILabel!
    
    // The gyroscope scale factor label.
    @IBOutlet weak var _labelSFGXX: UILabel!
    @IBOutlet weak var _labelSFGXY: UILabel!
    @IBOutlet weak var _labelSFGXZ: UILabel!
    @IBOutlet weak var _labelSFGYX: UILabel!
    @IBOutlet weak var _labelSFGYY: UILabel!
    @IBOutlet weak var _labelSFGYZ: UILabel!
    @IBOutlet weak var _labelSFGZX: UILabel!
    @IBOutlet weak var _labelSFGZY: UILabel!
    @IBOutlet weak var _labelSFGZZ: UILabel!
    
    // The accelerometer scale factor label.
    @IBOutlet weak var _labelSFAXX: UILabel!
    @IBOutlet weak var _labelSFAXY: UILabel!
    @IBOutlet weak var _labelSFAXZ: UILabel!
    @IBOutlet weak var _labelSFAYX: UILabel!
    @IBOutlet weak var _labelSFAYY: UILabel!
    @IBOutlet weak var _labelSFAYZ: UILabel!
    @IBOutlet weak var _labelSFAZX: UILabel!
    @IBOutlet weak var _labelSFAZY: UILabel!
    @IBOutlet weak var _labelSFAZZ: UILabel!
    
    @IBOutlet weak var _resetCalibrationButton: UIButton!
    @IBOutlet weak var _calibrateButton: UIButton!
    var requestedCalibration: Bool = false;
    
    // Số mẫu cho một vị trí
    var MaxPts = 300
    
    
    //NSNumberFormatter
    let _numberFormatterFixBias: NumberFormatter! = NumberFormatter()
    let _numberFormatterScaleFactor: NumberFormatter! = NumberFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close(_:)))
        
        self.navigationItem.leftBarButtonItems = [cancelButton]
        
        // Do any additional setup after loading the view.
        _numberFormatterFixBias.formatWidth = 7
        _numberFormatterFixBias.minimumFractionDigits = 0
        _numberFormatterFixBias.maximumFractionDigits = 0
        _numberFormatterFixBias.minimumIntegerDigits = 1
        _numberFormatterFixBias.maximumIntegerDigits = 5
        _numberFormatterFixBias.positivePrefix = "+"
        _numberFormatterFixBias.paddingCharacter = " "
        
        // Allocate and initialize the number formatter.
        _numberFormatterScaleFactor.formatWidth = 7
        _numberFormatterScaleFactor.minimumFractionDigits = 0
        _numberFormatterScaleFactor.maximumFractionDigits = 0
        _numberFormatterScaleFactor.minimumIntegerDigits = 1
        _numberFormatterScaleFactor.maximumIntegerDigits = 5
        _numberFormatterScaleFactor.positivePrefix = "+"
        _numberFormatterScaleFactor.paddingCharacter = " "
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startUpdateMotion()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopUpdateMotion()
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        // create the alert
        let alert = UIAlertController(title: "Close calibration", message: "Are you sure you want to close?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.dismiss(animated: true, completion: { () -> Void in
                
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func resetCalibrationAction(_ sender: Any) {
        
        // create the alert
        let alert = UIAlertController(title: "Reset calibration", message: "Are you sure you want to reset?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Reset", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            // Lưu vào setting giá trị mặc định
            let bias = double3([0,0,0])
            let sf = double3x3()
            setFixedBias(fixedBias: bias, forKey: "FixedBiasAcce")
            setFixedBias(fixedBias: bias, forKey: "FixedBiasGyro")
            setFactorMatrix(factorMatrix: sf, forKey: "FactorMatrixAcce")
            setFactorMatrix(factorMatrix: sf, forKey: "FactorMatrixGyro")
            
            // Hiển thị
            self.loadSetting()
            
            // Khởi động lại cảm biến
            self.startUpdateMotion();
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func calibrateAction(_ sender: Any) {
        // create the alert
        let alert = UIAlertController(title: "Calibration", message: "Are you sure you want to calibrate?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Calibrate", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.requestedCalibration = true
            // Cho hiển thị thanh tiến trình
            self.progressView.isHidden = false
            self.progressLabel.isHidden = false
            
            // Cho hiển thị hình ảnh 6 vị trí
            // Cho ẩn bảng kết quả
            
            
            let txt:String = alert.textFields![0].text!
            
            let maxpts = Int(txt)
            if (maxpts! < 300) {
                self.MaxPts = 300
            } else {
                self.MaxPts = maxpts!
            }
            
            // Khởi động lại cảm biến
            self.startUpdateMotion();
        }))
        alert.addTextField { (textField) in
            textField.placeholder = "Samples"
            textField.text = "\(self.MaxPts)"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func startUpdateMotion() {
        // Không cho thiết bị tự động nghỉ
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Gyro
        guard let motionManager = motionManager, motionManager.isAccelerometerAvailable else {print("noacce"); return }
        motionManager.showsDeviceMovementDisplay = true
        
        motionManager.deviceMotionUpdateInterval = 1.0/100
        motionManager.gyroUpdateInterval = 1.0/100.0
        motionManager.accelerometerUpdateInterval = 1.0/100.0
        
        // Lấy thời gian GPS - Thời gian kể từ khi thiết bị khởi động
        let gpsTimestamp = getGPSTimeOfWeek() - ProcessInfo.processInfo.systemUptime
        
        // Mỗi lần khởi động thì bắt đầu một hiệu chuẩn
        var isCalibrated = false
        
        // Vị trí hiệu chuản
        var calibPos = 0
        
        // Ghi dữ liệu vào file
        //let store = false
        
        // Thời điểm mất ổn định
        var lastDisturbance: Date = Date()
        
        // Số điểm đã lấy mẫu
        var staticAccePts: Int = 0
        var staticGyroPts: Int = 0
        
        // Các vị trí đã hiệu chuẩn
        var donePos:[Bool] = [false, false, false, false, false, false];
        
        // Dữ liệu một vị trí
        var acceDataPos = Array<double4>()
        var gyroDataPos = Array<double4>()
        
        // Dữ liệu sáu vị trí
        var acceData6Pos: Array<Any> = Array<Any>(repeating: Any.self, count: 6)
        var gyroData6Pos: Array<Any> = Array<Any>(repeating: Any.self, count: 6)
        
        // Lấy độ lệch cảm biến gia tốc từ hệ thống đã lưu
        let b_a: double3 = getFixedBias(forKey: "FixedBiasAcce")
        
        // Lấy ma trận hệ số tỷ lệ và chéo trục của cảm biến gia tốc từ hệ thống đã lưu
        let SM_a: double3x3 = double3x3.init(diagonal: [1.0,1.0,1.0]) + getFactorMatrix(forKey: "FactorMatrixAcce")
        
        // Lấy độ lệch cảm biến tốc độ góc từ hệ thống đã lưu
        let b_g: double3 = getFixedBias(forKey: "FixedBiasGyro")
        
        // Lấy ma trận hệ số tỷ lệ và chéo trục của cảm biến tốc độ góc từ hệ thống đã lưu
        let SM_g: double3x3 = double3x3.init(diagonal: [1.0,1.0,1.0]) + getFactorMatrix(forKey: "FactorMatrixGyro")
        
        // Nghịch đảo
        let ma = SM_a.inverse
        let mg = SM_g.inverse
        
        // Hiển thị các giá trị hiện tại
        self.loadSetting()
        
        let g2mpss = 9.80665
        
        // Điều chỉnh trục xyz -> y,x,-z cho cả hai cảm biến
        
        self.acceGraphView.setScale(100/9.80665)
        
        motionManager.startAccelerometerUpdates(to: .main) { accelerometerData, error in
            guard let accelerometerData = accelerometerData else { print("Loi acce"); return }
            
            let a = double3([accelerometerData.acceleration.y,
                             accelerometerData.acceleration.x,
                             -accelerometerData.acceleration.z])
            calibPos = getCalibPos(gravity: a)
            
            // Hiển thị đồ thị dữ liệu cảm biến gia tốc đã bù nhiễu
            self.acceGraphView.add(accelerometerData.valueWithCompensation(b: b_a, m: ma))
            
            // Xác định vị trí hiệu chuẩn
            
            // Nếu chưa hiệu chuẩn xong
            if (!isCalibrated && calibPos != 0 && self.requestedCalibration) {
                // Lấy mẫu nếu thời gian ổn định được 1.5 giây
                if (lastDisturbance.timeIntervalSinceNow < -1.0 && (staticAccePts < self.MaxPts)) {
                    let timestamp = gpsTimestamp + accelerometerData.timestamp
                    let a = double4([timestamp,
                                     accelerometerData.acceleration.y*g2mpss,
                                     accelerometerData.acceleration.x*g2mpss,
                                     -accelerometerData.acceleration.z*g2mpss])
                    acceDataPos.append(a)
                    staticAccePts += 1
                    let progressValue = Float(staticAccePts) / Float(self.MaxPts)
                    self.progressView.progress = progressValue
                    self.progressLabel?.text = "Vị trí: \(calibPos) _ \(Int(progressValue * 100)) %"
                }
                
                // Nếu số mẫu cho một vị trí đã đủ
                if (staticAccePts == self.MaxPts && staticGyroPts == self.MaxPts) {
                    donePos[calibPos-1] = true
                    acceData6Pos[calibPos-1] = acceDataPos
                    self.beepSound()
                    
                    // Khởi tạo lại mẫu nếu muốn đo lại
                    staticAccePts = 0
                    staticGyroPts = 0
                    acceDataPos.removeAll()
                    gyroDataPos.removeAll()
                }
                
                // Nếu tất cả các vị trí đã hoàn thành
                if (!donePos.contains(false)) {
                    isCalibrated = true
                    self.save(gyroData6Pos: gyroData6Pos, acceData6Pos: acceData6Pos)
                }
            }
        }
        
        self.gyroGraphView.setScale(200.0)
        motionManager.startGyroUpdates(to: .main) { gyroData, error in
            guard let gyroData = gyroData else {print("Loi gyro"); return }
            let a = double3([gyroData.rotationRate.y,
                             gyroData.rotationRate.x,
                             -gyroData.rotationRate.z])
            self.gyroGraphView.add(gyroData.valueWithCompensation(b: b_g, m: mg))
            
            // Nếu chưa hiệu chuẩn xong
            if (!isCalibrated && calibPos != 0 && self.requestedCalibration) {
                let norm = norm_one(a);
                if (fabs(norm - self.lastNorm) > 0.04) {
                    
                    // Thời điểm mất ổn định được thiết lập
                    lastDisturbance = Date()
                    print("Không ổn định!")
                    print(fabs(norm - self.lastNorm))
                    // Khởi tạo lại số mẫu
                    staticAccePts = 0
                    staticGyroPts = 0
                    acceDataPos.removeAll()
                    gyroDataPos.removeAll()
                    self.progressView.progress = 0.0;
                    self.progressLabel?.text = "0 %"
                }
                self.lastNorm = norm
                // Lấy mẫu nếu thời gian ổn định được 1.5 giây
                if (lastDisturbance.timeIntervalSinceNow < -1.0 && (staticGyroPts < self.MaxPts)) {
                    let timestamp = gpsTimestamp + gyroData.timestamp
                    let g = double4([timestamp,
                                     gyroData.rotationRate.y,
                                     gyroData.rotationRate.x,
                                     -gyroData.rotationRate.z])
                    gyroDataPos.append(g)
                    staticGyroPts += 1
                }
                
                // Nếu số mẫu cho một vị trí đã đủ
                if (staticAccePts == self.MaxPts && staticGyroPts == self.MaxPts) {
                    donePos[calibPos-1] = true
                    gyroData6Pos[calibPos-1] = gyroDataPos
                    self.beepSound()
                }
            }
        }
    }
    
    
    func stopUpdateMotion() {
        guard let motionManager = motionManager, motionManager.isAccelerometerAvailable else { return }
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func stopUpdates1() {
        guard let motionManager = motionManager, motionManager.isDeviceMotionActive else { return }
        motionManager.stopDeviceMotionUpdates()
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // Lưu dữ liệu
    func save(acceData6Pos acce: Array<Any>) {
        
        // Lấy thư mục Document
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        // Tạo tên file gốc
        let fileName = String(getGPSWeekNumber()) + "_" + String(CLong(getGPSTimeOfWeek()))
        
        // Tạo tên file Xup
        let file1 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_acce_Xu.txt")
        let file2 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_acce_Xd.txt")
        let file3 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_acce_Yu.txt")
        let file4 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_acce_Yd.txt")
        let file5 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_acce_Zu.txt")
        let file6 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_acce_Zd.txt")
        let file: Array<Any> = [file1, file2, file3, file4, file5, file6]
        
        // Chuẩn bị ghi vào file
        for i in 0...5 {
            var acceString = String()
            let pos: Array<double4> = acce[i] as! Array<double4>
            for j in 0...pos.count-1 {
                let a: double4 = pos[j]
                // Tạo chuỗi dữ liệu
                acceString.append(String(format:"%0.3lf %0.8lf %0.8lf %0.8lf", a[0], a[1], a[2], a[3]))
            }
            // Ghi vào file
            do {
                //try acceString.appendLineToURL(fileURL: file[i] as! URL)
            } catch {
                print("Could not write to file")
            }
        }
    }
    
    // Lưu dữ liệu
    func save(gyroData6Pos gyro: Array<Any>, acceData6Pos acce: Array<Any>) {
        // Lấy thư mục Document
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        // Tạo tên file gốc
        let fileName = String(getGPSWeekNumber()) + "_" + String(CLong(getGPSTimeOfWeek()))
        
        let file1 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_gyro_Xu.txt")
        let file2 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_gyro_Xd.txt")
        let file3 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_gyro_Yu.txt")
        let file4 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_gyro_Yd.txt")
        let file5 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_gyro_Zu.txt")
        let file6 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_gyro_Zd.txt")
        let gyroFile: Array<Any> = [file1, file2, file3, file4, file5, file6]
        
        let file7 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_acce_Xu.txt")
        let file8 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_acce_Xd.txt")
        let file9 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_acce_Yu.txt")
        let file10 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_acce_Yd.txt")
        let file11 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_acce_Zu.txt")
        let file12 = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName+"_acce_Zd.txt")
        let acceFile: Array<Any> = [file7, file8, file9, file10, file11, file12]
        
        var meas_a: Array<double3> = Array<double3>(repeating: double3(), count: 6)
        var meas_g: Array<double3> = Array<double3>(repeating: double3(), count: 6)
        
        // Chuẩn bị ghi gyro vào file
        for i in 0...5 {
            var gyroString = String()
            let pos: Array<double4> = gyro[i] as! Array<double4>
            var mean = double3()
            for j in 0...pos.count-1 {
                let g: double4 = pos[j]
                mean[0] = (mean[0] * Double(j) +  g[1]) / (Double(j)+1.0)
                mean[1] = (mean[1] * Double(j) +  g[2]) / (Double(j)+1.0)
                mean[2] = (mean[2] * Double(j) +  g[3]) / (Double(j)+1.0)
                // Tạo chuỗi dữ liệu
                gyroString.append(String(format: "%0.3lf %0.8lf %0.8lf %0.8lf\r\n", g[0], g[1], g[2], g[3]))
            }
            meas_g[i] = mean;
            
            // Ghi vào file
            do {
                //try gyroString.appendLineToURL(fileURL: gyroFile[i] as! URL)
                //lblMessage.text = "Gyroscope saved!\r\n"
            } catch {
                print("Could not write to file")
            }
        }
        
        // Chuẩn bị ghi acce vào file
        for i in 0...5 {
            var acceString = String()
            let pos: Array<double4> = acce[i] as! Array<double4>
            var mean = double3()
            for j in 0...pos.count-1 {
                let a: double4 = pos[j]
                mean[0] = (mean[0] * Double(j) +  a[1]) / (Double(j)+1.0)
                mean[1] = (mean[1] * Double(j) +  a[2]) / (Double(j)+1.0)
                mean[2] = (mean[2] * Double(j) +  a[3]) / (Double(j)+1.0)
                // Tạo chuỗi dữ liệu
                acceString.append(String(format:"%0.3lf %0.8lf %0.8lf %0.8lf\r\n", a[0], a[1], a[2], a[3]))
            }
            meas_a[i] = mean;
            
            // Ghi vào file
            do {
                //try acceString.appendLineToURL(fileURL: acceFile[i] as! URL)
                //lblMessage.text?.append("Accelerometer saved!")
            } catch {
                print("Could not write to file")
            }
        }
        
        // Hiệu chuẩn
        
        // Lấy vĩ độ gần đây nhất
        let location = getLocation()
        let lg = localGravity(location[0], location[2])
        
        let Aa : Matrix<Double> = Matrix<Double>([[-lg, lg,  0,  0,  0,  0],
                                                  [  0,  0,-lg, lg,  0,  0],
                                                  [  0,  0,  0,  0,-lg, lg],
                                                  [  1,  1,  1,  1,  1,  1]])
        
        let r00 = meas_a[0][0]+lg
        let r10 = meas_a[1][0]-lg
        let r20 = meas_a[2][0]
        let r30 = meas_a[3][0]
        let r40 = meas_a[4][0]
        let r50 = meas_a[5][0]
        let r01 = meas_a[0][1]
        let r11 = meas_a[1][1]
        let r21 = meas_a[2][1]+lg
        let r31 = meas_a[3][1]-lg
        let r41 = meas_a[4][1]
        let r51 = meas_a[5][1]
        let r02 = meas_a[0][2]
        let r12 = meas_a[1][2]
        let r22 = meas_a[2][2]+lg
        let r32 = meas_a[3][2]-lg
        let r42 = meas_a[4][2]
        let r52 = meas_a[5][2]
        
        let Ra = Matrix<Double>([[r00, r10, r20, r30, r40, r50],
                                 [r01, r11, r21, r31, r41, r51],
                                 [r02, r12, r22, r32, r42, r52]])
        //        let Pa = Matrix<Double>([[0.9,   0,   0,   0,   0,   0],
        //                                 [  0, 0.9,   0,   0,   0,   0],
        //                                 [  0,   0, 0.9,   0,   0,   0],
        //                                 [  0,   0,   0, 0.9,   0,   0],
        //                                 [  0,   0,   0,   0, 0.9,   0],
        //                                 [  0,   0,   0,   0,   0, 1.0]])
        let Pa = Matrix<Double>([[1.0,   0,   0,   0,   0,   0],
                                 [  0, 1.0,   0,   0,   0,   0],
                                 [  0,   0, 1.0,   0,   0,   0],
                                 [  0,   0,   0, 1.0,   0,   0],
                                 [  0,   0,   0,   0, 1.0,   0],
                                 [  0,   0,   0,   0,   0, 1.0]])
        let Xa : Matrix<Double> = (Ra*Pa*transpose(Aa))*inv(Aa*Pa*transpose(Aa))
        let ba: double3 = double3(Xa[0,3],Xa[1,3],Xa[2,3])
        let ma: double3x3 = double3x3([[Xa[0,0],Xa[0,1],Xa[0,2]],
                                       [Xa[1,0],Xa[1,1],Xa[1,2]],
                                       [Xa[2,0],Xa[2,1],Xa[2,2]]])
        
        //Gyro
        let phi: Double = location[0]
        let deg2rad = Double.pi/180.0
        let rps2dph: Double = 206264.806247096
        
        //Earth's rotation speed (rad/sec)
        let omega_e: Double = 15.0141/rps2dph
        
        // Earth's rotation speed at latitude (rad/sec)
        let omegae_at_phi = omega_e*sin(phi);
        
        // The fixed rate added (rad/s)
        let fixed_rate = 15.0141*(1.0-sin(phi))*deg2rad;
        
        // The speed of the Earth's rotation and fixed rate added (rad/s)
        let wex: Double = omegae_at_phi+fixed_rate;
        
        let Ag : Matrix<Double> = Matrix<Double>([[ wex,-wex,   0,   0,   0,   0],
                                                  [   0,   0, wex,-wex,   0,   0],
                                                  [   0,   0,   0,   0, wex,-wex],
                                                  [   1,   1,   1,   1,   1,   1]])
        let g00 = meas_g[0][0]+fixed_rate
        let g10 = meas_g[1][0]-fixed_rate
        let g20 = meas_g[2][0]
        let g30 = meas_g[3][0]
        let g40 = meas_g[4][0]
        let g50 = meas_g[5][0]
        let g01 = meas_g[0][1]
        let g11 = meas_g[1][1]
        let g21 = meas_g[2][1]+fixed_rate
        let g31 = meas_g[3][1]-fixed_rate
        let g41 = meas_g[4][1]
        let g51 = meas_g[5][1]
        let g02 = meas_g[0][2]
        let g12 = meas_g[1][2]
        let g22 = meas_g[2][2]+fixed_rate
        let g32 = meas_g[3][2]-fixed_rate
        let g42 = meas_g[4][2]
        let g52 = meas_g[5][2]
        let Rg = Matrix<Double>([[g00, g10, g20, g30, g40, g50],
                                 [g01, g11, g21, g31, g41, g51],
                                 [g02, g12, g22, g32, g42, g52]])
        //        let Pg = Matrix<Double>([[0.9,   0,   0,   0,   0,   0],
        //                                 [  0, 0.9,   0,   0,   0,   0],
        //                                 [  0,   0, 0.9,   0,   0,   0],
        //                                 [  0,   0,   0, 0.9,   0,   0],
        //                                 [  0,   0,   0,   0, 0.9,   0],
        //                                 [  0,   0,   0,   0,   0, 1.0]])
        let Pg = Matrix<Double>([[1.0,   0,   0,   0,   0,   0],
                                 [  0, 1.0,   0,   0,   0,   0],
                                 [  0,   0, 1.0,   0,   0,   0],
                                 [  0,   0,   0, 1.0,   0,   0],
                                 [  0,   0,   0,   0, 1.0,   0],
                                 [  0,   0,   0,   0,   0, 1.0]])
        
        let Xg : Matrix<Double> = (Rg*Pg*transpose(Ag))*inv(Ag*Pg*transpose(Ag))
        let bg: double3 = double3(Xg[0,3],Xg[1,3],Xg[2,3])
        let mg: double3x3 = double3x3([[Xg[0,0],Xg[0,1],Xg[0,2]],
                                       [Xg[1,0],Xg[1,1],Xg[1,2]],
                                       [Xg[2,0],Xg[2,1],Xg[2,2]]])
        // Lưu vào setting
        setFixedBias(fixedBias: ba, forKey: "FixedBiasAcce")
        setFixedBias(fixedBias: bg, forKey: "FixedBiasGyro")
        setFactorMatrix(factorMatrix: ma, forKey: "FactorMatrixAcce")
        setFactorMatrix(factorMatrix: mg, forKey: "FactorMatrixGyro")
        
        requestedCalibration = false
        self.loadSetting()
        
        // Đọc lại giá trị hiệu chuẩn mới và vẽ lại dữ liệu đầu ra
        self.startUpdateMotion();
        
        self.progressView.isHidden = true
        self.progressLabel.isHidden = true
    }
    
    func beepSound() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    func loadSetting() {
        let s2ppm: Double = 1e6
        let mpss2mipss: Double = 1e6
        let rps2dph: Double = 206264.806247096
        
        let ba: double3 = getFixedBias(forKey: "FixedBiasAcce")
        let ma: double3x3 = getFactorMatrix(forKey: "FactorMatrixAcce")
        let bg: double3 = getFixedBias(forKey: "FixedBiasGyro")
        let mg: double3x3 = getFactorMatrix(forKey: "FactorMatrixGyro")
        
        _labelFBAX.text = self._numberFormatterFixBias.string(for: ba[0]*mpss2mipss)
        _labelFBAY.text = self._numberFormatterFixBias.string(for: ba[1]*mpss2mipss)
        _labelFBAZ.text = self._numberFormatterFixBias.string(for: ba[2]*mpss2mipss)
        
        _labelFBGX.text = self._numberFormatterFixBias.string(for: bg[0]*rps2dph)
        _labelFBGY.text = self._numberFormatterFixBias.string(for: bg[1]*rps2dph)
        _labelFBGZ.text = self._numberFormatterFixBias.string(for: bg[2]*rps2dph)
        
        _labelSFAXX.text = self._numberFormatterScaleFactor.string(for: ma[0,0]*s2ppm)
        _labelSFAXY.text = self._numberFormatterScaleFactor.string(for: ma[0,1]*s2ppm)
        _labelSFAXZ.text = self._numberFormatterScaleFactor.string(for: ma[0,2]*s2ppm)
        _labelSFAYX.text = self._numberFormatterScaleFactor.string(for: ma[1,0]*s2ppm)
        _labelSFAYY.text = self._numberFormatterScaleFactor.string(for: ma[1,1]*s2ppm)
        _labelSFAYZ.text = self._numberFormatterScaleFactor.string(for: ma[1,2]*s2ppm)
        _labelSFAZX.text = self._numberFormatterScaleFactor.string(for: ma[2,0]*s2ppm)
        _labelSFAZY.text = self._numberFormatterScaleFactor.string(for: ma[2,1]*s2ppm)
        _labelSFAZZ.text = self._numberFormatterScaleFactor.string(for: ma[2,2]*s2ppm)
        
        _labelSFGXX.text = self._numberFormatterScaleFactor.string(for: mg[0,0]*s2ppm)
        _labelSFGXY.text = self._numberFormatterScaleFactor.string(for: mg[0,1]*s2ppm)
        _labelSFGXZ.text = self._numberFormatterScaleFactor.string(for: mg[0,2]*s2ppm)
        _labelSFGYX.text = self._numberFormatterScaleFactor.string(for: mg[1,0]*s2ppm)
        _labelSFGYY.text = self._numberFormatterScaleFactor.string(for: mg[1,1]*s2ppm)
        _labelSFGYZ.text = self._numberFormatterScaleFactor.string(for: mg[1,2]*s2ppm)
        _labelSFGZX.text = self._numberFormatterScaleFactor.string(for: mg[2,0]*s2ppm)
        _labelSFGZY.text = self._numberFormatterScaleFactor.string(for: mg[2,1]*s2ppm)
        _labelSFGZZ.text = self._numberFormatterScaleFactor.string(for: mg[2,2]*s2ppm)
        
    }
}



