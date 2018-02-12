//
//  GeoJSONKit.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 1/27/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

import Foundation

enum VisibleMode: Int {
    case normal
    case selecting
    case editing
}

protocol CGeoJSONDelegate: class {
    // Sự kiện đối tượng ở trạng thái thông thường
    func visibleModeNormal(featue: CFeature)
    // Sự kiện ở trạng thái lựa chọn
    func visibleModeSelecting(featue: CFeature)
    // Sự kiện ở trạng thái sửa
    func visibleModeEditing(featue: CFeature)
}

enum CGeoJSONMember: String {
    case type = "type"
    case id = "id"
    case geometry = "geometry"
    case geometries = "geometries"
    case properties = "properties"
    case boundingBox = "bbox"
    case coordinates = "coordinates"
    case features = "features"
    case crs = "crs"
}

enum CGeoJSONTypeValue: String {
    case feature = "Feature"
    case featureCollection = "FeatureCollection"
}

enum CGeoJSONGeometryTypeValue: String {
    case point = "Point"
    case multiPoint = "MultiPoint"
    case lineString = "LineString"
    case multiLineString = "MultiLineString"
    case polygon = "Polygon"
    case multiPolygon = "MultiPolygon"
    case geometryCollection = "GeometryCollection"
}

enum CPropMember: String {
    case stroke = "stroke"
    case strokeWidth = "stroke-width"
    case strokeOpacity = "stroke-opacity"
    case fill = "fill"
    case fillOpacity = "fill-opacity"
    case markerColor = "marker-color"
    case markerSize = "marker-size"
    case markerSymbol = "marker-symbol"
    case name = "name"
    case title = "title"
    case desc = "desc"
}

protocol CGeoJSON: class {
    var type: CGeoJSONTypeValue { get }
    init(dict: Dictionary<String, Any>)
    var dict: Dictionary<String, Any> { get }
}

protocol CGeoJSONObject: class {
    func style(properties: [String: Any]?)
    func renderer(map: GMSMapView!)
}

protocol CGeoJSONGeometry: CGeoJSONObject {
    var type: CGeoJSONGeometryTypeValue { get }
    var dict: Dictionary<String, Any> { get }
    var boundingBox: GMSCoordinateBounds { get }
    var feature: CFeature? { get set }
}

protocol CGeoJSONContainer: class {
    var type: CGeoJSONTypeValue { get }
    var geometry: CGeoJSONGeometry! { get }
    var properties: [String: Any]? { get set }
    var dict: Dictionary<String, Any> { get }
    func style(properties: [String: Any]?)
}

/*
 * Point coordinates are in x, y order (longitude, latitude for geographic coordinates).
 */
class CPoint: GMSMarker, CGeoJSONGeometry, PointViewDelegate {
    //////////////////////////////////////////////////////
    // Bắt đầu các sự kiện PointViewDelegate từ PointView
    //////////////////////////////////////////////////////
    
    // Chạm vào point (chạm xuống)
    func pointTouchBegan(touch: UITouch) {
        pointMoved = false
        guard let point: PointView = touch.view as? PointView else { return }

        if point.pointMode == .normal {
            // Đặt lại mặc định cho point trước đó
            if (selectedPoint != nil) {
                selectedPoint.pointMode = .normal
                selectedPoint = nil
            }
        }
        
        // Trường hợp đã chọn đỉnh từ trước
        if point == selectedPoint {
            // Kính lúp: Nếu chưa có thì tạo và hiển thị
            if magnifyView == nil {
                magnifyView = MagnifyView.init(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
                magnifyView.viewToMagnify = map // nền bản đồ
                magnifyView.setTouchPoint(pt: point.center)
                map?.addSubview(magnifyView)
            }
        }
    }
    
    // Đã chạm vào point đồng thời kéo (pan)
    func pointTouchMoved(touch: UITouch) {
        guard let point: PointView = touch.view as? PointView else { return }
        pointMoved = true
        
        // Nếu đã select thì mới cho move
        if point == selectedPoint {
            // Chuyển trạng thái cho point đã chọn
            if selectedPoint.pointMode != .moving {
                selectedPoint.pointMode = .moving
            }
            // Tính lại đỉnh cho path
            // position = (map?.projection.coordinate(for: point.center))!
            
            // Kính lúp: Di chuyển kính lúp
            magnifyView.setTouchPoint(pt: point.center)
            magnifyView.setNeedsDisplay()
        }
    }
    
    // Chạm vào point (thôi chạm, nhấc lên)
    func pointTouchEnded(touch: UITouch) {
        guard let point: PointView = touch.view as? PointView else { return }
        
        if point == selectedPoint {
            if (!pointMoved) {
                // Chạm 2 lần thì bỏ chọn
                selectedPoint.pointMode = .normal
                // Xóa đỉnh
                selectedPoint.removeFromSuperview()
                selectedPoint = nil
            } else { // Đã di chuyển điểm được chọn
                // Trả lại trạng thái editing sau khi di chuyển
                selectedPoint.pointMode = .editing
                // Tính lại đỉnh cho point
                 position = (map?.projection.coordinate(for: point.center))!
            }
        } else if selectedPoint == nil && !pointMoved { // Đã chọn vào một đỉnh bình thường
            // Đặt điểm chọn là điểm vừa chạm
            selectedPoint = point
            selectedPoint.pointMode = .editing
        }
        
        // Kính lúp: nếu đã có thì gỡ đi
        if magnifyView != nil {
            magnifyView.removeFromSuperview()
            magnifyView = nil
        }
        
        // Trả lại trạng thái pointMoved trước đó
        pointMoved = false
    }
    
    public var _icon: UIImage = #imageLiteral(resourceName: "pin")
    
    private var selecting_icon: UIImage = #imageLiteral(resourceName: "pin-large")
    private var editing_icon: UIImage = #imageLiteral(resourceName: "pinSquares")
    
    // Đỉnh được chọn
    var selectedPoint: PointView!
    
    // Kiểm tra point đã move trước đó hay chưa
    private var pointMoved: Bool = false
    
    // Kính lúp
    private var magnifyView: MagnifyView!
    
    weak var delegate: CGeoJSONDelegate?
    
    // Mode của polyline dùng để render: normal, selecting, editing
    var visibleMode: VisibleMode = VisibleMode.normal {
        didSet(prevValue){
            if prevValue != visibleMode {
                switch visibleMode {
                case .normal:
                    // Vẽ thông thường
                    icon = _icon
                    if selectedPoint != nil {
                        selectedPoint.pointMode = .normal
                        selectedPoint.removeFromSuperview()
                    }
                    delegate?.visibleModeNormal(featue: feature!)
                case .selecting:
                    if prevValue == .normal {
                        _icon = icon!
                    }
                    // Vẽ kiểu selecting
                    icon = selecting_icon
                    
                    if selectedPoint != nil {
                        selectedPoint.pointMode = .normal
                        selectedPoint.removeFromSuperview()
                    }
                    delegate?.visibleModeSelecting(featue: feature!)
                case .editing:
                    if prevValue == .normal {
                        _icon = self.icon!
                    }
                    // Vẽ kiểu editing
                    self.icon = editing_icon
                    
                    if selectedPoint == nil {
                        selectedPoint = PointView(frame: CGRect.zero)
                        selectedPoint.center = (map?.projection.point(for: position))!
                        selectedPoint.delegate = self
                    }
                    selectedPoint.pointMode = .editing
                    map?.addSubview(selectedPoint)
                    delegate?.visibleModeEditing(featue: feature!)
                }
            }
        }
    }
    
    override var map: GMSMapView? {
        didSet(prevValue) {
            
        }
    }
    
    override init() {
        super.init()
        zIndex = 5
        if self.icon == nil {
            self.icon = #imageLiteral(resourceName: "pin")
        }
    }
    
    // Thêm điểm
    public func addPointFor(_ p: CGPoint) {
        guard selectedPoint == nil else {
            selectedPoint.pointMode = .normal
            selectedPoint.removeFromSuperview()
            selectedPoint = nil
            return
        }
        
        let point = PointView(frame: CGRect.zero)
        point.delegate = self
        point.center = p
        point.pointMode = .normal
        selectedPoint = point
        position = (map?.projection.coordinate(for: point.center))!
        map?.addSubview(selectedPoint)
    }
    
    public func visibleVertices(_ show: Bool) {
        if selectedPoint != nil {
            selectedPoint.isHidden = !show
        }
    }
    
    public func updateVertex() {
        let p = (map?.projection.point(for: position))!
        if selectedPoint != nil {
            selectedPoint.center = p
        }
    }
    
    //////////////////////////////////////////////////////
    // Kết thúc các sự kiện PointViewDelegate từ PointView
    //////////////////////////////////////////////////////
    
    var feature: CFeature?
    
    func style(properties: [String : Any]?) {
        guard properties != nil else {
            return
        }
        if let name = (properties![CPropMember.name.rawValue]) {
            title = name as? String
        } else if let name = (properties![CPropMember.title.rawValue]) {
            title = name as? String
        }
        if let desc = (properties![CPropMember.desc.rawValue]) {
            snippet = desc as? String
        }
        if let iconName = (properties![CPropMember.markerSymbol.rawValue]) {
            icon = UIImage(named: iconName as! String)
        }
        if self.icon == nil {
            self.icon = #imageLiteral(resourceName: "pin-large")
        }
        isTappable = true
    }
    
    func renderer(map: GMSMapView!) {
        self.map = map
    }
    
    var type: CGeoJSONGeometryTypeValue = .point
    
    var altitude: CGFloat = 0.0
    
    init(dict: Dictionary<String, Any>) {
        super.init()
        let array: NSArray = dict[CGeoJSONMember.coordinates.rawValue] as! NSArray
        self.position = array.toCLLocationCoordinate2D()
        self.altitude = array.toAltitude()
    }
    
    var boundingBox: GMSCoordinateBounds {
        get {
            return GMSCoordinateBounds(coordinate: position, coordinate: position)
        }
    }
    
    var dict: Dictionary<String, Any> {
        get {
            return Dictionary(dictionaryLiteral: (CGeoJSONMember.type.rawValue, type.rawValue),
                              (CGeoJSONMember.coordinates.rawValue, position.toNSArray(altitude: altitude)))
        }
    }
}

/*
 * Coordinates of LineString are an array of Point coordinates.
 */
class CLineString: GMSPolyline, CGeoJSONGeometry, PointViewDelegate {
    //////////////////////////////////////////////////////
    // Bắt đầu các sự kiện PointViewDelegate từ PointView
    //////////////////////////////////////////////////////
    
