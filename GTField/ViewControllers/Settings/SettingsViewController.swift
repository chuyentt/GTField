//
//  SettingsViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 7/13/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase
import GeoTrans
import StoreKit

class SettingsViewController: UITableViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var swEnableSoundEffects: UISwitch!
    @IBOutlet weak var lblImageCompressionQuality: UILabel!
    @IBOutlet weak var sliImageCompressionQuality: UISlider!
    @IBOutlet weak var sliTrackDistanceFilter: UISlider!
    @IBOutlet weak var lblTrackDistanceFilter: UILabel!
        
    var adMobBannerView = GADBannerView()
    var interstitial = GADInterstitial(adUnitID: ADMOB_UNIT_ID_Interstitial)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "GTField Settings"
        
        // Load settings
        ENABLE_SOUND_EFFECT = getEnableSoundEffect()
        swEnableSoundEffects.isOn = ENABLE_SOUND_EFFECT
        IMAGE_COMPRESSION_QUALITY = getImageCompressionQuality()
        sliImageCompressionQuality.value = IMAGE_COMPRESSION_QUALITY
        lblImageCompressionQuality.text = "\(IMAGE_COMPRESSION_QUALITY)"
        
        TRACK_DISTANCE_FILTER = getTrackDistanceFilter()
        sliTrackDistanceFilter.value = Float(TRACK_DISTANCE_FILTER)
        lblTrackDistanceFilter.text = "\(TRACK_DISTANCE_FILTER)"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func soundEffectsValueChanged(_ sender: UISwitch) {
        ENABLE_SOUND_EFFECT = sender.isOn
        UserDefaults.standard.set(ENABLE_SOUND_EFFECT, forKey: "ENABLE_SOUND_EFFECT")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func sliImageCompressionQualityValueChanged(_ sender: UISlider) {
        IMAGE_COMPRESSION_QUALITY = roundf(sender.value*100.0)/100.0
        lblImageCompressionQuality.text = "\(IMAGE_COMPRESSION_QUALITY)"
        sender.value = IMAGE_COMPRESSION_QUALITY
        setImageCompressionQuality(IMAGE_COMPRESSION_QUALITY)
    }
    
    @IBAction func sliDistanceFilterValueChanged(_ sender: UISlider) {
        TRACK_DISTANCE_FILTER = round(Double(sender.value))
        lblTrackDistanceFilter.text = "\(TRACK_DISTANCE_FILTER)"
        sender.value = Float(TRACK_DISTANCE_FILTER)
        setTrackDistanceFilter(TRACK_DISTANCE_FILTER)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            break
        case 2:
            switch cell.tag {
            case 0: // Coordinate System
                let crsName = getCrsName();
                cell.detailTextLabel?.text = crsName
                break
            case 1: // Datum
                let datumCode = getDatumCode()
                if let index = datumItems.index(where: { (item) -> Bool in
                    item.code == datumCode! as String
                }) {
                    cell.detailTextLabel?.text = datumItems[index].name
                } else {
                    cell.detailTextLabel?.text = getDatumName()
                }
                break
            case 2: // Ellipsoid
                let ellipsoidCode = getEllipsoidCode()
                if let index = ellipsoidItems.index(where: { (item) -> Bool in
                    item.code == ellipsoidCode! as String
                }) {
                    cell.detailTextLabel?.text = ellipsoidItems[index].name
                } else {
                    cell.detailTextLabel?.text = ellipsoidItems[23].name
                }
                break
            default:
                break
            }
            
            break
        case 3:
            switch cell.tag {
            case 0: // Area Unit
                cell.detailTextLabel?.text = areaUnitItems[getAreaUnit()].name
                break
            case 1: // Length Unit
                cell.detailTextLabel?.text = distanceUnitItems[getDistanceUnit()].name
                break
            case 2: // Coordniate
                cell.detailTextLabel?.text = latLngFormatItems[getLatLngFormat()].name
                break
            case 3: // Map Grid
                cell.detailTextLabel?.text = mapGridFormatItems[getMapGridFormat()].name
                break
                
            default:
                break
            }
            break
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        switch indexPath.section {
        case 0:
            break
        case 1:
            break
        case 2:
            switch cell.tag {
            case 0:                
                let vc: SelectingTableViewController = SelectingTableViewController()
                vc.selectionType = .coordinateSystem
                vc.textLabel = cell.detailTextLabel
                vc.crsIndex = getCrsIndex()
                vc.title = NSLocalizedString("Select a coordinate system", comment: "")
                
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {

                })
                if (self.interstitial.isReady) {
                    self.interstitial.present(fromRootViewController: vc)
                }
                break
            case 1:
                /* Tạm thời không cho chọn, nếu chọn thì chỉ cho xem thông tin hiện tại
                let vc: SelectingTableViewController = SelectingTableViewController()
                vc.selectionType = .datumTransformation
                vc.items = datumItems
                vc.textLabel = cell.detailTextLabel
                vc.title = NSLocalizedString("Select a datum transformation", comment: "")
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {
                    
                })
                if (self.interstitial.isReady) {
                    self.interstitial.present(fromRootViewController: vc)
                }
                */
                break;
            case 2:
                /* Tạm thời không cho chọn, nếu chọn thì chỉ cho xem thông tin hiện tại
                let vc: SelectingTableViewController = SelectingTableViewController()
                vc.selectionType = .ellipsoid
                vc.items = ellipsoidItems
                vc.textLabel = cell.detailTextLabel
                vc.title = NSLocalizedString("Select an ellipsoid", comment: "")
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {
                    
                })
                if (self.interstitial.isReady) {
                    self.interstitial.present(fromRootViewController: vc)
                }
                */
                break;
            default:
                break
            }
            break
        case 3:
            switch cell.tag {
            case 0: // Area Unit
                let vc: SelectingTableViewController = SelectingTableViewController()
                vc.selectionType = .areaUnit
                vc.items = areaUnitItems
                vc.textLabel = cell.detailTextLabel
                vc.title = NSLocalizedString("Select an area unit", comment: "")
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {
                    
                })
                if (self.interstitial.isReady) {
                    self.interstitial.present(fromRootViewController: vc)
                }
                break
            case 1: // Length Unit
                let vc: SelectingTableViewController = SelectingTableViewController()
                vc.selectionType = .distanceUnit
                vc.items = distanceUnitItems
                vc.textLabel = cell.detailTextLabel
                vc.title = NSLocalizedString("Select a length unit", comment: "")
                
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {
                    
                })
                if (self.interstitial.isReady) {
                    self.interstitial.present(fromRootViewController: vc)
                }
                break
            case 2: // Coordniate
                let vc: SelectingTableViewController = SelectingTableViewController()
                vc.selectionType = .latLngFormat
                vc.items = latLngFormatItems
                vc.textLabel = cell.detailTextLabel
                vc.title = NSLocalizedString("Select a coordinates format", comment: "")
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {
                    
                })
                if (self.interstitial.isReady) {
                    self.interstitial.present(fromRootViewController: vc)
                }
                break
            case 3: // MapGrid
                let vc: SelectingTableViewController = SelectingTableViewController()
                vc.selectionType = .mapGridFormat
                vc.items = mapGridFormatItems
                vc.textLabel = cell.detailTextLabel
                vc.title = NSLocalizedString("Select a map grid format", comment: "")
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {
                    
                })
                if (self.interstitial.isReady) {
                    self.interstitial.present(fromRootViewController: vc)
                }
                break
            default:
                break
            }
            break
        case 4: // Subscription
            switch cell.tag {
            case 0: // Subscribe
                
                break
            case 1: // Restore Purchased
                if(SKPaymentQueue.canMakePayments()) {
                    SKPaymentQueue.default().add(self)
                    SubscriptionService.shared.loadSubscriptionOptions()
                    SKPaymentQueue.default().restoreCompletedTransactions()
                }
                break
            default:
                break
            }
            
            break
        default:
            break
        }
        
        print("You selected cell #\(cell.tag)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ADS_ENABLED == true {
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                
            } else {
                
            }
            let request = GADRequest()
            interstitial.load(request)
            
            //initAdMobBanner()
        } else {
            //hideBanner(banner: adMobBannerView)
        }
    }
        
    // Initialize Google AdMob banner
    func initAdMobBanner() {
        adMobBannerView = GADBannerView(adSize: kGADAdSizeBanner)
        self.view.addSubview(adMobBannerView)
        adMobBannerView.adUnitID = ADMOB_UNIT_ID_Banner
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        let request = GADRequest()
        //request.testDevices = ["b0363f55ef349672aa7932774e71491d",kGADSimulatorID]
        adMobBannerView.load(request)
        adMobBannerView.load(GADRequest())

    }
    
    
    // Hide the banner
    func hideBanner(banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        // Hide the banner moving it below the bottom of the screen
        banner.frame = CGRect(x: 0, y: self.view.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
    }
    
    
    // Show the banner
    func showBanner(banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        
        // Move the banner on the bottom of the screen
        banner.frame = CGRect(x:0, y:self.view.frame.size.height - banner.frame.size.height,
                              width:banner.frame.size.width, height:banner.frame.size.height);
        UIView.commitAnimations()
        banner.isHidden = false
    }
    
    
    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView) {
        print("AdMob loaded!")
        showBanner(banner: adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(banner: adMobBannerView)
    }
}

extension SettingsViewController: SKPaymentTransactionObserver {
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        for transaction:SKPaymentTransaction in queue.transactions {
            if transaction.payment.productIdentifier == IAP_ID {
                setProVersion(true)
            }
        }

        let alert = UIAlertView(title: "Thank You", message: "Your purchase were restored.", delegate: nil, cancelButtonTitle: "OK")
        alert.show()

    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("restoreCompletedTransactionsFailedWithError", error.localizedDescription)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Buy")
    }
}
