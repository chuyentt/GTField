//
//  GeoJSONHelper.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 1/28/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

import Foundation

enum GeoJSONMember: String {
    case type = "type"
    case id = "id"
    case geometry = "geometry"
    case geometries = "geometries"
    case properties = "properties"
    case boundingBox = "bbox"
    case coordinates = "coordinates"
    case features = "features"
}

enum GeoJSONValue: String {
    case feature = "Feature"
    case featureCollection = "FeatureCollection"
    case point = "Point"
    case multiPoint = "MultiPoint"
    case lineString = "LineString"
    case multiLineString = "MultiLineString"
    case polygon = "Polygon"
    case multiPolygon = "MultiPolygon"
    case geometryCollection = "GeometryCollection"
}

enum PropMember: String {
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

protocol Geometry: class {
    var type: GeoJSONValue { get }
    var member: Dictionary<String, Any> { get set }
    func style(properties: [String: Any]?)
    func renderer(map: GMSMapView)
}

protocol GeoJSONContainer: class {
    var type: GeoJSONValue { get }
    var geometry: Geometry { get }
    var properties: [String: Any]? { get set }
    var member: Dictionary<String, Any> { get set }
    func style(properties: [String: Any]?)
}

class GeoJSON: NSObject {
    private var _url: URL!
    private var _features = [Feature]()
    public var features: [Feature] {
        get {
            return _features
        }
    }
    private var _bounds: GMSCoordinateBounds!
    private var _isParsed: Bool = false
    
    var bounds: GMSCoordinateBounds {
        get { return _bounds }
        set(bounds) {
            _bounds = bounds
        }
    }
    
    init(url: URL) {
        super.init()
        _url = url
    }
    
    func parse() {
        guard _isParsed == false && _url != nil else {
            return
        }
        guard let data = try? Data(contentsOf: _url, options: .alwaysMapped) else {
            return
        }
        guard let jsonDict: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> else {
            return
        }
        guard let type: GeoJSONValue = GeoJSONValue(rawValue: jsonDict[GeoJSONMember.type.rawValue] as! String) else {
            return
        }
        
        switch type {
        case .feature:
            let feature = featureFrom(dict: jsonDict)
            _features.append(feature)
        case .featureCollection:
            let featureArray = featureCollectionFrom(dict: jsonDict)
            _features = featureArray
        case .point,
             .multiPoint,
             .lineString,
             .multiLineString,
             .polygon,
             .multiPolygon,
             .geometryCollection:
            let feature = featureFromGeometry(dict: jsonDict)
            _features.append(feature)
        }
        
//        if ([type isEqual:kGMUFeatureValue]) {
//            feature = [self featureFromDict:_JSONDict];
//            if (feature) {
//                [_features addObject:feature];
//            }
//        } else if ([type isEqual:kGMUFeatureCollectionValue]) {
//            NSArray<GMUFeature *> *featureCollection = [self featureCollectionFromDict:_JSONDict];
//            if (featureCollection) {
//                [_features addObjectsFromArray:featureCollection];
//            }
//        } else if ([_geometryRegex firstMatchInString:type
//            options:0
//            range:NSMakeRange(0, [type length])]) {
//            feature = [self featureFromGeometryDict:_JSONDict];
//            if (feature) {
//                [_features addObject:feature];
//            }
//        }
    }
    
    func renderer(map: GMSMapView) {
        for feature in _features {
            feature.geometry.style(properties: feature.properties)
            feature.geometry.renderer(map: map)
        }
    }
    
    func save() -> Bool {
        
        return true
    }
    
    func featureFrom(dict: Dictionary<String, Any>) -> Feature {
        let geometry: Geometry = geometryFrom(dict: dict[GeoJSONMember.geometry.rawValue] as! Dictionary<String, Any>)
        let properties = dict[GeoJSONMember.properties.rawValue] as? [String: Any]
        return Feature(geometry: geometry, properties: properties)
    }
    
    func featureCollectionFrom(dict: Dictionary<String, Any>) -> [Feature] {
        let jsonDictArray = dict[GeoJSONMember.features.rawValue] as! [Dictionary<String, Any>]
        var featureArray: [Feature] = []
        for jsonDict in jsonDictArray {
            let type: GeoJSONValue = GeoJSONValue(rawValue: jsonDict[GeoJSONMember.type.rawValue] as! String)!
            switch type {
            case .feature:
                let feature = featureFrom(dict: jsonDict)
                featureArray.append(feature)
            default:
                break
            }
        }
        return featureArray
    }
    
    func featureFromGeometry(dict: Dictionary<String, Any>) -> Feature {
        let geometry = geometryFrom(dict: dict)
        return Feature(geometry: geometry, properties: [:])
    }
    
    func geometryFrom(dict: Dictionary<String, Any>) -> Geometry {
        let type: GeoJSONValue = GeoJSONValue(rawValue: dict[GeoJSONMember.type.rawValue] as! String)!
        var geometry: Geometry!
        switch type {
        case .point:
            geometry = Point()
        case .multiPoint:
            geometry = MultiPoint()
        case .lineString:
            geometry = LineString()
        case .multiLineString:
            geometry = MultiLineString()
        case .polygon:
            geometry = Polygon()
        case .multiPolygon:
            geometry = MultiPolygon()
        default:
            break
        }
        geometry.member = dict
        return geometry

        /*
         NSString *geometryType = [dict objectForKey:kGMUTypeMember];
         NSArray *geometryArray;
         if ([geometryType isEqual:kGMUGeometryCollectionValue]) {
         geometryArray = [dict objectForKey:kGMUGeometriesMember];
         } else if ([geometryType isEqual:kGMUGeometriesMember]) {
         geometryArray = [dict objectForKey:kGMUGeometryCollectionValue];
         } else if ([_geometryRegex firstMatchInString:geometryType
         options:0
         range:NSMakeRange(0, [geometryType length])]) {
         geometryArray = [dict objectForKey:kGMUCoordinatesMember];
         } else {
         return nil;
         }
         return [self geometryWithGeometryType:geometryType geometryArray:geometryArray];
         */
    }
}