    // Chạm vào point (chạm xuống)
    func pointTouchBegan(touch: UITouch) {
        pointMoved = false
        guard let point: PointView = touch.view as? PointView else { return }
        guard point.pointMode != .midpoint else {
            return
        }
        
        if point.pointMode == .normal {
            // Đặt lại mặc định cho point trước đó
            if (selectedPoint != nil) {
                selectedPoint.pointMode = .normal
                selectedPoint = nil
            }
        }
        
        // Trường hợp đã chọn đỉnh từ trước
        if point == selectedPoint {
            // Ẩn điểm giữa
            visibleMidPoints(false)
            
            // Kính lúp: Nếu chưa có thì tạo và hiển thị
            if magnifyView == nil {
                magnifyView = MagnifyView.init(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
                magnifyView.viewToMagnify = map // nền bản đồ
                magnifyView.setTouchPoint(pt: point.center)
                map?.addSubview(magnifyView)
            }
        }
    }
    
    // Đã chạm vào point đồng thời kéo (pan)
    func pointTouchMoved(touch: UITouch) {
        guard let point: PointView = touch.view as? PointView else { return }
        pointMoved = true
        guard point.pointMode != .midpoint else {
            return
        }
        
        // Nếu đã select thì mới cho move
        if point == selectedPoint {
            // Chuyển trạng thái cho point đã chọn
            if selectedPoint.pointMode != .moving {
                selectedPoint.pointMode = .moving
            }
            
            // Tính lại đỉnh cho path
            updatePathFor(point)
            
            // Kính lúp: Di chuyển kính lúp
            magnifyView.setTouchPoint(pt: point.center)
            magnifyView.setNeedsDisplay()
        }
    }
    
    // Chạm vào point (thôi chạm, nhấc lên)
    func pointTouchEnded(touch: UITouch) {
        guard let point: PointView = touch.view as? PointView else { return }
        // Nếu là midPoint
        if point.pointMode == .midpoint {
            guard !pointMoved else {
                // Hiện trở lại điểm giữa
                visibleMidPoints(true)
                return
            }
            // Chèn đỉnh
            insertPointFor(point)
            path = pathFromPoints()
        } else if point == selectedPoint {
            if (!pointMoved) {
                // Chạm 2 lần thì bỏ chọn
                selectedPoint.pointMode = .normal
                selectedPoint = nil
                // Xóa đỉnh
                removePointFor(point)
            } else { // Đã di chuyển điểm được chọn
                // Trả lại trạng thái editing sau khi di chuyển
                selectedPoint.pointMode = .editing
            }
            // Nếu đã thay đổi đỉnh thì tính lại điểm giữa
            updateMidPointsFromPath()
            
            // Hiện trở lại điểm giữa
            visibleMidPoints(true)
        } else if selectedPoint == nil && !pointMoved { // Đã chọn vào một đỉnh bình thường
            // Đặt điểm chọn là điểm vừa chạm
            selectedPoint = point
            selectedPoint.pointMode = .editing
        }
        
        // Kính lúp: nếu đã có thì gỡ đi
        if magnifyView != nil {
            magnifyView.removeFromSuperview()
            magnifyView = nil
        }
        
        // Trả lại trạng thái pointMoved trước đó
        pointMoved = false
    }
    
    
    
    // Màu của polyline: dùng để lưu lại màu gốc
    public var _strokeColor: UIColor = UIColor.blue
    
    // Lực nét của polyline: đường chính giữa ở mode normal
    public var _strokeWidth: CGFloat = 1.0
    
    private var selecting_color = UIColor.white
    private var selecting_width: CGFloat = 1.0
    private var editing_color = UIColor(red: 99/255, green: 131/255, blue: 178/255, alpha: 1.0)
    private var editing_width: CGFloat = 1.0
    
    // Đỉnh được chọn
    var selectedPoint: PointView!
    
    // Mảng các đỉnh
    private var points    : [PointView] = []
    
    // Mảng các điểm giữa
    private var midPoints : [PointView] = []
    
    // Kiểm tra point đã move trước đó hay chưa
    private var pointMoved: Bool = false
    
    // Kiểm tra polylineView đã move trước đó hay chưa
    private var polylineViewMoved: Bool = false
    
    // Kính lúp
    private var magnifyView: MagnifyView!
    
    // Border outline
    private var border: GMSPolyline = GMSPolyline()
    
    weak var delegate: CGeoJSONDelegate?
    
    // Mode của polyline dùng để render: normal, selecting, editing
    var visibleMode: VisibleMode = VisibleMode.normal {
        didSet(prevValue){
            if prevValue != visibleMode {
                switch visibleMode {
                case .normal:
                    // Vẽ thông thường
                    strokeColor = _strokeColor
                    strokeWidth = _strokeWidth
                    removePointsFromMap()
                    
                    border.map = nil
                    
                    delegate?.visibleModeNormal(featue: feature!)
                case .selecting:
                    if prevValue == .normal {
                        _strokeColor = self.strokeColor
                        _strokeWidth = self.strokeWidth
                    }
                    // Vẽ kiểu selecting
                    self.strokeColor = selecting_color
                    self.strokeWidth = selecting_width
                    removePointsFromMap()
                    
                    // Vẽ border outline
                    self.border.strokeColor = UIColor.orange
                    self.border.strokeWidth = 3
                    self.border.zIndex = self.zIndex - 1
                    self.border.map = map
                    delegate?.visibleModeSelecting(featue: feature!)
                case .editing:
                    if prevValue == .normal {
                        _strokeColor = self.strokeColor
                        _strokeWidth = self.strokeWidth
                    }
                    // Vẽ border outline
                    self.border.strokeColor = UIColor.white
                    self.border.strokeWidth = 3
                    self.border.zIndex = self.zIndex - 1
                    self.border.map = map

                    // Vẽ kiểu editing
                    self.strokeColor = editing_color
                    self.strokeWidth = editing_width
                    addPointsToMap()
                    delegate?.visibleModeEditing(featue: feature!)
                }
            }
        }
    }
    
    override var map: GMSMapView? {
        didSet(prevValue) {
            if path == nil {
                // Tạo 2 điểm mặc định
                let p1: CGPoint = (map?.center.applying(CGAffineTransform(translationX: -(map?.frame.width)!/8.0, y: (map?.frame.height)!/8.0)))!
                addPointFor(p1)
                let p2: CGPoint = (map?.center.applying(CGAffineTransform(translationX: (map?.frame.width)!/8.0, y: -(map?.frame.height)!/8.0)))!
                addPointFor(p2)
            }
            
            // Trường hợp xóa LineString thì xóa luôn border
            if border.path != nil && map == nil {
                border.map = nil
            }
        }
    }
    
    override var path: GMSPath? {
        didSet(prevValue) {
            if prevValue != path {
                border.path = path
            }
        }
    }
    
    override init() {
        super.init()
        zIndex = 5
        border.zIndex = zIndex - 1
        _strokeColor = self.strokeColor
        _strokeWidth = strokeWidth
    }
    
    // Chuyển GMSPolyline qua
    init(gmsPolyline: GMSPolyline) {
        super.init()
        zIndex = 5
        path = gmsPolyline.path
        _strokeColor = gmsPolyline.strokeColor
        _strokeWidth = gmsPolyline.strokeWidth
        spans = gmsPolyline.spans
        
        gmsPolyline.map = nil
    }
    
    // Có vẻ hàm này không cần thiết
    public func gmsPolyline() -> GMSPolyline {
        let pl = GMSPolyline(path: path)
        pl.map = map
        pl.strokeColor = strokeColor
        pl.strokeWidth = strokeWidth
        pl.spans = spans
        
        removePointsFromMap()
        map = nil
        return pl
    }
    
    // Chèn đỉnh tại midPoint
    private func insertPointFor(_ midPoint: PointView) {
        // Xác định id của midPoint
        let i: Int = midPoints.index(of: midPoint)!
        if points.count > 0 {
            // Chèn đỉnh mới
            let newPoint = PointView(frame: CGRect.zero)
            newPoint.center = midPoint.center
            newPoint.delegate = self
            
            // Tính lại tọa độ cho midPoint
            midPoint.center = calculateMidPoint(midPoint.center, points[i].center)
            
            // Chèn midPoint mới
            let mp: CGPoint = calculateMidPoint(newPoint.center, points[i+1].center)
            let newMidPoint = PointView(frame: CGRect.zero)
            newMidPoint.center = mp
            newMidPoint.pointMode = .midpoint
            newMidPoint.delegate = self
            
            points.insert(newPoint, at: i+1)
            midPoints.insert(newMidPoint, at: i+1)
            
            // Thêm và đỉnh mới vào map
            map?.addSubview(newMidPoint)
            map?.addSubview(newPoint)
        }
        
        path = pathFromPoints()
    }
    
    // Xóa một đỉnh
    private func removePointFor(_ point: PointView) {
        guard (points.count > 2 && point.pointMode != .midpoint) else {
            return
        }
        let newPath: GMSMutablePath = GMSMutablePath(path: path!)
        let i = points.index(of: point)!
        newPath.removeCoordinate(at: UInt(i))
        path = newPath
        
        if i == 0 {
            // Nếu là đỉnh đầu
            points.removeFirst().removeFromSuperview()
            midPoints.removeFirst().removeFromSuperview()
            //midPoints.first?.center = calculateMidPoint(points[i-1].center, points[i+1].center)
        } else if i == points.count - 1 {
            // Nếu là đỉnh cuối
            points.removeLast().removeFromSuperview()
            midPoints.removeLast().removeFromSuperview()
            midPoints.last?.center = (points.last?.center)!
        } else {
            // Nếu là các đỉnh giữa
            midPoints[i-1].center = calculateMidPoint(points[i-1].center, points[i+1].center)
            points.remove(at: i).removeFromSuperview()
            midPoints.remove(at: i).removeFromSuperview()
        }
    }
    
    public func removeSeletedPoint() {
        removePointFor(selectedPoint)
    }
    
    // Thêm điểm
    public func addPointFor(_ p: CGPoint) {
        guard selectedPoint == nil else {
            selectedPoint.pointMode = .normal
            selectedPoint = nil
            return
        }
        
        if points.count == 0 {
            let point = PointView(frame: CGRect.zero)
            point.delegate = self
            point.center = p
            point.pointMode = .normal
            
            let midPoint = PointView(frame: CGRect.zero)
            midPoint.delegate = self
            midPoint.center = point.center
            midPoint.pointMode = .midpoint
            
            points.append(point)
            midPoints.append(midPoint)
            
            // Thêm và đỉnh mới vào map
            map?.addSubview(midPoint)
            map?.addSubview(point)
            //
        } else {
            // Thêm đỉnh mới
            let point = PointView(frame: CGRect.zero)
            point.delegate = self
            point.center = p
            point.pointMode = .normal
            
            // Cập nhật lại điểm giữa trước đó
            midPoints.last?.center = calculateMidPoint((points.last?.center)!, p)
            
            // Thêm điểm giữa mới
            let midPoint = PointView(frame: CGRect.zero)
            midPoint.delegate = self
            midPoint.center = point.center
            midPoint.pointMode = .midpoint
            
            points.append(point)
            midPoints.append(midPoint)
            
            // Thêm và đỉnh mới vào map
            map?.addSubview(midPoint)
            map?.addSubview(point)
        }
        path = pathFromPoints()
    }
    
    public func updateVertex() {
        updatePointsFromPath()
    }
    
    public func visibleVertices(_ show: Bool) {
        for i in 0..<points.count {
            points[i].isHidden = !show
            midPoints[i].isHidden = !show
        }
    }
    
    private func visibleMidPoints(_ show: Bool) {
        for i in 0..<midPoints.count {
            midPoints[i].isHidden = !show
        }
    }
    
    // Hiện tất cả point lên map
    private func addPointsToMap() {
        // Gỡ points và midPoints ra khỏi map trước
        removePointsFromMap()
        
        // Tạo các đỉnh từ path
        pointsFromPath(path!)
        
        // Chèn lên bản đồ
        for i in 0..<points.count {
            map?.addSubview(midPoints[i])
            map?.addSubview(points[i])
        }
    }
    
    // Gỡ tất cả point khỏi map và xóa khỏi list
    private func removePointsFromMap() {
        // Gỡ points và midPoints ra khỏi view
        while points.count > 0 {
            points.removeLast().removeFromSuperview()
            midPoints.removeLast().removeFromSuperview()
        }
    }
    
    private func pathFromPoints() -> GMSPath {
        let newPath: GMSMutablePath = GMSMutablePath()
        for i in 0..<points.count {
            newPath.add((map?.projection.coordinate(for: points[i].center))!)
        }
        return newPath
    }
    
    private func pointsFromPath(_ newPath: GMSPath) {
        guard map != nil else {
            return
        }
        
        guard newPath.count() > 0 else {
            return
        }
        
        // Cập nhật points và midPoints từ path
        for i in 0..<newPath.count() {
            let p: CGPoint = (map?.projection.point(for: newPath.coordinate(at: i)))!
            // Thêm đỉnh và tự động thêm midPoint
            addPointFor(p)
        }
    }
    
    // Cập nhật lại path khi có thay đổi đỉnh
    private func updatePathFor(_ point: PointView) {
        let newPath: GMSMutablePath = GMSMutablePath(path: path!)
        let i: UInt = UInt(points.index(of: point)!)
        newPath.replaceCoordinate(at: i, with: (map?.projection.coordinate(for: point.center))!)
        path = newPath
    }
    
    // Cập nhật lại toàn bộ đỉnh và điểm giữa (sau khi map thay đổi)
    private func updatePointsFromPath() {
        guard let newPath: GMSPath = path else { return }
        guard points.count == newPath.count() else {
            return
        }
        
        // Cập nhật points từ path
        for i in 0..<newPath.count() {
            let p = (map?.projection.point(for: newPath.coordinate(at: i)))!
            points[Int(i)].center = p
        }
        
        // Cập nhật midPoints
        for i in 0..<newPath.count()-1 {
            let mp = calculateMidPoint(points[Int(i)].center, points[Int(i)+1].center)
            midPoints[Int(i)].center = mp
        }
        midPoints.last?.center = (points.last?.center)!
    }
    
    // Chỉ cập nhật lại mỗi điểm giữa sau khi đỉnh đã moved
    private func updateMidPointsFromPath() {
        guard let newPath: GMSPath = path else { return }
        guard midPoints.count == newPath.count() else {
            return
        }
        
        // Cập nhật midPoints
        for i in 0..<newPath.count()-1 {
            let mp = calculateMidPoint(points[Int(i)].center, points[Int(i)+1].center)
            midPoints[Int(i)].center = mp
        }
        midPoints.last?.center = (points.last?.center)!
    }
    //////////////////////////////////////////////////////
    // Kết thúc các sự kiện PointViewDelegate từ PointView
    //////////////////////////////////////////////////////
    
    var feature: CFeature?
    
    func style(properties: [String : Any]?) {
        guard properties != nil else {
            return
        }
        var titleStr = String()
        if let name = (properties![CPropMember.name.rawValue]) {
            titleStr = name as! String
        } else if let name = (properties![CPropMember.title.rawValue]) {
            titleStr = name as! String
        }
        if let strokeStr = (properties![CPropMember.stroke.rawValue]) {
            strokeColor = UIColor(hex: strokeStr as! String)
            _strokeColor = strokeColor
        }
        if let sw = (properties![CPropMember.strokeWidth.rawValue]) {
            strokeWidth = CGFloat((sw as AnyObject).floatValue)
            _strokeWidth = strokeWidth
        }
        title = titleStr
        isTappable = true
    }
    
    func renderer(map: GMSMapView!) {
        self.map = map
    }
    
    var type: CGeoJSONGeometryTypeValue = .lineString
    
    var altitudes: [CGFloat] = [CGFloat]()
    
    var boundingBox: GMSCoordinateBounds {
        get {
            return GMSCoordinateBounds(path: path!)
        }
    }
    
    init(dict: Dictionary<String, Any>) {
        super.init()
        let array: NSArray = dict[CGeoJSONMember.coordinates.rawValue] as! NSArray
        path = array.toGMSPath(false)
        altitudes = array.toAltitudes(false)
//        let _path: GMSMutablePath = GMSMutablePath()
//
//        for array in arrays {
//            _path.add((array as! NSArray).toCLLocationCoordinate2D())
//        }
//        path = _path
    }
    
    var dict: Dictionary<String, Any> {
        get {
            return Dictionary(dictionaryLiteral: (CGeoJSONMember.type.rawValue, type.rawValue),
                              (CGeoJSONMember.coordinates.rawValue, (path?.toNSArray(altitudes: altitudes))!))
        }
    }
}

/*
 * Coordinates of a Polygon are an array of LinearRing coordinates (LineString coordinates where the first and last points are equivalent). The first element in the array represents the exterior ring. Any subsequent elements represent interior rings (or holes).
 */
class CPolygon: GMSPolygon, CGeoJSONGeometry, PointViewDelegate {
    //////////////////////////////////////////////////////
    // Bắt đầu các sự kiện PointViewDelegate từ PointView
    //////////////////////////////////////////////////////
    
