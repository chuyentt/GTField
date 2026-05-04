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

import GoogleMobileAds
import MapKit
import Firebase


class MapPoiViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {

    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var bottomTableView: NSLayoutConstraint!
    
    var comeFromSection = true
    var section = ""
    var idsection = ""
    var arrayPoiSection = NSArray()
    var nameToPass = ""
    var idToPass = ""
    var adMobBannerView = GADBannerView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DEFAULT_POI_VIEW == "List" {
            mapView.isHidden = true
            tableView.isHidden = false
            self.navigationItem.rightBarButtonItem?.title = "Map"
        }

        
        centerMap()
        addSectionPin(section: section)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        if self.tableView.indexPathForSelectedRow != nil {
            let iPath : NSIndexPath = self.tableView.indexPathForSelectedRow! as NSIndexPath
            self.tableView.deselectRow(at: iPath as IndexPath, animated: true)
        }
        
        if ADS_ENABLED && !getProVersion() {
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

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: MKUserLocation.self) {   // error handler for the current location
            return nil
        }

        var reuseID = ((annotation.subtitle)!)! as String
        
        if comeFromSection == false {
            reuseID = ((annotation.title)!)! as String
        }
        
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

    
    // Let's add pins
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
        idToPass = ((view.annotation?.subtitle)!)!
        performSegue(withIdentifier: "seguePoiDetail", sender: nil)
    }
    
    
    func addSectionPin(section: String){
        
        //var idName = "" as String
        var poiName = "" as String
        var poiLat = ""
        var poiLon = ""
        
        arrayPoiSection = NSArray(contentsOfFile: Bundle.main.path(forResource: section, ofType: "plist")!)!
        
        for x in 0 ..< arrayPoiSection.count {
            
            //idName = (arrayPoiSection[x] as AnyObject).object(forKey: "idName") as! String
            poiName = (arrayPoiSection[x] as AnyObject).object(forKey: "Name") as! String
            poiLat = (arrayPoiSection[x] as AnyObject).object(forKey: "Lat") as! String
            poiLon = (arrayPoiSection[x] as AnyObject).object(forKey: "Lon") as! String
            
            let latD = Double(poiLat)
            let lonD = Double(poiLon)
            
            let myLocation = CLLocationCoordinate2DMake(latD!, lonD!)
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = myLocation
            dropPin.title = poiName
            dropPin.subtitle = section
            
            if comeFromSection == false {
                dropPin.subtitle = ""
            }
            
            
            
            mapView.addAnnotation(dropPin)
            
        }
    }
    
    
    func centerMap() {
        
        let centerLat = CENTER_MAP_LAT
        let centerLon = CENTER_MAP_LON
        var centerLatDelta = 0 as CLLocationDegrees
        var centerLonDelta = 0 as CLLocationDegrees
        
        let device = UIDevice.current.model
        let index = device.index(device.startIndex, offsetBy: 4)
        let deviceType = String(device[..<index])//device.substring(to: index)
        
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
            centerLatDelta = SCREEN_IPAD_LAT
            centerLonDelta = SCREEN_IPAD_LON
        }
        
        let zoom = MKCoordinateSpan(latitudeDelta: centerLatDelta, longitudeDelta: centerLonDelta)
        let centerPoint = CLLocationCoordinate2D(latitude: centerLat , longitude: centerLon)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: centerPoint, span: zoom)
        mapView.setRegion(region, animated: true)
    }

    
    // MARK: - TableView
    // --------------------------------------------------------------------------------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPoiSection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellListMap", for: indexPath as IndexPath) as! MapListPoiTableViewCell
        
        let poiName = (arrayPoiSection[indexPath.row] as AnyObject).object(forKey: "Name") as! String
        let idPic = (arrayPoiSection[indexPath.row] as AnyObject).object(forKey: "id") as! String
        var imgName = "\(section)-\(idPic).jpg"
        
        if comeFromSection == false {
            imgName = "\(poiName).jpg"
        }
        
        if let image = UIImage(named: imgName) {
            cell.imgPoi.image = image
        } else if let image = UIImage(named: "\(poiName).jpg") {
            cell.imgPoi.image = image
        } else if let image = UIImage(named: "\(idPic).jpg") {
            cell.imgPoi.image = image
        } else {
            cell.imgPoi.image = UIImage(named: "nothumb.png")
        }

        //cell.lblPoiIdName.text = (arrayPoiSection[indexPath.row] as AnyObject).object(forKey: "idName") as? String
        cell.lblPoiName.text = (arrayPoiSection[indexPath.row] as AnyObject).object(forKey: "Name") as? String

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MapListPoiTableViewCell
        nameToPass = cell.lblPoiName.text!
        performSegue(withIdentifier: "seguePoiDetail", sender: nil)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let PDVC : PoiDetailViewController = segue.destination as! PoiDetailViewController
        PDVC.poiName = nameToPass
        PDVC.section = section
        
        if comeFromSection == false {
            PDVC.comeFromSection = false
        }
        
 
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

    

}
