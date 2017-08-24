//
//  GPX.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 7/22/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps
//import AEXML

let STROKE_COLOR_SELECTING = UIColor(hue: 204.0/360.0, saturation: 65.0/100.0, brightness: 50.0/100.0, alpha: 1.0)
let STROKE_COLOR_EDITING = UIColor(hue: 204.0/360.0, saturation: 65.0/100.0, brightness: 50.0/100.0, alpha: 1.0)
let FILL_COLOR_NONE = UIColor(hue: 204.0/360.0, saturation: 65.0/100.0, brightness: 50.0/100.0, alpha: 0.05)
let STROKE_COLOR_NONE = UIColor(hue: 204.0/360.0, saturation: 65.0/100.0, brightness: 50.0/100.0, alpha: 1.0)
let STROKE_WIDTH_NONE: CGFloat = 1
let FILL_COLOR_SELECTING = UIColor(hue: 129.0/360.0, saturation: 68.0/100.0, brightness: 85.0/100.0, alpha: 0.06)
let STROKE_WIDTH_SELECTING: CGFloat = 2
let FILL_COLOR_EDITING = UIColor.clear
let STROKE_WIDTH_EDITING: CGFloat = 2

extension GMSPath {
    func closed() -> GMSPath {
        let cllc2d1 = self.coordinate(at: 0)
        let cllc2d2 = self.coordinate(at: count()-1)
        if cllc2d1.latitude == cllc2d2.latitude && cllc2d1.longitude == cllc2d2.longitude {
            return self
        } else {
            let path = self.mutableCopy() as? GMSMutablePath
            path?.add(cllc2d1)
            return path!
        }
    }
}

class GPXMetadata: NSObject {
    private var _root: AEXMLElement
    var root: AEXMLElement {
        get { return _root }
    }
    private var _name: AEXMLElement
    var name: String {
        get {
            if let value = _name.value {
                return value.removingPercentEncoding!
            } else {
                _name.value = ""
            }
            return (_name.value?.removingPercentEncoding)!
        }
        set (name) {
            _name.value = name.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        }
    }
    private var _desc: AEXMLElement
    var desc: String {
        get {
            if let value = _desc.value {
                return value.removingPercentEncoding!
            } else {
                _desc.value = ""
            }
            return (_desc.value?.removingPercentEncoding)!
        }
        set (desc) {
            _desc.value = desc.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        }
    }
    private var _time: Date
    var time: Date {
        get { return _time }
        set (time) { _time = time }
    }
    func delete() {
        _root.removeFromParent()
    }
    
    override init() {
        _root = AEXMLElement(name: "metadata")
        _time = Date()
        _name = AEXMLElement(name: "name", value: getFileNameByGPSTime(ext: "gpx", date: _time))
        _desc = AEXMLElement(name: "desc", value: _time.local.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed))
        _root.addChild(_name)
        _root.addChild(_desc)
        _root.addChild(AEXMLElement(name: "time", value: _time.iso8601))
        super.init()
    }
    init(_ root: AEXMLElement) {
        _root = root
        // TODO: parse ở đây
        _time = (root["time"].value?.dateFromISO8601)!
        _name = root["name"]
        _desc = root["desc"]
        super.init()
    }
}

class GPXWaypoint: GMSMarker {
    private var _root: AEXMLElement
    var root: AEXMLElement {
        get { return _root }
    }
    private var _name: AEXMLElement
    var name: String {
        get {
            if let value = _name.value {
                return value.removingPercentEncoding!
            } else {
                if let value = _time.value {
                    return value
                } else {
                    _name.value = ""
                }
            }
            return (_name.value?.removingPercentEncoding)!
        }
        set (value) {
            _name.value = value.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
            title = value
        }
    }
    private var _time: AEXMLElement
    var time: String {
        get {
            if let value = _time.value {
                return value
            } else {
                _time.value = Date().iso8601
            }
            return (_time.value)!
        }
        set (value) {
            _time.value = value
        }
    }
    private var _desc: AEXMLElement
    var desc: String {
        get {
            if let value = _desc.value {
                return value.removingPercentEncoding!
            } else {
                _desc.value = ""
            }
            return (_desc.value?.removingPercentEncoding)!
        }
        set (value) {
            _desc.value = value.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        }
    }
    private var _ele: AEXMLElement
    var ele: String {
        get { return _ele.value! }
        set (value) { _ele.value = value }
    }
    private var _iconType: AEXMLElement
    var iconType: String {
        get {
            if let value = _iconType.value {
                return value.removingPercentEncoding!
            } else {
                _iconType.value = ""
            }
            return (_iconType.value?.removingPercentEncoding)!
        }
        set (iconType) {
            _iconType.value = iconType.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        }
    }
    func delete() {
        map = nil
        _root.removeFromParent()
    }
    
    init(position: CLLocationCoordinate2D) {
        let attributes = ["lat" : position.latitude.toString(6),"lon": position.longitude.toString(6)]
        let time = Date()
        _name = AEXMLElement(name: "title", value: time.iso8601)
        _ele = AEXMLElement(name: "ele", value: "0.0")
        _desc = AEXMLElement(name: "desc", value: "")
        _time = AEXMLElement(name: "time", value: time.iso8601)
        _iconType = AEXMLElement(name: "type", value: "Waypoint")
        _root = AEXMLElement(name: "wpt", attributes: attributes)
        _root.addChild(AEXMLElement(name: "name", value: getFileNameByGPSTime(ext: "", date: time)))
        _root.addChild(_time)
        _root.addChild(_name)
        _root.addChild(_ele)
        _root.addChild(_desc)
        _root.addChild(_iconType)
        
        super.init()
        self.position = position
        title = _name.value
        snippet = "\(position.latitude.toString(6)),\(position.longitude.toString(6))"
        appearAnimation = .pop
        isFlat = true
        groundAnchor = CGPoint(x:0.5, y:1.0)
        icon = #imageLiteral(resourceName: "pinWaypoint")
    }
    
