//
//  PhotoAnnotation.swift
//  PhotoMap
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/11/23.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 A simple model class to display pins representing photos on the map.
 */

import Foundation
import MapKit
import CoreLocation
import ImageIO
//import AEXML
import Photos

@objc(PhotoAnnotation)
class PhotoAnnotation: NSObject, MKAnnotation {

    // Bổ sung để xóa annotation từ mapView
    private var _mapView: MKMapView
    private var _allAnnotationsMapView: MKMapView
    
    private var _image: UIImage?
    var image: UIImage? {
        get { return getImage() }
    }
    
    //private var _thumbnail: UIImage?
    var thumbnail: UIImage? {
        get {
            let imageData = try! Data(contentsOf: URL(fileURLWithPath: imagePath!))
            let dataProvider = CGDataProvider(data: imageData as CFData)
            let imageSource = CGImageSourceCreateWithDataProvider(dataProvider!, nil)
            return thumbnailImage(src: imageSource!)
            
            // Nếu lưu _thumbnail thì một nhiều ảnh sẽ bị memorywaring
//            if _thumbnail == nil {
//                let imageData = try! Data(contentsOf: URL(fileURLWithPath: imagePath!))
//                let dataProvider = CGDataProvider(data: imageData as CFData)
//                let imageSource = CGImageSourceCreateWithDataProvider(dataProvider!, nil)
//                _thumbnail = thumbnailImage(src: imageSource!)
//            }
//            return _thumbnail
        }
    }
    
    private var _size: String?
    var size: String? {
        get {
            if _size == nil {
                _size = sizeForLocalFilePath(filePath: imagePath!)
            }
            return _size
        }
    }
    private var _descXML: AEXMLDocument?
    var descXML: AEXMLDocument? {
        get { return _descXML }
    }
    
    var imageFile: String?
    
    private var _imagePath: String?
    var imagePath: String? {
        get {
            if _imagePath == nil {
                _imagePath = docsURL.appendingPathComponent("Photos").appendingPathComponent(imageFile!).path
            }
            return _imagePath
        }
    }
    
    private var _title: String
    var title: String? {
        get { return getTitle() }
        set (newTitle) {
            _title = newTitle!
        }
    }
    
    private var _subtitle: String?
    var subtitle: String? {
        get {
//            if _subtitle == nil {
//                let location = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
//                let geocoder = CLGeocoder()
//                geocoder.reverseGeocodeLocation(location) {placemarks, error in
//                    if placemarks?.count ?? 0 > 0 {
//                        let placemark = placemarks![0]
//                        self._subtitle = "Near \(self.stringForPlacemark(placemark))"
//                    }
//                }
//            }
            return _subtitle
        }
    }
    
    private var _photoTitle: String
    var photoTitle: String? {
        get { return _photoTitle }
        set (newTitle) {
            _photoTitle = newTitle!
            updateFor(title: _photoTitle, desc: _photoDesc)
        }
    }
    
    private var _date: Date
    
    // GPX Element
    var wpt: AEXMLElement? {
        get {
            let wpt = AEXMLElement(name: "wpt", attributes:
                ["lat":_coordinate.latitude.toString(6),"lon":_coordinate.longitude.toString(6)])
            wpt.addChild(AEXMLElement(name: "ele", value: _altitude.toString(1)))
            wpt.addChild(AEXMLElement(name: "time", value: _date.iso8601))
            wpt.addChild(AEXMLElement(name: "cmt", value: _date.local))
            wpt.addChild(AEXMLElement(name: "name", value: imgName))
            wpt.addChild(AEXMLElement(name: "title", value: _photoTitle))
            wpt.addChild(AEXMLElement(name: "desc", value: _photoDesc))
            wpt.addChild(AEXMLElement(name: "type", value: "Photo"))
            return wpt
        }
    }
    // GPX Element
    var wptWithPhoto: AEXMLElement? {
        get {
            let wpt = AEXMLElement(name: "wpt", attributes:
                ["lat":_coordinate.latitude.toString(6),"lon":_coordinate.longitude.toString(6)])
            wpt.addChild(AEXMLElement(name: "ele", value: _altitude.toString(1)))
            wpt.addChild(AEXMLElement(name: "time", value: _date.iso8601))
            wpt.addChild(AEXMLElement(name: "desc", value: _photoDesc))
            wpt.addChild(AEXMLElement(name: "name", value: imgName))
            wpt.addChild(AEXMLElement(name: "title", value: _photoTitle))
            wpt.addChild(AEXMLElement(name: "type", value: "Photo"))
            let imageData = UIImageJPEGRepresentation(image!, CGFloat(IMAGE_COMPRESSION_QUALITY)/2.5)
            let imageStr:String = (imageData?.base64EncodedString())!
            let imgtag = "<img width='800' height=auto src='data:image/jpeg;base64,\(imageStr)'><br />"
            wpt.addChild(AEXMLElement(name: "cmt", value: "\(imgtag)\(_photoDesc)"))
            return wpt
        }
    }
    
