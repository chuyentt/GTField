//  Config.swift
//  appyMap
//
//  Created by AppyStudio 09/2015
//  Copyright (c) 2015 Nicola Canali. All rights reserved.

import UIKit
import Foundation
import MapKit
import GeoTrans

let RAD2DEG = (180.0/Double.pi)
let DEG2RAD = (Double.pi/180.0)

let itcAccountSecret = "3ac723f53d704e0483bc8bf17da8a449"

// -----------------------------------------
// Test the Template
// -----------------------------------------

// In order to test the routes on a simulator, you need to simulate your location.
// To do this, open the simulator and go to Debug -> Location -> Custom Location...
// here you can enter a Latitude and Longitude for the location you want to simulate.


// -----------------------------------------
// General variables
// -----------------------------------------

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

let APP_NAME: String = "GTField";
let APP_VERSION: String = Bundle.main.releaseVersionNumber!
let APP_BUILD: String = Bundle.main.buildVersionNumber!
let APP_WEBSITE: String = "https://gtfield.rbc.vn"
let APP_FULL_NAME: String = APP_NAME + " v" + APP_VERSION + " (build " + APP_BUILD + ")"

let TEXTVIEW_FONT_DEFAULT: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
//UIFont(name: "Bauhaus-Light", size: 17.0)!
let TEXTVIEW_FONT_EDIT: UIFont = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
//UIFont(name: "Bauhaus-Medium", size: 17.0)!
let TITLE_FONT_DEFAULT: UIFont = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
//UIFont(name: "Bauhaus-Medium", size: 22.0)!
let TEXTVIEW_TEXT_COLOR_DEFAULT: UIColor = UIColor.darkGray

let BAR_TINT_COLOR_DEFAULT: UIColor = UIColor(red: (82.0/255.0), green: (172.0/255.0), blue: (238.0/255.0), alpha: 1.0)

var IMAGE_COMPRESSION_QUALITY: Float = getImageCompressionQuality()
let IMAGE_CROP_TO_SIZE: CGSize = CGSize(width: 1280, height: 960)

var TRACK_DISTANCE_FILTER: Double = getTrackDistanceFilter()
let ELEVATION_COLOR_SPANS = 750.0 // Hệ số dùng để span polyline theo độ cao

var ENABLE_SOUND_EFFECT: Bool = getEnableSoundEffect()
var ENABLE_RULER_BAR: Bool = getEnableRulerBar()
var ENABLE_MAP_CENTER_COORDINATE: Bool = getEnableMapCenterCoordinate()

var ENABLE_IMPROVED_PERFORMANCE: Bool = getEnableImprovedPerformance()

var INTERNET_AVAILABLE: Bool = false
var WIFI_AVAILABLE: Bool = false

var HELP_EN_URL: String = "https://gtfield.rbc.vn/index.html"
var HELP_VI_URL: String = "https://gtfield.rbc.vn/vi.html"

var ABOUT_EN_URL: String = "https://gtfield.rbc.vn/abouten.html"
var ABOUT_VI_URL: String = "https://gtfield.rbc.vn/aboutvi.html"
var TERMS_OF_USE_EN_URL: String = "https://gtfield.rbc.vn/terms-en.html"
var TERMS_OF_USE_VI_URL: String = "https://gtfield.rbc.vn/terms-vi.html"

let docsURL = applicationDocumentsDirectory()
var MB_TILES_PATH: String = docsURL.appendingPathComponent("tiles.mbtiles").path
var MB_TILES_CACHED: String = docsURL.appendingPathComponent(TILE_CACHED).appendingPathComponent("cached.mbtiles").path

let MB_TILES_VERSION = "1.2"
var DOWNLOADING_PATH_TO_DATABASE: String = ""

// maximum number of vertices editable
let MAX_N_VERTICES_EDITABLE = 100

// Feature gate: true chỉ trong DEBUG build (simulator / development device).
// Trong Release build (Archive → App Store), isDebug = false → gate IAP hoạt động đúng.
#if DEBUG
let isDebug = true
#else
let isDebug = false
#endif

// Độ cao mylocation
var myAltitude = 0.0

// -------------------------------------------------------------------
// Customize Navigation Bar (Main)
// -------------------------------------------------------------------
func configMainView() {
    // Customize Navigation Bar
    UINavigationBar.appearance().barTintColor = BAR_TINT_COLOR_DEFAULT
    UINavigationBar.appearance().tintColor = UIColor.white
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

//    let font = UIFont(name: ".SFUIText-Light", size: UIFont.systemFontSize)
//
//    if let font = font {
//        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.white]
//    }
//
//    let fontButton = UIFont(name: ".SFUIText-Light", size: UIFont.systemFontSize)
//
//    if let fontButton = fontButton {
//        UIBarButtonItem.appearance().setTitleTextAttributes(
//            [
//                NSAttributedString.Key.font : fontButton,
//                NSAttributedString.Key.foregroundColor : UIColor.white
//            ],
//            for: .normal)
//    }
    
    // Tạo thư mục cần thiết
    _ = createDirectoryAtURL(url: applicationDocumentsDirectory().appendingPathComponent(TILE_CACHED))
    _ = createDirectoryAtURL(url: applicationDocumentsDirectory().appendingPathComponent("Photos"))
}

// -------------------------------------------------------------------
// Customize Navigation Bar (MapView)
// -------------------------------------------------------------------
func configMapView() {
    
}


// -------------------------------------------------------------------
// CloudKit or Plist
// -------------------------------------------------------------------

