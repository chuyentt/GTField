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
    
//    let purchaseUnlimitedSuffix = RegisteredPurchase.Unlimited
//    let subscribeYearlySuffix = RegisteredPurchase.Yearly
//    let subscribeMonthlySuffix = RegisteredPurchase.Monthly

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
        
        // Detect the screen width (format purpose)
        let deviceWidth = UIScreen.main.bounds.width
        switch deviceWidth {
            
        case 320.0: // 5
            DEVICE_WIDTH = "320"
        case 375.0: // 6
            DEVICE_WIDTH = "375"
        case 414.0: // 6+
            DEVICE_WIDTH = "414"
        case 768.0: // iPad
            DEVICE_WIDTH = "768"
        default:    //320.0
            DEVICE_WIDTH = "320"
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
//        let alert = UIAlertController(
//            title: NSLocalizedString("Warning delete", comment: ""),
//            message: "\(count) "+NSLocalizedString("photos will be deleted from this app on your device", comment: ""),
//            preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(
//            title: NSLocalizedString("Cancel", comment: ""),
//            style: .cancel,
//            handler: { (action: UIAlertAction!) in
//                // Cancel
//        }))
//        alert.addAction(UIAlertAction(
//            title: NSLocalizedString("OK", comment: ""),
//            style: .default,
//            handler: { (action: UIAlertAction!) in
//                if count == 1 {
//                    self.deletePhoto(nil)
//                    return
//                }
//                for photo in self.photosToShow {
//                    photo.delete(all: false)
//                }
//                self.navigationController?.popViewController(animated: true)
//        }))
//        present(alert, animated: true, completion: nil)
        
        
        
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


        switch DEVICE_WIDTH {

            case "320": // 5
                cell.heightCellPic.constant = 46
                cell.widthCellPic.constant = 46
            
            case "375": // 6
                cell.heightCellPic.constant = 54
                cell.widthCellPic.constant = 54

            case "414": //6+
                cell.heightCellPic.constant = 59
                cell.widthCellPic.constant = 59
            
            case "768": // iPad
                cell.heightCellPic.constant = 110
                cell.widthCellPic.constant = 110
            
            default:
                
                cell.heightCellPic.constant = 46
                cell.widthCellPic.constant = 46

        }

        
        // UI Formatting
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 5
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        switch DEVICE_WIDTH {
            case "320": //5,SE
                return CGSize(width: 84, height: 88)
            
            case "375": //6,7
                return CGSize(width: 99, height: 119)
            
            case "414": //6+,7+
                return CGSize(width: 109, height: 139)
                
            case "768": //iPad
                return CGSize(width: 202, height: 222)

            default:
                return CGSize(width: 84, height: 104)
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(10, 18, 10, 18); //top,left,bottom,right
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
