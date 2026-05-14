//
//  CameraViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 6/9/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import ImageIO
import CoreLocation
import MobileCoreServices
import Photos
//import AEXML
import AVFoundation
import CoreMotion
import GoogleMobileAds
import Firebase

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MotionContainer {
    
    private let interstitialHelper = InterstitialHelper()
    
    // Bắt buôc phải có nếu dùng MotionContainer
    var motionManager: CMMotionManager?
    
    //Variables
    let imagePicker = UIImagePickerController()
    
    //Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    // Gọi photomap
    private var buttonAction: UIBarButtonItem?
    
    /// Location manager used to start and stop updating location.
    let manager = CLLocationManager()
    
    /// Indicates whether the location manager is updating location.
    var isUpdatingLocation = false
    
    @IBOutlet weak var buttonTakePhotoBorder: SpringButton!
    @IBOutlet weak var buttonTakePhoto: SpringButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var cameraPane: UIView!
    
    @IBOutlet weak var lblPosition1: UILabel!
    @IBOutlet weak var lblPosition2: UILabel!
    @IBOutlet weak var lblBearing: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    let strokeTextAttributes = [
        NSAttributedString.Key.strokeColor : UIColor.white,
        NSAttributedString.Key.foregroundColor : UIColor.orange,
        NSAttributedString.Key.strokeWidth : -4.0,
        NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)
        ] as [NSAttributedString.Key : Any]
    
    override func loadView() {
        super.loadView()
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        self.imagePicker.dismiss(animated: true) { 
            
        }
    }
    
    @IBAction func btnTakePhoto(_ sender: Any) {
        buttonTakePhoto.animation = "pop"
        buttonTakePhoto.animate()
        self.imagePicker.takePicture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stopUpdateMotion()
        interstitialHelper.show(from: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Thêm nút action để gọi photomap
        self.buttonAction = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.bookmarks, target: self, action: #selector(btnAction(_:)))
        self.buttonAction?.tag = 1
        self.navigationItem.rightBarButtonItem = self.buttonAction
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(btnAction(_:)))
        self.navigationItem.leftBarButtonItem?.tag = 2
        
        takePhotoTapped(self)
        
        // TODO: Nên xem xét thêm
        stackView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2).translatedBy(x: self.view.frame.width / 2, y: self.view.frame.width / 2 - stackView.frame.height)

        buttonTakePhoto.layer.borderColor = UIColor.white.cgColor
        
        if ADS_ENABLED && !getProVersion() {
            if UIDevice.current.userInterfaceIdiom == .pad {
                
            } else {
                
            }
            interstitialHelper.load()
        }
    }
    
    // Bắt buôc phải có nếu dùng MotionContainer
    func startUpdateMotion() {
        guard let motionManager = motionManager, motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = TimeInterval(1.0)
        motionManager.showsDeviceMovementDisplay = true
        
        motionManager.startAccelerometerUpdates(to: .main) { accelerometerData, error in
            guard let accelerometerData = accelerometerData else { return }
            if self.manager.headingOrientation != accelerometerData.acceleration.getDeviceOrientation() {
                self.manager.headingOrientation = accelerometerData.acceleration.getDeviceOrientation()
                self.manager.startUpdatingHeading()
            }
        }
    }
    
    // Bắt buôc phải có nếu dùng MotionContainer
    func stopUpdateMotion() {
        guard let motionManager = motionManager, motionManager.isAccelerometerAvailable else { return }
        motionManager.stopAccelerometerUpdates()
    }

    @IBAction func btnAction(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 1:
            // Trở về NavigationController
            //self.navigationController?.popViewController(animated: true)
            
            // Gọi view
            self.performSegue(withIdentifier: "seguePhotos", sender: self)
            break
        case 2:
            // Tắt NavigationController hoặc ViewController
            self.dismiss(animated: true, completion: {
                self.stopUpdatingLocation()
            })
            break
        default:
            break
        }
        
    }
    
    @IBAction func libraryTapped(_ sender: AnyObject) {
        PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
            switch status {
            case .authorized: // Đã cho phép
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.mediaTypes = [kUTTypeImage as String]
                DispatchQueue.main.async {
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
                break
            case .denied: // Khi bị từ chối
                let alert = UIAlertController(
                    title: "IMPORTANT",
                    message: "\(APP_NAME) has been denied access your photo library. The photo library access required for import photo!. To enable access, please go to app settings and turn it on.",
                    preferredStyle: UIAlertController.Style.alert
                )
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Settings...", style: .cancel, handler: { (alert) -> Void in
                    //UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler:nil)
                    } else {
                        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
                break
            default: // Lần đầu sử dụng
                break
            }
        })
    }
    
    @IBAction func takePhotoTapped(_ sender: AnyObject) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (authStatus) in
            if authStatus {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.imagePicker.allowsEditing = false
                    self.imagePicker.sourceType = .camera
                    self.imagePicker.mediaTypes = [kUTTypeImage as String]
                    self.imagePicker.cameraFlashMode = .off
                    self.imagePicker.delegate = self
                    self.imagePicker.showsCameraControls = false
                    
                    let screenSize = UIScreen.main.bounds.size
                    let cameraAspectRatio = CGFloat(4.0 / 3.0)
                    let cameraImageHeight = screenSize.width * cameraAspectRatio
                    
                    // Đúng kích thước 4x3 1280x960 nhưng ở giữa màn hình
                    self.imagePicker.cameraViewTransform =
                        CGAffineTransform(translationX: 0, y: (screenSize.height - 88 - cameraImageHeight)/2)
                    
                    // Cho rộng nốt phần còn lại
                    //let scale = screenSize.height / cameraImageHeight
                    //self.imagePicker.cameraViewTransform = self.imagePicker.cameraViewTransform.scaledBy(x: scale, y: scale)
                    DispatchQueue.main.async {
                        self.cameraPane.layer.borderWidth = 0.5
                        self.cameraPane.layer.borderColor = UIColor.darkGray.cgColor
                        self.imagePicker.cameraOverlayView = self.cameraPane
                    }
                    
                    // Kiểm tra dịch vụ định vị, nếu đã cho phép thì mới hiện
                    if CLLocationManager.authorizationStatus() == .authorizedAlways ||
                        CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                        DispatchQueue.main.async {
                            self.present(self.imagePicker, animated: true) {
                                self.startUpdateMotion()
                            }
                        }
                    }
                    
                    // Gọi dịch vụ định vị
                    self.startUpdatingLocation()
                } else {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "No camera available.",
                        preferredStyle: .alert
                    )
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(
                    title: "IMPORTANT",
                    message: "\(APP_NAME) has been denied access your camera. The camera access required for capturing photos!. To enable access, please go to app settings and turn it on.",
                    preferredStyle: UIAlertController.Style.alert
                )
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Settings...", style: .cancel, handler: { (alert) -> Void in
                    //UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler:nil)
                    } else {
                        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }

    //MARK: - Delegate methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        stopUpdateMotion()
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        imageView.contentMode = .scaleAspectFit
        imageView.image = chosenImage.cropImage(cropSize: IMAGE_CROP_TO_SIZE)

        let photoRoot = applicationDocumentsDirectory().appendingPathComponent("Photos")
        _ = createDirectoryAtURL(url: photoRoot)
        var fileName = photoRoot.appendingPathComponent(getFileNameByGPSTime(ext: "jpg"))

        if picker.sourceType == .photoLibrary {
            picker.dismiss(animated: true, completion: nil)
            // Thông báo ảnh này lấy từ thư viện
            guard let assetUrl = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.referenceURL)] as? URL else {
                return
            }
            let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [assetUrl], options: PHFetchOptions())
            
            if let photo = fetchResult.firstObject {
                // retrieve the image for the first result
                let requestOptions = PHImageRequestOptions()
                requestOptions.resizeMode = .exact
                requestOptions.deliveryMode = .highQualityFormat
                requestOptions.isNetworkAccessAllowed = true
                
                PHImageManager.default().requestImageData(for: photo, options: requestOptions, resultHandler: { (data, str, orientation, info) in
                    let dataProvider = CGDataProvider(data: data! as CFData)
                    let imageSource = CGImageSourceCreateWithDataProvider(dataProvider!, nil)
                    var imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil) as! [String: AnyObject]
                    if let gpsInfo = imageProperties[kCGImagePropertyGPSDictionary as String] as? [String: AnyObject] {
                        let keys = gpsInfo.keys
                        if keys.contains(kCGImagePropertyGPSLatitude as String),
                            keys.contains(kCGImagePropertyGPSLongitude as String),
                            keys.contains(kCGImagePropertyGPSAltitude as String),
                            keys.contains(kCGImagePropertyGPSLatitudeRef as String),
                            keys.contains(kCGImagePropertyGPSLongitudeRef as String),
                            keys.contains(kCGImagePropertyGPSDestBearing as String),
                            keys.contains(kCGImagePropertyGPSDateStamp as String),
                            keys.contains(kCGImagePropertyGPSTimeStamp as String) {
                            let dateStamp = gpsInfo[kCGImagePropertyGPSDateStamp as String] as? String
                            let timeStamp = gpsInfo[kCGImagePropertyGPSTimeStamp as String] as? String
                            // Kiểm tra độ dài của dateStamp và timeStamp
                            if dateStamp?.length == 10 && timeStamp?.length == 8 {
                                let dateFormatter = DateFormatter()
                                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                                dateFormatter.locale = Locale(identifier: "en_GB")
                                dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                                let dateObject = dateFormatter.date(from: "\(dateStamp!) \(timeStamp!)")
                                fileName = photoRoot.appendingPathComponent(getFileNameByGPSTime(ext: "jpg", date: dateObject!))
                            }
                            // Thay đổi kích dung lượng
                            let imageData = self.imageView.image!.jpegData(compressionQuality: CGFloat(IMAGE_COMPRESSION_QUALITY))
                            
                            // TODO: Quan trọng: Sau khi xoay thì chuyển ảnh về up = 1
                            imageProperties[kCGImagePropertyOrientation as String] = 1 as AnyObject
                            self.createFileFor(imageData!, imageProperties as NSDictionary, fileName)
                        } else {
                            // create the alert
                            let alert = UIAlertController(title: "Location Error", message: "The photo you selected does not have GPS data", preferredStyle: UIAlertController.Style.alert)
                            
                            // add an action (button)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
                                alert -> Void in
                                return
                            }))
                            
                            // show the alert
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        // create the alert
                        let alert = UIAlertController(title: "Location Not Found", message: "The photo you selected does not have GPS data", preferredStyle: UIAlertController.Style.alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
                            alert -> Void in
                            return
                        }))
                        
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        } else {
            let location = manager.location
            let heading = manager.heading?.trueHeading
            let imageData = imageView.image!.jpegData(compressionQuality: CGFloat(IMAGE_COMPRESSION_QUALITY))
            
            if var metadata: NSDictionary = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaMetadata)] as? NSDictionary {
                if metadata[kCGImagePropertyGPSDictionary as String] == nil {
                    metadata = metadata.gpsDictionaryFor(location: location!, heading: heading!, orientation: chosenImage.imageOrientation)
                }

                createFileFor(imageData!, metadata, fileName)
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func createFileFor(_ imageData: Data, _ metadata: NSDictionary, _ fileURL: URL) {
        let options = [kCGImageSourceShouldCache as String: kCFBooleanFalse, kCGImageSourceCreateThumbnailFromImageAlways as String: kCFBooleanTrue]
        let cgImgSource: CGImageSource = CGImageSourceCreateWithData(imageData as CFData, options as CFDictionary)!
        let uti: CFString = CGImageSourceGetType(cgImgSource)!
        let dataWithGPS: NSMutableData = NSMutableData(data: imageData)
        let destination: CGImageDestination = CGImageDestinationCreateWithData((dataWithGPS as CFMutableData), uti, 1, options as CFDictionary)!
        
        CGImageDestinationAddImageFromSource(destination, cgImgSource, 0, (metadata as CFDictionary))
        CGImageDestinationFinalize(destination)
        
        dataWithGPS.write(to: fileURL, atomically: true)
    }
    
    /**
     Informs the manager to stop updating location, invalidates the timer, and
     updates the view.
     
     If the command comes from the phone, this method sends a state update to
     the watch to inform the watch that location updates have stopped.
     */
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
        manager.delegate = nil
//        if #available(iOS 9.0, *), CLLocationManager.authorizationStatus() == .authorizedAlways {
//            manager.allowsBackgroundLocationUpdates = false
//        }
        isUpdatingLocation = false
    }
    
    func startUpdatingLocation() {
        if isUpdatingLocation {
           return
        }
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            //This app is authorized to start location services at any time.
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            manager.distanceFilter = kCLDistanceFilterNone
            manager.headingFilter = kCLHeadingFilterNone
            manager.headingOrientation = .unknown
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
//            if #available(iOS 9.0, *), CLLocationManager.authorizationStatus() == .authorizedAlways {
//                manager.allowsBackgroundLocationUpdates = true
//            } else {
//                
//            }
            isUpdatingLocation = true

            break
        case .denied:
            //The user explicitly denied the use of location services for this app or location services are currently disabled in Settings.
            let alert = UIAlertController(
                title: "IMPORTANT",
                message: "\(APP_NAME) has been denied access your location. The location services access required for embed the GPS information within the picture!. To enable access, please go to app settings and select \"While Using the App\" or \"Alway\" option..",
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (alert) -> Void in
                self.dismiss(animated: true, completion: {
                    self.stopUpdatingLocation()
                })
            }))
            alert.addAction(UIAlertAction(title: "Settings...", style: .cancel, handler: { (alert) -> Void in
                //UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler:nil)
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
                self.dismiss(animated: true, completion: {
                    self.stopUpdatingLocation()
                })
            }))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            break
        case .restricted:
            //This app is not authorized to use location services. The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
            let alert = UIAlertController(
                title: "IMPORTANT",
                message: "\(APP_NAME) is not authorized to use location services. You cannot change this app’s status, possibly due to active restrictions such as parental controls being in place",
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (alert) -> Void in
                self.dismiss(animated: true, completion: {
                    self.stopUpdatingLocation()
                })
            }))
            alert.addAction(UIAlertAction(title: "Settings...", style: .cancel, handler: { (alert) -> Void in
                //UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler:nil)
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
                self.dismiss(animated: true, completion: {
                    self.stopUpdatingLocation()
                })
            }))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            break
        default:
            //The user has not yet made a choice regarding whether this app can use location services.
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse: // Nếu đồng ý
            self.startUpdatingLocation()
            break
        case .restricted: // Nếu dịch vụ định vị bị vô hiệu hóa toàn bộ
            let alert = UIAlertController(
                title: "IMPORTANT",
                message: "\(APP_NAME) is not authorized to use location services. You cannot change this app’s status, possibly due to active restrictions such as parental controls being in place",
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (alert) -> Void in
                self.dismiss(animated: true, completion: {
                    self.stopUpdatingLocation()
                })
            }))
            alert.addAction(UIAlertAction(title: "Settings...", style: .cancel, handler: { (alert) -> Void in
                //UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler:nil)
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
                self.dismiss(animated: true, completion: {
                    self.stopUpdatingLocation()
                })
            }))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            break
        case .denied:
            let alert = UIAlertController(
                title: "IMPORTANT",
                message: "\(APP_NAME) has been denied access your location. The location services access required for embed the GPS information within the picture!. To enable access, please go to app settings and select \"While Using the App\" or \"Alway\" option..",
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (alert) -> Void in
                self.dismiss(animated: true, completion: {
                    self.stopUpdatingLocation()
                })
            }))
            alert.addAction(UIAlertAction(title: "Settings...", style: .cancel, handler: { (alert) -> Void in
                //UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler:nil)
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
                self.dismiss(animated: true, completion: {
                    self.stopUpdatingLocation()
                })
            }))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            break
            
        default: // Lần đầu gọi
            
            break
        }
    }
    
    /**
     Increases that location count by the number of locations received by the
     manager. Updates the batch count with the added locations.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations.debugDescription)
        
        lblPosition1.attributedText = NSMutableAttributedString(string: "\((locations.last?.coordinate.localCoordinate(false))!)", attributes: strokeTextAttributes)
        lblPosition2.attributedText = NSMutableAttributedString(string: (locations.last?.coordinate.localizedCoordinateString2())!, attributes: strokeTextAttributes)
        
//        
//        // Kiểm tra xem orientation hiện tại để đặt lại heading
//        if UIDevice.current.orientation.isFlat {
//            manager.headingOrientation = .faceUp
//            //manager.startUpdatingHeading()
//            print("isFlat", manager.heading?.trueHeading ?? "NA")
//        } else if UIDevice.current.orientation.isPortrait {
//            manager.headingOrientation = .portrait
//            //manager.startUpdatingHeading()
//            print("isPortrait", manager.heading?.trueHeading ?? "NA")
//        } else if UIDevice.current.orientation.isLandscape {
//            manager.headingOrientation = .landscape
//            //manager.startUpdatingHeading()
//            print("isLandscape", manager.heading?.trueHeading ?? "NA")
//        } else if UIDevice.current.orientation.isValidInterfaceOrientation {
//            manager.headingOrientation = .unknown
//            //manager.startUpdatingHeading()
//            print("isValidInterfaceOrientation", manager.heading?.trueHeading ?? "NA")
//        }
//        manager.startUpdatingHeading()
    }
    
    /// Log any errors to the console.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error occured: \(error.localizedDescription).")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {

        lblBearing.attributedText = NSMutableAttributedString(string: "∡ \(manager.heading?.trueHeading.toString(1) ?? "N/A")° T", attributes: strokeTextAttributes)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
