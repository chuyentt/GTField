//
//  Point.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 1/31/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

import Foundation

class Point: GMSMarker, Geometry, PointViewDelegate {
//////////////////////////////////////////////////////
// Bắt đầu các sự kiện PointViewDelegate từ PointView
//////////////////////////////////////////////////////
    
    func pointTouchBegan(touch: UITouch) {
//        pointMoved = false
//        guard let point: PointView = touch.view as? PointView else { return }
//        guard point.pointMode != .midpoint else {
//            return
//        }
//        
//        if point.pointMode == .normal {
//            // Đặt lại mặc định cho point trước đó
//            if (selectedPoint != nil) {
//                selectedPoint.pointMode = .normal
//                selectedPoint = nil
//            }
//        }
//        
//        // Trường hợp đã chọn đỉnh từ trước
//        if point == selectedPoint {
//            // Ẩn điểm giữa
//            visibleMidPoints(false)
//            
//            // Kính lúp: Nếu chưa có thì tạo và hiển thị
//            if magnifyView == nil {
//                magnifyView = MagnifyView.init(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
//                magnifyView.viewToMagnify = map // nền bản đồ
//                magnifyView.setTouchPoint(pt: point.center)
//                map?.addSubview(magnifyView)
//            }
//        }
    }
    
    func pointTouchMoved(touch: UITouch) {
        
    }
    
    func pointTouchEnded(touch: UITouch) {
        
    }
//////////////////////////////////////////////////////
// Kết thúc các sự kiện PointViewDelegate từ PointView
//////////////////////////////////////////////////////

    // Kiểm tra point đã move trước đó hay chưa
    private var pointMoved: Bool = false
    
//////////////////////////////////////////////////////
    func style(properties: [String : Any]?) {
        if let name = (properties![PropMember.name.rawValue]) {
            title = name as? String
        } else if let name = (properties![PropMember.title.rawValue]) {
            title = name as? String
        }
        if let desc = (properties![PropMember.desc.rawValue]) {
            snippet = desc as? String
        }
        if let iconName = (properties![PropMember.markerSymbol.rawValue]) {
            icon = UIImage(named: iconName as! String)
        }
    }
    
    func renderer(map: GMSMapView) {
        self.map = map
    }
    
    var type: GeoJSONValue = .point
    var member: Dictionary<String, Any> {
        set {
            let array: NSArray = newValue[GeoJSONMember.coordinates.rawValue] as! NSArray
            position = array.toCLLocationCoordinate2D()
        }
        get {
            return Dictionary(dictionaryLiteral: (GeoJSONMember.type.rawValue, type.rawValue),
                              (GeoJSONMember.coordinates.rawValue, position.toNSArray()))
        }
    }
}
