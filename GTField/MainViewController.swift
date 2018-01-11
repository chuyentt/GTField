//
//  MainViewController.swift
//  appyMap Template
//
//  Created by AppyStudio 09/2015
//  Copyright (c) 2015 Nicola Canali. All rights reserved.
//


import UIKit
import Foundation
import Firebase
import CloudKit
import StoreKit
import CoreMotion


class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate, MotionContainer {

    var motionManager: CMMotionManager?
    
    @IBOutlet var imgLogo: SpringImageView!
    @IBOutlet var btnRefresh: UIBarButtonItem!
    @IBOutlet var btnInfo: UIBarButtonItem!
    @IBOutlet weak var inlineLogo: UIImageView!
    
    var mapViewController: MapViewController?
    
    @IBOutlet var myCollectionView: UICollectionView!
    var mainSectionsArray = NSArray()

    var list = [SKProduct]()
    var p = SKProduct()
    
    let userDefaults = UserDefaults.standard
    var adMobBannerView = GADBannerView()
    
    @IBOutlet var heightBackground: NSLayoutConstraint!
    
    init() {
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = APP_FULL_NAME
        
        if REFRESH_BTN_ENABLED == false {
            btnRefresh.tintColor = UIColor.clear
            btnRefresh.isEnabled = false
        }
        
        if INFO_BTN_ENABLED == false {
            btnInfo.tintColor = UIColor.clear
            btnInfo.isEnabled = false
        }
        
        if USE_CLOUDKIT {
            querySections() // Query CloudKit
        } else {
            queryPlist()    // Query Plist
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleActive(notification:)),
                                               name: SubscriptionService.activeNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInactive(notification:)),
                                               name: SubscriptionService.inactiveNotification,
                                               object: nil)
        
        guard SubscriptionService.shared.currentSessionId != nil,
            SubscriptionService.shared.hasReceiptData else {
                SubscriptionService.shared.restorePurchases()
                return
        }
    }

    @objc func handleActive(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.inlineLogo.image = #imageLiteral(resourceName: "Inline-Logo-Pro")
            self?.adMobBannerView.removeFromSuperview()
        }
    }
    
    @objc func handleInactive(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.inlineLogo.image = #imageLiteral(resourceName: "Inline-Logo")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startUpdateMotion()
        
        imgLogo.alpha = 1

        if ADS_ENABLED && !getProVersion() {
                //heightBackground.constant = 50
                initAdMobBanner()
        } else {
            //heightBackground.constant = 0
        }
        self.statusBarStyle = .lightContent
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopUpdateMotion()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        /*
         Các thiết bị hỗ trợ iOS 10
         *iPhone 640×1136
         *iPhone 750×1334
         *iPhone 1080×1920
         *iPhone 1125×2436
         *iPad 1536×2048
         *iPad 1668×2224
         *iPad 2048×2732
         */
        myCollectionView.reloadData()
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    var statusBarStyle: UIStatusBarStyle? {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle ?? super.preferredStatusBarStyle
    }

    // Bắt buôc phải có nếu dùng MotionContainer
    func startUpdateMotion() {
        guard let motionManager = motionManager, motionManager.isAccelerometerAvailable else { return }
        
    }
    
    // Bắt buôc phải có nếu dùng MotionContainer
    func stopUpdateMotion() {
        guard let motionManager = motionManager, motionManager.isAccelerometerAvailable else { return }
        motionManager.stopAccelerometerUpdates()
    }

    // ----------------------------------------------------------------------------------
    // Main Sections Collection View
    // ----------------------------------------------------------------------------------
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainSectionsArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "mainCell", for: indexPath) as! MainCollectionViewCell

        if USE_CLOUDKIT {

            let catClass = mainSectionsArray[(indexPath as NSIndexPath).row] as! CKRecord
            cell.lblSection.text = "\(catClass["name"]!)"
            cell.lblSection.accessibilityIdentifier = "\(catClass["id"]!)"

            let imageFile = catClass["pic"] as? CKAsset
            if imageFile != nil {
                cell.imgSection.image = UIImage(contentsOfFile: imageFile!.fileURL.path)
            }

            let isFree = catClass["isFree"] as! Int
            if (isFree == 0) && !getProVersion() {
                cell.imgLock.isHidden = false
            } else {
                cell.imgLock.isHidden = true
            }

        } else { // PLIST

            if let plistDict = mainSectionsArray[(indexPath as NSIndexPath).row] as? [String:String] {
                cell.lblSection.text = plistDict["name"]!
                cell.lblSection.accessibilityIdentifier = "\(plistDict["id"]!)"
                let sectionPic = UIImage(named: plistDict["id"]! + ".png")
                cell.imgSection.image = sectionPic

                let isFree = plistDict["isFree"]!
                if (isFree == "no") && !getProVersion() {
                    cell.imgLock.isHidden = false
                } else {
                    cell.imgLock.isHidden = true
                }
            }

        }

        // Thiết lập kích thước icon theo màn hình
        // Lưu ý: UIScreen.main.bounds là kích thước màn hình ở dạng point, có thể thay đổi khi xoay ngang
        let deviceWidth = Int(UIScreen.main.bounds.width)
        let deviceHeight = Int(UIScreen.main.bounds.height)
        var height = deviceHeight
        if deviceHeight < deviceWidth {
            // Landscape
            height = deviceWidth
        }
        switch height {
        case 568: // 320x568pt, 640×1136 iPhone 5, 5C, 5S, SE, iPod Touch 6
            cell.heightCellPic.constant = 32
            cell.widthCellPic.constant = 32
        case 667: // 375x667pt, 750×1334 iPhone 6, 6S, 7, 8
            cell.heightCellPic.constant = 54
            cell.widthCellPic.constant = 54
        case 736: // 414x736pt, 1080×1920 iPhone 6+, 6S+, 7+, 8+
            cell.heightCellPic.constant = 59
            cell.widthCellPic.constant = 59
        case 812: // 375x812pt, 1125×2436 iPhone X
            cell.heightCellPic.constant = 64
            cell.widthCellPic.constant = 64
        case 1024: // 768x1024pt, 1536×2048 iPad 4, Air, Air 2, 2017, mini 2, mini 3, mini 4
            cell.heightCellPic.constant = 90
            cell.widthCellPic.constant = 90
        case 1112: // 834x1112pt, 1668×2224 iPad Pro (10.5-inch)
            cell.heightCellPic.constant = 110
            cell.widthCellPic.constant = 110
        case 1366: // 1024x1366pt, 2048×2732 iPad Pro (9.7-inch), (12.9-inch)
            cell.heightCellPic.constant = 110
            cell.widthCellPic.constant = 110
        default: // iPhone 6, 6S, 7, 8
            cell.heightCellPic.constant = 54
            cell.widthCellPic.constant = 54
        }
        // UI Formatting
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 5
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let deviceWidth = Int(UIScreen.main.bounds.width)
        let deviceHeight = Int(UIScreen.main.bounds.height)
        var height = deviceHeight
        if deviceHeight < deviceWidth {
            // Landscape
            height = deviceWidth
        }
        switch height {
        case 568: // 320x568pt, 640×1136 iPhone 5, 5C, 5S, SE, iPod Touch 6
            return CGSize(width: 90, height: 98)
        case 667: // 375x667pt, 750×1334 iPhone 6, 6S, 7, 8
            return CGSize(width: 99, height: 119)
        case 736: // 414x736pt, 1080×1920 iPhone 6+, 6S+, 7+, 8+
            return CGSize(width: 119, height: 142)
        case 812: // 375x812pt, 1125×2436 iPhone X
            return CGSize(width: 106, height: 148)
        case 1024: // 768x1024pt, 1536×2048 iPad 4, Air, Air 2, 2017, mini 2, mini 3, mini 4
            return CGSize(width: 164, height: 210)
        case 1112: // 834x1112pt, 1668×2224 iPad Pro (10.5-inch)
            return CGSize(width: 185, height: 235)
        case 1366: // 1024x1366pt, 2048×2732 iPad Pro (9.7-inch), (12.9-inch)
            return CGSize(width: 232, height: 282)
        default: // iPhone 6, 6S, 7, 8
            return CGSize(width: 99, height: 119)
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIEdgeInsetsMake(10, 14, 44, 14); //top,left,bottom,right
        } else {
            return UIEdgeInsetsMake(50, 64, 64, 64); //top,left,bottom,right
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = myCollectionView.cellForItem(at: indexPath) as! MainCollectionViewCell
        let section = cell.lblSection.accessibilityIdentifier
        
        
        if cell.imgLock.isHidden { // Free Section
            cell.imgSection.delay = 0.0;
            cell.imgSection.animation = "flipX"
            cell.imgSection.animate()
            let when = DispatchTime.now() + 0.2 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                switch indexPath.row {
                case 0: // MapsView
                    self.performSegue(withIdentifier: "segueViewMaps", sender: section)
                    break
                case 1: // Camera
                    self.performSegue(withIdentifier: "segueCameraView", sender: section)
                    break
                case 2: // Photos
                    self.performSegue(withIdentifier: "seguePhotos", sender: section)
                    break
                case 3: // WayPoints
                    let vc = GPXTableViewController(nibName: nil, bundle: nil)
                    //vc.title = "Your Way Points"
                    let navController = UINavigationController(rootViewController: vc)
                    self.present(navController, animated: true) { () -> Void in }
                    break
                case 4: // Tracks
                    let vc = GPXTableViewController(nibName: nil, bundle: nil)
                    //vc.title = "Your Tracks"
                    let navController = UINavigationController(rootViewController: vc)
                    self.present(navController, animated: true) { () -> Void in }
                    break
                case 5: // SETTINGS
                    self.performSegue(withIdentifier: "segueSettings", sender: section)
                    break
                case 6: // TOOLS
                    self.performSegue(withIdentifier: "segueTools", sender: section)
                    break
                case 7: // HELP
                    self.performSegue(withIdentifier: "segueHelp", sender: section)
                    break
                case 8: // ABOUT
                    self.performSegue(withIdentifier: "segueInfo", sender: section)
                    break
                default:
                    break
                }
            }   
        }
    }
    
    @IBAction func btnReload(_ sender: AnyObject) {
        if USE_CLOUDKIT {
            querySections()
        } else {
            queryPlist()
        }
    }
    
    @IBAction func btnInfo(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "segueInfo", sender: sender)
    }