    init(xmlElement: AEXMLElement) {
        _root = xmlElement
        _name = _root["name"]
        if _name.error != nil {
            _name = _root["title"]
        }
        _ele = _root["ele"]
        _desc = _root["desc"]
        _iconType = _root["type"]
        _time = _root["time"]
        let attributes = _root.attributes
        super.init()
        let position = CLLocationCoordinate2D(latitude: Double(attributes["lat"]!)!, longitude: Double(attributes["lon"]!)!)
        self.position = position
        title = _name.value
        snippet = "\(position.latitude.toString(6)),\(position.longitude.toString(6))"
        appearAnimation = .pop
        isFlat = true
        groundAnchor = CGPoint(x:0.5, y:1.0)
        
        icon = UIImage(named: "pin\(iconType)")
    }
}

class GPXTrackPoint: NSObject {
    private var _lat: CLLocationDegrees
    private var _lon: CLLocationDegrees
    private var _ele: CLLocationDistance
    private var _time: String
    
    init(_ lat: CLLocationDegrees, _ lon: CLLocationDegrees, _ ele: CLLocationDistance, _ time: String) {
        _lat = lat
        _lon = lon
        _ele = ele
        _time = time
        super.init()
    }
    
    init(_ location: CLLocation) {
        _lat = location.coordinate.latitude
        _lon = location.coordinate.longitude
        _ele = location.altitude
        _time = location.timestamp.iso8601
        super.init()
    }
    
    init(xmlElement: AEXMLElement) {
        let attributes = xmlElement.attributes
        _lat = Double(attributes["lat"]!)!
        _lon = Double(attributes["lon"]!)!
        if xmlElement["ele"].error == nil {
            _ele = Double(xmlElement["ele"].value!)!
        } else {
            _ele = 0.0
        }
        
        if xmlElement["time"].error == nil {
            _time = xmlElement["time"].value!
        } else {
            _time = ""
        }
        
        super.init()
    }
    
    var element: AEXMLElement {
        get {
            let attributes = ["lat" : _lat.toString(6),"lon": _lon.toString(6)]
            let element = AEXMLElement(name: "trkpt", attributes: attributes)
            element.addChild(AEXMLElement(name: "ele", value: _ele.toString(1)))
            element.addChild(AEXMLElement(name: "time", value: _time))
            return element
        }
    }
    
    var coord: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: _lat, longitude: _lon)
        }
    }
    
    var ele: CLLocationDistance {
        get { return _ele }
    }
}

class GPXPoint: NSObject {
    private var _lat: CLLocationDegrees
    private var _lon: CLLocationDegrees
    private var _ele: CLLocationDistance
    private var _time: String
    
    init(_ lat: CLLocationDegrees, _ lon: CLLocationDegrees, _ ele: CLLocationDistance, _ time: String) {
        _lat = lat
        _lon = lon
        _ele = ele
        _time = time
        super.init()
    }
    
    init(_ location: CLLocation) {
        _lat = location.coordinate.latitude
        _lon = location.coordinate.longitude
        _ele = location.altitude
        _time = location.timestamp.iso8601
        super.init()
    }
    
    init(xmlElement: AEXMLElement) {
        let attributes = xmlElement.attributes
        _lat = Double(attributes["lat"]!)!
        _lon = Double(attributes["lon"]!)!
        if xmlElement["ele"].error == nil {
            _ele = Double(xmlElement["ele"].value!)!
        } else {
            _ele = 0.0
        }
        
        if xmlElement["time"].error == nil {
            _time = xmlElement["time"].value!
        } else {
            _time = ""
        }
        
        super.init()
    }
    
    var element: AEXMLElement {
        get {
            let attributes = ["lat" : _lat.toString(6),"lon": _lon.toString(6)]
            let element = AEXMLElement(name: "pt", attributes: attributes)
            element.addChild(AEXMLElement(name: "ele", value: _ele.toString(1)))
            element.addChild(AEXMLElement(name: "time", value: _time))
            return element
        }
    }
    
    var coord: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: _lat, longitude: _lon)
        }
        set (value) {
            element.attributes["lat"] = coord.latitude.toString(6)
            element.attributes["lon"] = coord.longitude.toString(6)
        }
    }
    
    var ele: CLLocationDistance {
        get { return _ele }
    }
}

class GPXTrackSegmentOverlay: GMSPolyline {
    private var _trackSegment: GPXTrackSegment?
    var trackSegment: GPXTrackSegment {
        get { return _trackSegment! }
        set (trackSegment) {
            _trackSegment = trackSegment
        }
    }
}

class GPXPointSegmentOverlay: GMSPolygon {
    private var _pointSegment: GPXPointSegment?
    var pointSegment: GPXPointSegment {
        get { return _pointSegment! }
        set (pointSegment) {
            _pointSegment = pointSegment
        }
    }
}

extension GPXTrackSegment: VertexViewTouchDelegate {
    func touchBegan(touch: UITouch) {
        
    }
    
    func touchMoved(touch: UITouch) {
//        let idx1 = (activeIndex - 1) >= 0 ? (activeIndex - 1) : path.count() - 1
//        let idx2 = (activeIndex + 1) < path.count() ? (activeIndex + 1) : 0
//        let pt = GMSMutablePath()
//        pt.add(path.coordinate(at: idx1))
//        pt.add(path.coordinate(at: idx2))
//        let dashedPolyline = GMSPolyline(path: pt)
//        dashedPolyline.map = map
    }
    
    func touchEnded(touch: UITouch) {
        let view: VertexView = touch.view as! VertexView
        let poi = view.origin
        let position = map?.projection.coordinate(for: poi)
        self.updateVertex(self.activeIndex, position!)
        
        print(position?.localizedCoordinateString() ?? "")
        //selectedOverlay?.trackSegment.updateVertex(index, position)
    }
}

