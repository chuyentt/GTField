//
//  GeometryCollection.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 1/31/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

import Foundation

class GeometryCollection: Geometry {
    func style(properties: [String : Any]?) {
        for geometry in geometries {
            geometry.style(properties: properties)
        }
    }
    
    func renderer(map: GMSMapView) {
        for geometrie in geometries {
            geometrie.renderer(map: map)
        }
    }

    var geometries = [Geometry]()
    var type: GeoJSONValue = .geometryCollection
    var member: Dictionary<String, Any> {
        set {
            let arrays: NSArray = newValue[GeoJSONMember.geometries.rawValue] as! NSArray
            for array in arrays {
                let geoDict: Dictionary<String, Any> = array as! Dictionary<String, Any>
                let _type: GeoJSONValue = GeoJSONValue(rawValue: geoDict[GeoJSONMember.type.rawValue] as! String)!
                switch _type {
                case .point:
                    geometries.append(Point(position: (geoDict[GeoJSONMember.coordinates.rawValue] as! NSArray).toCLLocationCoordinate2D()))
                case .lineString:
                    geometries.append(LineString(path: (geoDict[GeoJSONMember.coordinates.rawValue] as! NSArray).toGMSPath(false)))
                case .polygon:
                    let arr = geoDict[GeoJSONMember.coordinates.rawValue] as! NSArray
                    let outer = arr[0] as! NSArray
                    let pl = Polygon(path: outer.toGMSPath(true))
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
        get {
            let geometryArray: NSMutableArray = NSMutableArray()
            for geometry in geometries {
                geometryArray.add(geometry.member)
            }
            return Dictionary(dictionaryLiteral: (GeoJSONMember.type.rawValue, type.rawValue),
                              (GeoJSONMember.geometries.rawValue, geometryArray))
        }
    }
}