// true = Use ClouKit - false = Use Plist files (See User Guide)
// YOU MUST BE LOGGED in an iCloud account (in the simulator and/or in a real device)
// in order to use iCloud services (CloudKit)
let USE_CLOUDKIT = false


// -----------------------------------------
// In App Purchase
// -----------------------------------------

let IAP_ID: String = "vn.geomatics.GTField"


// -------------------------------------------------------------------
// Ads Settings
// -------------------------------------------------------------------

// Enable/Disable Ads.
var ADS_ENABLED = getEnableADS()

// -------------------------------------------------------------------
// AdMob Settings
// -------------------------------------------------------------------

// Replace the string below with the unit id you've got
// by registering your App on AdMob
// GTField:
//  App ID: ca-app-pub-9906627814658770~4067421272
//  Ad unit ID: ca-app-pub-9906627814658770/5544154475
let ADMOB_UNIT_ID_Banner        = "ca-app-pub-9906627814658770/5544154475"
let ADMOB_UNIT_ID_Interstitial  = "ca-app-pub-9906627814658770/5403877649"
// Rewarded Ad — dùng cho "Xem quảng cáo để xuất DXF/CSV/KML".
// GTField Rewarded: ca-app-pub-9906627814658770/2106619310
let ADMOB_UNIT_ID_Rewarded      = "ca-app-pub-9906627814658770/2106619310"


// -------------------------------------------------------------------
// DEFAULT MAP NAVIGATION MODE
//
// "w" - by foot
// "d" - by car
// "r" - by public transit
//

let NAV_MODE = "w"


// -------------------------------------------------------------------
// Show / Hide Refresh button in Home Screen

// Set true to enable the Refresh button in home screen
// Useful in developing mode when you make changes in CloudKit
// -------------------------------------------------------------------

let REFRESH_BTN_ENABLED = false

let INFO_BTN_ENABLED = false;

// -------------------------------------------------------------------
// GoogleMaps API Key

internal let kPlacesAPIKey = "AIzaSyBZTtATG9vQgzNhRxC-eW2Xjd8FQP6dKu8"
internal let kMapsAPIKey = "AIzaSyCWRBoYjGfOfn1OqrtA0UqrcCT9a8ihoMA"
//AIzaSyCPAyi6abAMsjwwbVXwFKEypJERFyZoqj4
//AIzaSyBf9TDGs2ibhXl2-SozWiDf84enzYXtVxo

// ----------------------------------------------------------------------------------------------
// Here you must specify the NAME of the PLIST files for every main button
//
// NOTE: if the name of the file begin with "Section", the app
// will know that this is a section, and will show the view controller
// with the list of the section.
//
// Otherwise, the app will show the Poi view controller directly.
//
// See the example below and the plist file on this project as reference:

let PLIST_MAIN_1 = "SectionCulture"         // THIS IS A LIST OF SUBSECTIONS (start with "Section")
let PLIST_MAIN_2 = "SectionThings"          // THIS IS A LIST OF SUBSECTIONS (start with "Section")
let PLIST_MAIN_3 = "SectionInfo"            // THIS IS A LIST OF SUBSECTIONS (start with "Section")
let PLIST_MAIN_4 = "Services"               // THIS IS A LIST OF POINTS OF INTEREST (because doesn't start with "Section")

// ----------------------------------------------------------------------------------------------


// Here you can choose the default view for sections and poi:
// "List" or "Map"

let DEFAULT_SECTION_VIEW = "List"
let DEFAULT_POI_VIEW = "Map"




// ----------------------------------------------------------------------------------------------
// Center Map

let CENTER_MAP_LAT = 43.844000 as CLLocationDegrees
let CENTER_MAP_LON = 10.505000 as CLLocationDegrees


// ----------------------------------------------------------------------------------------------
// GeoServer Url
// var GEOSERVER_URL = "https://webgis.humg.edu.vn:8080/geoserver"
var GEOSERVER_URL = "https://openwms.statkart.no/skwms1/wms.norges_grunnkart"

// ----------------------------------------------------------------------------------------------
// OfflineTiles
let OFFLINE_TILES = "OfflineTiles"

// ----------------------------------------------------------------------------------------------
// TileCached
let TILE_CACHED: String = "TileCached"

// ----------------------------------------------------------------------------------------------
// CachedName
let CACHED_NAME = "WMS"


// ----------------------------------------------------------------------------------------------
// Zoom Map

// 320 PIXEL
let SCREEN_320_LAT = 0.055 as CLLocationDegrees
let SCREEN_320_LON = 0.055 as CLLocationDegrees

// 375 PIXEL
let SCREEN_375_LAT = 0.050 as CLLocationDegrees
let SCREEN_375_LON = 0.050 as CLLocationDegrees

// 414 PIXEL
let SCREEN_414_LAT = 0.045 as CLLocationDegrees
let SCREEN_414_LON = 0.045 as CLLocationDegrees

// iPad
let SCREEN_IPAD_LAT = 0.025 as CLLocationDegrees
let SCREEN_IPAD_LON = 0.025 as CLLocationDegrees

// Zoom Level on Detail View
let DETAIL_ZOOM_LAT = 0.005 as CLLocationDegrees
let DETAIL_ZOOM_LON = 0.005 as CLLocationDegrees

let DEGREE_TO_RADIAN = Double.pi/180.0
let RADIAN_TO_DEGREE = 180.0/Double.pi

let DETAIL_MAP_TYPE = MKMapType.standard

// GeoTrans
let geotrans = GeoTrans()
