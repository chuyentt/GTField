//
//  Settings.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 6/11/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps
//import AEXML

enum CoordinateType: Int {
    case albersEqualAreaConic = 0
    case azimuthalEquidistant = 1
    case bonne = 2
    case britishNationalGrid = 3
    case cassini = 4
    case cylindricalEqualArea = 5
    case eckert4 = 6
    case eckert6 = 7
    case equidistantCylindrical = 8
    case geocentric = 9
    case geodetic = 10
    case georef = 11
    case globalAreaReferenceSystem = 12
    case gnomonic = 13
    case lambertConformalConic1Parallel = 14
    case lambertConformalConic2Parallels = 15
    case localCartesian = 16
    case mercatorScaleFactor = 17
    case mercatorStandardParallel = 18
    case militaryGridReferenceSystem = 19
    case millerCylindrical = 20
    case mollweide = 21
    case newZealandMapGrid = 22
    case neys = 23
    case obliqueMercator = 24
    case orthographic = 25
    case polarStereographicScaleFactor = 26
    case polarStereographicStandardParallel = 27
    case polyconic = 28
    case sinusoidal = 29
    case stereographic = 30
    case transverseCylindricalEqualArea = 31
    case transverseMercator = 32
    case universalPolarStereographic = 33
    case universalTransverseMercator = 34
    case usNationalGrid = 35
    case vanDerGrinten = 36
    case webMercator = 37
}

enum CoordinateTypeName: String {
    case albersEqualAreaConic = "Albers Equal Area Conic"
    case azimuthalEquidistant = "Azimuthal Equidistant (S)"
    case bonne = "Bonne"
    case britishNationalGrid = "British National Grid (BNG)"
    case cassini = "Equidistant Cylindrical (S)"
    case cylindricalEqualArea = "Cassini"
    case eckert4 = "Eckert VI (S)"
    case eckert6 = "Eckert IV (S)"
    case equidistantCylindrical = "Global Area Reference System (GARS)"
    case geocentric = "Geocentric"
    case geodetic = "Geodetic"
    case georef = "GEOREF"
    case globalAreaReferenceSystem = "Gnomonic (S)"
    case gnomonic = "Lambert Conformal Conic (1 Standard Parallel)"
    case lambertConformalConic1Parallel = "Lambert Conformal Conic (2 Standard Parallel)"
    case lambertConformalConic2Parallels = "Local Cartesian"
    case localCartesian = "Cylindrical Equal Area"
    case mercatorScaleFactor = "Mercator (Standard Parallel)"
    case mercatorStandardParallel = "Mercator (Scale Factor)"
    case militaryGridReferenceSystem = "Military Grid Reference System (MGRS)"
    case millerCylindrical = "Miller Cylindrical (S)"
    case mollweide = "Mollweide (S)"
    case newZealandMapGrid = "New Zealand Map Grid (NZMG)"
    case neys = "Ney's (Modified Lambert Conformal Conic)"
    case obliqueMercator = "Oblique Mercator"
    case orthographic = "Orthographic (S)"
    case polarStereographicScaleFactor = "Polar Stereographic (Scale Factor)"
    case polarStereographicStandardParallel = "Polar Stereographic (Standard Parallel)"
    case polyconic = "Polyconic"
    case sinusoidal = "Sinusoidal"
    case stereographic = "Stereographic (S)"
    case transverseCylindricalEqualArea = "Transverse Mercator"
    case transverseMercator = "Transverse Cylindrical Equal Area"
    case universalPolarStereographic = "Universal Polar Stereographic (UPS)"
    case universalTransverseMercator = "United States National Grid (USNG)"
    case usNationalGrid = "Universal Transverse Mercator (UTM)"
    case vanDerGrinten = "Van der Grinten"
    case webMercator = "Web Mercator"
}

enum HeightType: Int {
    case noHeight = 0
    case ellipsoidHeight = 1
    case EGM96FifteenMinBilinear = 2
    case EGM96VariableNaturalSpline = 3
    case EGM84TenDegBilinear = 4
    case EGM84TenDegNaturalSpline = 5
    case EGM84ThirtyMinBiLinear = 6
    case EGM2008TwoPtFiveMinBicubicSpline = 7
}