// Query Sections CloudKit
    func querySections() {
        view.showHUD(view)
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Main", predicate: predicate)
        let sort = NSSortDescriptor(key: "order", ascending: true)
        query.sortDescriptors = [sort]

        publicDatabase.perform(query, inZoneWith: nil) { (results, error) -> Void in
            if error == nil { DispatchQueue.main.async {
                self.mainSectionsArray = NSMutableArray(array: results!)
                self.myCollectionView.reloadData()
                self.view.hideHUD()
                // Error
                }} else { DispatchQueue.main.async {
                
                //errorAlert.show();
                self.view.hideHUD()
                } } }
        
    }

// Query Plist File
    func queryPlist(){
        mainSectionsArray = NSArray(contentsOfFile: Bundle.main.path(forResource: "Main", ofType: "plist")!)!
    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
    
//        if let chkSender: String = sender as? String {
//            
//            if chkSender != "Buy" {
//                
//                if ((segue.identifier != "segueInfo") &&
//                    (segue.identifier != "viewMaps")) {
//
//                        let SEZVC: SectionTableViewController = segue.destination as! SectionTableViewController
//                        SEZVC.currentSection = sender as! String
//                }
//            }
//        }
        let identifier:String = segue.identifier!
        switch identifier {
        case "segueViewMaps":
            let nav: UINavigationController = segue.destination as! UINavigationController
            let vc: MapViewController = nav.viewControllers.first as! MapViewController
            vc.motionManager = motionManager
            break
        case "segueCameraView":
            let nav: UINavigationController = segue.destination as! UINavigationController
            let vc: CameraViewController = nav.viewControllers.first as! CameraViewController
            vc.motionManager = motionManager
            break
        case "seguePhotos":
            break
        case "segueSettings":
            let nav: UINavigationController = segue.destination as! UINavigationController
            let vc: SettingsContainer = nav.viewControllers.first as! SettingsContainer
            vc.motionManager = motionManager
            break
        case "segueEmbed":
            
            break
        case "segueTools":
            break
        case "segueHelp":
            break
        case "segueInfo":
            let nav: UINavigationController = segue.destination as! UINavigationController
            let vc: WebViewController = nav.viewControllers.first as! WebViewController
            let prefferedLanguage = Locale.preferredLanguages[0] as String
            let arr = prefferedLanguage.lowercased().components(separatedBy: "-")
            
            if arr.contains("vn") || arr.contains("vi") {
                vc.title = "Về chúng tôi"
                vc.urlString = ABOUT_VI_URL
            } else {
                vc.title = "About Us"
                vc.urlString = ABOUT_EN_URL
            }
            break
        case "segueTermsOfUse":
            let nav: UINavigationController = segue.destination as! UINavigationController
            let vc: WebViewController = nav.viewControllers.first as! WebViewController
            let prefferedLanguage = Locale.preferredLanguages[0] as String
            let arr = prefferedLanguage.lowercased().components(separatedBy: "-")
            
            if arr.contains("vn") || arr.contains("vi") {
                vc.title = "Terms of Use"
                vc.urlString = TERMS_OF_USE_VI_URL
            } else {
                vc.title = "Terms of Use"
                vc.urlString = TERMS_OF_USE_EN_URL
            }
            break
        default:
            break
        }
    }

    // MARK: -- ADS
    
    // Initialize Google AdMob banner
    func initAdMobBanner() {
        switch DEVICE_WIDTH {
        case "320": //5,SE
            adMobBannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: 256, height: 40)))
            break
        case "375": //6,7
            adMobBannerView = GADBannerView(adSize: kGADAdSizeBanner)
            break
        case "414": //6+,7+
            adMobBannerView = GADBannerView(adSize: kGADAdSizeBanner)
            break
        case "768": //iPad
            adMobBannerView = GADBannerView(adSize: kGADAdSizeFullBanner)
            break
        default:
            adMobBannerView = GADBannerView(adSize: kGADAdSizeBanner)
            break
        }
        
        self.view.addSubview(adMobBannerView)
        adMobBannerView.adUnitID = ADMOB_UNIT_ID_Banner
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        let request = GADRequest()
        request.testDevices = ["b0363f55ef349672aa7932774e71491d","74fe0112c024148d80fba2b4f9761655406f5c25",kGADSimulatorID]
        adMobBannerView.load(request)
        adMobBannerView.load(GADRequest())
    }


    // Hide the banner
    func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        // Hide the banner moving it below the bottom of the screen
        banner.frame = CGRect(x: 0, y: self.view.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
        
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        
        // Move the banner on the bottom of the screen
        banner.frame = CGRect(x: 0, y: self.view.frame.size.height - banner.frame.size.height,
            width: banner.frame.size.width, height: banner.frame.size.height);
        UIView.commitAnimations()
        banner.isHidden = false
        
    }


    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView) {
        print("AdMob loaded!")
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(adMobBannerView)
        
    }
    
}
