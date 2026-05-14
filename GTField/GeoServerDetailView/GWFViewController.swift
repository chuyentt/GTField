//
//  GWFViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 6/13/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit

import GoogleMobileAds
import Firebase

class GWFViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    var adMobBannerView = GADBannerView()
    
    @IBOutlet var tableView: UITableView!
    
    // Array of dictionary
    // Danh sách thông tin layers
    var arrRes = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Feature Information", comment: "")
        // Do any additional setup after loading the view.
        
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ADS_ENABLED && !getProVersion() {
            if UIDevice.current.userInterfaceIdiom == .pad {
                //bottomTableView.constant = 62
            } else {
                //bottomTableView.constant = 50
            }
            initAdMobBanner()
        } else {
            hideBanner(banner: adMobBannerView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionDone(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - TableView
    // --------------------------------------------------------------------------------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrRes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        let dict = arrRes[(indexPath as NSIndexPath).section]
        cell.textLabel?.text = dict["name"] as? String
        cell.detailTextLabel?.text = dict["value"] as? String
        return cell
    }
    
    // Initialize Google AdMob banner
    func initAdMobBanner() {
        adMobBannerView = GADBannerView(adSize: GADAdSizeBanner)
        
        installAdMobBanner(adMobBannerView)
        adMobBannerView.adUnitID = ADMOB_UNIT_ID_Banner
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        let request = GADRequest()
        adMobBannerView.load(request)
    }
    
    
    // Hide the banner
    func hideBanner(banner: UIView) {
        banner.setAdBannerVisible(false)
    }
    
    
    // Show the banner
    func showBanner(banner: UIView) {
        banner.setAdBannerVisible(true)
    }
    
    
    // AdMob banner available
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("AdMob loaded!")
        showBanner(banner: adMobBannerView)
    }
    
    // NO AdMob banner available
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(banner: adMobBannerView)
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let dict = arrRes[section]
//        return dict["name"] as? String
//    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
