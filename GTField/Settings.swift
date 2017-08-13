//
//  Settings.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 6/11/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import Foundation
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
/*
     0	AC	Albers Equal Area Conic
     1	AL	Azimuthal Equidistant (S)
     2	BF	Bonne
     3	BN	British National Grid (BNG)
     4	CP	Equidistant Cylindrical (S)
     5	CS	Cassini
     6	ED	Eckert VI (S)
     7	EF	Eckert IV (S)
     8	GA	Global Area Reference System (GARS)
     9	GC	Geocentric
     10	GD	Geodetic
     11	GE	GEOREF
     12	GN	Gnomonic (S)
     13	L1	Lambert Conformal Conic (1 Standard Parallel)
     14	L2	Lambert Conformal Conic (2 Standard Parallel)
     15	LC	Local Cartesian
     16	LI	Cylindrical Equal Area
     17	MC	Mercator (Standard Parallel)
     18	MF	Mercator (Scale Factor)
     19	MG	Military Grid Reference System (MGRS)
     20	MH	Miller Cylindrical (S)
     21	MP	Mollweide (S)
     22	NT	New Zealand Map Grid (NZMG)
     23	NY	Ney's (Modified Lambert Conformal Conic)
     24	OC	Oblique Mercator
     25	OD	Orthographic (S)
     26	PF	Polar Stereographic (Scale Factor)
     27	PG	Polar Stereographic (Standard Parallel)
     28	PH	Polyconic
     29	SA	Sinusoidal
     30	SD	Stereographic (S)
     31	TC	Transverse Mercator
     32	TX	Transverse Cylindrical Equal Area
     33	UP	Universal Polar Stereographic (UPS)
     34	US	United States National Grid (USNG)
     35	UT	Universal Transverse Mercator (UTM)
     36	VA	Van der Grinten
     37	WM	Web Mercator
 */
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