    // Chạm vào point (chạm xuống)
    func pointTouchBegan(touch: UITouch) {
        pointMoved = false
        guard let point: PointView = touch.view as? PointView else { return }
        guard point.pointMode != .midpoint else {
            return
        }
        
        if point.pointMode == .normal {
            // Đặt lại mặc định cho point trước đó
            if (selectedPoint != nil) {
                selectedPoint.pointMode = .normal
                selectedPoint = nil
            }
        }
        
        // Trường hợp đã chọn đỉnh từ trước
        if point == selectedPoint {
            // Ẩn điểm giữa
            visibleMidPoints(false)
            
            // Kính lúp: Nếu chưa có thì tạo và hiển thị
            if magnifyView == nil {
                magnifyView = MagnifyView.init(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
                magnifyView.viewToMagnify = map // nền bản đồ
                magnifyView.setTouchPoint(pt: point.center)
                map?.addSubview(magnifyView)
            }
        }
    }
    
    // Đã chạm vào point đồng thời kéo (pan)
    func pointTouchMoved(touch: UITouch) {
        guard let point: PointView = touch.view as? PointView else { return }
        pointMoved = true
        guard point.pointMode != .midpoint else {
            return
        }
        
        // Nếu đã select thì mới cho move
        if point == selectedPoint {
            // Chuyển trạng thái cho point đã chọn
            if selectedPoint.pointMode != .moving {
                selectedPoint.pointMode = .moving
            }
            
            // Tính lại đỉnh cho path
            updatePathFor(point)
            
            // Kính lúp: Di chuyển kính lúp
            magnifyView.setTouchPoint(pt: point.center)
            magnifyView.setNeedsDisplay()
        }
    }
    
    // Chạm vào point (thôi chạm, nhấc lên)
    func pointTouchEnded(touch: UITouch) {
        guard let point: PointView = touch.view as? PointView else { return }
        // Nếu là midPoint
        if point.pointMode == .midpoint {
            guard !pointMoved else {
                // Hiện trở lại điểm giữa
                visibleMidPoints(true)
                return
            }
            // Chèn đỉnh
            insertPointFor(point)
            path = pathFromPoints()
        } else if point == selectedPoint {
            if (!pointMoved) {
                // Chạm 2 lần thì bỏ chọn
                selectedPoint.pointMode = .normal
                selectedPoint = nil
                // Xóa đỉnh
                removePointFor(point)
            } else { // Đã di chuyển điểm được chọn
                // Trả lại trạng thái editing sau khi di chuyển
                selectedPoint.pointMode = .editing
            }
            // Nếu đã thay đổi đỉnh thì tính lại điểm giữa
            updateMidPointsFromPath()
            
            // Hiện trở lại điểm giữa
            visibleMidPoints(true)
        } else if selectedPoint == nil && !pointMoved { // Đã chọn vào một đỉnh bình thường
            // Đặt điểm chọn là điểm vừa chạm
            selectedPoint = point
            selectedPoint.pointMode = .editing
        }
        
        // Kính lúp: nếu đã có thì gỡ đi
        if magnifyView != nil {
            magnifyView.removeFromSuperview()
            magnifyView = nil
        }
        
        // Trả lại trạng thái pointMoved trước đó
        pointMoved = false
    }
    
    // Màu của polygon: đường chính giữa ở mode normal
    public var _strokeColor: UIColor = UIColor.blue
    
    // Lực nét của polygon: đường chính giữa ở mode normal
    public var _strokeWidth: CGFloat = 1.0
    
    // Lực nét của polygon: đường chính giữa ở mode normal
    public var _strokeOpacity: CGFloat = 1.0 {
        didSet(prevValue) {
            if prevValue != _strokeOpacity {
                _strokeColor = _strokeColor.withAlphaComponent(_strokeOpacity)
            }
        }
    }
    
    // Màu của polygon: fillColor
    public var _fillColor: UIColor = UIColor.blue.withAlphaComponent(0.2)
    
    public var _fillOpacity: CGFloat = 0.5 {
        didSet(prevValue) {
            if prevValue != _fillOpacity {
                _fillColor = _fillColor.withAlphaComponent(_fillOpacity)
            }
        }
    }
    
    private var selecting_color = UIColor.white
    private var selecting_width: CGFloat = 1.0
    private var editing_color = UIColor(red: 99/255, green: 131/255, blue: 178/255, alpha: 1.0)
    private var editing_width: CGFloat = 1.0
    
    // Đỉnh được chọn
    var selectedPoint: PointView!
    
    // Mảng các đỉnh
    private var points    : [PointView] = []
    
    // Mảng các điểm giữa
    private var midPoints : [PointView] = []
    
    // Kiểm tra point đã move trước đó hay chưa
    private var pointMoved: Bool = false
    
    // Kiểm tra polygonView đã move trước đó hay chưa
    private var polygonViewMoved: Bool = false
    
    // Kính lúp
    private var magnifyView: MagnifyView!
    
    // Border outline
    private var border: GMSPolygon = GMSPolygon()
    
    weak var delegate: CGeoJSONDelegate?
    
    // Mode của polygon dùng để render: normal, selecting, editing
    var visibleMode: VisibleMode = VisibleMode.normal {
        didSet(prevValue){
            if prevValue != visibleMode {
                switch visibleMode {
                case .normal:
                    // Vẽ thông thường
                    strokeColor = _strokeColor
                    strokeWidth = _strokeWidth
                    fillColor = _fillColor
                    removePointsFromMap()
                    
                    border.map = nil
                    delegate?.visibleModeNormal(featue: feature!)
                case .selecting:
                    if prevValue == .normal {
                        if strokeColor != nil {
                            _strokeColor = strokeColor!
                        }
                        _strokeWidth = strokeWidth
                        if fillColor != nil {
                            _fillColor = fillColor!
                        }
                    }
                    // Vẽ kiểu selecting
                    strokeColor = selecting_color
                    strokeWidth = selecting_width
                    fillColor = selecting_color.withAlphaComponent(0.5)
                    removePointsFromMap()
                    
                    // Vẽ border outline
                    border.strokeColor = UIColor.orange
                    border.strokeWidth = 3
                    border.zIndex = zIndex - 1
                    border.map = map
                    delegate?.visibleModeSelecting(featue: feature!)
                case .editing:
                    // Vẽ kiểu editing
                    strokeColor = editing_color
                    strokeWidth = editing_width
                    fillColor = editing_color.withAlphaComponent(0.5)
                    addPointsToMap()
                    
                    // Vẽ border outline
                    border.strokeColor = UIColor.white
                    border.strokeWidth = 3
                    border.zIndex = zIndex - 1
                    border.map = map
                    delegate?.visibleModeEditing(featue: feature!)
                }
            }
        }
    }
    
    override var map: GMSMapView? {
        didSet(prevValue) {
            if path == nil {
                // Tạo 4 điểm mặc định
                let p1: CGPoint = (map?.center.applying(CGAffineTransform(translationX: -(map?.frame.width)! / 4.0, y: 0)))!
                let p2: CGPoint = (map?.center.applying(CGAffineTransform(translationX: 0, y: -(map?.frame.height)! / 4)))!
                let p3: CGPoint = (map?.center.applying(CGAffineTransform(translationX: (map?.frame.width)! / 4.0, y: 0)))!
                let p4: CGPoint = (map?.center.applying(CGAffineTransform(translationX: 0, y: (map?.frame.height)! / 4)))!
                addPointFor(p1)
                addPointFor(p2)
                addPointFor(p3)
                addPointFor(p4)
            }
            
            // Trường hợp xóa LineString thì xóa luôn border
            if border.path != nil && map == nil {
                border.map = map
            }
        }
    }
    
    override var path: GMSPath? {
        didSet(prevValue) {
            if prevValue != path {
                border.path = path
            }
        }
    }
    
    override var holes: [GMSPath]? {
        didSet(prevValue) {
            border.holes = holes
        }
    }
    
    override init() {
        super.init()
        zIndex = 5
        border.zIndex = zIndex - 1
        if strokeColor != nil {
            _strokeColor = strokeColor!
            _strokeOpacity = (strokeColor?.cgColor.alpha)!
        }
        if fillColor != nil {
            _fillColor = fillColor!
        }
    }
    
    // Chuyển GMSPolygon qua
    init(gmsPolygon: GMSPolygon) {
        super.init()
        zIndex = 5
        path  = gmsPolygon.path
        if (gmsPolygon.strokeColor != nil) {
            _strokeColor = gmsPolygon.strokeColor!
        }
        if gmsPolygon.fillColor != nil {
            _fillColor  = gmsPolygon.fillColor!
        }
        _strokeWidth = gmsPolygon.strokeWidth
        gmsPolygon.map = nil
    }
        
    public func gmsPolygon() -> GMSPolygon {
        let pl = GMSPolygon(path: path)
        pl.map = map
        pl.strokeColor = _strokeColor
        pl.strokeWidth = _strokeWidth
        pl.fillColor   = _fillColor
        
        removePointsFromMap()
        map = nil
        return pl
    }
    
    // Chèn đỉnh tại midPoint
    private func insertPointFor(_ midPoint: PointView) {
        // Xác định id của midPoint
        let i: Int = midPoints.index(of: midPoint)!
        if points.count > 0 {
            // Chèn đỉnh mới
            let newPoint = PointView(frame: CGRect.zero)
            newPoint.center = midPoint.center
            newPoint.delegate = self
            
            // Tính lại tọa độ cho midPoint
            midPoint.center = calculateMidPoint(midPoint.center, points[i].center)
            
            // Chèn midPoint mới
            var mp: CGPoint = calculateMidPoint(newPoint.center, (points.first?.center)!)
            if i != midPoints.count - 1 {
                mp = calculateMidPoint(newPoint.center, points[i+1].center)
            }
            let newMidPoint = PointView(frame: CGRect.zero)
            newMidPoint.center = mp
            newMidPoint.pointMode = .midpoint
            newMidPoint.delegate = self
            
            points.insert(newPoint, at: i+1)
            midPoints.insert(newMidPoint, at: i+1)
            
            // Thêm và đỉnh mới vào map
            map?.addSubview(newMidPoint)
            map?.addSubview(newPoint)
        }
        
        path = pathFromPoints()
    }
    
    // Xóa một đỉnh
    private func removePointFor(_ point: PointView) {
        guard (points.count > 3 && point.pointMode != .midpoint) else {
            return
        }
        let newPath: GMSMutablePath = GMSMutablePath(path: path!)
        let i = points.index(of: point)!
        newPath.removeCoordinate(at: UInt(i))
        path = newPath
        if i == 0 {
            // Nếu là đỉnh đầu
            points.removeFirst().removeFromSuperview()
            midPoints.removeFirst().removeFromSuperview()
            //midPoints.first?.center = calculateMidPoint(points[i-1].center, points[i+1].center)
        } else if i == points.count - 1 {
            // Nếu là đỉnh cuối
            points.removeLast().removeFromSuperview()
            midPoints.removeLast().removeFromSuperview()
            midPoints.last?.center = calculateMidPoint((points.last?.center)!, (points.first?.center)!)
        } else {
            // Nếu là các đỉnh giữa
            midPoints[i-1].center = calculateMidPoint(points[i-1].center, points[i+1].center)
            points.remove(at: i).removeFromSuperview()
            midPoints.remove(at: i).removeFromSuperview()
        }
    }
    
    public func removeSeletedPoint() {
        removePointFor(selectedPoint)
    }
    
    // Thêm điểm
    public func addPointFor(_ p: CGPoint) {
        guard selectedPoint == nil else {
            selectedPoint.pointMode = .normal
            selectedPoint = nil
            return
        }
        
        if points.count == 0 {
            let point = PointView(frame: CGRect.zero)
            point.delegate = self
            point.center = p
            point.pointMode = .normal
            
            let midPoint = PointView(frame: CGRect.zero)
            midPoint.delegate = self
            midPoint.center = point.center
            midPoint.pointMode = .midpoint
            
            points.append(point)
            midPoints.append(midPoint)
            
            // Thêm và đỉnh mới vào map
            map?.addSubview(midPoint)
            map?.addSubview(point)
            //
        } else {
            // Thêm đỉnh mới
            let point = PointView(frame: CGRect.zero)
            point.delegate = self
            point.center = p
            point.pointMode = .normal
            
            // Cập nhật lại điểm giữa trước đó
            midPoints.last?.center = calculateMidPoint((points.last?.center)!, p)
            
            // Thêm điểm giữa mới
            let midPoint = PointView(frame: CGRect.zero)
            midPoint.delegate = self
            midPoint.center = point.center
            midPoint.pointMode = .midpoint
            
            points.append(point)
            midPoints.append(midPoint)
            
            if points.count > 2 {
                // Tính lại tọa độ midPoit trước đó
                midPoints.last?.center = calculateMidPoint((points.last?.center)!, (points.first?.center)!)
            }
            
            // Thêm và đỉnh mới vào map
            map?.addSubview(midPoint)
            map?.addSubview(point)
        }
        path = pathFromPoints()
    }
    
    public func updateVertex() {
        updatePointsFromPath()
    }
    
    public func visibleVertices(_ show: Bool) {
        for i in 0..<points.count {
            points[i].isHidden = !show
            midPoints[i].isHidden = !show
        }
    }
    
    private func visibleMidPoints(_ show: Bool) {
        for i in 0..<midPoints.count {
            midPoints[i].isHidden = !show
        }
    }
    
    // Hiện tất cả point lên map
    private func addPointsToMap() {
        // Gỡ points và midPoints ra khỏi map trước
        removePointsFromMap()
        
        // Tạo các đỉnh từ path
        pointsFromPath(path!)
        
        // Chèn lên bản đồ
        for i in 0..<points.count {
            map?.addSubview(midPoints[i])
            map?.addSubview(points[i])
        }
    }
    
    // Gỡ tất cả point khỏi map và xóa khỏi list
    private func removePointsFromMap() {
        // Gỡ points và midPoints ra khỏi view
        while points.count > 0 {
            points.removeLast().removeFromSuperview()
            midPoints.removeLast().removeFromSuperview()
        }
    }
    
    private func pathFromPoints() -> GMSPath {
        let newPath: GMSMutablePath = GMSMutablePath()
        for i in 0..<points.count {
            newPath.add((map?.projection.coordinate(for: points[i].center))!)
        }
        return newPath
    }
    
    private func pointsFromPath(_ newPath: GMSPath) {
        guard map != nil else {
            return
        }
        
        guard newPath.count() > 0 else {
            return
        }
        
        // Cập nhật points và midPoints từ path
        for i in 0..<newPath.count() {
            let p: CGPoint = (map?.projection.point(for: newPath.coordinate(at: i)))!
            // Thêm đỉnh và tự động thêm midPoint
            addPointFor(p)
        }
    }
    
    // Cập nhật lại path khi có thay đổi đỉnh
    private func updatePathFor(_ point: PointView) {
        let newPath: GMSMutablePath = GMSMutablePath(path: path!)
        let i: UInt = UInt(points.index(of: point)!)
        newPath.replaceCoordinate(at: i, with: (map?.projection.coordinate(for: point.center))!)
        path = newPath
    }
    
    // Cập nhật lại toàn bộ đỉnh và điểm giữa (sau khi map thay đổi)
    private func updatePointsFromPath() {
        guard let newPath: GMSPath = path else { return }
        guard points.count == newPath.count() else {
            return
        }
        
        // Cập nhật points từ path
        for i in 0..<newPath.count() {
            let p = (map?.projection.point(for: newPath.coordinate(at: i)))!
            points[Int(i)].center = p
        }
        
        // Cập nhật midPoints
        for i in 0..<newPath.count()-1 {
            let mp = calculateMidPoint(points[Int(i)].center, points[Int(i)+1].center)
            midPoints[Int(i)].center = mp
        }
        midPoints.last?.center = calculateMidPoint((points.last?.center)!, (points.first?.center)!)
    }
    
    // Chỉ cập nhật lại mỗi điểm giữa sau khi đỉnh đã moved
    private func updateMidPointsFromPath() {
        guard let newPath: GMSPath = path else { return }
        guard midPoints.count == newPath.count() else {
            return
        }
        
        // Cập nhật midPoints
        for i in 0..<newPath.count()-1 {
            let mp = calculateMidPoint(points[Int(i)].center, points[Int(i)+1].center)
            midPoints[Int(i)].center = mp
        }
        midPoints.last?.center = calculateMidPoint((points.last?.center)!, (points.first?.center)!)
    }
    //////////////////////////////////////////////////////
    // Kết thúc các sự kiện PointViewDelegate từ PointView
    //////////////////////////////////////////////////////
    
    var feature: CFeature?
    
    func style(properties: [String : Any]?) {
        guard properties != nil else {
            return
        }
        var titleStr = String()
        if let name = (properties![CPropMember.name.rawValue]) {
            titleStr = name as! String
        } else if let name = (properties![CPropMember.title.rawValue]) {
            titleStr = name as! String
        }
        if let strokeStr = (properties![CPropMember.stroke.rawValue]) {
            strokeColor = UIColor(hex: strokeStr as! String)
        }
        if let strokeOpacity = ((properties![CPropMember.strokeOpacity.rawValue]) as AnyObject).floatValue {
            strokeColor = strokeColor?.withAlphaComponent(CGFloat(strokeOpacity))
        }
        
        if let fillStr = (properties![CPropMember.fill.rawValue]) {
            fillColor = UIColor(hex: fillStr as! String)
        }
        if let fillOpacity = ((properties![CPropMember.fillOpacity.rawValue]) as AnyObject).floatValue {
            fillColor = fillColor?.withAlphaComponent(CGFloat(fillOpacity))
        }
        if let sw = (properties![CPropMember.strokeWidth.rawValue]) {
            strokeWidth = CGFloat((sw as AnyObject).floatValue)
        }
        title = titleStr
        let fillAlpha = fillColor?.cgColor.components![3]
        // Nếu fill không có alpha thì đặt alpha = 0.5
        if fillAlpha == 1.0 {
            fillColor = fillColor?.withAlphaComponent(0.5)
        }
        if strokeColor != nil {
            _strokeColor = strokeColor!
        }
        if fillColor != nil {
            _fillColor = fillColor!
        }
        _strokeWidth = strokeWidth
        _fillOpacity = fillAlpha!
        
        isTappable = true
    }
    
    func renderer(map: GMSMapView!) {
        self.map = map
    }
    
    var type: CGeoJSONGeometryTypeValue = .polygon

    var altitudes: [CGFloat] = [CGFloat]()
    
    init(dict: Dictionary<String, Any>) {
        super.init()
        let arrays: NSArray = dict[CGeoJSONMember.coordinates.rawValue] as! NSArray
        path = (arrays[0] as! NSArray).toGMSPath(true)
        altitudes = (arrays[0] as! NSArray).toAltitudes(true)
        if arrays.count > 1 {
            holes = [GMSPath]()
            for i in 1..<arrays.count {
                holes?.append((arrays[i] as! NSArray).toGMSPath(true))
            }
        }
    }
    
    var boundingBox: GMSCoordinateBounds {
        get {
            return GMSCoordinateBounds(path: path!)
        }
    }

    var dict: Dictionary<String, Any> {
        get {
            let arrays: NSMutableArray = NSMutableArray()
            arrays.add(path?.closed().toNSArray(altitudes: altitudes) as Any)
            if holes != nil {
                for hole in holes! {
                    arrays.add(hole.closed().toNSArray(altitudes: altitudes) as Any)
                }
            }
            return Dictionary(dictionaryLiteral: (CGeoJSONMember.type.rawValue, type.rawValue),
                              (CGeoJSONMember.coordinates.rawValue, arrays))
        }
    }    
}

/*
 * Coordinates of a MultiPoint are an array of Point coordinates.
 */
class CMultiPoint: CGeoJSONGeometry {
    
