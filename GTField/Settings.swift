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


