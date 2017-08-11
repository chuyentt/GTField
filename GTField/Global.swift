//
//  Global.swift
//  appyMap
//
//  Created by AppyStudio on 09/2015.
//  Copyright (c) 2015 Nicola Canali. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import CoreMotion

var DEVICE_WIDTH = ""

let publicDatabase = CKContainer.default().publicCloudDatabase


// HUD View (customizable by editing the code below)
let hudView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
let indicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
extension UIView {
    func showHUD(_ view: UIView) {
        hudView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        hudView.backgroundColor = UIColor.black
        hudView.alpha = 0.5
        hudView.layer.cornerRadius = 5
        
        indicatorView.center = CGPoint(x: hudView.frame.size.width/2, y: hudView.frame.size.height/2)
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        hudView.addSubview(indicatorView)
        indicatorView.startAnimating()
        view.addSubview(hudView)
    }
    func hideHUD() {
        hudView.removeFromSuperview()
    }

    func simpleAlert(_ mess:String) {
        UIAlertView(title: APP_NAME, message: mess, delegate: nil, cancelButtonTitle: "OK").show()
    }

    func startFlashing() {
        self.alpha = 1.0
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseInOut, .repeat, .autoreverse, .allowUserInteraction], animations: {() -> Void in
            self.alpha = 0.1
            if ENABLE_SOUND_EFFECT {
                SoundPlayer.play(file: "beep.mp3")
            }
        }, completion: {(_ finished: Bool) -> Void in
            // Do nothing
            if ENABLE_SOUND_EFFECT {
                SoundPlayer.play(file: "click.mp3")
            }
        })
    }
    
    func stopFlashing() {
        UIView.animate(withDuration: 0.12, delay: 0.0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {() -> Void in
            self.alpha = 1.0
        }, completion: {(_ finished: Bool) -> Void in
            // Do nothing
        })
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
    static let local: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
}

extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
    var local: String {
        return Formatter.local.string(from: self)
    }
}

extension String {
    subscript(i: Int) -> String {
        guard i >= 0 && i < characters.count else { return "" }
        return String(self[index(startIndex, offsetBy: i)])
    }
    subscript(range: Range<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) ?? endIndex))
    }
    subscript(range: ClosedRange<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound + 1, limitedBy: endIndex) ?? endIndex))
    }
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8), options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

class CButton : UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(_ frame: CGRect, _ title: String, _ view: UIView) {
        super.init(frame: frame)
        titleLabel?.numberOfLines = 2
        setTitle(title, for: UIControlState.normal)
        backgroundColor = UIColor(red: 142.0/255.0, green: 224.0/255.0, blue: 102.0/255.0, alpha: 0.90)
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
    }
    override func layoutSubviews() {
        layer.cornerRadius = frame.width / 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel?.textAlignment = .center
        // Đặt chiều cao
        NSLayoutConstraint(item: self,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: self.frame.height).isActive = true
        // Đặt chiều rộng
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: self.frame.width).isActive = true
        // Căn chỉnh giữa
        NSLayoutConstraint(item: self,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: self.superview,
                           attribute: .centerX,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        // Căn dưới
        NSLayoutConstraint(item: self,
                           attribute: .bottom,
                           relatedBy: .lessThanOrEqual,
                           toItem: self.superview,
                           attribute: .bottom,
                           multiplier: 1.0,
                           constant: -280).isActive = true

     super.layoutSubviews()
    }
//    override var isHighlighted: Bool {
//        didSet {
//            if (isHighlighted) {
//                self.imageView?.layer.borderColor = self.tintColor.cgColor
//                self.imageView?.layer.borderWidth = 1
//                self.imageView?.layer.cornerRadius = 5
//            } else {
//                self.imageView?.layer.borderColor = self.tintColor.cgColor
//                self.imageView?.layer.borderWidth = 0
//                self.imageView?.layer.cornerRadius = 5
//            }
//        }
//    }
}


open class UIDistanceLabel: UILabel {
    open var distance: CLLocationDistance {
        get {
            return 0
        }
        set {
            if newValue > 1000.0 { //use km
                let formatted = String(format: "%.2f", (newValue/1000.0))
                self.text = "\(formatted)km"
            } else {
                let formatted = String(format: "%.0f", (newValue))
                self.text = "\(formatted)m"
            }
        }
    }
}

extension CLLocationCoordinate2D {
    func localizedCoordinateString() -> String {
        let latString = (latitude < 0) ? "S" : "N"
        let lonString = (longitude < 0) ? "W" : "E"
        return "\(fabs(latitude)) \(latString)\n\(fabs(longitude)) \(lonString)"
    }
    func localizedCoordinateString2() -> String {
        let latString = (latitude < 0) ? "S" : "N"
        let lonString = (longitude < 0) ? "W" : "E"
        return "\(fabs(latitude).toDMSString(0)) \(latString)\n\(fabs(longitude).toDMSString(0)) \(lonString)"
    }
    func middleLocationWith(location:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        
        let lon1 = longitude * .pi / 180
        let lon2 = location.longitude * .pi / 180
        let lat1 = latitude * .pi / 180
        let lat2 = location.latitude * .pi / 180
        let dLon = lon2 - lon1
        let x = cos(lat2) * cos(dLon)
        let y = cos(lat2) * sin(dLon)
        
        let lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) )
        let lon3 = lon1 + atan2(y, cos(lat1) + x)
        
        let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat3 * 180 / .pi, lon3 * 180 / .pi)
        return center
    }
}

extension CMAcceleration {
    func getDeviceOrientation() -> CLDeviceOrientation {
        let epsilon = 0.5
        if (self.x <= -epsilon)  {       // Xup
            return .landscapeLeft
        } else if (self.x >= epsilon) {  // Xdown
            return .landscapeRight
        } else if (self.y <= -epsilon) { // Yup
            return .portrait
        } else if (self.y >= epsilon) {  // Ydown
            return .portraitUpsideDown
        } else if (self.z <= -epsilon) { // Zup
            return .faceUp
        } else if (self.z >= epsilon) {  // Zdown
            return .faceDown
        }
        return .unknown
    }
}

extension UIViewController {
    /// Executes the specified closure for each of the child and descendant view
    /// controller, as well as for the view controller itself.
    func enumerateHierarchy(_ closure: (UIViewController) -> Void) {
        closure(self)
        
        for child in childViewControllers {
            child.enumerateHierarchy(closure)
        }
        
    }
}

// ERROR ALERT
var error = NSError(domain: APP_NAME, code: 1, userInfo: nil)
var errorAlert = UIAlertView(title: APP_NAME,
    message: "\(error.description)",
    delegate: nil,
    cancelButtonTitle: "OK" )