    var feature: CFeature? {
        didSet(prevValue) {
            if feature != nil {
                for point in points {
                    point.feature = feature
                }
            }
        }
    }
    
    func style(properties: [String : Any]?) {
        guard properties != nil else {
            return
        }
        var titleStr = String()
        var descStr = String()
        var iconStr = String()
        if let name = (properties![CPropMember.name.rawValue]) {
            titleStr = name as! String
        } else if let name = (properties![CPropMember.title.rawValue]) {
            titleStr = name as! String
        }
        if let desc = (properties![CPropMember.desc.rawValue]) {
            descStr = desc as! String
        }
        if let iconName = (properties![CPropMember.markerSymbol.rawValue]) {
            iconStr = iconName as! String
        }
        for point in points {
            point.title = titleStr
            point.snippet = descStr
            point.icon = UIImage(named: iconStr)
            if point.icon == nil {
                point.icon = #imageLiteral(resourceName: "pin-large")
            }
        }
    }
    
    func renderer(map: GMSMapView!) {
        for point in points {
            point.renderer(map: map)
        }
    }
    
    var type: CGeoJSONGeometryTypeValue = .multiPoint
    
    var points = [CPoint]()
    
    init(dict: Dictionary<String, Any>) {
        let arrays: NSArray = dict[CGeoJSONMember.coordinates.rawValue] as! NSArray
        for array in arrays {
            let point = CPoint(position: (array as! NSArray).toCLLocationCoordinate2D())
            points.append(point)
        }
    }
    
