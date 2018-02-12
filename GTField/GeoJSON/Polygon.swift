//
//  Polygon.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 1/30/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

import Foundation

class Polygon: GMSPolygon, Geometry, PointViewDelegate {
    
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
            selectedPoint.pointMode = .moving
            
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
    private var stroke: UIColor = UIColor(red: 99/255, green: 131/255, blue: 178/255, alpha: 1.0) {
        didSet(prevValue) {
            if prevValue != stroke {
                strokeColor = stroke
            }
        }
    }
    
    // Lực nét của polygon: đường chính giữa ở mode normal
    private var stroke_width: CGFloat = 1.0 {
        didSet(prevValue) {
            if prevValue != stroke_width {
                strokeWidth = stroke_width
            }
        }
    }
    
    // Lực nét của polygon: đường chính giữa ở mode normal
    private var stroke_opacity: CGFloat = 1.0 {
        didSet(prevValue) {
            if prevValue != stroke_opacity {
                strokeColor = strokeColor?.withAlphaComponent(stroke_opacity)
            }
        }
    }
    
    // Màu của polygon: fillColor
    private var fill: UIColor = UIColor.clear {
        didSet(prevValue) {
            if prevValue != fill {
                fillColor = fill
            }
        }
    }
    
    private var fill_opacity: CGFloat = 1.0 {
        didSet(prevValue) {
            if prevValue != fill_opacity {
                fillColor = fillColor?.withAlphaComponent(fill_opacity)
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
    
    // Mode của polygon dùng để render: normal, selecting, editing
    var visibleMode: VisibleMode = VisibleMode.normal {
        didSet(prevValue){
            if prevValue != visibleMode {
                switch visibleMode {
                case .normal:
                    // Vẽ thông thường
                    strokeColor = stroke
                    strokeWidth = stroke_width
                    fillColor = fill
                    removePointsFromMap()
                    
                    border.map = nil
                    break
                case .selecting:
                    // Vẽ kiểu selecting
                    strokeColor = selecting_color
                    strokeWidth = selecting_width
                    fillColor = selecting_color.withAlphaComponent(0.5)
                    removePointsFromMap()

                    // Vẽ border outline
                    border.strokeColor = UIColor.orange
                    border.strokeWidth = 3
                    //border.fillColor = UIColor.orange.withAlphaComponent(0.2)
                    border.map = map
                    break
                case .editing:
                    // Vẽ kiểu editing
                    strokeColor = editing_color
                    strokeWidth = editing_width
                    fillColor = editing_color.withAlphaComponent(0.5)
                    addPointsToMap()
                    
                    // Vẽ border outline
                    border.strokeColor = UIColor.white
                    border.strokeWidth = 3
                    border.map = map
                    break
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
        border.zIndex = zIndex - 1
    }
    
    // Chuyển GMSPolygon qua
    init(gmsPolygon: GMSPolygon) {
        super.init()
        path  = gmsPolygon.path
        stroke = gmsPolygon.strokeColor!
        stroke_width = gmsPolygon.strokeWidth
        fill  = gmsPolygon.fillColor!
        gmsPolygon.map = nil
    }
    
    public func gmsPolygon() -> GMSPolygon {
        let pl = GMSPolygon(path: path)
        pl.map = map
        pl.strokeColor = stroke
        pl.strokeWidth = stroke_width
        pl.fillColor   = fill
        
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
    
    func style(properties: [String : Any]?) {
        guard properties != nil else {
            return
        }
        var titleStr = String()
        if let name = (properties![PropMember.name.rawValue]) {
            titleStr = name as! String
        } else if let name = (properties![PropMember.title.rawValue]) {
            titleStr = name as! String
        }
        if let strokeStr = (properties![PropMember.stroke.rawValue]) {
            stroke = UIColor(hex: strokeStr as! String)
        }
        if let strokeOpacity = ((properties![PropMember.strokeOpacity.rawValue]) as AnyObject).floatValue {
            stroke = stroke.withAlphaComponent(CGFloat(strokeOpacity))
        }
        
        if let fillStr = (properties![PropMember.fill.rawValue]) {
            fill = UIColor(hex: fillStr as! String)
        }
        if let fillOpacity = ((properties![PropMember.fillOpacity.rawValue]) as AnyObject).floatValue {
            fill = fill.withAlphaComponent(CGFloat(fillOpacity))
        }
        if let sw = (properties![PropMember.strokeWidth.rawValue]) {
            stroke_width = CGFloat((sw as AnyObject).floatValue)
        }
        title = titleStr
        strokeColor = stroke
        strokeWidth = stroke_width
        let fillAlpha = fill.cgColor.components![3]
        // Nếu fill không có alpha thì đặt alpha = 0.5
        if fillAlpha == 1.0 {
            fill = fill.withAlphaComponent(0.5)
        }
        fillColor = fill
        isTappable = true
    }
    
    func renderer(map: GMSMapView) {
        self.map = map
    }
    
    var type: GeoJSONValue = .polygon
    var member: Dictionary<String, Any> {
        set {
            let arrays: NSArray = newValue[GeoJSONMember.coordinates.rawValue] as! NSArray
            path = (arrays[0] as! NSArray).toGMSPath(true)
            if arrays.count > 1 {
                holes = [GMSPath]()
                for i in 1..<arrays.count {
                    holes?.append((arrays[i] as! NSArray).toGMSPath(true))
                }
            }
        }
        get {
            let arrays: NSMutableArray = NSMutableArray()
            arrays.add(path?.closed().toNSArray() as Any)
            if holes != nil {
                for hole in holes! {
                    arrays.add(hole.closed().toNSArray() as Any)
                }
            }
            return Dictionary(dictionaryLiteral: (GeoJSONMember.type.rawValue, type.rawValue),
                              (GeoJSONMember.coordinates.rawValue, arrays))
        }
    }
}