/**
 * Lấy danh sách layers cho WFS
 * GetCapabilities
 * service="WFS"
 * outputFormat="application/xml"
 */

func getCapabilitiesForWFS() -> URL? {
    var urlComponents = URLComponents(string: getGeoServerBaseUrl())
    urlComponents?.path = "/geoserver/wfs"
    urlComponents?.queryItems = [URLQueryItem(name: "service", value: "WFS"),
                                 URLQueryItem(name: "request", value: "GetCapabilities")]
    return urlComponents?.url
}

/**
 * Lấy danh sách layers cho WMS
 * GetCapabilities
 * service="WMS"
 * outputFormat="application/xml"
 */

func getCapabilitiesForWMS() -> URL? {
    var urlComponents = URLComponents(string: getGeoServerBaseUrl())
    urlComponents?.path = "/geoserver/wms"
    urlComponents?.queryItems = [URLQueryItem(name: "service", value: "WMS"),
                                 URLQueryItem(name: "request", value: "GetCapabilities")]
    return urlComponents?.url
}

/**
 * Lấy Feature theo layer và danh sách tên trường
 * Trả về thuộc tính của các trường đưa vào
 * Nếu bỏ service=WFS thì sẽ trả về nguyên feature cả topo và tất cả các trường
 * Bổ sung EPSG:900913 vào bbox khi kết nối
 * Thêm outputFormat=application/json
 * URLQueryItem(name: "outputFormat", value: "application/json")
 */

func getFeatureForWFS(typeName: String, propertyName: String, maxFeatures: Int) -> URL? {
    var urlComponents = URLComponents(string: getGeoServerBaseUrl())
    urlComponents?.path = "/geoserver/wfs"
    urlComponents?.queryItems = [URLQueryItem(name: "service", value: "WFS"),
                                 URLQueryItem(name: "version", value: "1.3.0"),
                                 URLQueryItem(name: "request", value: "GetFeature"),
                                 URLQueryItem(name: "typeName", value: typeName),
                                 URLQueryItem(name: "propertyName", value: propertyName),
                                 URLQueryItem(name: "maxFeatures", value: "\(maxFeatures)")]
    return urlComponents?.url
}

/**
 * Lấy đường dẫn của GeoServerLayers
 * BaseUrl = http://192.168.1.152:8080/geoserver/
 */
func getGeoServerTilesUrl() -> URL? {
    var urlComponents = URLComponents(string: getGeoServerBaseUrl())
    urlComponents?.path = "/geoserver/wms"
    urlComponents?.queryItems = [URLQueryItem(name: "service", value: "WMS"),
                                 URLQueryItem(name: "version", value: "1.3.0"),
                                 URLQueryItem(name: "request", value: "GetMap"),
                                 URLQueryItem(name: "format", value: "image/png"),
                                 URLQueryItem(name: "layers", value: getWMSActiveLayers()),
                                 URLQueryItem(name: "styles", value: ""),
                                 URLQueryItem(name: "crs", value: "EPSG:900913"),
                                 URLQueryItem(name: "transparent", value: "true")]
    return urlComponents?.url
}

/************************************************
 * Lưu danh sách các trường để tra cứu
 *
 */
func setActiveLayersPropertyName(activeLayersPropertyName: String) {
    UserDefaults.standard.set(activeLayersPropertyName, forKey: "ActiveLayersPropertyName")
    UserDefaults.standard.synchronize()
}

/**
 * Lấy danh sách các trường để tra cứu
 * 
 */
func getActiveLayersPropertyName() -> String {
    var activeLayersPropertyName = UserDefaults.standard.value(forKey: "ActiveLayersPropertyName")
    if !(activeLayersPropertyName is String) {
        activeLayersPropertyName = ""
    }
    return activeLayersPropertyName as! String
}

/************************************************
 * Lưu đường dẫn của GeoServer
 * BaseUrl = http://192.168.1.152:8080/geoserver/
 */
