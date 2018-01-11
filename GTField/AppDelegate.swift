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
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    
    let motionManager = CMMotionManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        self.window?.makeKeyAndVisible()
        
        if !getAgreement() {
            agreement()
        }
        
        getSettings(urlString: "http://gtfield.geomatics.com.vn/settings.xml")
        self.window?.rootViewController?.enumerateHierarchy { viewController in
            guard var container = viewController as? MotionContainer else { return }
            container.motionManager = motionManager
            //container.locationManager = locationManager
        }
        print(Bundle.main.bundlePath)
        print(docsURL.path)

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
        
        SKPaymentQueue.default().add(self)
        SubscriptionService.shared.loadSubscriptionOptions()
        
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
        case kGPXFileExt:
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
                        let alert = UIAlertController(title: "Your file \"\(gpxURL.lastPathComponent)\" was copied to app's GPX folder.", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: nil))
                        alert.show()
                    }
                } else {
                    let alert = UIAlertController(title: "Ooops! Something went wrong: \(error)", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: nil))
                    alert.show()
                }
            }
            break
        case kMBTileFileExt:
            let mbtileDB = MBTileDB(path: url.path)
            if mbtileDB.isDBOpen {
                let format = mbtileDB.metadataValueFor(name: "format")
                if format.lowercased().length != 0 && (format.lowercased() != "png" && format.lowercased() != "jpg") {
                    let alert = UIAlertController(title: NSLocalizedString("This format", comment: "")+" \"\(format)\" "+NSLocalizedString("does not support", comment: ""), message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: nil))
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
                            let alert = UIAlertController(title: NSLocalizedString("Your file", comment: "")+" \"\(url.lastPathComponent)\" "+NSLocalizedString("was copied to GTField documents folder with the new name", comment: "")+" \"\(mbtilesURL.lastPathComponent)\".", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: nil))
                            alert.show()
                        } catch {
                            let alert = UIAlertController(title: NSLocalizedString("Ooops! Something went wrong:", comment: "")+" \(error)", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: nil))
                            alert.show()
                        }
                    }
                }
            }
            break
        case kKmlFileExt:
            let kmlURL = docsURL.appendingPathComponent(url.lastPathComponent)
            do {
                try FileManager.default.copyItem(at: url, to: kmlURL)
                let alert = UIAlertController(title: NSLocalizedString("Your file", comment: "")+" \"\(url.lastPathComponent)\" "+NSLocalizedString("was copied to GTField documents folder with the new name", comment: "")+" \"\(kmlURL.lastPathComponent)\".", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: nil))
                alert.show()
            } catch {
                let alert = UIAlertController(title: NSLocalizedString("Ooops! Something went wrong:", comment: "")+" \(error)", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: nil))
                alert.show()
            }
            break
        case kGeoJSONExt, kGeoJSONExt1:
            let jsonURL = docsURL.appendingPathComponent(url.lastPathComponent)
            do {
                try FileManager.default.copyItem(at: url, to: jsonURL)
                let alert = UIAlertController(title: NSLocalizedString("Your file", comment: "")+" \"\(url.lastPathComponent)\" "+NSLocalizedString("was copied to GTField documents folder with the new name", comment: "")+" \"\(jsonURL.lastPathComponent)\".", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: nil))
                alert.show()
            } catch {
                let alert = UIAlertController(title: NSLocalizedString("Ooops! Something went wrong:", comment: "")+" \(error)", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: nil))
                alert.show()
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
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

// Agreement
func agreement() {
    let alert = UIAlertController(title: NSLocalizedString("Agreement", comment: ""),
                                  message: NSLocalizedString("Terms of Use", comment: ""),
                                  preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .destructive, handler: { (action: UIAlertAction!) in
        setAgreement(false)
        exit(0)
    }))
    alert.addAction(UIAlertAction(title: NSLocalizedString("Agree", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
        setAgreement(true)
    }))
    alert.show()
}
// MARK: - SKPaymentTransactionObserver

extension AppDelegate: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
    
    func paymentQueue(_ queue: SKPaymentQueue,
                      updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                handlePurchasingState(for: transaction, in: queue)
            case .purchased:
                handlePurchasedState(for: transaction, in: queue)
            case .restored:
                handleRestoredState(for: transaction, in: queue)
            case .failed:
                handleFailedState(for: transaction, in: queue)
            case .deferred:
                handleDeferredState(for: transaction, in: queue)
            }
        }
    }
    
    func handlePurchasingState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User is attempting to purchase product id: \(transaction.payment.productIdentifier)")
    }
    
    func handlePurchasedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User purchased product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        if transaction.payment.productIdentifier.contains("Unlimited") {
            setUnlimited(true)
            setProVersion(true)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: SubscriptionService.activeNotification, object: nil)
            }
        } else {
            SubscriptionService.shared.uploadReceipt { (success) in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: SubscriptionService.purchaseSuccessfulNotification, object: nil)
                }
            }
        }
    }
    
    func handleRestoredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase restored for product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        if transaction.payment.productIdentifier.contains("Unlimited") {
            setUnlimited(true)
            setProVersion(true)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: SubscriptionService.activeNotification, object: nil)
            }
        } else {
            SubscriptionService.shared.uploadReceipt { (success) in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: SubscriptionService.restoreSuccessfulNotification, object: nil)
                }
            }
        }
    }
    
    func handleFailedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase failed for product id: \(transaction.payment.productIdentifier)")
        setProVersion(false)
        print("setProVersion(false)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: SubscriptionService.inactiveNotification, object: nil)
        }
    }
    
    func handleDeferredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase deferred for product id: \(transaction.payment.productIdentifier)")
    }
}