class GPXTrackSegment: GMSOverlay {
    var vertices: [GMSMarker] = [GMSMarker]()
    var middlePoint: [GMSMarker] = [GMSMarker]()
    var _oldPath: GMSMutablePath?
    var _oldTrackPts: [GPXTrackPoint] = [GPXTrackPoint]()
    private var _activeIndex: UInt = 0
    private var _activeVertexView: VertexView? = nil
    private var _areaLabel: UILabel? = nil
    var areaLabel: UILabel {
        get {
            if _areaLabel == nil {
                _areaLabel = UILabel()
                _areaLabel?.isUserInteractionEnabled = true
                _areaLabel?.copyable = true
                _areaLabel?.frame = CGRect(x: 0, y: 0, width: 320, height: 24)
                _areaLabel?.translatesAutoresizingMaskIntoConstraints = false
                _areaLabel?.textAlignment = .center
                _areaLabel?.numberOfLines = 0
                _areaLabel?.textColor = UIColor.brown
                _areaLabel?.font=UIFont.boldSystemFont(ofSize: 12)
                _areaLabel?.isHidden = true
                map?.addSubview(_areaLabel!)
                // Căn trên
                NSLayoutConstraint(item: _areaLabel!,
                                   attribute: .top,
                                   relatedBy: .equal,
                                   toItem: map,
                                   attribute: .top,
                                   multiplier: 1.0,
                                   constant: 110).isActive = true
                
                // Căn giữa so với view
                NSLayoutConstraint(item: _areaLabel!,
                                   attribute: .centerX,
                                   relatedBy: .equal,
                                   toItem: map,
                                   attribute: .centerX,
                                   multiplier: 1.0,
                                   constant: 0).isActive = true
            }
            return _areaLabel!
        }
    }
    
    var activeIndex: UInt {
        get { return _activeIndex }
        set (value) {
            _activeIndex = value
        }
    }
    
    // TODO: Nên thay NSObject bằng GMSPolyline để quản lý với bản đồ
    enum GPXTrackSegmentActions {
        case none
        case clear
        case done
        case tracking
        case selecting
        case editing
        case reset
        case delete
    }
    
    //
    override var map: GMSMapView? {
        didSet {
            _polyline?.map = map
            if map != nil {
                
            } else {
                
            }
        }
    }
    
    var area: Double {
        get {
            return GMSGeometryArea(path)
        }
    }
    var length: Double {
        get {
            return GMSGeometryLength(path)
        }
    }
    
    func updateLabel() {
        areaLabel.text = NSLocalizedString("Length:", comment: "") + " \((length.distanceUnit()))"
    }
    
    private var _actions: GPXTrackSegmentActions = .none
    var actions: GPXTrackSegmentActions {
        get { return _actions }
        set (actions) {
            if _actions == actions {
                return
            }
            if _actions == .editing {
                setEditing(false)
            }
            if _actions == .tracking {
                _root?.attributes["type"] = "tracks"
            }
            switch actions {
            case .none:
                _polyline?.strokeColor = UIColor.clear
                _polyline?.spans = _spans
                
                removeVertices()
                if _oldPath != nil {
                    _path = _oldPath
                    _polyline?.path = _path
                    _root?.children.removeAll()
                    for child in _oldTrackPts {
                        _root?.addChild(child.element)
                    }
                }
                break
            case .clear:
                _polyline?.map = nil
                _polyline = nil
                removeVertices()
                break
            case .done:
                _polyline?.strokeColor = UIColor.clear
                _polyline?.spans = _spans
                _oldPath = nil
                removeVertices()
                break
            case .tracking:
                
                break
            case .selecting:
                areaLabel.isHidden = false
                updateLabel()
                _polyline?.spans = nil
                _polyline?.strokeColor = STROKE_COLOR_SELECTING
                _polyline?.strokeWidth = 2
                break
            case .editing:
                _polyline?.spans = nil
                _polyline?.strokeColor = STROKE_COLOR_EDITING
                _polyline?.strokeWidth = 2
                setEditing(true)
                _oldPath = _path?.mutableCopy() as? GMSMutablePath
                
                // Tạo bản sao root
                for child in (_root?.children)! {
                    _oldTrackPts.append(GPXTrackPoint(xmlElement: child))
                }
                
                break
            case .reset, .delete:
                _polyline?.map = nil
                _polyline = nil
                root.removeFromParent()
                removeVertices()
                break
            }
            _actions = actions
        }
    }
    private func addVertices() {
        if _polyline == nil {
            return
        }
        for i:UInt in 0...(path.count()) {
            let coord = path.coordinate(at: i)
            let vertex = GMSMarker(position: coord)
            //vertex.isDraggable = true
            let markerImage = UIImage(named: "vertex")!.withRenderingMode(.alwaysTemplate)
            vertex.icon = markerImage
            vertex.userData =  ["type":"vertex","id": "\(i)"]
            vertex.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            vertex.map = map
            vertices.append(vertex)
            if i > 0 {
                let coord0 = path.coordinate(at: i-1)
                let coord1 = path.coordinate(at: i)
                let middle = GMSMarker(position: (coord0.middleLocationWith(location: coord1)))
                middle.isDraggable = true
                let markerImage = UIImage(named: "middle")!.withRenderingMode(.alwaysTemplate)
                middle.icon = markerImage
                middle.userData =  ["type":"middle","id": "\(i)"]
                middle.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                middle.map = map
                middlePoint.append(middle)
            }
        }
        // Hiện vertex để sửa (drag)
        setActiveVertex(_activeIndex)
        areaLabel.isHidden = false
        updateLabel()
    }
    
