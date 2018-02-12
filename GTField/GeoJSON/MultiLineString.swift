//
//  MultiLineString.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 1/31/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

import Foundation

class MultiLineString: Geometry {
    func style(properties: [String : Any]?) {
        var titleStr = String()
        var stroke_color = UIColor(red: 99/255, green: 131/255, blue: 178/255, alpha: 1.0)
        var stroke_width: CGFloat = 1
        if let name = (properties![PropMember.name.rawValue]) {
            titleStr = name as! String
        } else if let name = (properties![PropMember.title.rawValue]) {
            titleStr = name as! String
        }
        if let strokeStr = (properties![PropMember.stroke.rawValue]) {
            stroke_color = UIColor(hex: strokeStr as! String)
        }
        if let sw = (properties![PropMember.strokeWidth.rawValue]) {
            stroke_width = CGFloat((sw as AnyObject).floatValue)
        }
        for lineString in lineStrings {
            lineString.title = titleStr
            lineString.strokeColor = stroke_color
            lineString.strokeWidth = stroke_width
        }
    }
    
    func renderer(map: GMSMapView) {
        for lineString in lineStrings {
            lineString.map = map
        }
    }
    
    var type: GeoJSONValue = .multiLineString
    var lineStrings = [LineString]()
    var member: Dictionary<String, Any> {
        set {
            let arrays: NSArray = newValue[GeoJSONMember.coordinates.rawValue] as! NSArray
            for array in arrays {
                lineStrings.append(LineString(path: (array as! NSArray).toGMSPath(false)))
            }
        }
        get {
            let arrays: NSMutableArray = NSMutableArray()
            for lineString in lineStrings {
                arrays.add(lineString.path?.toNSArray() as Any)
            }
            return Dictionary(dictionaryLiteral: (GeoJSONMember.type.rawValue, type.rawValue),
                              (GeoJSONMember.coordinates.rawValue, arrays))
        }
    }
}