func setGeoServerBaseUrl(urlString: String) -> Bool {
    var urlComponents = URLComponents(string: urlString)
    urlComponents?.path = "/geoserver"
    let success = UIApplication.shared.canOpenURL((urlComponents?.url)!)
    if !success {
        return false
    } else {
        UserDefaults.standard.set(urlComponents?.url?.absoluteString, forKey: "GeoServerBaseUrl")
        UserDefaults.standard.synchronize()
        return success
    }
}

/**
 * Lấy đường dẫn của GeoServer
 * BaseUrl = http://192.168.1.152:8080/geoserver/
 */
func getGeoServerBaseUrl() -> String {
    var geoServerBaseUrl = UserDefaults.standard.value(forKey: "GeoServerBaseUrl")
    if !(geoServerBaseUrl is String) {
        geoServerBaseUrl = GEOSERVER_URL
    }
    
    return geoServerBaseUrl as! String
}

/************************************************
 * Lưu WMS layers đang làm việc
 * wmsActiveLayers: String = "geomatics:Resco_GeoTIFF"
 */
func setWMSActiveLayers(wmsActiveLayers: String) {
    UserDefaults.standard.set(wmsActiveLayers, forKey: "WMSActiveLayers")
    UserDefaults.standard.synchronize()
}

/**
 * Lấy WMS layers đang làm việc
 * wmsActiveLayers: String = "geomatics:Resco_GeoTIFF"
 */
func getWMSActiveLayers() -> String {
    var wmsActiveLayers = UserDefaults.standard.value(forKey: "WMSActiveLayers")
    if !(wmsActiveLayers is String) {
        wmsActiveLayers = "topp:states"
    }
    return wmsActiveLayers as! String
}

/************************************************
 * Lưu WFS layers đang làm việc
 * wfsActiveLayers: String = "geomatics:Resco_GeoTIFF"
 */
func setWFSActiveLayers(wfsActiveLayers: String) {
    UserDefaults.standard.set(wfsActiveLayers, forKey: "WFSActiveLayers")
    UserDefaults.standard.synchronize()
}

/**
 * Lấy WFS layers đang làm việc
 * wfsActiveLayers: String = "geomatics:Resco_GeoTIFF"
 */
func getWFSActiveLayers() -> String {
    var wfsActiveLayers = UserDefaults.standard.value(forKey: "WFSActiveLayers")
    if !(wfsActiveLayers is String) {
        wfsActiveLayers = "topp:states"
    }
    return wfsActiveLayers as! String
}

/************************************************
 * Lưu đường bao của layer WMS
 * {{westBoundLongitude,southBoundLatitude},{eastBoundLongitude,northBoundLatitude}}
 */
func setLayersBoundingBoxForWMS(layersBboxStr: String) {
    UserDefaults.standard.set(layersBboxStr, forKey: "LayersBoundingBoxForWMS")
    UserDefaults.standard.synchronize()
}

/**
 * Lấy đường bao của layer WMS
 * {{westBoundLongitude,southBoundLatitude},{eastBoundLongitude,northBoundLatitude}}
 */
func getLayersBoundingBoxForWMS() -> String {
    var layersBboxStr = UserDefaults.standard.value(forKey: "LayersBoundingBoxForWMS")
    if !(layersBboxStr is String) {
        layersBboxStr = "{{-124.731422,24.955967},{57.761573,24.415768}}"
    }
    return layersBboxStr as! String
}

/************************************************
 * Lưu đường bao của layer WFS
 * {{westBoundLongitude,southBoundLatitude},{eastBoundLongitude,northBoundLatitude}}
 */
func setLayersBoundingBoxForWFS(layersBboxStr: String) {
    UserDefaults.standard.set(layersBboxStr, forKey: "LayersBoundingBoxForWFS")
    UserDefaults.standard.synchronize()
}

/**
 * Lấy đường bao của layer WFS
 * {{westBoundLongitude,southBoundLatitude},{eastBoundLongitude,northBoundLatitude}}
 */
func getLayersBoundingBoxForWFS() -> String {
    var layersBboxStr = UserDefaults.standard.value(forKey: "LayersBoundingBoxForWFS")
    if !(layersBboxStr is String) {
        layersBboxStr = "{{-124.731422,24.955967},{57.761573,24.415768}}"
    }
    return layersBboxStr as! String
}