    private func removeVertices() {
        for vertex in vertices {
            vertex.map = nil
        }
        for middle in middlePoint {
            middle.map = nil
        }
        vertices.removeAll()
        middlePoint.removeAll()
        
        // Ẩn vertex sau khi sửa xong (drag)
        deActiveVertex()
        areaLabel.isHidden = true
    }
    
    private func setEditing(_ editing: Bool) {
        if editing {
            addVertices()
        } else {
            removeVertices()
        }
    }
    
    // Thay đổi icon, cho phéo drag để chỉnh sửa đỉnh
    func setActiveVertex(_ index: UInt) {
        activeIndex = index
        let poi = map?.projection.point(for: path.coordinate(at: index))
        if _activeVertexView == nil {
            _activeVertexView = VertexView(origin: poi!)
            map?.addSubview(_activeVertexView!)
        } else {
            _activeVertexView?.origin = poi!
            _activeVertexView?.isHidden = false
        }
        _activeVertexView?.delegate = self
    }
    
    // Bỏ chế độ chỉnh sửa đỉnh
    func deActiveVertex() {
        if _activeVertexView != nil {
            _activeVertexView?.isHidden = true
        }
    }
    
    // Sửa đỉnh
    func updateVertex(_ index: UInt, _ position: CLLocationCoordinate2D) {
        _path?.replaceCoordinate(at: index, with: position)
        _polyline?.path = _path
        let trkpt: AEXMLElement = (_root?["trkpt"].all![Int(index)])!
        trkpt.attributes["lat"] = position.latitude.toString(6)
        trkpt.attributes["lon"] = position.longitude.toString(6)
        removeVertices()
        addVertices()
    }
    
    // Thêm đỉnh
    func insertVertex(_ index: UInt, _ position: CLLocationCoordinate2D) {
        insertTrackPoint(index, GPXTrackPoint(position.latitude, position.longitude, 0, Date().iso8601))
        removeVertices()
        addVertices()
    }
    
    // Xóa đỉnh
    func deleteVertex(_ index: UInt) {
        if path.count() > 0 {
            deleteTrackPoint(at: index)
        }
    }
    
    func deleteActiveVertex() {
        deleteVertex(activeIndex)
    }
    
//    private var _desc: AEXMLElement
//    var desc: String {
//        get {
//            if let value = _desc.value {
//                return value.removingPercentEncoding!
//            } else {
//                _desc.value = ""
//            }
//            return (_desc.value?.removingPercentEncoding)!
//        }
//        set (desc) {
//            _desc.value = desc.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
//        }
//    }

    private var _elevations: [CLLocationDistance]
    var elevations: [CLLocationDistance] {
        get { return _elevations }
    }
    
    private var _root: AEXMLElement?
    var root: AEXMLElement {
        get { return _root! }
    }
    
    private var _path: GMSMutablePath?
    var path: GMSMutablePath {
        get { return _path! }
    }
    
    private var _spans: [GMSStyleSpan]
    var spans: [GMSStyleSpan] {
        get { return _spans }
    }
    
    private var _prevColor: UIColor?
    
    func delete() {
        map = nil
        root.removeFromParent()
    }
    
    private var _polyline: GPXTrackSegmentOverlay?
    var overlay: GPXTrackSegmentOverlay {
        get {
            return _polyline!
        }
    }
    
    // Tạo đối tượng để thêm mới bình thường
    init(_ track: AEXMLElement, _ map: GMSMapView) {
        //_coords = [CLLocationCoordinate2D]()
        _elevations = [CLLocationDistance]()
        _spans = [GMSStyleSpan]()
        _path = GMSMutablePath()
        _prevColor = nil
        
        let attributes = ["type" : ""]
        _root = AEXMLElement(name: "trkseg", attributes: attributes)
        
        //_desc = AEXMLElement(name: "desc", value: "")
        //_root?.addChild(_desc)
        track.addChild(_root!)
        super.init()
        self.map = map
        title = Date().iso8601
        isTappable = true
        
        _polyline = GPXTrackSegmentOverlay(path: _path)
        _polyline?.spans = spans
        _polyline?.strokeWidth = 3
        _polyline?.isTappable = true
        _polyline?.trackSegment = self
    }
    
    // Parse từ file
    init(xmlElement: AEXMLElement, map: GMSMapView) {
        //_coords = [CLLocationCoordinate2D]()
        _elevations = [CLLocationDistance]()
        _spans = [GMSStyleSpan]()
        _path = GMSMutablePath()
        _prevColor = nil
        _root = xmlElement
        let attributes = xmlElement.attributes
        if attributes.count == 0 {
            _root?.attributes = ["type" : ""]
        }
        
//        _desc = xmlElement["desc"]
//        if _desc.error != nil  {
//            _desc = AEXMLElement(name: "desc", value: "")
//            _root?.addChild(_desc)
//        }
        super.init()
        
        self.map = map
        
        // TODO: Parse
        if let trkptElements = _root?["trkpt"].all,
            (trkptElements.count) > 0 {
            for trkptElement in trkptElements {
                let trkpt = GPXTrackPoint(xmlElement: trkptElement)
                //addTrackPoint(trkpt)
                // Add track point nhưng không thêm vào root root.addChild(trkpt.element)
                //_coords.append(trkpt.coord)
                _elevations.append(trkpt.ele)
                _path?.add(trkpt.coord)
                let toColor = UIColor(hue: CGFloat(trkpt.ele/ELEVATION_COLOR_SPANS),
                                      saturation: 1.0,
                                      brightness: 0.9,
                                      alpha: 1.0)
                if (_prevColor == nil) {
                    _prevColor = toColor
                }
                let style = GMSStrokeStyle.gradient(from: _prevColor!, to: toColor)
                _spans.append(GMSStyleSpan(style: style))
                _prevColor = toColor
            }
            _polyline = GPXTrackSegmentOverlay(path: _path)
            _polyline?.spans = spans
            _polyline?.strokeWidth = 3
            _polyline?.map = map
            _polyline?.isTappable = true
            _polyline?.trackSegment = self
        }
    }
    
