//
//  MultiPolygon.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 1/31/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

import Foundation

class MultiPolygon: Geometry {
    func style(properties: [String : Any]?) {
        var titleStr = String()
        var stroke_color = UIColor(red: 99/255, green: 131/255, blue: 178/255, alpha: 1.0)
        var fill_color = UIColor(red: 99/255, green: 131/255, blue: 178/255, alpha: 0.5)
        var stroke_width: CGFloat = 1
        if let name = (properties![PropMember.name.rawValue]) {
            titleStr = name as! String
        } else if let name = (properties![PropMember.title.rawValue]) {
            titleStr = name as! String
        }
        if let strokeStr = (properties![PropMember.stroke.rawValue]) {
            stroke_color = UIColor(hex: strokeStr as! String)
        }
        if let fillStr = (properties![PropMember.fill.rawValue]) {
            fill_color = UIColor(hex: fillStr as! String)
        }
        if let sw = (properties![PropMember.strokeWidth.rawValue]) {
            stroke_width = CGFloat((sw as AnyObject).floatValue)
        }
        for polygon in polygons {
            polygon.title = titleStr
            polygon.strokeColor = stroke_color
            polygon.strokeWidth = stroke_width
            polygon.fillColor = fill_color
        }
    }
    
    func renderer(map: GMSMapView) {
        for polygon in polygons {
            polygon.map = map
        }
    }
    
    var polygons = [Polygon]()
    var type: GeoJSONValue = .multiPolygon
    var member: Dictionary<String, Any> {
        set {
            let arrays: NSArray = newValue[GeoJSONMember.coordinates.rawValue] as! NSArray
            for array in arrays {
                let path = ((array as! NSArray)[0] as! NSArray).toGMSPath(true)
                let polygon = Polygon(path: path)
                if (array as! NSArray).count > 1 {
                    polygon.holes = [GMSPath]()
                    for i in 1..<(array as! NSArray).count {
                        polygon.holes?.append(((array as! NSArray)[i] as! NSArray).toGMSPath(true))
                    }
                }
                polygons.append(polygon)
            }
        }
        get {
            let polygonArray: NSMutableArray = NSMutableArray()
            for polygon in polygons {
                let arrays: NSMutableArray = NSMutableArray()
                arrays.add(polygon.path?.closed().toNSArray() as Any)
                if polygon.holes != nil {
                    for hole in polygon.holes! {
                        arrays.add(hole.closed().toNSArray())
                    }
                }
                polygonArray.add(arrays)
            }
            return Dictionary(dictionaryLiteral: (GeoJSONMember.type.rawValue, type.rawValue),
                              (GeoJSONMember.coordinates.rawValue, polygonArray))
        }
    }
}
