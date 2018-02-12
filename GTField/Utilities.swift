//
//  Utilities.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 6/11/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import Foundation
import UIKit
import ImageIO
import simd

/**
 *
 * Returns the path to the application's documents directory.
 *
 * **/

func applicationDocumentsDirectory() -> URL {
    let docsUrl = try! FileManager.default.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    return docsUrl
}

/**
 *
 * Create directory.
 *
 * **/

func createDirectoryAtURL(url: URL) -> Bool {
    do {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    } catch let error as NSError {
        NSLog("Unable to create directory \(error.debugDescription)")
        return false
    }
    return true
}

func createDocumentFileFor(subPath: String, fileName: String, ext: String) -> URL {
    var docDir = docsURL
    if subPath.length > 0 {
        _ = createDirectoryAtURL(url: docDir.appendingPathComponent(subPath))
        docDir = docDir.appendingPathComponent(subPath)
    }
    
    if ext.length == 0 {
        return docDir.appendingPathComponent(fileName)
    } else {
        return docDir.appendingPathComponent(fileName).appendingPathExtension(ext)
    }
}

func deleteFolderFor(_ path: String) -> Bool {
    do {
        try FileManager.default.removeItem(atPath: path)
        return true
    }
    catch let error as NSError {
        print("Ooops! Something went wrong: \(error)")
        return false
    }
}

/**
 Convert longitude to tile x
 - parameter lon: Longitude
 - parameter z: Zoom level
 */
func lon2Tilex(lon: Double, z: UInt) -> UInt {
    return UInt(floor((lon + 180.0) / 360.0 * Double(1 << z)))
}

/**
 Convert latitude to tile y
 - parameter lat: Latitude
 - parameter z: Zoom level
 */
func lat2Tiley(lat: Double, z: UInt) -> UInt {
    return UInt(floor((1.0 - log(tan(lat * Double.pi/180.0) + 1.0 /
        cos(lat * Double.pi/180.0)) / Double.pi) / 2.0 * Double(1 << z)))
}

/**
 Convert tile x to longitude
 - parameter x: Tile x
 - parameter z: Zoom level
 */
func tilex2Lon(x: UInt, z: UInt) -> Double {
    return Double(x) / Double(1 << z) * 360.0 - 180
}

/**
 Convert tile y to latitude
 - parameter y: Tile y
 - parameter z: Zoom level
 */
func tiley2Lat(y: UInt, z: UInt) -> Double {
    let n = Double.pi - 2.0 * Double.pi * Double(y) / Double(1 << z)
    return 180.0 / Double.pi * atan(0.5 * (exp(n) - exp(-n)))
}

/**
 Create boundary box values for tile in spherical Mercator projection
 - parameter x: Tile x
 - parameter y: Tile y
 - parameter zoom: Zoom level
 */
func bboxForTile(x: UInt, y: UInt, zoom: UInt) -> String {
    let TILE_ORIGIN_X: Double = -20037508.34789244
    let TILE_ORIGIN_Y: Double =  20037508.34789244
    
    let MAP_SIZE = 20037508.34789244 * 2.0
    
    let size = MAP_SIZE / Double(1 << zoom)
    let minx:Double = TILE_ORIGIN_X + Double(x) * Double(size)
    let maxx:Double = TILE_ORIGIN_X + Double(x+1) * Double(size)
    let miny:Double = TILE_ORIGIN_Y - Double(y+1) * Double(size)
    let maxy:Double = TILE_ORIGIN_Y - Double(y) * Double(size)
    
    return "\(minx.toString(8)),\(miny.toString(8)),\(maxx.toString(8)),\(maxy.toString(8))"
}


/**
 *
 * Lấy thời gian GPS, kết quả trả về là Tuần
 *
 **/
func getGPSWeekNumber() -> UInt {
    // Unix timestamp of the GPS epoch 1980-01-06 00:00:00 UTC
    let gpsEpochSeconds = 315964800
    
    // Number of seconds in a week
    let weekSeconds = (60 * 60 * 24 * 7)
    
    // UTC to GPS Time Conversion Table https://confluence.qps.nl/display/KBE/UTC+to+GPS+Time+Correction
    let leapSecondsOffset = 17
    
    let timestamp = Date()
    
    // UTCTimestampToWeekNumberAndTimeOfWeek:
    let gpsTimeMs = timestamp.timeIntervalSince1970 - Double(gpsEpochSeconds) + Double(leapSecondsOffset)
    
    let wn = floor(gpsTimeMs / Double(weekSeconds)) // GPS Week Number
    return UInt(wn)
}

/**
 *
 * Lấy thời gian GPS, kết quả trả về là giây trong tuần
 *
 **/