    func addTrackPoint(_ trkpt: GPXTrackPoint, _ actions: GPXTrackSegmentActions) {
        _actions = actions
        _polyline?.map = nil
        _polyline = nil
        
        //_coords.append(trkpt.coord)
        _elevations.append(trkpt.ele)
        _path?.add(trkpt.coord)
        let toColor = UIColor(hue: CGFloat(trkpt.ele/700),
                              saturation: 1.0,
                              brightness: 0.9,
                              alpha: 1.0)
        if (_prevColor == nil) {
            _prevColor = toColor
        }
        let style = GMSStrokeStyle.gradient(from: _prevColor!, to: toColor)
        _spans.append(GMSStyleSpan(style: style))
        _prevColor = toColor
        root.addChild(trkpt.element)
        
        _polyline = GPXTrackSegmentOverlay(path: _path)
        _polyline?.spans = spans
        _polyline?.strokeWidth = 3
        _polyline?.map = map
        _polyline?.isTappable = true
        _polyline?.trackSegment = self
        if _actions == .editing {
            removeVertices()
            addVertices()
        }
    }
    
    private func insertTrackPoint(_ index: UInt, _ trkpt: GPXTrackPoint) {
        if index == (_path?.count())! {
            addTrackPoint(trkpt, .editing)
            return
        }
        //_actions = .editing
        _polyline?.map = nil
        _polyline = nil
        
        _elevations.insert(trkpt.ele, at: Int(index))
        _path?.insert(trkpt.coord, at: index)
        _root?.insertChild(trkpt.element, at: Int(index))
        
        _polyline = GPXTrackSegmentOverlay(path: _path)
        _polyline?.strokeWidth = 3
        _polyline?.map = map
        _polyline?.isTappable = true
        _polyline?.trackSegment = self
    }
    private func deleteTrackPoint(at: UInt) {
        _polyline?.map = nil
        _polyline = nil
        
        _elevations.remove(at: Int(at))
        _path?.removeCoordinate(at: at)
        _root?.children.remove(at: Int(at))
        
        _polyline = GPXTrackSegmentOverlay(path: _path)
        _polyline?.strokeWidth = 3
        _polyline?.map = map
        _polyline?.isTappable = true
        _polyline?.trackSegment = self
        if _actions == .editing {
            removeVertices()
            addVertices()
        }
    }
}

extension GPXPointSegment: VertexViewTouchDelegate {
    func touchBegan(touch: UITouch) {
        
    }
    
    func touchMoved(touch: UITouch) {
        
    }
    
    func touchEnded(touch: UITouch) {
        let view: VertexView = touch.view as! VertexView
        let poi = view.origin
        let position = map?.projection.coordinate(for: poi)
        self.updateVertex(self.activeIndex, position!)
        
        print(position?.localizedCoordinateString() ?? "")
        //selectedOverlay?.trackSegment.updateVertex(index, position)
    }
}

class GPXPointSegment: GMSOverlay {
    var vertices: [GMSMarker] = [GMSMarker]()
    var middlePoint: [GMSMarker] = [GMSMarker]()
    var _oldPath: GMSMutablePath?
    var _oldPts: [GPXPoint] = [GPXPoint]()
    private var _activeIndex: UInt = 0
    private var _activeVertexView: VertexView? = nil
    private var _areaLabel: UILabel? = nil
    var areaLabel: UILabel {
        get {
            if _areaLabel == nil {
                _areaLabel = UILabel()
                _areaLabel?.isUserInteractionEnabled = true
                _areaLabel?.copyable = true
                _areaLabel?.frame = CGRect(x: 0, y: 0, width: 320, height: 24)
                _areaLabel?.translatesAutoresizingMaskIntoConstraints = false
                _areaLabel?.textAlignment = .center
                _areaLabel?.numberOfLines = 0
                _areaLabel?.textColor = UIColor.brown
                _areaLabel?.font=UIFont.boldSystemFont(ofSize: 12)
                _areaLabel?.isHidden = true
                map?.addSubview(_areaLabel!)
                // Căn trên
                NSLayoutConstraint(item: _areaLabel!,
                                   attribute: .top,
                                   relatedBy: .equal,
                                   toItem: map,
                                   attribute: .top,
                                   multiplier: 1.0,
                                   constant: 110).isActive = true
                
                // Căn giữa so với view
                NSLayoutConstraint(item: _areaLabel!,
                                   attribute: .centerX,
                                   relatedBy: .equal,
                                   toItem: map,
                                   attribute: .centerX,
                                   multiplier: 1.0,
                                   constant: 0).isActive = true
            }
            return _areaLabel!
        }
    }
    
    var activeIndex: UInt {
        get { return _activeIndex }
        set (value) {
            _activeIndex = value
        }
    }
    
    // TODO: Nên thay NSObject bằng GMSPolyline để quản lý với bản đồ
    enum GPXPointSegmentActions {
        case none
        case clear
        case done
        case selecting
        case editing
        case reset
        case delete
    }
    override var map: GMSMapView? {
        didSet {
            _polygon?.map = map
            if map != nil {

            } else {

            }
        }
    }
    var area: Double {
        get {
            return GMSGeometryArea(path)
        }
    }
    var length: Double {
        get {
            return GMSGeometryLength(path.closed())
        }
    }
    
    func updateLabel() {
        areaLabel.text = NSLocalizedString("Area:", comment: "")+" \((area.areaUnit())), "+NSLocalizedString("Perimeter:", comment: "")+" \((length.distanceUnit()))"
    }
    