    var boundingBox: GMSCoordinateBounds {
        get {
            var bounds = GMSCoordinateBounds()
            for point in points {
                bounds = bounds.includingBounds(point.boundingBox)
            }
            return bounds
        }
    }

    var dict: Dictionary<String, Any> {
        get {
            let arrays: NSMutableArray = NSMutableArray()
            for point in points {
                arrays.add(point.position.toNSArray(altitude: point.altitude))
            }
            return Dictionary(dictionaryLiteral: (CGeoJSONMember.type.rawValue, type.rawValue),
                              (CGeoJSONMember.coordinates.rawValue, arrays))
        }
    }
}

/*
 * Coordinates of a MultiLineString are an array of LineString coordinates.
 */
class CMultiLineString: CGeoJSONGeometry {
    var feature: CFeature? {
        didSet(prevValue) {
            if feature != nil {
                for lineString in lineStrings {
                    lineString.feature = feature
                }
            }
        }
    }
    
    func style(properties: [String : Any]?) {
        guard properties != nil else {
            return
        }
        var titleStr = String()
        var stroke_color = UIColor(red: 99/255, green: 131/255, blue: 178/255, alpha: 1.0)
        var stroke_width: CGFloat = 1
        if let name = (properties![CPropMember.name.rawValue]) {
            titleStr = name as! String
        } else if let name = (properties![CPropMember.title.rawValue]) {
            titleStr = name as! String
        }
        if let strokeStr = (properties![CPropMember.stroke.rawValue]) {
            stroke_color = UIColor(hex: strokeStr as! String)
        }
        if let sw = (properties![CPropMember.strokeWidth.rawValue]) {
            stroke_width = CGFloat((sw as AnyObject).floatValue)
        }
        for lineString in lineStrings {
            lineString.title = titleStr
            lineString.strokeColor = stroke_color
            lineString.strokeWidth = stroke_width
            lineString.isTappable = true
        }
    }
    