    // Mô tả ảnh
    private var _photoDesc: String
    var photoDesc: String? {
        get { return _photoDesc }
        set (newDesc) {
            _photoDesc = newDesc!
            updateFor(title: _photoTitle, desc: _photoDesc)
        }
    }
    
    var _coordinate: CLLocationCoordinate2D
    dynamic var coordinate: CLLocationCoordinate2D {  //must be KVO compliant. (see MKAnnotation)
        get { return _coordinate }
    }
    func setCoordinate(_ newCoordinate: CLLocationCoordinate2D) {
        self._coordinate = newCoordinate
    }
    
    var _altitude: CLLocationDistance
    dynamic var altitude: CLLocationDistance {
        get { return _altitude }
        set (newAltitude) { self._altitude = newAltitude }
    }
    
    // Tên ảnh 
    var imgName: String? {
        get { return getImgName() }
    }

    
    
    // Hướng của ảnh
    private var _destBearing: Double
    var destBearing: Double? {
        get { return _destBearing }
    }
    
    // Ngày giờ chụp ảnh
    private var _dateTime: String
    var dateTime: String? {
        get { return _dateTime }
    }

    // Bổ sung GPS Info
    private var _gpsInfo: [String: AnyObject]
    var gpsInfo: [String: AnyObject]? {
        get { return getGPSInfo() }
        set (newGPSInfo) {
            self._gpsInfo = newGPSInfo!
        }
    }
    
    var clusterAnnotation: PhotoAnnotation?
    var containedAnnotations: [PhotoAnnotation] = []

    // Bổ sung thêm mapView để xóa annotation
    init(imageFile anImageFile: String, descXML aDescXML: String, gpsInfo aGPSInfo: [String: AnyObject], coordinate aCoordinate: CLLocationCoordinate2D, mapView aMapView: MKMapView, allAnnotationsMapView aAllAnnotationsMapView: MKMapView) {
        
        self.imageFile = anImageFile
        let xml = XMLParser(data: aDescXML.data(using: .utf8)!)
        if xml.parse() {
            var options = AEXMLOptions()
            options.parserSettings.shouldProcessNamespaces = false
            options.parserSettings.shouldReportNamespacePrefixes = false
            options.parserSettings.shouldResolveExternalEntities = false
            self._descXML = try! AEXMLDocument(xml: aDescXML.data(using: .utf8)!, options: options)
            let childDesc = self._descXML?.root["GTField"]["desc"]
            if childDesc?.error == nil {
                let title = (childDesc?.attributes["title"])!
                let desc = childDesc?.value ?? ""
                self._title = title.removingPercentEncoding!
                self._photoTitle = title.removingPercentEncoding!
                self._photoDesc = desc.removingPercentEncoding!
            } else {
                self._title = URL(fileURLWithPath: docsURL.appendingPathComponent("Photos").appendingPathComponent(imageFile!).path).deletingPathExtension().lastPathComponent
                self._photoTitle = self._title
                self._photoDesc = ""
            }
        } else {
            let xmlRequest = AEXMLDocument()
            let userCommentRoot = xmlRequest.addChild(name: "UserComment")
            let appAttributes = ["version":"\(APP_VERSION)","build":"\(APP_BUILD)"]
            let appRoot = userCommentRoot.addChild(name: "\(APP_NAME)", attributes: appAttributes)
            let title = URL(fileURLWithPath: docsURL.appendingPathComponent("Photos").appendingPathComponent(imageFile!).path).deletingPathExtension().lastPathComponent
            let photoAttributes = ["type":"Photo","name":title,"title":title]
            let desc = ""
            appRoot.addChild(name: "desc", value: desc, attributes: photoAttributes)
            self._descXML = xmlRequest
            self._title = title
            self._photoTitle = title
            self._photoDesc = desc
            setImagePropertyExifUserComment(URL(fileURLWithPath: docsURL.appendingPathComponent("Photos").appendingPathComponent(imageFile!).path), xmlRequest.xmlCompact)
        }
        
        self._gpsInfo = aGPSInfo
        self._coordinate = aCoordinate
        self._mapView = aMapView
        self._allAnnotationsMapView = aAllAnnotationsMapView
        
        self._destBearing = aGPSInfo[kCGImagePropertyGPSDestBearing as String] as! Double
        self._altitude = aGPSInfo[kCGImagePropertyGPSAltitude as String] as! Double
        
        // Lấy thời gian
        let dateStamp = aGPSInfo[kCGImagePropertyGPSDateStamp as String] as! String
        let timeStamp = aGPSInfo[kCGImagePropertyGPSTimeStamp as String] as! String
        let dateString = "\(dateStamp) \(timeStamp)"
        var dateFormatter = DateFormatter()
        
        // TODO: Lưu ý khi chuyển đổi thời gian
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        self._date = dateFormatter.date(from: dateString)!
        
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        self._dateTime = dateFormatter.string(from: self._date)
        super.init()
    }
    