    private var _actions: GPXPointSegmentActions = .none
    var actions: GPXPointSegmentActions {
        get { return _actions }
        set (actions) {
            if _actions == actions {
                return
            }
            if _actions == .editing {
                setEditing(false)
            }
            switch actions {
            case .none:
                _polygon?.fillColor = FILL_COLOR_NONE
                _polygon?.strokeColor = STROKE_COLOR_NONE
                _polygon?.strokeWidth = STROKE_WIDTH_NONE
                removeVertices()
                if _oldPath != nil {
                    _path = _oldPath
                    _polygon?.path = _path
                    _root?.children.removeAll()
                    for child in _oldPts {
                        _root?.addChild(child.element)
                    }
                }
                break
            case .clear:
                _polygon?.map = nil
                _polygon = nil
                _oldPath = nil
                break
            case .done:
                _polygon?.fillColor = FILL_COLOR_NONE
                _polygon?.strokeColor = STROKE_COLOR_NONE
                _polygon?.strokeWidth = STROKE_WIDTH_NONE
                _oldPath = nil
                removeVertices()
                break
            case .selecting:
                areaLabel.isHidden = false
                updateLabel()
                _polygon?.fillColor = FILL_COLOR_SELECTING
                _polygon?.strokeColor = STROKE_COLOR_SELECTING
                _polygon?.strokeWidth = STROKE_WIDTH_SELECTING
                break
            case .editing:
                _polygon?.fillColor = FILL_COLOR_EDITING
                _polygon?.strokeColor = STROKE_COLOR_EDITING
                _polygon?.strokeWidth = STROKE_WIDTH_EDITING
                setEditing(true)
                _oldPath = _path?.mutableCopy() as? GMSMutablePath
                
                // Tạo bản sao root
                for child in (_root?.children)! {
                    _oldPts.append(GPXPoint(xmlElement: child))
                }
                break
            case .reset, .delete:
                _polygon?.map = nil
                _polygon = nil
                _oldPath = nil
                root.removeFromParent()
                removeVertices()
                break
            }
            _actions = actions
        }
    }
    private func addVertices() {
        if _polygon == nil || _path?.count() == 0 {
            return
        }
        for i:UInt in 0...(path.count()) {
            let coord = path.coordinate(at: i)
            let vertex = GMSMarker(position: coord)
            vertex.isDraggable = true
            let markerImage = UIImage(named: "vertex")!.withRenderingMode(.alwaysTemplate)
            vertex.icon = markerImage
            vertex.userData = ["type":"vertex","id": "\(i)"]
            vertex.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            vertex.map = map
            vertices.append(vertex)
            if i > 0 {
                let coord0 = path.coordinate(at: i-1)
                let coord1 = path.coordinate(at: i)
                let middle = GMSMarker(position: (coord0.middleLocationWith(location: coord1)))
                middle.isDraggable = true
                let markerImage = UIImage(named: "middle")!.withRenderingMode(.alwaysTemplate)
                middle.icon = markerImage
                middle.userData =  ["type":"middle","id": "\(i)"]
                middle.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                middle.map = map
                middlePoint.append(middle)
            }
            if i == (path.count())-1 {
                let coord0 = path.coordinate(at: i)
                let coord1 = path.coordinate(at: 0)
                let middle = GMSMarker(position: (coord0.middleLocationWith(location: coord1)))
                middle.isDraggable = true
                let markerImage = UIImage(named: "middle")!.withRenderingMode(.alwaysTemplate)
                middle.icon = markerImage
                middle.userData = ["type":"middle","id": "\(i)"]
                middle.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                middle.map = map
                middlePoint.append(middle)
            }
        }
        setActiveVertex(activeIndex)
        areaLabel.isHidden = false
        updateLabel()
    }
    
    private func removeVertices() {
        for vertex in vertices {
            vertex.map = nil
        }
        for middle in middlePoint {
            middle.map = nil
        }
        vertices.removeAll()
        middlePoint.removeAll()
        deActiveVertex()
        areaLabel.isHidden = true
    }
    
    private func setEditing(_ editing: Bool) {
        if editing {
            addVertices()
        } else {
            removeVertices()
        }
    }
    
    // Thay đổi icon, cho phéo drag để chỉnh sửa đỉnh
    func setActiveVertex(_ index: UInt) {
        _activeIndex = index
        let poi = map?.projection.point(for: path.coordinate(at: index))
        if _activeVertexView == nil {
            _activeVertexView = VertexView(origin: poi!)
            map?.addSubview(_activeVertexView!)
        } else {
            _activeVertexView?.origin = poi!
            _activeVertexView?.isHidden = false
        }
        _activeVertexView?.delegate = self
    }
    
    // Bỏ chế độ chỉnh sửa đỉnh
    func deActiveVertex() {
        if _activeVertexView != nil {
            _activeVertexView?.isHidden = true
        }
    }
    
    // Sửa đỉnh
    func updateVertex(_ index: UInt, _ position: CLLocationCoordinate2D) {
        _path?.replaceCoordinate(at: index, with: position)
        _polygon?.path = _path
        let pt: AEXMLElement = (_root?["pt"].all![Int(index)])!
        pt.attributes["lat"] = position.latitude.toString(6)
        pt.attributes["lon"] = position.longitude.toString(6)
        removeVertices()
        addVertices()
    }
    
    // Thêm đỉnh
    func insertVertex(_ index: UInt, _ position: CLLocationCoordinate2D) {
        insertPoint(index, GPXPoint(position.latitude, position.longitude, 0, Date().iso8601))
        removeVertices()
        addVertices()
    }
    
    // Xóa đỉnh
    func deleteVertex(_ index: UInt) {
        if path.count() > 0 {
            deletePoint(at: index)
        }
    }
    
    func deleteActiveVertex() {
        deleteVertex(activeIndex)
    }

    private var _elevations: [CLLocationDistance]
    var elevations: [CLLocationDistance] {
        get { return _elevations }
    }
    
    private var _root: AEXMLElement?
    var root: AEXMLElement {
        get { return _root! }
    }
    