    func renderer(map: GMSMapView!) {
        for lineString in lineStrings {
            lineString.renderer(map: map)
        }
    }
    
    var type: CGeoJSONGeometryTypeValue = .multiLineString
    
    var lineStrings = [CLineString]()
    
    init(dict: Dictionary<String, Any>) {
        
        let arrays: NSArray = dict[CGeoJSONMember.coordinates.rawValue] as! NSArray
        for array in arrays {
            lineStrings.append(CLineString(path: (array as! NSArray).toGMSPath(false)))
        }
    }
    
    var boundingBox: GMSCoordinateBounds {
        get {
            var bounds = GMSCoordinateBounds()
            for lineString in lineStrings {
                bounds = bounds.includingBounds(lineString.boundingBox)
            }
            return bounds
        }
    }

    var dict: Dictionary<String, Any> {
        get {
            let arrays: NSMutableArray = NSMutableArray()
            for lineString in lineStrings {
                arrays.add(lineString.path?.toNSArray(altitudes: lineString.altitudes) as Any)
            }
            return Dictionary(dictionaryLiteral: (CGeoJSONMember.type.rawValue, type.rawValue),
                              (CGeoJSONMember.coordinates.rawValue, arrays))
        }
    }
}

/*
 * Coordinates of a MultiPolygon are an array of Polygon coordinates.
 */
class CMultiPolygon: CGeoJSONGeometry {
    var feature: CFeature? {
        didSet(prevValue) {
            if feature != nil {
                for polygon in polygons {
                    polygon.feature = feature
                }
            }
        }
    }
    