func getGPSTimeOfWeek() -> TimeInterval {
    // Unix timestamp of the GPS epoch 1980-01-06 00:00:00 UTC
    let gpsEpochSeconds = 315964800
    
    // Number of seconds in a week
    let weekSeconds = (60 * 60 * 24 * 7)
    
    // UTC to GPS Time Conversion Table https://confluence.qps.nl/display/KBE/UTC+to+GPS+Time+Correction
    let leapSecondsOffset = 17
    
    let timestamp = Date()
    
    // UTCTimestampToWeekNumberAndTimeOfWeek:
    let gpsTimeMs = timestamp.timeIntervalSince1970 - Double(gpsEpochSeconds) + Double(leapSecondsOffset)
    
    let wn = floor(gpsTimeMs / Double(weekSeconds)) // GPS Week Number
    
    let tow = gpsTimeMs - (wn * Double(weekSeconds)) // GPS Time of Week
    return Double(tow)
}

/**
 *
 * Lấy thời gian GPS, kết quả trả về là Tuần
 *
 **/
func getGPSWeekNumber(_ date: Date) -> UInt {
    // Unix timestamp of the GPS epoch 1980-01-06 00:00:00 UTC
    let gpsEpochSeconds = 315964800
    
    // Number of seconds in a week
    let weekSeconds = (60 * 60 * 24 * 7)
    
    // UTC to GPS Time Conversion Table https://confluence.qps.nl/display/KBE/UTC+to+GPS+Time+Correction
    let leapSecondsOffset = 17
    
    let timestamp = date
    
    // UTCTimestampToWeekNumberAndTimeOfWeek:
    let gpsTimeMs = timestamp.timeIntervalSince1970 - Double(gpsEpochSeconds) + Double(leapSecondsOffset)
    
    let wn = floor(gpsTimeMs / Double(weekSeconds)) // GPS Week Number
    return UInt(wn)
}

/**
 *
 * Lấy thời gian GPS, kết quả trả về là giây trong tuần
 *
 **/
func getGPSTimeOfWeek(_ date: Date) -> TimeInterval {
    // Unix timestamp of the GPS epoch 1980-01-06 00:00:00 UTC
    let gpsEpochSeconds = 315964800
    
    // Number of seconds in a week
    let weekSeconds = (60 * 60 * 24 * 7)
    
    // UTC to GPS Time Conversion Table https://confluence.qps.nl/display/KBE/UTC+to+GPS+Time+Correction
    let leapSecondsOffset = 17
    
    let timestamp = date
    
    // UTCTimestampToWeekNumberAndTimeOfWeek:
    let gpsTimeMs = timestamp.timeIntervalSince1970 - Double(gpsEpochSeconds) + Double(leapSecondsOffset)
    
    let wn = floor(gpsTimeMs / Double(weekSeconds)) // GPS Week Number
    
    let tow = gpsTimeMs - (wn * Double(weekSeconds)) // GPS Time of Week
    return Double(tow)
}

/**
 *
 * Tạo chuỗi theo thời gian GPS với cấu trúc [Tuần]_[Giây trong tuần]
 *
 **/
func getFileNameByGPSTime(ext: String) -> String {
    return "\(getGPSWeekNumber())_\(getGPSTimeOfWeek().toString(2)).\(ext)"
}

/**
 *
 * Tạo chuỗi theo thời gian GPS với cấu trúc [Tuần]_[Giây trong tuần]
 *
 **/
func getFileNameByGPSTime(ext: String, date: Date) -> String {
    if ext.length == 0 {
        return "\(getGPSWeekNumber(date))_\(getGPSTimeOfWeek(date).toString(2))"
    }
    return "\(getGPSWeekNumber(date))_\(getGPSTimeOfWeek(date).toString(2)).\(ext)"
}

/**
 * Đọc mô tả từ file ảnh
 *
 */
func getImagePropertyExifUserComment(_ url: URL) -> String {
    let data = try! Data(contentsOf: url)
    let dataProvider = CGDataProvider(data: data as CFData)
    let imageSource = CGImageSourceCreateWithDataProvider(dataProvider!, nil)
    let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil) as! [String: AnyObject]
    if let exifInfo = imageProperties[kCGImagePropertyExifDictionary as String] as? [String: AnyObject] {
        if let comment = exifInfo[kCGImagePropertyExifUserComment as String] as? String {
            return comment
        }
    }
    return String()
}

/**
 * Ghi mô tả vào file ảnh
 *
 */
