//
//  NSDictionary+Extensions.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 6/10/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import Foundation
import ImageIO
import CoreLocation

extension NSDictionary {
    func gpsDictionaryFor(location: CLLocation, heading: Double, orientation: UIImageOrientation) -> NSDictionary {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let alt = location.altitude
        let hdop = location.horizontalAccuracy

        let gpsDict = NSMutableDictionary()
        gpsDict[kCGImagePropertyGPSLatitude as String] = (fabs(lat))
        gpsDict[kCGImagePropertyGPSLongitude as String] = (fabs(lon))
        gpsDict[kCGImagePropertyGPSLatitudeRef as String] = ((lat >= 0) ? "N" : "S")
        gpsDict[kCGImagePropertyGPSLongitudeRef as String] = ((lon >= 0) ? "E" : "W")
        gpsDict[kCGImagePropertyGPSAltitude as String] = alt
        gpsDict[kCGImagePropertyGPSAltitudeRef as String] = "0"
        gpsDict[kCGImagePropertyGPSDestBearing as String] = heading
        gpsDict[kCGImagePropertyGPSDestBearingRef as String] = "T"
        gpsDict[kCGImagePropertyGPSImgDirection as String] = heading
        gpsDict[kCGImagePropertyGPSImgDirectionRef as String] = "T"
        gpsDict[kCGImagePropertyGPSHPositioningError as String] = hdop
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = "yyyy:MM:dd"
        let dateStamp = dateFormatter.string(from: location.timestamp)
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let timeStamp = dateFormatter.string(from: location.timestamp)
        
        gpsDict[kCGImagePropertyGPSDateStamp as String] = dateStamp
        gpsDict[kCGImagePropertyGPSTimeStamp as String] = timeStamp
        
        let dict = NSMutableDictionary(dictionary: self)
        
        // TODO: Quan trọng: Sau khi xoay thì chuyển ảnh về up = 1
        dict[kCGImagePropertyOrientation as String] = 1
        
        dict[kCGImagePropertyGPSDictionary] = gpsDict
        return dict as NSDictionary
    }
}
