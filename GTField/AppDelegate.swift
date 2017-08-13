//
//  AppDelegate.swift
//  appyMap
//
//  Created by AppyStudio on 09/2015.
//  Copyright (c) 2015 Nicola Canali. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreMotion
//import AEXML
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    
    let motionManager = CMMotionManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        self.window?.makeKeyAndVisible()
        getSettings(urlString: "http://gtfield.geomatics.com.vn/settings.xml")
        self.window?.rootViewController?.enumerateHierarchy { viewController in
            guard var container = viewController as? MotionContainer else { return }
            container.motionManager = motionManager
            //container.locationManager = locationManager
        }
        
//        //
//        let geotrans = GeoTrans("WGE", "WGE")
//        var x: Double = 0.0
//        var y: Double = 0.0
//        var z: Double = 0.0
//        let lat = 21.0*DEGREE_TO_RADIAN
//        let lon = 105.0*DEGREE_TO_RADIAN
//        let height = 0.0
//
//        geotrans?.llh2XYZ(lat, lon, height, &x, &y, &z)
//        geotrans?.setTargetDatumCode("VN-2")
//        print(x,y,z)
//        var zone: CLong = 0
//        var hemi: NSString? = nil
//        var easting: Double = 0.0
//        var northing: Double = 0.0
//        geotrans?.geocentric2UTM(x, y, z, &zone, &hemi, &easting, &northing)
//        print(zone, hemi!, easting, northing)
//        
////        -1612214.53349457 5731088.48380319 2280518.7887406
////        -1204283.11169226 4281699.65429547 1703872.61206855
////        let wrapperItem = GeoTrans()
////        wrapperItem.sayHello()
////        
////        wrapperItem.testCoordinateConversion()
////        let s = wrapperItem.datumName(for: "WGE")
////        print(s!)
        // Xử lý các thay đổi từ phiên bản cũ
        migration()
        
        // Customize Navigation Bar
        configMainView()

        // Do a quick check to see if you've provided an API key, in a real app you wouldn't need this
        // but for the demo it means we can provide a better error message if you haven't.
        if kMapsAPIKey.isEmpty || kPlacesAPIKey.isEmpty {
            // Blow up if API keys have not yet been set.
            let bundleId = Bundle.main.bundleIdentifier!
            let msg = "Configure API keys inside SDKDemoAPIKey.swift for your  bundle `\(bundleId)`, " +
            "see README.GooglePlacePickerDemos for more information"
            fatalError(msg)
        }
        
        // Provide the Places API with your API key.
        GMSPlacesClient.provideAPIKey(kPlacesAPIKey)
        // Provide the Maps API with your API key. We need to provide this as well because the Place
        // Picker displays a Google Map.
        GMSServices.provideAPIKey(kMapsAPIKey)
        
        FirebaseApp.configure()
        
        return true
    }

    // Xử lý các thay đổi từ phiên bản cũ
    func migration() {
        // Phiên bản 1.0 và 1.0.1 được thiết kế thư mục cho dữ liệu GPX, nên phải chuyển các file qua thư mục gốc docsURL và xóa thư mục GPX
        let gpxURL = docsURL.appendingPathComponent("GPX")
        let files = fileListFromDocs(subPath: "GPX", ext: "gpx") as! [String]
        for item in files {
            do {
                try FileManager.default.moveItem(at: gpxURL.appendingPathComponent(item), to: docsURL.appendingPathComponent(item))
            } catch {
                
            }
        }
        
        // Xóa thư mục GPX nếu có
        do {
            try FileManager.default.removeItem(atPath: gpxURL.path)
        }
        catch {
            
        }
        
        // Xóa thư mục OFFLINE_TILES nếu có
        do {
            try FileManager.default.removeItem(atPath: docsURL.appendingPathComponent(OFFLINE_TILES).path)
        }
        catch {
            
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // Kiểm tra xem xml có bị lỗi không
        let ext = url.pathExtension
        switch ext {
        case "gpx":
            let data = try! Data.init(contentsOf: url)
            let xml = XMLParser(data: data)
            if xml.parse() {
                var options = AEXMLOptions()
                options.parserSettings.shouldProcessNamespaces = false
                options.parserSettings.shouldReportNamespacePrefixes = false
                options.parserSettings.shouldResolveExternalEntities = false
                let xmlDoc = try! AEXMLDocument(xml: data, options: options)
                let gpxRoot = xmlDoc["gpx"]
                if (gpxRoot.error == nil) {
                    let fileName = url.deletingPathExtension().lastPathComponent
                    var gpxURL = createDocumentFileFor(subPath: "", fileName: fileName, ext: "gpx")
                    var counter = 0
                    while FileManager.default.fileExists(atPath: gpxURL.path) {
                        counter += 1
                        gpxURL = createDocumentFileFor(subPath: "", fileName: "\(fileName)(\(counter))", ext: "gpx")
                    }
                    // Kiểm tra xem có metadata hay không
                    let metadataElement = gpxRoot["metadata"]
                    if metadataElement.error == nil {
                        // Kiểm tra xem có thông tin cần thiết hay không
                        let now = Date()
                        let _name = AEXMLElement(name: "name", value: gpxURL.lastPathComponent)
                        let _time = AEXMLElement(name: "time", value: now.iso8601)
                        let _desc = AEXMLElement(name: "desc", value: "Imported")
                        
                        if metadataElement["name"].error != nil {
                            metadataElement.addChild(_name)
                        } else {
                            metadataElement["name"].value = gpxURL.lastPathComponent
                        }
                        if metadataElement["desc"].error != nil {
                            metadataElement.addChild(_desc)
                        } else if metadataElement["desc"].value?.length == 0 {
                            metadataElement["desc"].value = "Imported"
                        }
                        if metadataElement["time"].error != nil {
                            metadataElement.addChild(_time)
                        } else if metadataElement["time"].value?.length == 0 {
                            metadataElement["time"].value = now.iso8601
                        }
                    } else {
                        // Nếu không có thì tạo mới
                        let metadata = GPXMetadata()
                        gpxRoot.addChild(metadata.root)
                    }
                    print(metadataElement.xml)
                    do {
                        try! xmlDoc.xml.write(toFile: gpxURL.path, atomically: true, encoding: .utf8)
                        
                        let alert = UIAlertView(title: "Your file \"\(gpxURL.lastPathComponent)\" was copied to app's GPX folder.", message: nil, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                } else {
                    let alert = UIAlertView(title: "Ooops! Something went wrong: \(error)", message: nil, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
            break
        case kMBTileFileExt:
            let mbtileDB = MBTileDB(path: url.path)
            if mbtileDB.isDBOpen {
                let format = mbtileDB.metadataValueFor(name: "format")
                if format.lowercased() != "png" && format.lowercased() != "jpg" {
                    let alert = UIAlertView(title: "This format \"\(format)\" does not support", message: nil, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                } else {
                    let bounds = mbtileDB.metadataValueFor(name: "bounds")
                    let arrbounds:Array = bounds.components(separatedBy: ",")
                    let center = mbtileDB.metadataValueFor(name: "center")
                    let arrcenter:Array = center.components(separatedBy: ",")
                    if arrbounds.count == 4 || arrcenter.count == 2 {
                        if mbtileDB.metadataValueFor(name: "description").length == 0 {
                            mbtileDB.saveToMetadata(name: "description", value: "Imported by GTField")
                        }
                        // Tạo tên file mặc định tự tăng
                        let fileName = "Import"
                        var tileName = fileName
                        var mbtilesURL = docsURL.appendingPathComponent(tileName).appendingPathExtension(kMBTileFileExt)
                        var counter = 0
                        while FileManager.default.fileExists(atPath: mbtilesURL.path) {
                            counter += 1
                            tileName = "\(fileName)\(counter)"
                            mbtilesURL = docsURL.appendingPathComponent(tileName).appendingPathExtension(kMBTileFileExt)
                        }
                        if mbtileDB.metadataValueFor(name: "name").length == 0 {
                            mbtileDB.saveToMetadata(name: "name", value: tileName)
                        }
                        do {
                            try FileManager.default.copyItem(at: url, to: mbtilesURL)
                            let alert = UIAlertView(title: "Your file \"\(url.lastPathComponent)\" was copied to GTField documents folder with the new name \"\(mbtilesURL.lastPathComponent)\".", message: nil, delegate: nil, cancelButtonTitle: "OK")
                            alert.show()
                        } catch {
                            let alert = UIAlertView(title: "Ooops! Something went wrong: \(error)", message: nil, delegate: nil, cancelButtonTitle: "OK")
                            alert.show()
                        }
                    }
                }
            }
            break
        default:
            break
        }
        if FileManager.default.fileExists(atPath: url.path) {
            try! FileManager.default.removeItem(at: url)
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