func setImagePropertyExifUserComment(_ url: URL, _ comment: String) {
    let data = try! Data(contentsOf: url)
    let dataProvider = CGDataProvider(data: data as CFData)
    let imageSource = CGImageSourceCreateWithDataProvider(dataProvider!, nil)
    var imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil) as! [String: AnyObject]
    if var exifInfo = imageProperties[kCGImagePropertyExifDictionary as String] as? [String: AnyObject] {
        exifInfo[kCGImagePropertyExifUserComment as String] = comment as AnyObject
        imageProperties[kCGImagePropertyExifDictionary as String] = exifInfo as AnyObject
    }
    
    let uti: CFString = CGImageSourceGetType(imageSource!)!
    let dataWithComment: NSMutableData = NSMutableData(data: data)
    let destination: CGImageDestination = CGImageDestinationCreateWithData((dataWithComment as CFMutableData), uti, 1, nil)!
    
    CGImageDestinationAddImageFromSource(destination, imageSource!, 0, (imageProperties as CFDictionary))
    CGImageDestinationFinalize(destination)
    dataWithComment.write(to: url, atomically: true)
}

func thumbnailImage(src: CGImageSource) -> UIImage {
    let scale = UIScreen.main.scale
    let w = 132//(UIScreen.main.bounds.width / 3) * scale
    let d : [NSObject:AnyObject] = [
        kCGImageSourceShouldAllowFloat : true as AnyObject,
        kCGImageSourceCreateThumbnailWithTransform : true as AnyObject,
        kCGImageSourceCreateThumbnailFromImageAlways : true as AnyObject,
        kCGImageSourceThumbnailMaxPixelSize : w as AnyObject
    ]
    let imref = CGImageSourceCreateThumbnailAtIndex(src, 0, d as CFDictionary)
    return UIImage(cgImage: imref!, scale: scale, orientation: .up)
}

func sizeForLocalFilePath(filePath: String) -> String {
    do {
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
        if let fileSize = fileAttributes[FileAttributeKey.size]  {
            let size = (fileSize as! NSNumber).uint64Value
            var convertedValue: Double = Double(size)
            var multiplyFactor = 0
            let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
            while convertedValue > 1024 {
                convertedValue /= 1024
                multiplyFactor += 1
            }
            return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
        } else {
            print("Failed to get a size attribute from path: \(filePath)")
        }
    } catch {
        print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
    }
    return ""
}

func creationDateForLocalFilePath(filePath: String) -> Date {
    do {
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
        if let fileDate = fileAttributes[FileAttributeKey.creationDate]  {
            let date = fileDate as! Date
            return date
        } else {
            print("Failed to get a size attribute from path: \(filePath)")
        }
    } catch {
        print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
    }
    return Date()
}

func fileInfoDetail(filePath: String) -> String {
    do {
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath) as [FileAttributeKey : Any]
        let fileDate: Date = fileAttributes[FileAttributeKey.creationDate] as! Date
        var fileSize = Double((fileAttributes[FileAttributeKey.size] as! NSNumber).uint64Value)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while fileSize > 1024 {
            fileSize /= 1024
            multiplyFactor += 1
        }
        return String(format: "%@\n%4.2f %@", fileDate.local, fileSize, tokens[multiplyFactor])
    } catch {
        return String()
    }
}

// Lấy danh sách các file từ thư mục docs theo
func fileListFromDocs(subPath: String, ext: String) -> [AnyObject] {
    var Files: [String] = []
    
    do {
        // if you want to filter the directory contents you can do like this:
        if let directoryURLs = try? FileManager.default.contentsOfDirectory(at: docsURL.appendingPathComponent(subPath),
                                                                            includingPropertiesForKeys: nil,
                                                                            options: FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants) {
            
            for url: URL in directoryURLs {
                if url.pathExtension == ext {
                    Files.append(url.lastPathComponent)
                }
            }
        }
    }
    return Files.sorted(by: { (s1, s2) -> Bool in
        s1 > s2 // Sắp xếp mới lên trên
    }) as [AnyObject]
}