    private var _path: GMSMutablePath?
    var path: GMSMutablePath {
        get { return _path! }
    }
    
    func delete() {
        map = nil
        root.removeFromParent()
    }

    private var _polygon: GPXPointSegmentOverlay?
    var overlay: GPXPointSegmentOverlay {
        get {
            return _polygon!
        }
    }
    
    
    // Tạo đối tượng để thêm mới bình thường
    init(_ map: GMSMapView) {
        //_coords = [CLLocationCoordinate2D]()
        _elevations = [CLLocationDistance]()
        _path = GMSMutablePath()
        _root = AEXMLElement(name: "ptseg")
        //_desc = AEXMLElement(name: "desc", value: "")
        //_root?.addChild(_desc)
        super.init()
        self.map = map
        title = Date().iso8601
        isTappable = true
        
        _polygon = GPXPointSegmentOverlay(path: _path)
        _polygon?.strokeWidth = 3
        _polygon?.isTappable = true
        _polygon?.pointSegment = self
    }
    
    // Parse từ file
    init(xmlElement: AEXMLElement, map: GMSMapView) {
        //_coords = [CLLocationCoordinate2D]()
        _elevations = [CLLocationDistance]()
        _path = GMSMutablePath()
        _root = xmlElement
//        _desc = xmlElement["desc"]
//        if _desc.error != nil  {
//            _desc = AEXMLElement(name: "desc", value: "")
//            _root?.addChild(_desc)
//        }
        super.init()
        
        self.map = map
        
        // TODO: Parse
        if let ptElements = _root?["pt"].all,
            (ptElements.count) > 2 {
            for ptElement in ptElements {
                let pt = GPXPoint(xmlElement: ptElement)
                //_coords.append(pt.coord)
                _elevations.append(pt.ele)
                _path?.add(pt.coord)
            }
            _polygon = GPXPointSegmentOverlay(path: _path)
            _polygon?.strokeWidth = 3
            _polygon?.map = map
            _polygon?.isTappable = true
            _polygon?.pointSegment = self
            
            actions = .none
        }
    }
    
    func addPoint(_ pt: GPXPoint) {
        _actions = .editing
        _polygon?.map = nil
        _polygon = nil
        
        //_coords.append(pt.coord)
        _elevations.append(pt.ele)
        _path?.add(pt.coord)
        root.addChild(pt.element)
        
        _polygon = GPXPointSegmentOverlay(path: _path)
        _polygon?.strokeWidth = 3
        _polygon?.map = map
        _polygon?.isTappable = true
        _polygon?.pointSegment = self
        if _actions == .editing {
            removeVertices()
            addVertices()
        }
    }
    
    private func insertPoint(_ index: UInt, _ pt: GPXPoint) {
        if index == (_path?.count())!-1 {
            addPoint(pt)
            return
        }
        _actions = .editing
        _polygon?.map = nil
        _polygon = nil
        
        //_coords.insert(pt.coord, at: Int(index))
        _elevations.insert(pt.ele, at: Int(index))
        _path?.insert(pt.coord, at: index)
        _root?.insertChild(pt.element, at: Int(index))
        
        _polygon = GPXPointSegmentOverlay(path: _path)
        _polygon?.strokeWidth = 3
        _polygon?.map = map
        _polygon?.isTappable = true
        _polygon?.pointSegment = self
    }
    
    private func deletePoint(at: UInt) {
        _polygon?.map = nil
        _polygon = nil
        
        _elevations.remove(at: Int(at))
        _path?.removeCoordinate(at: at)
        _root?.children.remove(at: Int(at))
        
        _polygon = GPXPointSegmentOverlay(path: _path)
        _polygon?.strokeWidth = 3
        _polygon?.map = map
        _polygon?.isTappable = true
        _polygon?.pointSegment = self
        if _actions == .editing {
            removeVertices()
            addVertices()
        }
    }
}

class GPX: NSObject {
    enum GPXTrackingStatus {
        case notStarted
        case tracking
        case paused
    }
    
    enum GPXTrackingActions {
        case none
        case done
        case reset
    }
    
    private var _bounds: GMSCoordinateBounds
    var bounds: GMSCoordinateBounds {
        get { return _bounds }
        set(bounds) {
            _bounds = bounds
        }
    }
    
    private var _status: GPXTrackingStatus = .notStarted
    var status: GPXTrackingStatus {
        get { return _status }
        set (status) {
            _status = status
        }
    }
    
    private var _actions: GPXTrackingActions = .none
    var actions: GPXTrackingActions {
        get { return _actions }
        set (actions) {
            _actions = actions
            switch actions {
            case .none:
                break
            case .done:
                save()
                newTrackSegment()
                break
            case .reset:
                _currentTrackSegment?.actions = .reset
                newTrackSegment()
                break
            }
        }
    }
    
    func save() {
        if wayPoints.count > 0 ||
            (trackSegments.count) > 0 ||
            (pointSegments.count) > 0 {
            _save()
        }
    }
    
    private func _save() {
        var fileName = createDocumentFileFor(subPath: "", fileName: metadata.name, ext: String())
        if fileName.pathExtension != "gpx" {
            fileName = fileName.appendingPathExtension("gpx")
        }
        print(fileName.path)
        try! xml.write(toFile: fileName.path, atomically: true, encoding: .utf8)
    }
    
    func clear() {
        for wayPoint in wayPoints {
            wayPoint.map = nil
        }
        wayPoints.removeAll()
        for trackSegment in trackSegments {
            trackSegment.actions = .clear
        }
        trackSegments.removeAll()
        for pointSegment in pointSegments {
            pointSegment.actions = .clear
        }
        pointSegments.removeAll()
    }
    
    private var _gpxDoc: AEXMLDocument?
    
    private var _root: AEXMLElement
    var root: AEXMLElement? {
        get { return _root }
    }
    