    func style(properties: [String : Any]?) {
        guard properties != nil else {
            return
        }
        var titleStr = String()
        var stroke_color = UIColor(red: 99/255, green: 131/255, blue: 178/255, alpha: 1.0)
        var fill_color = UIColor(red: 99/255, green: 131/255, blue: 178/255, alpha: 0.5)
        var stroke_width: CGFloat = 1
        if let name = (properties![CPropMember.name.rawValue]) {
            titleStr = name as! String
        } else if let name = (properties![CPropMember.title.rawValue]) {
            titleStr = name as! String
        }
        if let strokeStr = (properties![CPropMember.stroke.rawValue]) {
            stroke_color = UIColor(hex: strokeStr as! String)
        }
        if let fillStr = (properties![CPropMember.fill.rawValue]) {
            fill_color = UIColor(hex: fillStr as! String)
        }
        if let sw = (properties![CPropMember.strokeWidth.rawValue]) {
            stroke_width = CGFloat((sw as AnyObject).floatValue)
        }
        for polygon in polygons {
            polygon.title = titleStr
            polygon.strokeColor = stroke_color
            polygon.strokeWidth = stroke_width
            polygon.fillColor = fill_color
            polygon.isTappable = true
        }
    }
    
    func renderer(map: GMSMapView!) {
        for polygon in polygons {
            polygon.renderer(map: map)
        }
    }
    
    var type: CGeoJSONGeometryTypeValue = .multiPolygon
    
    var polygons = [CPolygon]()
    
    var boundingBox: GMSCoordinateBounds {
        get {
            var bounds = GMSCoordinateBounds()
            for polygon in polygons {
                bounds = bounds.includingBounds(polygon.boundingBox)
            }
            return bounds
        }
    }

    init(dict: Dictionary<String, Any>) {
        let arrays: NSArray = dict[CGeoJSONMember.coordinates.rawValue] as! NSArray
        for array in arrays {
            let path = ((array as! NSArray)[0] as! NSArray).toGMSPath(true)
            let polygon = CPolygon(path: path)
            if (array as! NSArray).count > 1 {
                polygon.holes = [GMSPath]()
                for i in 1..<(array as! NSArray).count {
                    polygon.holes?.append(((array as! NSArray)[i] as! NSArray).toGMSPath(true))
                }
            }
            polygons.append(polygon)
        }
    }
    
    var dict: Dictionary<String, Any> {
        get {
            let polygonArray: NSMutableArray = NSMutableArray()
            for polygon in polygons {
                let arrays: NSMutableArray = NSMutableArray()
                arrays.add(polygon.path?.closed().toNSArray(altitudes: polygon.altitudes) as Any)
                if polygon.holes != nil {
                    for hole in polygon.holes! {
                        arrays.add(hole.closed().toNSArray(altitudes: []))
                    }
                }
                polygonArray.add(arrays)
            }
            return Dictionary(dictionaryLiteral: (CGeoJSONMember.type.rawValue, type.rawValue),
                              (CGeoJSONMember.coordinates.rawValue, polygonArray))
        }
    }
}

/*
 * Each element in the geometries array of a GeometryCollection is one of the geometry objects described above.
 */
class CGeometryCollection: CGeoJSONGeometry {
    var feature: CFeature? {
        didSet(prevValue) {
            if feature != nil {
                for geometry in geometries {
                    geometry.feature = feature
                }
            }
        }
    }
    
    func style(properties: [String : Any]?) {
        for geometry in geometries {
            geometry.style(properties: properties)
        }
    }
    
    func renderer(map: GMSMapView!) {
        for geometry in geometries {
            geometry.renderer(map: map)
        }
    }
    
    var type: CGeoJSONGeometryTypeValue = .geometryCollection
    
    var geometries = [CGeoJSONGeometry]()
    
    init(dict: Dictionary<String, Any>) {
        let arrays: NSArray = dict[CGeoJSONMember.geometries.rawValue] as! NSArray
        for array in arrays {
            let geoDict: Dictionary<String, Any> = array as! Dictionary<String, Any>
            let _type: CGeoJSONGeometryTypeValue = CGeoJSONGeometryTypeValue(rawValue: geoDict[CGeoJSONMember.type.rawValue] as! String)!
            switch _type {
            case .point:
                geometries.append(CPoint(position: (geoDict[CGeoJSONMember.coordinates.rawValue] as! NSArray).toCLLocationCoordinate2D()))
            case .lineString:
                geometries.append(CLineString(path: (geoDict[CGeoJSONMember.coordinates.rawValue] as! NSArray).toGMSPath(false)))
            case .polygon:
                let arr = geoDict[CGeoJSONMember.coordinates.rawValue] as! NSArray
                let outer = arr[0] as! NSArray
                let pl = CPolygon(path: outer.toGMSPath(true))
                if arr.count > 1 {
                    pl.holes = NSArray() as? [GMSPath]
                    for i in 1..<arr.count {
                        pl.holes?.append((arr[i] as! NSArray).toGMSPath(true))
                    }
                }
                geometries.append(pl)
            default:
                break
            }
        }
    }
    
    var boundingBox: GMSCoordinateBounds {
        get {
            var bounds = GMSCoordinateBounds()
            for geometry in geometries {
                bounds = bounds.includingBounds(geometry.boundingBox)
            }
            return bounds
        }
    }
    
    var dict: Dictionary<String, Any> {
        get {
            let geometryArray: NSMutableArray = NSMutableArray()
            for geometry in geometries {
                geometryArray.add(geometry.dict)
            }
            return Dictionary(dictionaryLiteral: (CGeoJSONMember.type.rawValue, type.rawValue),
                              (CGeoJSONMember.geometries.rawValue, geometryArray))
        }
    }
}

/*
 * A Feature is an object with a geometry and additional properties.
 */
class CFeature: NSObject, CGeoJSONContainer {
    
