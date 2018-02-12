//
//  Feature.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 1/31/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

import Foundation

class Feature: NSObject, GeoJSONContainer {
    var type: GeoJSONValue = .feature
    
    var geometry: Geometry
    
    var properties: [String : Any]?
    
    var member: Dictionary<String, Any> {
        set {
            properties = newValue[GeoJSONMember.properties.rawValue] as? [String : Any]
            geometry = newValue[GeoJSONMember.geometry.rawValue] as! Geometry
        }
        get {
            return Dictionary(dictionaryLiteral: (GeoJSONMember.type.rawValue, type.rawValue),
                          (GeoJSONMember.properties.rawValue, properties ?? [:]),
                          (GeoJSONMember.geometry.rawValue, geometry.member))
        }
    }
    
    func style(properties: [String : Any]?) {
        geometry.style(properties: properties)
    }

    init(geometry: Geometry, properties: [String: Any]?) {
        self.geometry = geometry
        self.properties = properties
    }
}