/************************************************
 * Lưu đường dẫn hiện tại của map offline (offlineActiveTilesPath)
 * offlineActiveTilesPath 
 */
func setOfflineActiveTilesPath(_ offlineActiveTilesPath: String) {
    UserDefaults.standard.set(offlineActiveTilesPath, forKey: "OfflineActiveTilesPath")
    UserDefaults.standard.synchronize()
}

/**
 * Lấy đường dẫn hiện tại của map offline (activeTilesOfflinePath)
 * activeTilesOfflinePath = "Download01"
 */
func getOfflineActiveTilesPath() -> String {
    var offlineActiveTilesPath = UserDefaults.standard.value(forKey: "OfflineActiveTilesPath")
    if !(offlineActiveTilesPath is String) {
        offlineActiveTilesPath = ""
    }
    return offlineActiveTilesPath as! String
}

/************************************************
 * TRACK_DISTANCE_FILTER
 */
func getTrackDistanceFilter() -> Double {
    guard UserDefaults.standard.object(forKey: "TRACK_DISTANCE_FILTER") != nil else { return 10 }
    return UserDefaults.standard.double(forKey: "TRACK_DISTANCE_FILTER")
}

func setTrackDistanceFilter(_ value: Double) {
    UserDefaults.standard.set(value, forKey: "TRACK_DISTANCE_FILTER")
    UserDefaults.standard.synchronize()
}

/************************************************
 * Chất lượng ảnh lưu
 */
func getImageCompressionQuality() -> Float {
    guard UserDefaults.standard.object(forKey: "IMAGE_COMPRESSION_QUALITY") != nil else { return 0.35 }
    return UserDefaults.standard.float(forKey: "IMAGE_COMPRESSION_QUALITY")
}

func setImageCompressionQuality(_ value: Float) {
    UserDefaults.standard.set(value, forKey: "IMAGE_COMPRESSION_QUALITY")
    UserDefaults.standard.synchronize()
}

/************************************************
 * Hiệu ứng âm thanh
 */
func getEnableSoundEffect() -> Bool {
    guard UserDefaults.standard.object(forKey: "ENABLE_SOUND_EFFECT") != nil else { return true }
    return UserDefaults.standard.bool(forKey: "ENABLE_SOUND_EFFECT")
}

func setEnableSoundEffect(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: "ENABLE_SOUND_EFFECT")
    UserDefaults.standard.synchronize()
}

/************************************************
 * Quangr caos
 */
func getEnableADS() -> Bool {
    guard UserDefaults.standard.object(forKey: "ADS_ENABLED") != nil else { return true }
    return UserDefaults.standard.bool(forKey: "ADS_ENABLED")
}

func setEnableADS(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: "ADS_ENABLED")
    UserDefaults.standard.synchronize()
}

func getSettings(urlString: String) {
    guard let url = URL(string: urlString) else {
        return
    }
    DispatchQueue.main.async { 
        if let data = try? Data(contentsOf: url) {
            let xml = XMLParser(data: data)
            if xml.parse() {
                var options = AEXMLOptions()
                options.parserSettings.shouldProcessNamespaces = false
                options.parserSettings.shouldReportNamespacePrefixes = false
                options.parserSettings.shouldResolveExternalEntities = false
                let xmlDoc = try! AEXMLDocument(xml: data, options: options)
                let settings = xmlDoc.root
                let ads = settings["ads"]
                let server = settings["server"]
                let help = settings["help"]
                if ads.error == nil {
                    ADS_ENABLED = Bool(ads["ads_enabled"].value!)!
                    setEnableADS(ADS_ENABLED)
                }
                if server.error == nil {
                    GEOSERVER_URL = server["geoserver_url"].value!
                }
                if help.error == nil {
                    HELP_EN_URL = help["en_url"].value!
                    HELP_VI_URL = help["vi_url"].value!
                }
            }
        }
    }
}

