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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        switch cell.tag {
        case 0:
            // To CoordinateType
            let vc: SelectingTableViewController = SelectingTableViewController()
            vc.selectionType = .areaUnit
            let nav: UINavigationController = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: { 
                
            })
            break
        case 1:
            // Datum
            break
        case 2:
            // Ellipsoid
            break
        default:
            break
        }
        print("You selected cell #\(cell.tag)")
        if (self.interstitial.isReady) {
            self.interstitial.present(fromRootViewController: self)
        }
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
