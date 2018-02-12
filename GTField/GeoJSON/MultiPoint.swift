//
//  MultiPoint.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 1/31/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

import Foundation

class MultiPoint: Geometry {
    func geometryFromDict(jsonDict: Dictionary<String, Any>) {
        
    }
    
    func style(properties: [String : Any]?) {
        var titleStr = String()
        var descStr = String()
        var iconStr = String()
        if let name = (properties![PropMember.name.rawValue]) {
            titleStr = name as! String
        } else if let name = (properties![PropMember.title.rawValue]) {
            titleStr = name as! String
        }
        if let desc = (properties![PropMember.desc.rawValue]) {
            descStr = desc as! String
        }
        if let iconName = (properties![PropMember.markerSymbol.rawValue]) {
            iconStr = iconName as! String
        }
        for point in points {
            point.title = titleStr
            point.snippet = descStr
            point.icon = UIImage(named: iconStr)
        }
    }
    
    func renderer(map: GMSMapView) {
        for point in points {
            point.map = map
        }
    }
    
    var points = [Point]()
    var type: GeoJSONValue = .multiPoint
    var member: Dictionary<String, Any> {
        set {
            let arrays: NSArray = newValue[GeoJSONMember.coordinates.rawValue] as! NSArray
            for array in arrays {
                points.append(Point(position: (array as! NSArray).toCLLocationCoordinate2D()))
            }
        }
        get {
            let arrays: NSMutableArray = NSMutableArray()
            for point in points {
                arrays.add(point.position.toNSArray())
            }
            return Dictionary(dictionaryLiteral: (GeoJSONMember.type.rawValue, type.rawValue),
                              (GeoJSONMember.coordinates.rawValue, arrays))
        }
    }
}