func createSettings() {
    let xmlDoc = AEXMLDocument()
    let settings = AEXMLElement(name: "settings", attributes: ["version":"1.1","creator":"\(APP_FULL_NAME)"])
    xmlDoc.addChild(settings)
    let ads = AEXMLElement(name: "ads")
    settings.addChild(ads)
    let ads_enabled = AEXMLElement(name: "ads_enabled", value: "true")
    ads.addChild(ads_enabled)
    let server = AEXMLElement(name: "server")
    settings.addChild(server)
    let geoserver_url = AEXMLElement(name: "geoserver_url", value: "http://webgis.humg.edu.vn:8080/geoserver")
    server.addChild(geoserver_url)
    let help = AEXMLElement(name: "help")
    settings.addChild(help)
    let vi_url = AEXMLElement(name: "vi_url", value: "http://gtfield.geomatics.com.vn/vi.html")
    let en_url = AEXMLElement(name: "vi_url", value: "http://gtfield.geomatics.com.vn/index.html")
    help.addChild(en_url)
    help.addChild(vi_url)
    print(xmlDoc.xml)
}

/*
 * Lấy tọa độ mặc định cho mapView
 */
func getDefaultCoordinate2D() -> CLLocationCoordinate2D {
    var latitude:CLLocationDegrees = 16.5
    var longitude:CLLocationDegrees = 105.5
    guard UserDefaults.standard.object(forKey: "DefaultLatitude") != nil else {
        UserDefaults.standard.set(latitude, forKey: "DefaultLatitude")
        UserDefaults.standard.set(longitude, forKey: "DefaultLongitude")
        UserDefaults.standard.synchronize()
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    latitude = UserDefaults.standard.double(forKey: "DefaultLatitude")
    longitude = UserDefaults.standard.double(forKey: "DefaultLongitude")
    
    return CLLocationCoordinate2DMake(latitude, longitude)
}

func setDefaultCoordinate2D(_ location: CLLocationCoordinate2D) {
    UserDefaults.standard.set(location.latitude, forKey: "DefaultLatitude")
    UserDefaults.standard.set(location.longitude, forKey: "DefaultLongitude")
    UserDefaults.standard.synchronize()
}

/************************************************
 * Datum
 */
func getSourceDatumCode() -> String {
    guard UserDefaults.standard.value(forKey: "SOURCE_DATUM_CODE") != nil else {
        return "WGE"
    }
    return UserDefaults.standard.value(forKey: "SOURCE_DATUM_CODE") as! String
}

func setSourceDatumCode(_ value: String) {
    UserDefaults.standard.set(value, forKey: "SOURCE_DATUM_CODE")
    UserDefaults.standard.synchronize()
}

func getTargetDatumCode() -> String {
    guard UserDefaults.standard.value(forKey: "TARGET_DATUM_CODE") != nil else {
        return "WGE"
    }
    return UserDefaults.standard.value(forKey: "TARGET_DATUM_CODE") as! String
}

func setTargetDatumCode(_ value: String) {
    UserDefaults.standard.set(value, forKey: "TARGET_DATUM_CODE")
    UserDefaults.standard.synchronize()
}

// CoordinateType
func getSourceCoordinateType() -> Int {
    guard UserDefaults.standard.object(forKey: "SOURCE_COORDINATE_TYPE") != nil else {
        return 10
    }
    return UserDefaults.standard.integer(forKey: "SOURCE_COORDINATE_TYPE")
}

func setSourceCoordinateType(_ value: Int) {
    UserDefaults.standard.set(value, forKey: "SOURCE_COORDINATE_TYPE")
    UserDefaults.standard.synchronize()
}

func getTargetCoordinateType() -> Int {
    guard UserDefaults.standard.object(forKey: "TARGET_COORDINATE_TYPE") != nil else {
        return 35
    }
    return UserDefaults.standard.integer(forKey: "TARGET_COORDINATE_TYPE")
}

func setTargetCoordinateType(_ value: Int) {
    UserDefaults.standard.set(value, forKey: "TARGET_COORDINATE_TYPE")
    UserDefaults.standard.synchronize()
}

// HeightType
func getSourceHeightType() -> Int {
    guard UserDefaults.standard.object(forKey: "SOURCE_HEIGHT_TYPE") != nil else {
        return 0
    }
    return UserDefaults.standard.integer(forKey: "SOURCE_HEIGHT_TYPE")
}

func setSourceHeightType(_ value: Int) {
    UserDefaults.standard.set(value, forKey: "SOURCE_HEIGHT_TYPE")
    UserDefaults.standard.synchronize()
}

func getTargetHeightType() -> Int {
    guard UserDefaults.standard.object(forKey: "TARGET_HEIGHT_TYPE") != nil else {
        return 0
    }
    return UserDefaults.standard.integer(forKey: "TARGET_HEIGHT_TYPE")
}

func setTargetHeightType(_ value: Int) {
    UserDefaults.standard.set(value, forKey: "TARGET_HEIGHT_TYPE")
    UserDefaults.standard.synchronize()
}

// Displaying
func getAreaUnit() -> Int {
    guard UserDefaults.standard.object(forKey: "AREA_UNIT") != nil else {
        return 0
    }
    return UserDefaults.standard.integer(forKey: "AREA_UNIT")
}

func setAreaUnit(_ value: Int) {
    UserDefaults.standard.set(value, forKey: "AREA_UNIT")
    UserDefaults.standard.synchronize()
}

func getDistanceUnit() -> Int {
    guard UserDefaults.standard.object(forKey: "DISTANCE_UNIT") != nil else {
        return 0
    }
    return UserDefaults.standard.integer(forKey: "DISTANCE_UNIT")
}

func setDistanceUnit(_ value: Int) {
    UserDefaults.standard.set(value, forKey: "DISTANCE_UNIT")
    UserDefaults.standard.synchronize()
}

func getLatLngFormat() -> Int {
    guard UserDefaults.standard.object(forKey: "LAT_LNG_FORMAT") != nil else {
        return 0
    }
    return UserDefaults.standard.integer(forKey: "LAT_LNG_FORMAT")
}

func setLatLngFormat(_ value: Int) {
    UserDefaults.standard.set(value, forKey: "LAT_LNG_FORMAT")
    UserDefaults.standard.synchronize()
}

func getMapGridFormat() -> Int {
    guard UserDefaults.standard.object(forKey: "MapGridFormat") != nil else {
        return 0
    }
    return UserDefaults.standard.integer(forKey: "MapGridFormat")
}

func setMapGridFormat(_ value: Int) {
    UserDefaults.standard.set(value, forKey: "MapGridFormat")
    UserDefaults.standard.synchronize()
}


/*
 * Lấy Index trong CrsItems
 */
func getCrsIndex() -> Int {
    guard UserDefaults.standard.object(forKey: "CrsIndex") != nil else {
        return 0
    }
    return UserDefaults.standard.integer(forKey: "CrsIndex")
}

func setCrsIndex(_ value: Int) {
    UserDefaults.standard.set(value, forKey: "CrsIndex")
    UserDefaults.standard.synchronize()
}

/*
 * Lấy Index trong DatumItems
 */
func getDatumIndex() -> Int {
    guard UserDefaults.standard.object(forKey: "DatumIndex") != nil else {
        return 0
    }
    return UserDefaults.standard.integer(forKey: "DatumIndex")
}

func setDatumIndex(_ value: Int) {
    UserDefaults.standard.set(value, forKey: "DatumIndex")
    UserDefaults.standard.synchronize()
}


/*
 * Lấy custom crs proj4 string
 */
func getCustomCrsProj4String() -> String {
    guard UserDefaults.standard.object(forKey: "CustomCrsProj4String") != nil else {
        return "+proj_code=34 +ellps_code=WE +proj=utm +zone=48 +ellps=WGS84 +datum=WGE +units=m +no_defs"
    }
    return UserDefaults.standard.string(forKey: "CustomCrsProj4String")!
}

func setCustomCrsProj4String(_ value: String) {
    UserDefaults.standard.set(value, forKey: "CustomCrsProj4String")
    UserDefaults.standard.synchronize()
}

/*
 * Lấy custom projection: dùng trong trường hợp người dùng tự định nghĩa để thiết lập
 */
func getCustomMapProjectionType() -> Int {
    guard UserDefaults.standard.object(forKey: "CustomMapProjectionType") != nil else {
        return 34
    }
    return UserDefaults.standard.integer(forKey: "CustomMapProjectionType")
}

func setCustomMapProjectionType(_ value: Int) {
    UserDefaults.standard.setValue(value, forKey: "CustomMapProjectionType")
    UserDefaults.standard.synchronize()
}

/*
 * Lấy custom ellipsoid proj4 string
 */
func getCustomEllpsProj4String() -> String {
    guard UserDefaults.standard.object(forKey: "CustomEllpsProj4String") != nil else {
        return "+ellps_code=99 +a=6378137.0 +rf=298.257223563 +no_defs"
    }
    return UserDefaults.standard.string(forKey: "CustomEllpsProj4String")!
}

func setCustomEllpsProj4String(_ value: String) {
    UserDefaults.standard.set(value, forKey: "CustomEllpsProj4String")
    UserDefaults.standard.synchronize()
}

/*
 * Lấy custom datum proj4 string
 */
func getCustomDatumProj4String() -> String {
    guard UserDefaults.standard.object(forKey: "CustomDatumProj4String") != nil else {
        return "+datum=9999 +towgs84=0,0,0,0,0,0,0 +no_defs"
    }
    return UserDefaults.standard.string(forKey: "CustomDatumProj4String")!
}

func setCustomDatumProj4String(_ value: String) {
    UserDefaults.standard.set(value, forKey: "CustomDatumProj4String")
    UserDefaults.standard.synchronize()
}

/*
 * Lấy Index trong EllipsoidItems
 */
func getEllipsoidIndex() -> Int {
    guard UserDefaults.standard.object(forKey: "EllipsoidIndex") != nil else {
        return 0
    }
    return UserDefaults.standard.integer(forKey: "EllipsoidIndex")
}

func setEllipsoidIndex(_ value: Int) {
    UserDefaults.standard.set(value, forKey: "EllipsoidIndex")
    UserDefaults.standard.synchronize()
}

/*
 * Lấy Pro version
 */
func getProVersion() -> Bool {
    guard UserDefaults.standard.object(forKey: "ProVersion") != nil else {
        return false
    }
    return UserDefaults.standard.bool(forKey: "ProVersion")
}

func setProVersion(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: "ProVersion")
    UserDefaults.standard.synchronize()
}

