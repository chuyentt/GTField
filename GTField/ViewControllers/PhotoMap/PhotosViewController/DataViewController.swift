//
//  DataViewController.swift
//  PhotoMap
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/11/23.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The view controller representing each page in PhotosViewController.
 */

import UIKit

import GoogleMobileAds
import MapKit
import Firebase
//import AEXML

@objc(DataViewController)
class DataViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate, UITextViewDelegate, GADBannerViewDelegate {
    
    var dataObject: PhotoAnnotation?
    
    // Gọi lần 2 từ map
    // Slide 5 >> 1->2
    // << Slide back 5
    
    // Chuyển từ PoiDetailViewController qua
    @IBOutlet var imgPoi: UIImageView!
    @IBOutlet var imgSection: UIImageView!
    @IBOutlet var lblDateTime: UILabel!
    @IBOutlet var txtDesc: UITextView!
    @IBOutlet var txtTitle: UITextField!
    @IBOutlet var btnDirections: UIButton!
    @IBOutlet var map: MKMapView!
    @IBOutlet var heightMap: NSLayoutConstraint!
    @IBOutlet var heightPic: NSLayoutConstraint!
    @IBOutlet var heightTxt: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var dirW: NSLayoutConstraint!
    @IBOutlet var dirH: NSLayoutConstraint!
    
    @IBOutlet weak var lblPosition: UILabel!
    @IBOutlet weak var lblPosition1: UILabel!
    @IBOutlet weak var lblImageBearing: UILabel!
    
    var comeFromSection = true
    var section = ""
    var poiId = ""
    var poiName = ""
    private var _poiTitle: String = ""
    var poiTitle: String? {
        get { return _poiTitle }
        set (newTitle) {
            _poiTitle = newTitle!
            dataObject?.photoTitle = _poiTitle
            txtTitle.text = _poiTitle
        }
    }
    private var _poiDesc: String = ""
    var poiDesc: String? {
        get { return _poiDesc }
        set (newDesc) {
            _poiDesc = newDesc!
            dataObject?.photoDesc = _poiDesc
            txtDesc.text = _poiDesc
        }
    }
    var poiLat = ""
    var poiLon = ""
    var poiDestBearing = 0.0
    var poiDateTime = ""
    
    var interstitial = GADInterstitial(adUnitID: ADMOB_UNIT_ID_Interstitial)
    var adMobBannerView = GADBannerView()
    //

    let strokeTextAttributes = [
        NSAttributedString.Key.strokeColor : UIColor.white,
        NSAttributedString.Key.foregroundColor : UIColor.orange,
        NSAttributedString.Key.strokeWidth : -4.0,
        NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)
        ] as [NSAttributedString.Key : Any]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.mapType = DETAIL_MAP_TYPE
        // Chuyển từ PoiDetailViewController
        formatView()
        caricaPoi()
        centerMap()
        addPin()
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+200)
        
        if ADS_ENABLED && !getProVersion() {
            initAdMobBanner()
            let request = GADRequest()
            interstitial.load(request)
        } else {
            hideBanner(banner: adMobBannerView)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)

        // we want for the title to only be the image name (obtained from the file system path)
        var title = (self.dataObject?.imagePath as NSString?)?.lastPathComponent
        title = (title as NSString?)?.deletingPathExtension
        self.title = self.dataObject?.imgName
        
        self.imgPoi?.image = self.dataObject?.image
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.interstitial.isReady) {
            self.interstitial.present(fromRootViewController: self)
        }
    }
    
    
    // chuyển từ PoiDetailViewController qua
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
            v?.transform = CGAffineTransform(rotationAngle: CGFloat(poiDestBearing*DEGREE_TO_RADIAN))
        }
        
        return v
        
    }
    
    // Lấy thông tin PhotoAnntation
    func caricaPoi(){
        
        poiLat = (dataObject?._coordinate.latitude.toString(8))!
        poiLon = (dataObject?.coordinate.longitude.toString(8))!
        poiName = "\(dataObject?.imgName ?? "No name")"
        _poiTitle = "\(dataObject?.photoTitle ?? "No name")"
        _poiDesc = "\(dataObject?.photoDesc ?? "")"
        poiDestBearing  = (dataObject?.destBearing)!
        poiDateTime = (dataObject?.dateTime)!

        txtTitle.text = poiTitle
        lblDateTime.text = "🕓 \(poiDateTime)"
        txtDesc.text = poiDesc
        let hSize = txtDesc.sizeThatFits(CGSize(width: view.frame.size.width, height: view.frame.size.height))
        heightTxt.constant = hSize.height
        txtDesc.sizeThatFits(txtDesc.frame.size)
        
        imgPoi.image = dataObject?.image
        imgSection.image = #imageLiteral(resourceName: "pinPhoto")
        
        map.layer.borderWidth = 1
        map.layer.borderColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.7).cgColor
        
        lblPosition.attributedText = NSMutableAttributedString(string: "\((dataObject?._coordinate.localCoordinate(false))!)", attributes: strokeTextAttributes)
        lblPosition1.attributedText = NSMutableAttributedString(string: (dataObject?._coordinate.localizedCoordinateString2())!, attributes: strokeTextAttributes)
        lblImageBearing.attributedText = NSMutableAttributedString(string: "∡ \(poiDestBearing.toDMSString(0)) T\n\(sizeForLocalFilePath(filePath: (dataObject?.imagePath)!))", attributes: strokeTextAttributes)
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
            txtTitle.font = UIFont(name: (txtTitle.font?.fontName)!, size: 28)
            txtDesc.font = UIFont(name: (txtDesc.font?.fontName)!, size: 24)
            //btnDirections.titleLabel?.font = UIFont(name: (btnDirections.titleLabel?.font.fontName)!, size: 24)
            //dirW.constant = 32
            //dirH.constant = 32
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = UIColor.yellow
        textField.textColor = UIColor.black
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = UIColor.clear
        textField.textColor = TEXTVIEW_TEXT_COLOR_DEFAULT
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.backgroundColor = UIColor.yellow
        textView.font = TEXTVIEW_FONT_EDIT
        textView.textColor = UIColor.black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.backgroundColor = UIColor.white
        textView.font = TEXTVIEW_FONT_DEFAULT
        textView.textColor = TEXTVIEW_TEXT_COLOR_DEFAULT
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // Capj nhaatj
        let hSize = txtDesc.sizeThatFits(CGSize(width: view.frame.size.width, height: view.frame.size.height))
        heightTxt.constant = hSize.height
        txtDesc.sizeThatFits(txtDesc.frame.size)
    }
    
    // Initialize Google AdMob banner
    func initAdMobBanner() {
        adMobBannerView = GADBannerView(adSize: GADAdSizeBanner)
        self.view.addSubview(adMobBannerView)
        adMobBannerView.adUnitID = ADMOB_UNIT_ID_Banner
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        let request = GADRequest()
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