    var type: CGeoJSONTypeValue = .feature
    
    var geometry: CGeoJSONGeometry!
    
    var properties: [String : Any]?
    
    var featureCollection: CFeatureCollection!
    
    var dict: Dictionary<String, Any> {
        get {
            return Dictionary(dictionaryLiteral: (CGeoJSONMember.type.rawValue, type.rawValue),
                              (CGeoJSONMember.properties.rawValue, properties ?? [:]),
                              (CGeoJSONMember.geometry.rawValue, geometry.dict))
        }
    }
    
    func style(properties: [String : Any]?) {
        geometry.style(properties: properties)
    }
    
    init(dict: Dictionary<String, Any> ) {
        super.init()
        self.properties = dict[CGeoJSONMember.properties.rawValue] as? [String : Any]
        let geometryDict = dict[CGeoJSONMember.geometry.rawValue] as! Dictionary<String, Any>
        let type: CGeoJSONGeometryTypeValue = CGeoJSONGeometryTypeValue(rawValue: geometryDict[CGeoJSONMember.type.rawValue] as! String)!
        var geometry: CGeoJSONGeometry!
        switch type {
        case .point:
            geometry = CPoint(dict: geometryDict)
        case .multiPoint:
            geometry = CMultiPoint(dict: geometryDict)
        case .lineString:
            geometry = CLineString(dict: geometryDict)
        case .multiLineString:
            geometry = CMultiLineString(dict: geometryDict)
        case .polygon:
            geometry = CPolygon(dict: geometryDict)
        case .multiPolygon:
            geometry = CMultiPolygon(dict: geometryDict)
        case .geometryCollection:
            geometry = CGeometryCollection(dict: geometryDict)
        }
        self.geometry = geometry
        self.geometry.feature = self
        self.geometry.style(properties: self.properties)
    }
    
    init(geometry: CGeoJSONGeometry, properties: [String : Any]?) {
        super.init()
        self.geometry = geometry
        self.properties = properties
        self.geometry.feature = self
        self.geometry.style(properties: self.properties)
    }
    
    func delete() {
        guard featureCollection != nil else {
            return
        }
        featureCollection.deleteFeature(self)
    }
}

/*
 * Each element in the features array of a FeatureCollection is a Feature object as described above.
 */
class CFeatureCollection: CGeoJSON {
    func renderer(map: GMSMapView!) {
        for feature in _features {
            feature.geometry.style(properties: feature.properties)
            feature.geometry.renderer(map: map)
            _boundingBox = _boundingBox.includingBounds(feature.geometry.boundingBox)
        }
    }
    
    var type: CGeoJSONTypeValue = .featureCollection
    
    private var _features:[CFeature] = []
    
    var features: [CFeature] {
        get { return _features }
    }
    
    private var _boundingBox = GMSCoordinateBounds()
    
    var boundingBox: GMSCoordinateBounds {
        get {
            return _boundingBox
        }
    }
    
    func addFeature(_ feature: CFeature) {
        feature.featureCollection = self
        _features.append(feature)
    }
    
    fileprivate func deleteFeature(_ feature: CFeature) {
        if let index = _features.index(where: {$0 == feature}) {
            feature.geometry.renderer(map: nil)
            _features.remove(at: index)
        }
    }
    
    required init(dict: Dictionary<String, Any>) {
        guard !dict.isEmpty else {
            return
        }
        
        let jsonDictArray = dict[CGeoJSONMember.features.rawValue] as! [Dictionary<String, Any>]
        for jsonDict in jsonDictArray {
            let type: CGeoJSONTypeValue = CGeoJSONTypeValue(rawValue: jsonDict[CGeoJSONMember.type.rawValue] as! String)!
            switch type {
            case .feature:
                let feature = CFeature(dict: jsonDict)
                feature.featureCollection = self
                _features.append(feature)
            default:
                break
            }
        }
    }
    
    var dict: Dictionary<String, Any> {
        get {
            let featureArray = NSMutableArray()
            for feature in _features {
                featureArray.add(feature.dict)
            }
            return Dictionary(dictionaryLiteral: (CGeoJSONMember.type.rawValue, type.rawValue),
                          (CGeoJSONMember.features.rawValue, featureArray))
        }
    }
}

class CGeoJSONKit: NSObject {
    private var _url: URL!
    var url: URL {
        get {
            return _url
        }
    }
    
    private var _featureCollection = CFeatureCollection(dict: Dictionary())
    
    private var _isParsed: Bool = false
    
    public var featureCollection: CFeatureCollection {
        get {
            return _featureCollection
        }
    }
    
    private func parse() {
        guard let data = try? Data(contentsOf: _url, options: .alwaysMapped) else {
            return
        }
        guard let jsonDict: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> else {
            return
        }
        
        if let type: CGeoJSONTypeValue = CGeoJSONTypeValue(rawValue: jsonDict[CGeoJSONMember.type.rawValue] as! String) {
            switch type {
            case .feature:
                let feature = CFeature(dict: jsonDict)
                _featureCollection.addFeature(feature)
            case .featureCollection:
                _featureCollection = CFeatureCollection(dict: jsonDict)
            }
        } else if let type: CGeoJSONGeometryTypeValue = CGeoJSONGeometryTypeValue(rawValue: jsonDict[CGeoJSONMember.type.rawValue] as! String) {
            switch type {
            case .point:
                let point = CPoint(dict: jsonDict)
                _featureCollection.addFeature(CFeature(geometry: point, properties: nil))
            case .multiPoint:
                let multiPoint = CMultiPoint(dict: jsonDict)
                _featureCollection.addFeature(CFeature(geometry: multiPoint, properties: nil))
            case .lineString:
                let lineString = CLineString(dict: jsonDict)
                _featureCollection.addFeature(CFeature(geometry: lineString, properties: nil))
            case .multiLineString:
                let multiLineString = CMultiLineString(dict: jsonDict)
                _featureCollection.addFeature(CFeature(geometry: multiLineString, properties: nil))
            case .polygon:
                let polygon = CPolygon(dict: jsonDict)
                _featureCollection.addFeature(CFeature(geometry: polygon, properties: nil))
            case .multiPolygon:
                let multiPolygon = CMultiPolygon(dict: jsonDict)
                _featureCollection.addFeature(CFeature(geometry: multiPolygon, properties: nil))
            case .geometryCollection:
                let geometryCollection = CGeometryCollection(dict: jsonDict)
                _featureCollection.addFeature(CFeature(geometry: geometryCollection, properties: nil))
            }
        }
        _isParsed = true
    }
    
    override init() {
        super.init()
        if self._url == nil {
            let alertController = UIAlertController(title: NSLocalizedString("Create New GeoJSON", comment: ""), message: nil, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default, handler: {
                alert -> Void in
                let textField = alertController.textFields![0] as UITextField
                let fileName: String = (textField.text?.removingPercentEncoding)!
                if fileName.length != 0 {
                    var fileUrl = createDocumentFileFor(subPath: "", fileName: fileName, ext: String())
                    if fileUrl.pathExtension != "geojson" {
                        fileUrl = fileUrl.appendingPathExtension("geojson")
                    }
                    self._url = fileUrl
                } else {
                    var fileUrl = createDocumentFileFor(subPath: "", fileName: getFileNameByGPSTime(ext: "geojson", date: Date()), ext: String())
                    if fileUrl.pathExtension != "geojson" {
                        fileUrl = fileUrl.appendingPathExtension("geojson")
                    }
                    self._url = fileUrl
                }
            }))
            
            alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
                textField.placeholder = NSLocalizedString("Type your file name", comment: "")
                textField.text = getFileNameByGPSTime(ext: "geojson", date: Date())
            })
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    init(url: URL) {
        super.init()
        _url = url
        parse()
    }
    
    func renderer(map: GMSMapView!) {
        guard _isParsed == true else {
            return
        }
        _featureCollection.renderer(map: map)
    }
    
    func addFeature(_ feature: CFeature) {
        guard _url != nil else {
            return
        }
        _featureCollection.addFeature(feature)
    }
    
    func save() {
        guard _url != nil else {
            setRecentGeoJSONPath(nil)
            return
        }
        setRecentGeoJSONPath(_url)
        guard _featureCollection.features.count > 0 else {
            return
        }
        try! _featureCollection.dict.json.write(to: _url, atomically: true, encoding: .utf8)
    }
}