    private func getTitle() -> String {
        if self.containedAnnotations.count > 0 {
            return "\(self.containedAnnotations.count + 1) Photos"
        }
        return _title
    }
    
    private func getImgName() -> String {
        return URL(fileURLWithPath: imagePath!).deletingPathExtension().lastPathComponent
    }
    
    private func getGPSInfo() -> [String: AnyObject] {
        return _gpsInfo
    }
    
    private func getImage() -> UIImage? {

        if _image == nil && self.imagePath != nil {
            _image = UIImage(contentsOfFile: self.imagePath!)
        }
        return _image
    }

    private func stringForPlacemark(_ placemark: CLPlacemark) -> String {

        var string = ""
        if placemark.locality != nil {
            string += placemark.locality!
        }

        if placemark.administrativeArea != nil {
            if !string.isEmpty {
                string += ", "
            }
            string += placemark.administrativeArea!
        }

        if string.isEmpty && placemark.name != nil {
            string += placemark.name!
        }

        return string
    }

    func updateSubtitleIfNeeded() {

        if self._subtitle == nil {
        // for the subtitle, we reverse geocode the lat/long for a proper location string name
            let location = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) {placemarks, error in
                if placemarks?.count ?? 0 > 0 {
                    let placemark = placemarks![0]
                    self._subtitle = "\(self.stringForPlacemark(placemark))"
                }
            }
        }
    }
    
    func updateSubtitleFor(label: UILabel) {
        if self._subtitle == nil {
            // for the subtitle, we reverse geocode the lat/long for a proper location string name
            let location = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) {placemarks, error in
                if placemarks?.count ?? 0 > 0 {
                    let placemark = placemarks![0]
                    self._subtitle = "\(self.stringForPlacemark(placemark))"
                    //"Near \(self.stringForPlacemark(placemark))"
                    label.text = self._subtitle
                }
            }
        }
        label.text = _subtitle
    }
    
    func updateFor(title: String, desc: String) {
        // Đọc xml
        var options = AEXMLOptions()
        options.parserSettings.shouldProcessNamespaces = false
        options.parserSettings.shouldReportNamespacePrefixes = false
        options.parserSettings.shouldResolveExternalEntities = false
        
        do {
            _photoTitle = title
            _photoDesc = desc
            let childDesc = self._descXML?.root["GTField"]["desc"]
            childDesc?.attributes["title"] = _photoTitle.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
            childDesc?.value = _photoDesc.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
            setImagePropertyExifUserComment(URL(fileURLWithPath: imagePath!), (self._descXML?.xmlCompact)!)
        }
    }
    
    // Xóa annotation khỏi mapView
    func delete(all : Bool) {
        self._mapView.removeAnnotation(self)
        self._allAnnotationsMapView.removeAnnotation(self)
        
        // Xóa ảnh
        if all && self.containedAnnotations.count > 0 {
            for item in self.containedAnnotations {
                do {
                    try FileManager.default.removeItem(atPath: item.imagePath!)
                }
                catch let error as NSError {
                    print("Ooops! Something went wrong: \(error)")
                }
            }
        }
        
        do {
            try FileManager.default.removeItem(atPath: self.imagePath!)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
}