    private var _metadata: GPXMetadata
    var metadata: GPXMetadata {
        get { return _metadata }
        set(metadata) { _metadata = metadata }
    }
    
    private var _map: GMSMapView?
    private var _wayPoints: [GPXWaypoint] = []
    var wayPoints: [GPXWaypoint] {
        get { return _wayPoints }
        set (wayPoints) {
            _wayPoints = wayPoints
        }
    }
    private var _tracks: [AEXMLElement] = []
    private var _currentTrack: AEXMLElement?
    var currentTrack: AEXMLElement? {
        get {
            if _currentTrack == nil {
                newTrack()
            }
            return _currentTrack
        }
    }
    private var _trackSegments: [GPXTrackSegment] = []
    var trackSegments: [GPXTrackSegment] {
        get { return _trackSegments }
        set(trackSegments) { return _trackSegments = trackSegments }
    }
    private var _currentTrackSegment: GPXTrackSegment?
    var currentTrackSegment: GPXTrackSegment? {
        get {
            if _currentTrackSegment == nil {
                newTrackSegment()
            }
            return _currentTrackSegment
        }
    }

    // PointSegments
    private var _pointSegments: [GPXPointSegment] = []
    var pointSegments: [GPXPointSegment] {
        get { return _pointSegments }
        set(pointSegments) { return _pointSegments = pointSegments }
    }
    private var _currentPointSegment: GPXPointSegment?
    var currentPointSegment: GPXPointSegment? {
        get {
            if _currentPointSegment == nil {
                newPointSegment()
            }
            return _currentPointSegment
        }
    }

    var xml: String {
        get { return (_gpxDoc?.xml)! }
    }
    
    var xmlCompact: String {
        get { return (_gpxDoc?.xmlCompact)! }
    }
    
    init(_ map: GMSMapView) {
        _gpxDoc = AEXMLDocument()
        _root = (_gpxDoc?.addChild(name: "gpx", attributes: ["version":"1.1","creator":"\(APP_FULL_NAME)"]))!
        _metadata = GPXMetadata()
        _root.addChild(_metadata.root)
        _map = map
        _bounds = GMSCoordinateBounds()
        super.init()
    }
    
    init(_ map: GMSMapView, _ root: AEXMLElement) {
        _gpxDoc = AEXMLDocument()
        _gpxDoc?.addChild(root)
        _root = root
        _map = map
        _metadata = GPXMetadata()
        _bounds = GMSCoordinateBounds()
        super.init()
        let metadataElement = root["metadata"]
        
        if metadataElement.error == nil {
            _metadata = GPXMetadata(metadataElement)
        } else {
            _metadata = GPXMetadata()
            _root.addChild(_metadata.root)
            _save()
        }
        
        // TODO: Parse
        
        // Parse các điểm mốc wpt
        if let wpts = _root["wpt"].all {
            for wpt in wpts {
                let w = GPXWaypoint(xmlElement: wpt)
                w.map = _map
                _wayPoints.append(w)
                updateToBound(location: w.position)
            }
        }
        
        // Parse các polyine
        if let trks = _root["trk"].all {
            _tracks = trks
            for track in _tracks {
                //let name = track["name"]
                let trackSegElements = track["trkseg"].all
                if trackSegElements != nil {
                    for trksegElement in trackSegElements! {
                        let trkseg = GPXTrackSegment(xmlElement: trksegElement, map: _map!)
                        _trackSegments.append(trkseg)
                        updateToBound(path: trkseg.path)
                    }
                }
            }
        }
        
        // Parse các polygon
        let pointSegElements = _root["ptseg"].all
        if pointSegElements != nil {
            for pointElement in pointSegElements! {
                let pointSeg = GPXPointSegment(xmlElement: pointElement, map: _map!)
                _pointSegments.append(pointSeg)
                updateToBound(path: pointSeg.path)
            }
        }

        zoomToBounds()
    }
    
    // Thêm Track
    private func newTrack() {
        _currentTrack = AEXMLElement(name: "trk")
        _currentTrack?.addChild(name: "name", value: "\(APP_NAME) Track")
        _tracks.append(_currentTrack!)
        root?.addChild(_currentTrack!)
    }
    
    // Thêm polyline
    func newTrackSegment() {
        _currentTrackSegment = GPXTrackSegment(currentTrack!, _map!)
        _trackSegments.append(_currentTrackSegment!)
    }
    
    // Thêm polygon
    func newPointSegment() {
        _currentPointSegment = GPXPointSegment(_map!)
        _root.addChild((_currentPointSegment?.root)!)
        _pointSegments.append(_currentPointSegment!)
    }
    
    // Thêm mốc
    func addWaypoint(_ wpt: GPXWaypoint) {
        wayPoints.append(wpt)
        root?.addChild(wpt.root)
        // Tạo và quản lý marker
        wpt.map = _map
        _bounds.includingCoordinate(wpt.position)
        save()
    }
    
    // Thêm điểm vào polyline hiện tại
    func addTrackPoint(_ trkpt: GPXTrackPoint, _ actions: GPXTrackSegment.GPXTrackSegmentActions) {
        currentTrackSegment?.addTrackPoint(trkpt, actions)
    }
    
    // Thêm điểm vào polygon hiện tại
    func addPoint(_ pt: GPXPoint) {
        currentPointSegment?.addPoint(pt)
    }
    
    func updateToBound(location: CLLocationCoordinate2D) {
        if _bounds.isValid {
            _bounds.includingCoordinate(location)
        } else {
            _bounds = GMSCoordinateBounds(coordinate: location, coordinate: location)
        }
    }
    
    func updateToBound(path: GMSPath) {
        if _bounds.isValid {
            _bounds.includingPath(path)
        } else {
            _bounds = GMSCoordinateBounds(path: path)
        }
    }
    
    func zoomToBounds() {
        if bounds.isValid {
            _map?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 15.0))
        }
    }
}