/*
 * Lấy Donate
 */
func getDonated() -> Bool {
    guard UserDefaults.standard.object(forKey: "Donated") != nil else {
        return false
    }
    return UserDefaults.standard.bool(forKey: "Donated")
}

func setDonated(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: "Donated")
    UserDefaults.standard.synchronize()
}

/*
 * Lấy Unlimited
 */
func getUnlimited() -> Bool {
    guard UserDefaults.standard.object(forKey: "Unlimited") != nil else {
        return false
    }
    return UserDefaults.standard.bool(forKey: "Unlimited")
}

func setUnlimited(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: "Unlimited")
    UserDefaults.standard.synchronize()
}

/*
 * buttonRecordingMainButtonisHidden
 */
func getRecordingMainButtonisHidden() -> Bool {
    guard UserDefaults.standard.object(forKey: "buttonRecordingMainButtonisHidden") != nil else {
        return true
    }
    return UserDefaults.standard.bool(forKey: "buttonRecordingMainButtonisHidden")
}

func setRecordingMainButtonisHidden(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: "buttonRecordingMainButtonisHidden")
    UserDefaults.standard.synchronize()
}

func getRecordMainButtonisHidden() -> Bool {
    guard UserDefaults.standard.object(forKey: "buttonRecordMainButtonisHidden") != nil else {
        return false
    }
    return UserDefaults.standard.bool(forKey: "buttonRecordMainButtonisHidden")
}

func setRecordMainButtonisHidden(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: "buttonRecordMainButtonisHidden")
    UserDefaults.standard.synchronize()
}

/*
 * buttonPausedMainButtonisHidden
 */
func getPausedMainButtonisHidden() -> Bool {
    guard UserDefaults.standard.object(forKey: "buttonPausedMainButtonisHidden") != nil else {
        return true
    }
    return UserDefaults.standard.bool(forKey: "buttonPausedMainButtonisHidden")
}

func setPausedMainButtonisHidden(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: "buttonPausedMainButtonisHidden")
    UserDefaults.standard.synchronize()
}



