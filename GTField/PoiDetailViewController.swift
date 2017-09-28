//
//  by AppyStudio:
//
//  ------------------------------------------------------
//  CodeCanyon Page:
//  http://codecanyon.net/user/appystudio/portfolio
//
//  ChupaMobile Page:
//  http://www.chupamobile.com/author/AppyStudio
//
//  Facebook:
//  https://www.facebook.com/appystudionet/
//
//  ------------------------------------------------------
//  Copyright (c) 2016 Nicola Canali. All rights reserved.
//  https://www.facebook.com/nicolacanali
//  ------------------------------------------------------


import UIKit
import MapKit
import Firebase

class PoiDetailViewController: UIViewController, MKMapViewDelegate, GADBannerViewDelegate {

    
    @IBOutlet var imgPoi: UIImageView!
    @IBOutlet var imgSection: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var txtDesc: UITextView!
    @IBOutlet var btnDirections: UIButton!
    @IBOutlet var map: MKMapView!
    @IBOutlet var heightMap: NSLayoutConstraint!
    @IBOutlet var heightPic: NSLayoutConstraint!
    @IBOutlet var heightTxt: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var dirW: NSLayoutConstraint!
    @IBOutlet var dirH: NSLayoutConstraint!
    
    var comeFromSection = true
    var section = ""
    var poiId = ""
    var poiName = ""
    var poiDesc = ""
    var poiLat = ""
    var poiLon = ""
    var adMobBannerView = GADBannerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatView()
        caricaPoi()
        centerMap()
        addPin()
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+200)

    }

    override func viewWillAppear(_ animated: Bool) {
        
        if ADS_ENABLED == true {
            initAdMobBanner()
        } else {
            hideBanner(banner: adMobBannerView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func caricaPoi(){
        
        let arrayPoiSection = NSArray(contentsOfFile: Bundle.main.path(forResource: section, ofType: "plist")!)!
        
        for x in 0 ..< arrayPoiSection.count {
            
            if poiName == (arrayPoiSection[x] as AnyObject).object(forKey: "Name") as! String {
            
            poiId = (arrayPoiSection[x] as AnyObject).object(forKey: "id") as! String
            poiName = (arrayPoiSection[x] as AnyObject).object(forKey: "Name") as! String
            poiDesc = (arrayPoiSection[x] as AnyObject).object(forKey: "Desc") as! String
            poiLat = (arrayPoiSection[x] as AnyObject).object(forKey: "Lat") as! String
            poiLon = (arrayPoiSection[x] as AnyObject).object(forKey: "Lon") as! String
    
            }
        }
        
        lblName.text = poiName
        txtDesc.text = poiDesc
        
        
        

        let hSize = txtDesc.sizeThatFits(CGSize(width: view.frame.size.width, height: view.frame.size.height))
        heightTxt.constant = hSize.height
        txtDesc.sizeThatFits(txtDesc.frame.size)
        
        var imgName = "\(section)-\(poiId).jpg"
        
        if comeFromSection == false {
            imgName = "\(poiName).jpg"
        }
        
        if let picPoi = UIImage(named: imgName) {
            imgPoi.image = picPoi
        } else if let picPoi = UIImage(named: "\(poiName).jpg") {
            imgPoi.image = picPoi
        } else if let picPoi = UIImage(named: "\(poiId).jpg") {
            imgPoi.image = picPoi
        } else {
            imgPoi.image = UIImage(named: "nopic.png")
        }
        
        var namePoi = "pin\(section)"
        
        if comeFromSection == false {
            namePoi = "pin\(poiName)"
        }

        imgSection.image = UIImage(named: namePoi)
        
        map.layer.borderWidth = 1
        map.layer.borderColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.7).cgColor
        
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: MKUserLocation.self) {   // error handler for the current location
            return nil
        }
        
        let reuseID = section
        
        var v = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        
        if v != nil {
            v!.annotation = annotation
        } else {
            v = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            let pinImageName = "pinCamera"//"pin" + reuseID
            v!.image = UIImage(named: pinImageName)
            v?.transform = CGAffineTransform(rotationAngle: CGFloat(0.75))
        }
        
        return v
        
    }

    
    @IBAction func btnDirections(_ sender: AnyObject) {
        
        let directionUrl = "http://maps.apple.com/?daddr=\(poiLat),\(poiLon)&dirflg=\(NAV_MODE)"
        
        if (UIApplication.shared.canOpenURL(URL(string:"http://maps.apple.com")!)) {
            UIApplication.shared.openURL(URL(string: directionUrl)!)
        } else {
            NSLog("Can't use Apple Maps");
        }

        
    }
    
    func formatView(){
        
        let device = UIDevice.current.model
        let index = device.index(device.startIndex, offsetBy: 4)
        let deviceType = String(device[..<index])// device.substring(to: index)
        
        if deviceType != "iPad" {
            
            let screenSize: CGRect = UIScreen.main.bounds
            let deviceWidth = screenSize.width
            
            switch deviceWidth {
            case 320: // 4/5
                heightPic.constant = 180
                heightMap.constant = 180
            case 375: // 6
                heightPic.constant = 220
            default:
                print("Default")
            }
            
            
        } else {
            
            lblName.font = UIFont(name: lblName.font.fontName, size: 28)
            txtDesc.font = UIFont(name: (txtDesc.font?.fontName)!, size: 24)
            btnDirections.titleLabel?.font = UIFont(name: (btnDirections.titleLabel?.font.fontName)!, size: 24)
            dirW.constant = 32
            dirH.constant = 32
            heightPic.constant = 400
            heightMap.constant = 230
        }
        
    }
    
    
    func addPin(){
        
        let latD = Double(poiLat)
        let lonD = Double(poiLon)
        let myLocation = CLLocationCoordinate2DMake(latD!, lonD!)
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = myLocation
        map.addAnnotation(dropPin)
            
    }
    
    func centerMap() {
        
        let centerLat = Double(poiLat)!
        let centerLon = Double(poiLon)
        
        let centerLatDelta = DETAIL_ZOOM_LAT
        let centerLonDelta = DETAIL_ZOOM_LON
        
        let zoom = MKCoordinateSpan(latitudeDelta: centerLatDelta, longitudeDelta: centerLonDelta)
        let centerPoint = CLLocationCoordinate2D(latitude: centerLat , longitude: centerLon!)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: centerPoint, span: zoom)
        map.setRegion(region, animated: true)
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