// Xác định vị trí hiệu chuẩn tự động
func getCalibPos(gravity gr: double3) -> Int {
    let recipNorm = 1.0/norm_one(gr)
    var g: double3 = gr
    g[0] *= recipNorm
    g[1] *= recipNorm
    g[2] *= recipNorm
    
    let epsilon = 5.0
    if (round(g[0] * 100.0) <= -(100.0 - epsilon))  {       // Xup
        return 1
    } else if (round(g[0] * 100.0) >= (100.0 - epsilon)) {  // Xdown
        return 2
    } else if (round(g[1] * 100.0) <= -(100.0 - epsilon)) { // Yup
        return 3
    } else if (round(g[1] * 100.0) >= (100.0 - epsilon)) {  // Ydown
        return 4
    } else if (round(g[2] * 100.0) <= -(100.0 - epsilon)) { // Zup
        return 5
    } else if (round(g[2] * 100.0) >= (100.0 - epsilon)) {  // Zdown
        return 6
    } // Cho các vị trí khác:
    else if ((round(g[0] * 10.0) <= -7.0) && (round(g[2] * 10.0) <= -7.0)) { // Xup + Zup
        return 7
    } else if ((round(g[0] * 10.0) >= 7.0) && (round(g[2] * 10.0) <= -7.0)) { // Xdown + Zup
        return 8
    } else if ((round(g[1] * 10.0) <= -7.0) && (round(g[2] * 10.0) <= -7.0)) { // Yup + Zup
        return 9
    } else if ((round(g[1] * 10.0) >= 7.0) && (round(g[2] * 10.0) <= -7.0)) { // Ydown + Zup
        return 10
    } else if ((round(g[0] * 10.0) <= -7.0) && (round(g[2] * 10.0) >= 7.0)) { // Xup + Zdown
        return 11
    } else if ((round(g[0] * 10.0) >= 7.0) && (round(g[2] * 10.0) >= 7.0)) { // Xdown + Zdown
        return 12
    } else if ((round(g[1] * 10.0) <= -7.0) && (round(g[2] * 10.0) >= 7.0)) { // Yup + Zdown
        return 13
    } else if ((round(g[1] * 10.0) >= 7.0) && (round(g[2] * 10.0) >= 7.0)) { // Ydown + Zdown
        return 14
    }
    return 0
}

// Kiểm tra sự ổn định
func isStable(accelerometer a: double3) -> Bool {
    let recipNorm = 1.0/norm_one(a)
    var gravity: double3 = a
    gravity[0] *= recipNorm
    gravity[1] *= recipNorm
    gravity[2] *= recipNorm
    let ua = a - gravity
    print (norm_one(ua))
    return norm_one(ua) <= 0.07
}

func setLocation(_ location: double3) {
    let defaults = UserDefaults.standard
    defaults.set(Array.init(arrayLiteral: location[0],location[1],location[2]), forKey: "Location")
}

func getLocation() -> double3 {
    let defaults = UserDefaults.standard
    let obj = defaults.object(forKey: "Location")
    if obj == nil {
        return double3.init(21.07, 105.0, 10.0)
    }
    return double3.init(obj as! Array)
}

func setFixedBias(fixedBias b: double3, forKey key: String) {
    let defaults = UserDefaults.standard
    defaults.set(Array.init(arrayLiteral: b[0],b[1],b[2]), forKey: key)
}

func setFactorMatrix(factorMatrix m: double3x3, forKey key: String) {
    // Chuyển double3x3 sang các mảng số thực theo dòng
    let r0 = Array.init(arrayLiteral: m[0,0],m[0,1],m[0,2])
    let r1 = Array.init(arrayLiteral: m[1,0],m[1,1],m[1,2])
    let r2 = Array.init(arrayLiteral: m[2,0],m[2,1],m[2,2])
    
    // Lưu các véc-tơ dòng vào setting
    let defaults = UserDefaults.standard
    defaults.set(Array.init(arrayLiteral: r0,r1,r2), forKey: key)
}

func getFixedBias(forKey key: String) -> double3 {
    let defaults = UserDefaults.standard
    let obj = defaults.object(forKey: key)
    if obj == nil {
        return double3.init()
    }
    return double3.init(obj as! Array)
}

func getFactorMatrix(forKey key: String) -> double3x3 {
    // Lấy ra các dòng của ma trận từ setting
    let defaults = UserDefaults.standard
    let obj = defaults.object(forKey: key)
    if obj == nil {
        return double3x3.init(diagonal: [1.0,1.0,1.0])
    }
    let r: [[Double]] = obj as! [[Double]]
    if (r.count == 0) {
        return double3x3.init(diagonal: [1.0,1.0,1.0])
    }
    // Khôi phục lại double3x3
    return double3x3.init([double3.init(r[0]),double3.init(r[1]),double3.init(r[2])])
}

func RadiansToDegrees(_ radians: Double) -> Double {
    return radians * 180.0 / Double.pi
}

func RadiansToDegrees(_ radians: double3) -> double3 {
    let inv = 180.0/Double.pi
    return radians * inv
}

func DegreesToRadians(_ degrees: Double) -> Double {
    return degrees * Double.pi / 180.0
}

func DegreesToRadians(_ degrees: double3) -> double3 {
    let inv = Double.pi / 180.0
    return degrees * inv
}

func localGravity(_ latitude: Double,_ altitude: Double) -> Double {
    let phi = DegreesToRadians(latitude)
    let IGF = 9.780327*(1.0+0.0053024*sin(phi)*sin(phi)-0.0000058*sin(2.0*phi)*sin(2.0*phi))
    let FAC = -3.086*10e-6*altitude
    return IGF+FAC
}

func calculateMidPoint(_ p1 : CGPoint, _ p2 : CGPoint) -> CGPoint {
    return CGPoint(x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5);
}
