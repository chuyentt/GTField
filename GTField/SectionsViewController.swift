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

class SectionsViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {

    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var bottomTableView: NSLayoutConstraint!
    
    
    var arrayPoi = NSArray()
    var section = ""
    var idsection = ""
    var sectionToAdd = ""
    var selectedSection = ""
    var nameToPass = ""
    var adMobBannerView = GADBannerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arrayPoi = NSArray(contentsOfFile: Bundle.main.path(forResource: section, ofType: "plist")!)!
        centerMap()
        addSectionPin()
        
        if DEFAULT_SECTION_VIEW == "Map" {
            mapView.isHidden = false
            tableView.isHidden = true
            self.navigationItem.rightBarButtonItem?.title = "List"
        }
        
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        if self.tableView.indexPathForSelectedRow != nil {
            let iPath : NSIndexPath = self.tableView.indexPathForSelectedRow! as NSIndexPath
            self.tableView.deselectRow(at: iPath as IndexPath, animated: true)
        }
        
        if ADS_ENABLED == true {
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                bottomTableView.constant = 62
            } else {
                bottomTableView.constant = 50
            }

            initAdMobBanner()
        } else {
            hideBanner(banner: adMobBannerView)
        }

    }
    
    
    
    @IBAction func btnListMap(_ sender: AnyObject) {
        
        if mapView.isHidden {

            mapView.alpha = 0
            mapView.isHidden = false
            tableView.alpha = 1
            UIView.animate(withDuration: 0.4){
                self.tableView.alpha = 0
                self.mapView.alpha = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.tableView.isHidden = true
            }

            self.navigationItem.rightBarButtonItem?.title = "List"
        
        } else {
        
            tableView.alpha = 0
            tableView.isHidden = false
            mapView.alpha = 1
            UIView.animate(withDuration: 0.4){
                self.mapView.alpha = 0
                self.tableView.alpha = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.mapView.isHidden = true
            }
            
            self.navigationItem.rightBarButtonItem?.title = "Map"
            
        }
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPoi.count
    }

    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSection", for: indexPath) as! SectionsTableViewCell
        
            let imgName = "Icon\((arrayPoi[indexPath.row] as AnyObject).object(forKey: "Name") as! String)"
            cell.imgPoi.image = UIImage(named: imgName)
            
            cell.lblPoiName.text = (arrayPoi[indexPath.row] as AnyObject).object(forKey: "Name") as? String
            let stringNPoi = (arrayPoi[indexPath.row] as AnyObject).object(forKey: "Poi") as! String
            cell.lblNPoi.text = "\(stringNPoi) Points of Interest"
            //cell.lblPoiIdName.text = (arrayPoi[indexPath.row] as AnyObject).object(forKey: "idName") as? String
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SectionsTableViewCell
        nameToPass = cell.lblPoiName.text!
        performSegue(withIdentifier: "segueListPoi", sender: nil)
    }
    
    
    
    // MAP:
    
    func addSectionPin(){
        
        let arraySezioni = NSArray(contentsOfFile: Bundle.main.path(forResource: section, ofType: "plist")!)!
        
        for x in 0 ..< arraySezioni.count {
        
            sectionToAdd = (arraySezioni[x] as AnyObject).object(forKey: "Name") as! String
        
            var poiName = "" as String
            var poiLat = ""
            var poiLon = ""
            
            let arrayPoiMap = NSArray(contentsOfFile: Bundle.main.path(forResource: sectionToAdd, ofType: "plist")!)!
            
            for y in 0 ..< arrayPoiMap.count {
                
                    poiName = (arrayPoiMap[y] as AnyObject).object(forKey: "Name") as! String
                    poiLat = (arrayPoiMap[y] as AnyObject).object(forKey: "Lat") as! String
                    poiLon = (arrayPoiMap[y] as AnyObject).object(forKey: "Lon") as! String
                    
                    let latD = Double(poiLat)
                    let lonD = Double(poiLon)
                    
                    let myLocation = CLLocationCoordinate2DMake(latD!, lonD!)
                    let dropPin = MKPointAnnotation()
                    dropPin.coordinate = myLocation
                    dropPin.title = poiName
                    dropPin.subtitle = sectionToAdd
                    mapView.addAnnotation(dropPin)
                
            }
            
        }
        
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: MKUserLocation.self) {   // error handler for the current location
            return nil
        }
        
        
        let reuseID = ((annotation.subtitle)!)! as String
        
        var v = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        
        if v != nil {
            v!.annotation = annotation
        } else {
            v = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            let pinImageName = "pin" + reuseID
            v!.image = UIImage(named: pinImageName)
            v!.canShowCallout = true
            v!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
        }
        
        return v
        
    }

    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
        var i = -1
        for view in views {
            i += 1
            if view.annotation is MKUserLocation {
                continue
            }
            
            // Check if current annotation is inside visible map rect, else go to next one
            let point:MKMapPoint  =  MKMapPoint.init(view.annotation!.coordinate);
            if (!self.mapView.visibleMapRect.contains(point)) {
                continue;
            }
            
            let endFrame:CGRect = view.frame;
            
            // Move annotation out of view
            
            view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y - self.view.frame.size.height, width: view.frame.size.width, height: view.frame.size.height);
            
            
            // Animate drop
            let delay = 0.02 * Double(i)
            UIView.animate(withDuration: 0.2, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations:{() in
                view.frame = endFrame
                // Animate squash
                }, completion:{(Bool) in
                    UIView.animate(withDuration: 0.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations:{() in
                        view.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                        
                        }, completion: {(Bool) in
                            UIView.animate(withDuration: 0.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations:{() in
                                view.transform = CGAffineTransform.identity
                                }, completion: nil)
                    })
            })
        }
    }

    
    // Tap on detail
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        nameToPass = ((view.annotation?.title)!)!
        section = ((view.annotation?.subtitle)!)!
        performSegue(withIdentifier: "seguePoiDetail", sender: "poiDetail")
        
        
    }
    
    
    
    // Let's center the map for all devices
    func centerMap() {
        
        let centerLat = CENTER_MAP_LAT
        let centerLon = CENTER_MAP_LON
        var centerLatDelta = 0 as CLLocationDegrees
        var centerLonDelta = 0 as CLLocationDegrees
        
        let device = UIDevice.current.model
        let index = device.index(device.startIndex, offsetBy: 4)
        let deviceType = String(device[..<index]) //device.substring(to: index)
        
        if deviceType != "iPad" {
            
            let screenSize: CGRect = UIScreen.main.bounds
            let deviceWidth = screenSize.width
            
            switch deviceWidth {
            case 320: // 4/5
                centerLatDelta = SCREEN_320_LAT
                centerLonDelta = SCREEN_320_LON
            case 375: // 6
                centerLatDelta = SCREEN_375_LAT
                centerLonDelta = SCREEN_375_LON
            case 414: // 6+
                centerLatDelta = SCREEN_414_LAT
                centerLonDelta = SCREEN_414_LON
            default:
                centerLatDelta = SCREEN_375_LAT
                centerLonDelta = SCREEN_375_LON
            }
            
        } else {
            // iPad
            centerLatDelta = SCREEN_IPAD_LAT
            centerLonDelta = SCREEN_IPAD_LON
        }
        
        let zoom = MKCoordinateSpan(latitudeDelta: centerLatDelta, longitudeDelta: centerLonDelta)
        let centerPoint = CLLocationCoordinate2D(latitude: centerLat , longitude: centerLon)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: centerPoint, span: zoom)
        mapView.setRegion(region, animated: true)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if sender == nil {

            let cell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as! SectionsTableViewCell
            let MPVC: MapPoiViewController = segue.destination as! MapPoiViewController
            MPVC.section = cell.lblPoiName.text!

        } else {

            let PDVC : PoiDetailViewController = segue.destination as! PoiDetailViewController
            PDVC.poiName = nameToPass
            PDVC.section = section
            
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
        request.testDevices = ["b0363f55ef349672aa7932774e71491d","74fe0112c024148d80fba2b4f9761655406f5c25",kGADSimulatorID]
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
