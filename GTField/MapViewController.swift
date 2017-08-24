//
//  MapViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 2/17/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
//import AEXML
import GoogleMobileAds
import Firebase
import MessageUI

let kPaneViewHeight = CGFloat(280.0)

class GTMapView: GMSMapView {
    
}

// Begin Setup JellyButton===============================================
extension MapViewController: JellyButtonDelegate
{
    func JellyButtonHasBeenTap(touch: UITouch, image: UIImage, groupindex: Int, arrindex: Int) {
        print("groupindex \(groupindex) arrindex \(arrindex)")
        if groupindex == 0 {
            switch arrindex {
            case 0: // AddGPSMarker
                self.btnAddGPSMarker()
                break
            case 1: // Record Track
                self.startUpdatingLocationAllowsBackground()
                break
            case 2: // AddMarker
                self.btnAddMarker()
                break
            case 3: // Add Polyline
                self.btnAddPolyline()
                break
            case 4: // Add Polygon
                self.btnAddPolygon()
                break
            default:
                break
            }
        }
        if groupindex == 1 {
            switch arrindex {
            case 0: // AddMarker
                self.btnAddGPSMarker()
                break
            case 1: // Done
                self.setupButtonDone()
                break
            case 2: // Reset
                self.setupButtonReset()
                break
            case 3: // Pause
                self.setupButtonPaused()
                break
            case 4: // AddMarker
                self.btnAddMarker()
                break
            case 5: // Add Polyline
                self.btnAddPolyline()
                break
            case 6: // Add Polygon
                self.btnAddPolygon()
                break
            default:
                break
            }
        }
        if groupindex == 2 {
            switch arrindex {
            case 0: // AddMarker
                self.btnAddGPSMarker()
                break
            case 1: // Done
                self.setupButtonDone()
                break
            case 2: // Reset
                self.setupButtonReset()
                break
            case 3: // Resume
                self.startUpdatingLocationAllowsBackground()
                break
            case 4: // AddMarker
                self.btnAddMarker()
                break
            case 5: // Add Polyline
                self.btnAddPolyline()
                break
            case 6: // Add Polygon
                self.btnAddPolygon()
                break
            default:
                break
            }
        }
    }
}

extension MapViewController:JDJellyButtonDataSource {
    func groupcount()-> Int {
        return iconArray.count
    }
    func imagesource(forgroup groupindex:Int) -> [UIImage] {
        return iconArray[groupindex]
    }
}

//extension MapViewController:UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return titlestr.count
//    }
//}
//
//extension MapViewController:UIPickerViewDelegate {
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        let strings:NSAttributedString = NSAttributedString(string: titlestr[row], attributes: [NSForegroundColorAttributeName:UIColor.white])
//        return strings
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        button.setJellyType(type: typerow[row])
//    }
//}
// End Setup JellyButton===============================================

extension MapViewController: GPXFilesTableViewControllerDelegate {
    func didLoadGPXFileWithName(_ gpxFilename: String, gpxRoot: AEXMLElement) {
        // Kết thúc session cũ
        self.didDeSelectOverlay()
        gpx?.clear()
        self.setupButtonDone()
        
        // Tạo mới từ file
        
        gpx = GPX(self.mapView!, gpxRoot)
        if gpx?.metadata.name != gpxFilename {
            gpx?.metadata.name = gpxFilename
            gpx?.save()
        }
    }
}

extension MapViewController: MBTileTableViewControllerDelegate {
    func didLoadMBTileFilePath(_ mbtileFilePath: String) {
        setOfflineActiveTilesPath(mbtileFilePath)
    }
}

extension MapViewController:MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.sent.rawValue:
            let alert = UIAlertView(title: NSLocalizedString("Sent", comment: ""), message: nil, delegate: nil, cancelButtonTitle: NSLocalizedString("Close", comment: ""))
            alert.show()
            break
        default:
            let alert = UIAlertView(title: NSLocalizedString("Whoops", comment: ""), message: nil, delegate: nil, cancelButtonTitle: NSLocalizedString("Close", comment: ""))
            alert.show()
        }
        self.dismiss(animated: true, completion: nil)
    }
}

import CoreMotion

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate, GMSAutocompleteTableDataSourceDelegate, GADBannerViewDelegate, MotionContainer {
    
    // Định nghĩa từ Motion Container
    var motionManager: CMMotionManager?
    
    var adMobBannerView = GADBannerView()
    var interstitial = GADInterstitial(adUnitID: ADMOB_UNIT_ID_Interstitial)
    
    var mapView: GTMapView?
    var gpx: GPX?
    
    // Viết riêng cho GeoServer
    var wmsTileLayer: WMSTileLayer?
    var offlineTileLayer: OfflineTileLayer?
    
    private var paneView: PaneView?
    private var paneLayerView: UIView?
    private var toolsView: UIView?
    private var buttonMenu: UIButton?
    private var buttonBack: UIButton?
    private var buttonSearch: UIButton?
    private var buttonSearchLocal: UIButton?
    
    // Label
    private var coordinateLabel: UILabel!
    
    // Map Controll
    private var buttonLayer: UIButton?
    private var buttonFeatureInfo: UIButton?
    private var buttonZoomIn: UIButton?
    private var buttonZoomOut: UIButton?
    private var buttonTakePhoto: UIButton?
    
    // GPX
    private var buttonFolder: UIButton?
    
    //JDJellyButton
    private var buttonRecord: JDJellyButton?
    private var buttonRecording: JDJellyButton?
    private var buttonPaused: JDJellyButton?
    var iconArray:[[UIImage]] = [[UIImage]]()
    
    // Map type
    private var buttonMapTypeDefault: MyButton?
    private var buttonMapTypeSatellite: MyButton?
    private var buttonMapTypeTerrain: MyButton?
    
    // Map source
    private var buttonMapSourceWMS: MyButton?
    private var buttonMapSourceOffline: MyButton?
    private var buttonMapSourceDownload: MyButton?
    
    // Download
    private var buttonDownload: UIButton?
    
    // Configuration...
    private var buttonMapSourceConfiguration: UIButton?
    private var isRequesFeatureInfo: Bool = false
    
    private var isLocalSearch: Bool = false
    private var searchField: UITextField?
    private var resultsController: UITableViewController?
    private var tableDataSource: GMSAutocompleteTableDataSource?
    var searchResultMarker: GMSMarker?
    var placePicker: GMSPlacePickerViewController?
    
    var didFindMyLocation = false
    
    /// Location manager used to start and stop updating location.
    let manager = CLLocationManager()
    
    /// Indicates whether the location manager is updating location.
    var isUpdatingLocation = false
    
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient?
    var zoomLevel: Float = 12.0
    
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    
    // The currently selected place.
    var selectedPlace: GMSPlace?
    
    // Danh sách thuộc tính của đối tượng tra cứu
    var arrRes = [[String:AnyObject]]()
    
    // Download tiles
    
    var urlSession: URLSession?
    var totalTileDownloaded: Int = 0
    var urlList = [String]()
    
    var tiles = [TileDownloader]()
    var operationQueue = OperationQueue()
    
    var progressView: UIProgressView?
    var progressLabel: UILabel?
    
    // Kiểm tra GeoServer
    var imageViewForCheckingGeoServer = UIImageView(image: #imageLiteral(resourceName: "IconBroken"))
    
    // Polyline
    var selectedOverlay: GPXTrackSegmentOverlay?
    
    // Polygon
    var selectedPolygonOverlay: GPXPointSegmentOverlay?
    
    var downloadTileDB: MBTileDB?
    
    var opacitySlider: UISlider?
    
    var cross:UIImageView = UIImageView(image: #imageLiteral(resourceName: "vertexCross"))
    
    var vertexView: VertexView?
    
    override func loadView() {
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
        let camera = GMSCameraPosition.camera(withLatitude: 16.5, longitude: 105.5, zoom: 5)
        mapView = GTMapView.map(withFrame: .zero, camera: camera)
        mapView?.delegate = self
        mapView?.tag = 11
        self.view = mapView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ADS_ENABLED == true {
            if UIDevice.current.userInterfaceIdiom == .pad {
                //bottomTableView.constant = 62
            } else {
                //bottomTableView.constant = 50
            }
            initAdMobBanner()
        } else {
            hideBanner(banner: adMobBannerView)
        }
        
        startUpdateMotion()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopUpdateMotion()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.imageViewForCheckingGeoServer.iconForGeoServerBaseUrl()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        createButtonRecord()
        
        self.gpx = GPX(mapView!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueGWFView") {
            let nav: UINavigationController = segue.destination as! UINavigationController
            let vc: GWFViewController = nav.viewControllers.first as! GWFViewController
            vc.arrRes = self.arrRes
        }
        if segue.identifier == "segueCamera" {
            let nav: UINavigationController = segue.destination as! UINavigationController
            let vc: CameraViewController = nav.viewControllers.first as! CameraViewController
            vc.motionManager = motionManager
        }
        if segue.identifier == "segueConfigMapSource" {
            let nav: UINavigationController = segue.destination as! UINavigationController
            let vc: ConfigMapSourceViewController = nav.viewControllers.first as! ConfigMapSourceViewController
            vc.mapViewController = self
        }

    }
    
    func setupTrackButton() {
        // Căn giữa X
//        NSLayoutConstraint(item: gpx?.startButton as Any,
//                           attribute: .centerX,
//                           relatedBy: .equal,
//                           toItem: self.view,
//                           attribute: .centerX,
//                           multiplier: 1.0,
//                           constant: 0).isActive = true
    }
    
    
    func setupView() {
        // Thêm view sửa đỉnh
        self.mapView?.settings.consumesGesturesInView = false
        
        // Bảng chi tiết khi chạm vào màn hình
        // đây sẽ là nơi hiện thông tin chi tiết
        // khi chạm vào màn hình ở chế độ bình thường thì sẽ ẩn toolsView
        // và hiện bảng paneView và chữ chập để đo, di chuyển bản đồ trong
        // lúc này sẽ thay đổi tọa độ ở paneView trong tường hợp thêm mới điểm đo
        
        self.paneView = PaneView()
        self.view.addSubview(paneView!)
        
        // ----- Tools: buttonMenu, buttonBack, buttonSearch, searchField
        // Tạo một view cao 44 chứa buttonMenu, buttonBack, buttonSearch, searchField (như của GoogleMaps)
        toolsView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 54))
        // Autolayout
        toolsView?.translatesAutoresizingMaskIntoConstraints = false
        toolsView?.backgroundColor = UIColor.white
        // Tạo bo góc
        toolsView?.layer.cornerRadius = 2.0
        // Đổ bóng
        toolsView?.layer.shadowColor = UIColor.black.cgColor
        toolsView?.layer.shadowOpacity = 0.5
        toolsView?.layer.shadowOffset = CGSize(width: 1, height: 1)
        toolsView?.layer.shadowRadius = 2
        self.view.addSubview(toolsView!)
        
        // Đặt chiều cao
        NSLayoutConstraint(item: toolsView!,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 44).isActive = true
        // Căn trái
        NSLayoutConstraint(item: toolsView!,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .leading,
                           multiplier: 1.0,
                           constant: 5).isActive = true
        // Căn phải
        NSLayoutConstraint(item: toolsView!,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .trailingMargin,
                           multiplier: 1.0,
                           constant: 5).isActive = true
        // Căn trên
        NSLayoutConstraint(item: toolsView!,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: self.topLayoutGuide,
                           attribute: .bottom,
                           multiplier: 1.0,
                           constant: 5).isActive = true
        
        //----- Button menu -----
        buttonMenu = UIButton(frame: CGRect.zero)
        buttonMenu?.translatesAutoresizingMaskIntoConstraints = false
        buttonMenu?.setImage(UIImage(named: "buttonMainMenu") as UIImage?, for: .normal)
        // Tạo bo tròn
        buttonMenu?.layer.cornerRadius = 2.0
        // Gán thẻ
        buttonMenu?.tag = 1
        // Sự kiện chạm vào nút menu
        buttonMenu?.addTarget(self, action: #selector(MapViewController.btnMenu(_:)), for: .touchUpInside)
        // Cho vào toolsView.
        toolsView?.addSubview(buttonMenu!)
        
        // Căn trái
        NSLayoutConstraint(item: buttonMenu!,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: toolsView,
                           attribute: .leading,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        // Căn giữa Y
        NSLayoutConstraint(item: buttonMenu!,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: toolsView,
                           attribute: .centerY,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        
        //----- Button back -----
        buttonBack = UIButton(frame: CGRect.zero)
        buttonBack?.isHidden = true
        buttonBack?.translatesAutoresizingMaskIntoConstraints = false
        buttonBack?.setImage(UIImage(named: "buttonBack") as UIImage?, for: .normal)
        // Tạo bo góc
        buttonBack?.layer.masksToBounds = true
        buttonBack?.layer.cornerRadius = 2.0
        // Đặt thẻ
        buttonBack?.tag = 2
        // Đặt sự kiện chạm vào nút back
        buttonBack?.addTarget(self, action: #selector(btnBack(_:)), for: .touchUpInside)
        // Cho vào toolsView
        toolsView?.addSubview(buttonBack!)
        
        // Căn trái
        NSLayoutConstraint(item: buttonBack!,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: toolsView,
                           attribute: .leading,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        // Căn giữa Y
        NSLayoutConstraint(item: buttonBack!,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: toolsView,
                           attribute: .centerY,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        
        //----- Button search -----
        buttonSearch = UIButton(frame: CGRect.zero)
        buttonSearch?.titleLabel?.font = UIFont(name: "Bauhaus-Medium", size: 12.0)
        buttonSearch?.setTitle(NSLocalizedString("<<Search on Google>>", comment: ""), for: .normal)
        buttonSearch?.sizeToFit()
        buttonSearch?.setTitleColor(UIColor.lightGray, for: .normal)
        buttonSearch?.translatesAutoresizingMaskIntoConstraints = false
        // Tạo bo góc
        buttonSearch?.layer.cornerRadius = 2.0
        // Đặt thẻ
        buttonSearch?.tag = 3
        // Đặt sự kiện chạm vào nút search
        buttonSearch?.addTarget(self, action: #selector(btnSearch(_:)), for: .touchUpInside)
        // Đặt vào toolsView
        toolsView?.addSubview(buttonSearch!)
        
        // Căn trái
        NSLayoutConstraint(item: buttonSearch!,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: buttonMenu,
                           attribute: .trailing,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        // Căn giữa Y
        NSLayoutConstraint(item: buttonSearch!,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: toolsView,
                           attribute: .centerY,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        
        //----- Button search local -----
        buttonSearchLocal = UIButton(frame: CGRect.zero)
        buttonSearchLocal?.titleLabel?.font = UIFont(name: "Bauhaus-Medium", size: 12.0)
        buttonSearchLocal?.setTitle(NSLocalizedString("<<Search local data>>", comment: ""), for: .normal)
        buttonSearchLocal?.sizeToFit()
        buttonSearchLocal?.setTitleColor(UIColor.lightGray, for: .normal)
        buttonSearchLocal?.translatesAutoresizingMaskIntoConstraints = false
        // Tạo bo góc
        buttonSearchLocal?.layer.cornerRadius = 2.0
        // Đặt thẻ
        buttonSearchLocal?.tag = 4
        // Đặt sự kiện chạm vào nút search
        buttonSearchLocal?.addTarget(self, action: #selector(btnSearch(_:)), for: .touchUpInside)
        // Đặt vào toolsView
        toolsView?.addSubview(buttonSearchLocal!)
        
        // Căn trái
        NSLayoutConstraint(item: buttonSearchLocal!,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: toolsView,
                           attribute: .leading,
                           multiplier: 1.0,
                           constant: (buttonSearch?.frame.width)!).isActive = true
        // Căn giữa Y
        NSLayoutConstraint(item: buttonSearchLocal!,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: toolsView,
                           attribute: .centerY,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        
        
        // ----- searchField -----
        // Configure the text field to our linking.
        searchField = UITextField(frame: CGRect.zero)
        searchField?.translatesAutoresizingMaskIntoConstraints = false
        searchField?.borderStyle = .none
        searchField?.backgroundColor = UIColor.white
        searchField?.placeholder = NSLocalizedString("Search...", comment: "")
        searchField?.autocorrectionType = .no
        searchField?.keyboardType = .default
        searchField?.returnKeyType = .done
        searchField?.clearButtonMode = .whileEditing
        searchField?.contentVerticalAlignment = .center
        searchField?.isHidden = true
        searchField?.allowsEditingTextAttributes = true
        searchField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchField?.delegate = self
        
        toolsView?.addSubview(searchField!)
        self.view.bringSubview(toFront: searchField!)
        
        // Căn trái so với buttonMenu
        NSLayoutConstraint(item: searchField!,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: buttonSearch,
                           attribute: .leading,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        
        // Căn phải so với toolsView
        NSLayoutConstraint(item: searchField!,
                           attribute: .trailing,
                           relatedBy: .lessThanOrEqual,
                           toItem: buttonSearchLocal,
                           attribute: .trailingMargin,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        
        // Căn giữa so với buttonMenu
        NSLayoutConstraint(item: searchField!,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: buttonMenu,
                           attribute: .centerY,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        // Chiều rộng textField
        NSLayoutConstraint(item: searchField!,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: (toolsView?.frame.width)!).isActive = true
        
        //----- CoordinateLabel -----
        coordinateLabel = UILabel()
        coordinateLabel.isUserInteractionEnabled = true
        coordinateLabel?.copyable = true
        coordinateLabel?.frame = CGRect(x: 0, y: 0, width: 320, height: 24)
        coordinateLabel?.translatesAutoresizingMaskIntoConstraints = false
        coordinateLabel?.textAlignment = .center
        coordinateLabel?.numberOfLines = 0
        coordinateLabel?.textColor = UIColor.orange
        coordinateLabel?.font=UIFont.boldSystemFont(ofSize: 12)
        self.view?.addSubview(coordinateLabel!)
        
        // Đặt chiều cao
        NSLayoutConstraint(item: coordinateLabel!,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 32).isActive = true
        // Căn trái
        NSLayoutConstraint(item: coordinateLabel!,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .leading,
                           multiplier: 1.0,
                           constant: 5).isActive = true
        // Căn phải
        NSLayoutConstraint(item: toolsView!,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .trailingMargin,
                           multiplier: 1.0,
                           constant: 5).isActive = true
        // Căn trên
        NSLayoutConstraint(item: coordinateLabel!,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: self.topLayoutGuide,
                           attribute: .bottom,
                           multiplier: 1.0,
                           constant: 54).isActive = true
        
        // Căn giữa so với view
        NSLayoutConstraint(item: coordinateLabel!,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .centerX,
                           multiplier: 1.0,
                           constant: 0).isActive = true
       
        //----- Button Layer -----
        buttonLayer = UIButton(frame: CGRect.zero)
        buttonLayer?.translatesAutoresizingMaskIntoConstraints = false
        buttonLayer?.setImage(UIImage(named: "buttonLayer") as UIImage?, for: .normal)
        // Tạo bo tròn
        buttonLayer?.layer.cornerRadius = 2.0
        // Đổ bóng
        buttonLayer?.layer.shadowColor = UIColor.black.cgColor
        buttonLayer?.layer.shadowOpacity = 1
        buttonLayer?.layer.shadowOffset = CGSize.zero
        buttonLayer?.layer.shadowRadius = 2
        // Gán thẻ
        buttonLayer?.tag = 10
        // Sự kiện chạm vào nút menu
        buttonLayer?.addTarget(self, action: #selector(MapViewController.btnLayer(_:)), for: .touchUpInside)
        // Cho vào View.
        self.view.addSubview(buttonLayer!)
        
        // Căn phải
        NSLayoutConstraint(item: buttonLayer!,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .trailingMargin,
                           multiplier: 1.0,
                           constant: 5).isActive = true
        // Căn trên
        NSLayoutConstraint(item: buttonLayer!,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: toolsView,
                           attribute: .bottom,
                           multiplier: 1.0,
                           constant: 10).isActive = true
        
        // Kết nối với GeoServer để kiểm tra
        self.view.addSubview(self.imageViewForCheckingGeoServer)
        self.imageViewForCheckingGeoServer.translatesAutoresizingMaskIntoConstraints = false
        
        // Căn trên
        NSLayoutConstraint(item: self.imageViewForCheckingGeoServer,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: buttonLayer,
                           attribute: .bottom,
                           multiplier: 1.0,
                           constant: 5).isActive = true
        // Căn giữa buttonLayer
        NSLayoutConstraint(item: self.imageViewForCheckingGeoServer,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: buttonLayer,
                           attribute: .centerX,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        
        //----- Button Folder -----
        buttonFolder = UIButton(frame: CGRect.zero)
        buttonFolder?.translatesAutoresizingMaskIntoConstraints = false
        buttonFolder?.setImage(UIImage(named: "buttonFolder") as UIImage?, for: .normal)
        // Tạo bo tròn
        buttonFolder?.layer.cornerRadius = 2.0
        // Đổ bóng
        buttonFolder?.layer.shadowColor = UIColor.black.cgColor
        buttonFolder?.layer.shadowOpacity = 1
        buttonFolder?.layer.shadowOffset = CGSize.zero
        buttonFolder?.layer.shadowRadius = 2
        // Gán thẻ
        buttonFolder?.tag = 41
        // Sự kiện chạm vào nút menu
        buttonFolder?.addTarget(self, action: #selector(MapViewController.btnFolder(_:)), for: .touchUpInside)
        // Cho vào View.
        self.view.addSubview(buttonFolder!)
        
        // Căn trái
        NSLayoutConstraint(item: buttonFolder!,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .leading,
                           multiplier: 1.0,
                           constant: 5).isActive = true
        // Căn trên
        NSLayoutConstraint(item: buttonFolder!,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: toolsView,
                           attribute: .bottom,
                           multiplier: 1.0,
                           constant: 10).isActive = true
        
        //----- Button FeatureInfo -----
        // Nên để chế độ khi di chuyển đến đường bao WFSLayer thì mới hiện nút Info
        // Khi chạm nút info thì hiển thị thông báo trên màn hình
        //
        buttonFeatureInfo = UIButton(frame: CGRect.zero)
        buttonFeatureInfo?.translatesAutoresizingMaskIntoConstraints = false
        buttonFeatureInfo?.setImage(UIImage(named: "buttonFeatureInfo") as UIImage?, for: .normal)
        // Tạo bo tròn
        buttonFeatureInfo?.layer.cornerRadius = 2.0
        // Đổ bóng
        buttonFeatureInfo?.layer.shadowColor = UIColor.black.cgColor
        buttonFeatureInfo?.layer.shadowOpacity = 0.3
        buttonFeatureInfo?.layer.shadowOffset = CGSize.zero
        buttonFeatureInfo?.layer.shadowRadius = 1
        // Gán thẻ
        buttonFeatureInfo?.tag = 11
        // Sự kiện chạm vào nút menu
        buttonFeatureInfo?.addTarget(self, action: #selector(MapViewController.btnFeatureInfo(_:)), for: .touchUpInside)
        // Cho vào View.
        self.view.addSubview(buttonFeatureInfo!)
        
//        // Căn phải
//        NSLayoutConstraint(item: buttonFeatureInfo!,
//                           attribute: .trailing,
//                           relatedBy: .equal,
//                           toItem: self.view,
//                           attribute: .trailingMargin,
//                           multiplier: 1.0,
//                           constant: 5).isActive = true
        // Căn trên
        NSLayoutConstraint(item: buttonFeatureInfo!,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: buttonLayer,
                           attribute: .bottom,
                           multiplier: 1.0,
                           constant: 25).isActive = true
        
        // Căn giữa buttonLayer
        NSLayoutConstraint(item: buttonFeatureInfo!,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: buttonLayer,
                           attribute: .centerX,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        
        //----- Button ZoomIn -----
        buttonZoomIn = UIButton(frame: CGRect.zero)
        buttonZoomIn?.translatesAutoresizingMaskIntoConstraints = false
        buttonZoomIn?.setImage(UIImage(named: "buttonZoomIn") as UIImage?, for: .normal)
        // Tạo bo tròn
        buttonZoomIn?.layer.cornerRadius = 2.0
        // Đổ bóng
        buttonZoomIn?.layer.shadowColor = UIColor.black.cgColor
        buttonZoomIn?.layer.shadowOpacity = 0.3
        buttonZoomIn?.layer.shadowOffset = CGSize.zero
        buttonZoomIn?.layer.shadowRadius = 1
        // Gán thẻ
        buttonZoomIn?.tag = 0
        // Sự kiện chạm vào nút menu
        buttonZoomIn?.addTarget(self, action: #selector(MapViewController.btnZoom(_:)), for: .touchUpInside)
        // Cho vào View.
        self.view.addSubview(buttonZoomIn!)
        
//        // Căn phải
//        NSLayoutConstraint(item: buttonZoomIn!,
//                           attribute: .trailing,
//                           relatedBy: .equal,
//                           toItem: self.view,
//                           attribute: .trailingMargin,
//                           multiplier: 1.0,
//                           constant: 5).isActive = true
        // Căn giữa Y
        NSLayoutConstraint(item: buttonZoomIn!,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: mapView,
                           attribute: .centerY,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        
        // Căn giữa buttonLayer
        NSLayoutConstraint(item: buttonZoomIn!,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: buttonLayer,
                           attribute: .centerX,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        
        //----- Button ZoomOut -----
        buttonZoomOut = UIButton(frame: CGRect.zero)
        buttonZoomOut?.translatesAutoresizingMaskIntoConstraints = false
        buttonZoomOut?.setImage(UIImage(named: "buttonZoomOut") as UIImage?, for: .normal)
        // Tạo bo tròn
        buttonZoomOut?.layer.cornerRadius = 2.0
        // Đổ bóng
        buttonZoomOut?.layer.shadowColor = UIColor.black.cgColor
        buttonZoomOut?.layer.shadowOpacity = 0.3
        buttonZoomOut?.layer.shadowOffset = CGSize.zero
        buttonZoomOut?.layer.shadowRadius = 1
        // Gán thẻ
        buttonZoomOut?.tag = 1
        // Sự kiện chạm vào nút menu
        buttonZoomOut?.addTarget(self, action: #selector(MapViewController.btnZoom(_:)), for: .touchUpInside)
        // Cho vào View.
        self.view.addSubview(buttonZoomOut!)
        
//        // Căn phải
//        NSLayoutConstraint(item: buttonZoomOut!,
//                           attribute: .trailing,
//                           relatedBy: .equal,
//                           toItem: self.view,
//                           attribute: .trailingMargin,
//                           multiplier: 1.0,
//                           constant: 5).isActive = true
        // Căn trên
        NSLayoutConstraint(item: buttonZoomOut!,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: buttonZoomIn,
                           attribute: .bottom,
                           multiplier: 1.0,
                           constant: 15).isActive = true
        
        // Căn giữa buttonLayer
        NSLayoutConstraint(item: buttonZoomOut!,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: buttonLayer,
                           attribute: .centerX,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        
        //----- Button TakePhoto -----
        //
        buttonTakePhoto = UIButton(frame: CGRect.zero)
        buttonTakePhoto?.translatesAutoresizingMaskIntoConstraints = false
        buttonTakePhoto?.setImage(UIImage(named: "buttonTakePhoto") as UIImage?, for: .normal)
        // Tạo bo tròn
        buttonTakePhoto?.layer.cornerRadius = 2.0
        // Đổ bóng
        buttonTakePhoto?.layer.shadowColor = UIColor.black.cgColor
        buttonTakePhoto?.layer.shadowOpacity = 0.3
        buttonTakePhoto?.layer.shadowOffset = CGSize.zero
        buttonTakePhoto?.layer.shadowRadius = 1
        // Gán thẻ
        buttonTakePhoto?.tag = 21
        // Sự kiện chạm vào nút
        buttonTakePhoto?.addTarget(self, action: #selector(btnTakePhoto), for: .touchUpInside)
        // Cho vào View.
        self.view.addSubview(buttonTakePhoto!)
        
//        // Căn phải
//        NSLayoutConstraint(item: buttonTakePhoto!,
//                           attribute: .trailing,
//                           relatedBy: .equal,
//                           toItem: self.view,
//                           attribute: .trailingMargin,
//                           multiplier: 1.0,
//                           constant: 5).isActive = true
        // Căn trên
        NSLayoutConstraint(item: buttonTakePhoto!,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: buttonZoomOut,
                           attribute: .bottom,
                           multiplier: 1.0,
                           constant: 15).isActive = true
        
        // Căn giữa buttonLayer
        NSLayoutConstraint(item: buttonTakePhoto!,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: buttonLayer,
                           attribute: .centerX,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        
        // Setup the results view controller.
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource?.delegate = self
        resultsController = UITableViewController(style: .plain)
        resultsController?.view.layer.shadowColor = UIColor.black.cgColor
        resultsController?.view.layer.shadowOpacity = 0.5
        resultsController?.view.layer.shadowOffset = CGSize(width: 1, height: 1)
        resultsController?.view.layer.cornerRadius = 2.0
        resultsController?.tableView.delegate = tableDataSource
        resultsController?.tableView.dataSource = tableDataSource
        
        // SearchResultSelected
        searchResultMarker = GMSMarker();
        
        self.startUpdatingLocation(forChecking: true)
        placesClient = GMSPlacesClient.shared()
    }
    
    @IBAction func btnAction(_ sender: UIBarButtonItem) {
        //self.navigationController?.popViewController(animated: true)
        self.performSegue(withIdentifier: "segueCamera", sender: self)
    }

    func btnTakePhoto() {
        self.performSegue(withIdentifier: "segueCamera", sender: self)
    }
    
    func createButtonRecord() {
        let iconRecord:[UIImage] = [#imageLiteral(resourceName: "buttonAddGPS"),#imageLiteral(resourceName: "buttonAddTrack"),#imageLiteral(resourceName: "buttonAddWaypoint"),#imageLiteral(resourceName: "buttonAddPolyline"),#imageLiteral(resourceName: "buttonAddPolygon")]
        let iconRecording:[UIImage] = [#imageLiteral(resourceName: "buttonAddGPS"),#imageLiteral(resourceName: "buttonDone"),#imageLiteral(resourceName: "buttonReset"),#imageLiteral(resourceName: "buttonPause")]
        let iconPaused:[UIImage] = [#imageLiteral(resourceName: "buttonAddGPS"),#imageLiteral(resourceName: "buttonDone"),#imageLiteral(resourceName: "buttonReset"),#imageLiteral(resourceName: "buttonResume")]
        iconArray.append(iconRecord)
        iconArray.append(iconRecording)
        iconArray.append(iconPaused)
        
        //----- Button Record -----
        buttonRecord = JDJellyButton(rootView: self.view)
        buttonRecord?.attachtoView(rootView: self.view,
                                   mainbutton: #imageLiteral(resourceName: "buttonAddMarker"),
                                   frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        
        buttonRecord?.delegate = self
        buttonRecord?.datasource = self
        buttonRecord?.setJellyType(type: .LeftLine)
        buttonRecord?.Container.translatesAutoresizingMaskIntoConstraints = false
        
//        // Căn phải
//        NSLayoutConstraint(item: buttonRecord?.Container! as Any,
//                           attribute: .trailing,
//                           relatedBy: .equal,
//                           toItem: self.view,
//                           attribute: .trailingMargin,
//                           multiplier: 1.0,
//                           constant: -44).isActive = true
        // Căn dưới
        NSLayoutConstraint(item: buttonRecord?.Container! as Any,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.bottomLayoutGuide,
                           attribute: .top,
                           multiplier: 1.0,
                           constant: -140).isActive = true
        
        // Căn giữa buttonLayer
        NSLayoutConstraint(item: buttonRecord?.Container! as Any,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: buttonLayer,
                           attribute: .centerX,
                           multiplier: 1.0,
                           constant: -22).isActive = true

        //=====
        buttonRecording = JDJellyButton(rootView: self.view)
        buttonRecording?.attachtoView(rootView: self.view,
                                   mainbutton: #imageLiteral(resourceName: "buttonRecording"),
                                   frame: CGRect(x: 0, y: 0, width: 54, height: 54))
        buttonRecording?.delegate = self
        buttonRecording?.datasource = self
        buttonRecording?.setJellyType(type: .LeftLine)
        buttonRecording?.Container.translatesAutoresizingMaskIntoConstraints = false
        
        // Căn phải
        NSLayoutConstraint(item: buttonRecording?.Container! as Any,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .trailingMargin,
                           multiplier: 1.0,
                           constant: -44).isActive = true
        // Căn dưới
        NSLayoutConstraint(item: buttonRecording?.Container! as Any,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.bottomLayoutGuide,
                           attribute: .top,
                           multiplier: 1.0,
                           constant: -140).isActive = true
        buttonRecording?.MainButton.isHidden = true
        
        //=====
        buttonPaused = JDJellyButton(rootView: self.view)
        buttonPaused?.attachtoView(rootView: self.view,
                                      mainbutton: #imageLiteral(resourceName: "buttonPaused"),
                                      frame: CGRect(x: 0, y: 0, width: 54, height: 54))
        buttonPaused?.delegate = self
        buttonPaused?.datasource = self
        buttonPaused?.setJellyType(type: .LeftLine)
        buttonPaused?.Container.translatesAutoresizingMaskIntoConstraints = false
        
        // Căn phải
        NSLayoutConstraint(item: buttonPaused?.Container! as Any,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .trailingMargin,
                           multiplier: 1.0,
                           constant: -44).isActive = true
        // Căn dưới
        NSLayoutConstraint(item: buttonPaused?.Container! as Any,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.bottomLayoutGuide,
                           attribute: .top,
                           multiplier: 1.0,
                           constant: -140).isActive = true
        buttonPaused?.MainButton.isHidden = true
    
        // opacitySlider
        opacitySlider = UISlider(frame:CGRect(x: 20, y: 260, width: 280, height: 20))
        opacitySlider?.minimumValue = 0
        opacitySlider?.maximumValue = 1
        opacitySlider?.isContinuous = true
        opacitySlider?.tintColor = UIColor.red
        opacitySlider?.value = 1
        opacitySlider?.addTarget(self, action: #selector(opacitySliderValueChange(sender:)), for: .valueChanged)
        opacitySlider?.translatesAutoresizingMaskIntoConstraints = false
        opacitySlider?.isHidden = true
        self.mapView?.addSubview(opacitySlider!)
        
        // Căn trái
        NSLayoutConstraint(item: opacitySlider!,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .leading,
                           multiplier: 1.0,
                           constant: (toolsView?.frame.width)!/4).isActive = true
        // Căn phải
        NSLayoutConstraint(item: opacitySlider!,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .trailingMargin,
                           multiplier: 1.0,
                           constant: -(toolsView?.frame.width)!/4).isActive = true

        // Căn dưới
        NSLayoutConstraint(item: opacitySlider! as Any,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.paneView,
                           attribute: .top,
                           multiplier: 1.0,
                           constant: -15).isActive = true

        
    }
    
    func opacitySliderValueChange(sender:UISlider!) {
        if wmsTileLayer != nil {
            wmsTileLayer?.opacity = sender.value
        } else if offlineTileLayer != nil {
            offlineTileLayer?.opacity = sender.value
        }
    }
    
    func setupButtonRecord() {
        buttonRecord?.MainButton.isHidden = false
        buttonRecording?.MainButton.isHidden = true
        buttonRecording?.MainButton.stopFlashing()
        buttonPaused?.MainButton.isHidden = true
        buttonRecord?.MainButton.GroupIndex = 0
        gpx?.status = .notStarted
        self.stopUpdatingLocation()
    }
    
    func setupButtonRecording() {
        buttonRecord?.MainButton.isHidden = true
        buttonRecording?.MainButton.isHidden = false
        buttonRecording?.MainButton.startFlashing()
        buttonPaused?.MainButton.isHidden = true
        buttonRecording?.MainButton.GroupIndex = 1
        gpx?.status = .tracking
    }
    
    func setupButtonPaused() {
        buttonRecord?.MainButton.isHidden = true
        buttonRecording?.MainButton.isHidden = true
        buttonRecording?.MainButton.stopFlashing()
        buttonPaused?.MainButton.isHidden = false
        buttonPaused?.MainButton.GroupIndex = 2
        gpx?.status = .paused
        self.stopUpdatingLocation()
    }
    
    func setupButtonReset() {
        print("Reset")
        gpx?.actions = .reset
        self.setupButtonRecord()
    }
    
    func setupButtonDone() {
        print("Done")
        gpx?.actions = .done
        self.setupButtonRecord()
    }
    
    
    func btnAddGPSMarker() {
        if let location = self.mapView?.myLocation?.coordinate {
            let ele = (self.mapView?.myLocation?.altitude)!
            let wpt = GPXWaypoint(position: location)
            wpt.ele = ele.toString(2)
            gpx?.addWaypoint(wpt)
            if ENABLE_SOUND_EFFECT {
                SoundPlayer.play(file: "snap.mp3")
            }
        }
    }
    
    func btnAddMarker() {
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.toolbar.barStyle = .black
        self.navigationController?.toolbar.tintColor = UIColor.white
        self.navigationController?.toolbarItems?.removeAll()
        
        hideSomeView()
        
        cross.center = (self.mapView?.center)!
        self.mapView?.addSubview(cross)
        
        var items = [UIBarButtonItem]()
        items.append(
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelAddMarker))
        )
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        )
        items.append(
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didDoneAddMarker))
        )
        self.navigationController?.toolbar.items = items
    }
    
    func btnAddPolyline() {
        self.gpx?.newTrackSegment()
        self.gpx?.currentTrackSegment?.actions = .editing
        selectedOverlay = self.gpx?.currentTrackSegment?.overlay
        didSelectOverlay()
        didEditOverlay()
    }
    
    func btnAddPolygon() {
        self.gpx?.newPointSegment()
        self.gpx?.currentPointSegment?.actions = .editing
        selectedPolygonOverlay = self.gpx?.currentPointSegment?.overlay
        didSelectOverlay()
        didEditOverlay()
    }

    func didSelectOverlay() {
        hideSomeView()
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.toolbar.barStyle = .black
        self.navigationController?.toolbar.tintColor = UIColor.white
        self.navigationController?.toolbarItems?.removeAll()
        var items = [UIBarButtonItem]()
        if selectedOverlay != nil {
            let editable = selectedOverlay?.trackSegment.root.attributes["type"] != "tracks"
            if editable {
                items.append(
                    UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didEditOverlay))
                )
            }
        } else if selectedPolygonOverlay != nil {
            let editable = selectedPolygonOverlay?.pointSegment.root.attributes["type"] != "tracks"
            if editable {
                items.append(
                    UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didEditOverlay))
                )
            }
        }
        
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        )
        items.append(
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didDeSelectOverlay))
        )
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        )
        items.append(
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didDeleteOverlay))
        )
        self.navigationController?.toolbar.items = items
    }
    
    func didEditOverlay() {
        if selectedOverlay != nil {
            selectedOverlay?.trackSegment.actions = .editing
        } else if selectedPolygonOverlay != nil {
            selectedPolygonOverlay?.pointSegment.actions = .editing
        }
        
        self.navigationController?.toolbarItems?.removeAll()
        var items = [UIBarButtonItem]()
        items.append(
            UIBarButtonItem(image: #imageLiteral(resourceName: "removeVertex"), style: UIBarButtonItemStyle.done, target: self, action: #selector(removeActiveVertex))
        )
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        )
        items.append(
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didResetOverlay))
        )
        items.append(
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        )
        items.append(
            UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didSaveOverlay))
        )
        self.navigationController?.toolbar.items = items
        
    }
    
    func didSaveOverlay() {
        selectedOverlay?.trackSegment.actions = .done
        selectedPolygonOverlay?.pointSegment.actions = .done
        selectedOverlay = nil
        selectedPolygonOverlay = nil
        gpx?.save()
        self.navigationController?.isToolbarHidden = true
        self.showSomeView()
        
        if (self.interstitial.isReady) {
            self.interstitial.present(fromRootViewController: self)
        }
    }
    
    func didResetOverlay() {
        selectedOverlay?.trackSegment.actions = .none
        selectedPolygonOverlay?.pointSegment.actions = .none
        selectedOverlay = nil
        selectedPolygonOverlay = nil
        self.navigationController?.isToolbarHidden = true
        self.showSomeView()
    }
    
    func didDeSelectOverlay() {
        selectedOverlay?.trackSegment.actions = .none
        selectedPolygonOverlay?.pointSegment.actions = .none
        selectedOverlay = nil
        selectedPolygonOverlay = nil
        self.navigationController?.isToolbarHidden = true
        self.showSomeView()
    }
    
    func didDeleteOverlay() {
        if selectedOverlay != nil {
            selectedOverlay?.trackSegment.delete()
            selectedOverlay = nil
        }
        if selectedPolygonOverlay != nil {
            selectedPolygonOverlay?.pointSegment.delete()
            selectedPolygonOverlay = nil
        }
    }
    
    func didCancelAddMarker() {
        didDeSelectOverlay()
        cross.removeFromSuperview()
        showSomeView()
    }
    
    func didDoneAddMarker() {
        let location = self.mapView?.center
        let coord = self.mapView?.projection.coordinate(for: location!)
        let wpt = GPXWaypoint(position: coord!)
        wpt.iconType = ""
        wpt.icon = #imageLiteral(resourceName: "pin")
        gpx?.addWaypoint(wpt)
        didDeSelectOverlay()
        cross.removeFromSuperview()
        showSomeView()
        
        if (self.interstitial.isReady) {
            self.interstitial.present(fromRootViewController: self)
        }
    }
    
    func removeActiveVertex() {
        if selectedOverlay != nil {
            selectedOverlay?.trackSegment.deleteActiveVertex()
        } else if selectedPolygonOverlay != nil {
            selectedPolygonOverlay?.pointSegment.deleteActiveVertex()
        }
    }
    
    @IBAction func btnMenu(_ sender: Any) {
        if self.operationQueue.operations.isEmpty {
            btnClose(sender)
        } else {
            // create the alert
            let alert = UIAlertController(title: NSLocalizedString("Downloading!", comment: ""), message: "Please wait while downloading the map!", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertActionStyle.default, handler: {
                alert -> Void in
                return
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        print("Back ")
        buttonBack?.isHidden = true
        searchField?.isHidden = true
        searchField?.resignFirstResponder()
        buttonMenu?.isHidden = false
        buttonSearch?.isHidden = false
    }
    
    @IBAction func btnSearch(_ sender: UIButton) {
        isLocalSearch = true
        if sender.tag == 3 {
            isLocalSearch = false
        }
        buttonBack?.isHidden = false
        searchField?.isHidden = false
        searchField?.becomeFirstResponder()
        buttonMenu?.isHidden = true
        buttonSearch?.isHidden = true
    }
    
    @IBAction func btnClose(_ sender: Any) {
        // Kiểm tra nếu đang lưu lộ trình thì thông báo
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways && isUpdatingLocation {
            let alert = UIAlertController(
                title: NSLocalizedString("Warning close", comment: ""),
                message: NSLocalizedString("You are in a route recording session. If close this map view, it will not continue recording", comment: ""),
                preferredStyle: UIAlertControllerStyle.alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (alert) -> Void in
                
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: { (alert) -> Void in
                // Dừng dịch vụ định vị
                if #available(iOS 9.0, *) {
                    self.manager.allowsBackgroundLocationUpdates = false
                } else {
                    // Fallback on earlier versions
                }
                self.stopUpdatingLocation()
                // TODO: Lưu lại nếu cần thiết
                
                self.actionClose()
            }))
            // show the alert
            present(alert, animated: true, completion: nil)
        } else {
            self.actionClose()
        }
    }
    
    func actionClose() {
        self.gpx?.save()
        // Thoát view
        self.dismiss(animated: true) {
            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        }
    }
    
    @IBAction func btnLayer(_ sender: AnyObject) {
        togglePaneView(10)
        if (self.interstitial.isReady) {
            self.interstitial.present(fromRootViewController: self)
        }
    }
    
    @IBAction func btnFolder(_ sender: AnyObject) {
        let vc = GPXFilesTableViewController(nibName: nil, bundle: nil)
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true) { () -> Void in }
        
        if (self.interstitial.isReady) {
            self.interstitial.present(fromRootViewController: vc)
        }
    }
    
    
    @IBAction func btnFeatureInfo(_ sender: AnyObject) {
        // Kiểm tra nếu không kết nối được với GeoServer thì thông báo
        let img = self.imageViewForCheckingGeoServer.image
        if img == #imageLiteral(resourceName: "IconBroken") {
            // create the alert
            let alert = UIAlertController(title: NSLocalizedString("Could not connect to GeoServer!", comment: ""), message: NSLocalizedString("Please verify GeoServer Base Url", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertActionStyle.default, handler: {
                alert -> Void in
                return
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        } else {
            self.isRequesFeatureInfo = true
            // Hiện thông báo trên màn map
        }
        if (self.interstitial.isReady) {
            self.interstitial.present(fromRootViewController: self)
        }
    }
    
    @IBAction func btnZoom(_ sender: AnyObject) {
        switch sender.tag {
        case 0:
            //Zoom In
            self.mapView?.animate(toZoom: (mapView?.camera.zoom)!+1)
            break
        case 1:
            //Zoom Out
            self.mapView?.animate(toZoom: (mapView?.camera.zoom)!-1)
            break
        default:
            break
        }
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        tableDataSource?.sourceTextHasChanged(textField.text)
    }
    
    func hideSomeView() {
        self.toolsView?.isHidden = true
        
        // Ẩn buttonLayer khi chạm vào map
        self.buttonLayer?.isHidden = true
        self.buttonFeatureInfo?.isHidden = true
        self.buttonZoomIn?.isHidden = true
        self.buttonZoomOut?.isHidden = true
        self.buttonFolder?.isHidden = true
        self.buttonTakePhoto?.isHidden = true
        UserDefaults.standard.set(self.buttonRecord?.MainButton.isHidden, forKey: "buttonRecordMainButtonisHidden")
        UserDefaults.standard.synchronize()
        UserDefaults.standard.set(self.buttonRecording?.MainButton.isHidden, forKey: "buttonRecordingMainButtonisHidden")
        UserDefaults.standard.synchronize()
        UserDefaults.standard.set(self.buttonPaused?.MainButton.isHidden, forKey: "buttonPausedMainButtonisHidden")
        UserDefaults.standard.synchronize()
        
        self.buttonRecord?.MainButton.closingButtonGroup(expandagain: false)
        self.buttonRecording?.MainButton.closingButtonGroup(expandagain: false)
        self.buttonPaused?.MainButton.closingButtonGroup(expandagain: false)
        
        self.buttonRecord?.MainButton.isHidden = true
        self.buttonRecording?.MainButton.isHidden = true
        self.buttonPaused?.MainButton.isHidden = true
    }
    
    func showSomeView() {
        self.toolsView?.isHidden = false
        self.buttonLayer?.isHidden = false
        self.buttonFeatureInfo?.isHidden = false
        self.buttonZoomIn?.isHidden = false
        self.buttonZoomOut?.isHidden = false
        self.buttonFolder?.isHidden = false
        self.buttonTakePhoto?.isHidden = false
        self.buttonRecord?.MainButton.isHidden = UserDefaults.standard.value(forKey: "buttonRecordMainButtonisHidden") as! Bool
        self.buttonRecording?.MainButton.isHidden = UserDefaults.standard.value(forKey: "buttonRecordingMainButtonisHidden") as! Bool
        self.buttonPaused?.MainButton.isHidden = UserDefaults.standard.value(forKey: "buttonPausedMainButtonisHidden") as! Bool
        
        // Ẩn opacitySlider
        self.opacitySlider?.isHidden = true
    }
    
    @IBAction func togglePaneView(_ id: UInt) {
        let padding = mapView?.padding
        UIView.animate(withDuration: 0.3) {
            let size = self.view.bounds.size
            if ((padding?.bottom != 0.0 && id == 0) || id == 9999) { // Ẩn pane
                self.paneView?.frame = CGRect(x: 0, y: size.height, width: size.width, height: 0)
                self.mapView?.padding = UIEdgeInsets.zero
                
                self.showSomeView()
                
                // Trả về zoom mặc định
                self.mapView?.setMinZoom(0, maxZoom: 21)
                self.paneView?.subviews.forEach { $0.removeFromSuperview() }
                
            } else { // Hiện pane
                self.paneView?.frame = CGRect(x: 0, y: (size.height - kPaneViewHeight), width: size.width, height: kPaneViewHeight)
                self.paneView?.layer.zPosition = 100
                self.mapView?.padding = UIEdgeInsets(top: 0, left: 0, bottom: kPaneViewHeight, right: 0)
                
                self.hideSomeView()
                
                // Hiện opacitySlider
                if self.wmsTileLayer?.map != nil {
                    self.opacitySlider?.isHidden = false
                    self.opacitySlider?.value = (self.wmsTileLayer?.opacity)!
                } else if self.offlineTileLayer?.map != nil {
                    self.opacitySlider?.isHidden = false
                    self.opacitySlider?.value = (self.offlineTileLayer?.opacity)!
                }
                
                switch (id)
                {
                case 10: // buttonLayer
                    // Tiêu đề "Map type"
                    let mapTypeLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
                    mapTypeLabel.text = NSLocalizedString("Map type", comment: "")
                    mapTypeLabel.textColor = UIColor.black
                    mapTypeLabel.font = UIFont(name: "Bauhaus-Medium", size: 14.0)
                    mapTypeLabel.translatesAutoresizingMaskIntoConstraints = false
                    
                    self.paneView?.addSubview(mapTypeLabel)
                    
                    // Căn trái
                    NSLayoutConstraint(item: mapTypeLabel,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: self.paneView,
                                       attribute: .leading,
                                       multiplier: 1.0,
                                       constant: 5).isActive = true
                    
                    // Căn trên
                    NSLayoutConstraint(item: mapTypeLabel,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: self.paneView,
                                       attribute: .top,
                                       multiplier: 1.0,
                                       constant: 15).isActive = true
                    
                    let imageSize : CGSize = CGSize(width: 80, height: 56)
                    let gap : CGFloat = 0
                    let borderSize : CGFloat = 1
                    let textHeight : CGFloat = 25
                    let paddingTop : CGFloat = 20
                    let buttonWidth : CGFloat = borderSize * 2 + gap * 2 + imageSize.width
                    let buttonHeight : CGFloat = borderSize * 2 + gap * 3 + imageSize.height + textHeight
                    let imageOrigin : CGFloat = borderSize + gap
                    let textTop : CGFloat = imageOrigin + imageSize.height + gap
                    let textBottom : CGFloat = borderSize + gap
                    let imageBottom : CGFloat = textBottom + textHeight + gap
                    let titleLabelFont =  UIFont(name: "Bauhaus-Light", size: 13.0)
                    
                    // BUTTON1
                    self.buttonMapTypeDefault = MyButton()
                    self.buttonMapTypeDefault?.tag = 1
                    self.buttonMapTypeDefault?.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
                    self.buttonMapTypeDefault?.translatesAutoresizingMaskIntoConstraints = false
                    
                    //Image
                    self.buttonMapTypeDefault?.setImage(UIImage(named: "buttonMapTypeDefault") as UIImage?,
                                                        for: UIControlState.normal)
                    self.buttonMapTypeDefault?.setImage(UIImage(named: "buttonMapTypeDefault"), for: UIControlState.highlighted)
                    self.buttonMapTypeDefault?.imageEdgeInsets = UIEdgeInsets(top: imageOrigin, left: imageOrigin, bottom: imageBottom, right: imageOrigin)
                    
                    //Text
                    self.buttonMapTypeDefault?.setTitle(NSLocalizedString("Default", comment: ""), for: UIControlState.normal)
                    self.buttonMapTypeDefault?.titleLabel?.font = titleLabelFont
                    self.buttonMapTypeDefault?.setTitleColor(self.view.tintColor, for: UIControlState.normal)
                    self.buttonMapTypeDefault?.setTitleColor(self.view.tintColor, for: UIControlState.highlighted)
                    self.buttonMapTypeDefault?.titleEdgeInsets = UIEdgeInsets(top: textTop, left: -imageSize.width, bottom: textBottom, right: 0.0)
                    self.buttonMapTypeDefault?.addTarget(self, action: #selector(MapViewController.btnMapType(_:)), for: .touchUpInside)
                    
                    
                    // BUTTON2
                    self.buttonMapTypeSatellite = MyButton()
                    self.buttonMapTypeSatellite?.tag = 2
                    self.buttonMapTypeSatellite?.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
                    self.buttonMapTypeSatellite?.translatesAutoresizingMaskIntoConstraints = false
                    
                    //Image
                    self.buttonMapTypeSatellite?.setImage(UIImage(named: "buttonMapTypeSatellite") as UIImage?,
                                                          for: UIControlState.normal)
                    self.buttonMapTypeSatellite?.setImage(UIImage(named: "buttonMapTypeSatellite"), for: UIControlState.highlighted)
                    self.buttonMapTypeSatellite?.imageEdgeInsets = UIEdgeInsets(top: imageOrigin, left: imageOrigin, bottom: imageBottom, right: imageOrigin)
                    
                    //Text
                    self.buttonMapTypeSatellite?.setTitle(NSLocalizedString("Satellite", comment: ""), for: UIControlState.normal)
                    self.buttonMapTypeSatellite?.titleLabel?.font = titleLabelFont
                    self.buttonMapTypeSatellite?.setTitleColor(self.view.tintColor, for: UIControlState.normal)
                    self.buttonMapTypeSatellite?.setTitleColor(self.view.tintColor, for: UIControlState.highlighted)
                    self.buttonMapTypeSatellite?.titleEdgeInsets = UIEdgeInsets(top: textTop, left: -imageSize.width, bottom: textBottom, right: 0.0)
                    self.buttonMapTypeSatellite?.addTarget(self, action: #selector(MapViewController.btnMapType(_:)), for: .touchUpInside)
                    
                    
                    // BUTTON3
                    self.buttonMapTypeTerrain = MyButton()
                    self.buttonMapTypeTerrain?.tag = 3
                    self.buttonMapTypeTerrain?.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
                    self.buttonMapTypeTerrain?.translatesAutoresizingMaskIntoConstraints = false
                    
                    //Image
                    self.buttonMapTypeTerrain?.setImage(UIImage(named: "buttonMapTypeTerrain") as UIImage?,
                                                        for: UIControlState.normal)
                    self.buttonMapTypeTerrain?.setImage(UIImage(named: "buttonMapTypeTerrain"), for: UIControlState.highlighted)
                    self.buttonMapTypeTerrain?.imageEdgeInsets = UIEdgeInsets(top: imageOrigin, left: imageOrigin, bottom: imageBottom, right: imageOrigin)
                    
                    //Text
                    self.buttonMapTypeTerrain?.setTitle(NSLocalizedString("Terrain", comment: ""), for: UIControlState.normal)
                    self.buttonMapTypeTerrain?.titleLabel?.font = titleLabelFont
                    self.buttonMapTypeTerrain?.setTitleColor(self.view.tintColor, for: UIControlState.normal)
                    self.buttonMapTypeTerrain?.setTitleColor(self.view.tintColor, for: UIControlState.highlighted)
                    self.buttonMapTypeTerrain?.titleEdgeInsets = UIEdgeInsets(top: textTop, left: -imageSize.width, bottom: textBottom, right: 0.0)
                    self.buttonMapTypeTerrain?.addTarget(self, action: #selector(MapViewController.btnMapType(_:)), for: .touchUpInside)
                    
                    self.paneView?.addSubview(self.buttonMapTypeDefault!)
                    self.paneView?.addSubview(self.buttonMapTypeSatellite!)
                    self.paneView?.addSubview(self.buttonMapTypeTerrain!)
                    
                    // ================ Căn chỉnh button2 (giữa) ================
                    // Căn trên
                    NSLayoutConstraint(item: self.buttonMapTypeSatellite!,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: mapTypeLabel,
                                       attribute: .bottom,
                                       multiplier: 1.0,
                                       constant: paddingTop).isActive = true
                    
                    // Căn giữa X
                    NSLayoutConstraint(item: self.buttonMapTypeSatellite!,
                                       attribute: .centerX,
                                       relatedBy: .equal,
                                       toItem: self.paneView,
                                       attribute: .centerX,
                                       multiplier: 1.0,
                                       constant: 0).isActive = true
                    
                    // Chiều rộng button
                    NSLayoutConstraint(item: self.buttonMapTypeSatellite!,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: imageSize.width).isActive = true
                    // Chiều cao button
                    NSLayoutConstraint(item: self.buttonMapTypeSatellite!,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: imageSize.height+textHeight).isActive = true
                    
                    // ================ Căn chỉnh button1 (trái) ================
                    // Căn trên
                    NSLayoutConstraint(item: self.buttonMapTypeDefault!,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: mapTypeLabel,
                                       attribute: .bottom,
                                       multiplier: 1.0,
                                       constant: paddingTop).isActive = true
                    
                    // Căn trái so với pane
                    NSLayoutConstraint(item: self.buttonMapTypeDefault!,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: self.paneView,
                                       attribute: .leading,
                                       multiplier: 1.0,
                                       constant: 30).isActive = true
                    
                    // Chiều rộng button
                    NSLayoutConstraint(item: self.buttonMapTypeDefault!,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: imageSize.width).isActive = true
                    // Chiều cao button
                    NSLayoutConstraint(item: self.buttonMapTypeDefault!,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: imageSize.height+textHeight).isActive = true
                    
                    // ================ Căn chỉnh button3 (phải) ================
                    // Căn trên
                    NSLayoutConstraint(item: self.buttonMapTypeTerrain!,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: mapTypeLabel,
                                       attribute: .bottom,
                                       multiplier: 1.0,
                                       constant: paddingTop).isActive = true
                    
                    // Căn phải so với pane
                    NSLayoutConstraint(item: self.buttonMapTypeTerrain!,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: self.view,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: -30).isActive = true
                    
                    // Chiều rộng button
                    NSLayoutConstraint(item: self.buttonMapTypeTerrain!,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: imageSize.width).isActive = true
                    // Chiều cao button
                    NSLayoutConstraint(item: self.buttonMapTypeTerrain!,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: imageSize.height+textHeight).isActive = true
                    
                    
                    // Tiêu đề "Map source"
                    let mapSourceLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
                    mapSourceLabel.text = NSLocalizedString("Map source", comment: "")
                    mapSourceLabel.textColor = UIColor.black
                    mapSourceLabel.font = UIFont(name: "Bauhaus-Medium", size: 14.0)
                    mapSourceLabel.translatesAutoresizingMaskIntoConstraints = false
                    
                    self.paneView?.addSubview(mapSourceLabel)
                    
                    // Căn trái
                    NSLayoutConstraint(item: mapSourceLabel,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: self.paneView,
                                       attribute: .leading,
                                       multiplier: 1.0,
                                       constant: 5).isActive = true
                    
                    // Căn trên
                    NSLayoutConstraint(item: mapSourceLabel,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: self.paneView,
                                       attribute: .centerY,
                                       multiplier: 1.0,
                                       constant: 15).isActive = true
                    
                    // TẠO NÚT CẤU HÌNH MAPSOURCE buttonMapSourceConfiguration
                    self.buttonMapSourceConfiguration = UIButton()
                    self.buttonMapSourceConfiguration?.tag = 21
                    self.buttonMapSourceConfiguration?.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
                    self.buttonMapSourceConfiguration?.titleLabel?.font = UIFont(name: "Bauhaus-Medium", size: 18.0)
                    self.buttonMapSourceConfiguration?.setTitleColor(self.view.tintColor, for: UIControlState.normal)
                    self.buttonMapSourceConfiguration?.setTitleColor(UIColor.red, for: UIControlState.highlighted)
                    self.buttonMapSourceConfiguration?.translatesAutoresizingMaskIntoConstraints = false
                    self.buttonMapSourceConfiguration?.setTitle(NSLocalizedString("Configuration...", comment: ""), for: UIControlState.normal)
                    self.buttonMapSourceConfiguration?.addTarget(self, action: #selector(MapViewController.btnMapSource(_:)), for: .touchUpInside)
                    
                    
                    self.paneView?.addSubview(self.buttonMapSourceConfiguration!)
                    
                    // Căn phải
                    NSLayoutConstraint(item: self.buttonMapSourceConfiguration!,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: self.paneView,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: -15).isActive = true
                    
                    // Căn trên
                    NSLayoutConstraint(item: self.buttonMapSourceConfiguration!,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: self.paneView,
                                       attribute: .centerY,
                                       multiplier: 1.0,
                                       constant: 10).isActive = true

                    
                    // Các nút cho Map source
                    // 1) buttonMapSourceWMS
                    self.buttonMapSourceWMS = MyButton()
                    self.buttonMapSourceWMS?.tag = 11
                    self.buttonMapSourceWMS?.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
                    self.buttonMapSourceWMS?.translatesAutoresizingMaskIntoConstraints = false
                    
                    //Image
                    self.buttonMapSourceWMS?.setImage(UIImage(named: "buttonMapSourceWMS") as UIImage?,
                                                      for: UIControlState.normal)
                    self.buttonMapSourceWMS?.setImage(UIImage(named: "buttonMapSourceWMS"), for: UIControlState.highlighted)
                    self.buttonMapSourceWMS?.imageEdgeInsets = UIEdgeInsets(top: imageOrigin, left: imageOrigin, bottom: imageBottom, right: imageOrigin)
                    
                    //Text
                    self.buttonMapSourceWMS?.setTitle(NSLocalizedString("GeoServer", comment: ""), for: UIControlState.normal)
                    self.buttonMapSourceWMS?.titleLabel?.font = titleLabelFont
                    self.buttonMapSourceWMS?.setTitleColor(self.view.tintColor, for: UIControlState.normal)
                    self.buttonMapSourceWMS?.setTitleColor(self.view.tintColor, for: UIControlState.highlighted)
                    self.buttonMapSourceWMS?.titleEdgeInsets = UIEdgeInsets(top: textTop, left: -imageSize.width, bottom: textBottom, right: 0.0)
                    self.buttonMapSourceWMS?.addTarget(self, action: #selector(MapViewController.btnMapSource(_:)), for: .touchUpInside)
                    
                    // Nút remove ở góc
                    self.buttonMapSourceWMS?.isCornerButtonEnabled = true
                    self.buttonMapSourceWMS?.cornerButton.tag = 22
                    self.buttonMapSourceWMS?.cornerButton.addTarget(self, action: #selector(self.btnMapSource(_:)), for: .touchUpInside)
                    
                    
                    // 2) buttonMapSourceOffline
                    self.buttonMapSourceOffline = MyButton()
                    self.buttonMapSourceOffline?.tag = 12
                    self.buttonMapSourceOffline?.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
                    self.buttonMapSourceOffline?.translatesAutoresizingMaskIntoConstraints = false
                    
                    //Image
                    self.buttonMapSourceOffline?.setImage(UIImage(named: "buttonMapSourceOffline") as UIImage?,
                                                          for: UIControlState.normal)
                    self.buttonMapSourceOffline?.setImage(UIImage(named: "buttonMapSourceOffline"), for: UIControlState.highlighted)
                    self.buttonMapSourceOffline?.imageEdgeInsets = UIEdgeInsets(top: imageOrigin, left: imageOrigin, bottom: imageBottom, right: imageOrigin)
                    
                    //Text
                    self.buttonMapSourceOffline?.setTitle(NSLocalizedString("Offline Map", comment: ""), for: UIControlState.normal)
                    self.buttonMapSourceOffline?.titleLabel?.font = titleLabelFont
                    self.buttonMapSourceOffline?.setTitleColor(self.view.tintColor, for: UIControlState.normal)
                    self.buttonMapSourceOffline?.setTitleColor(self.view.tintColor, for: UIControlState.highlighted)
                    self.buttonMapSourceOffline?.titleEdgeInsets = UIEdgeInsets(top: textTop, left: -imageSize.width, bottom: textBottom, right: 0.0)
                    self.buttonMapSourceOffline?.addTarget(self, action: #selector(MapViewController.btnMapSource(_:)), for: .touchUpInside)
                    
                    // Nút remove ở góc
                    self.buttonMapSourceOffline?.isCornerButtonEnabled = true
                    self.buttonMapSourceOffline?.cornerButton.tag = 23
                    self.buttonMapSourceOffline?.cornerButton.addTarget(self, action: #selector(self.btnMapSource(_:)), for: .touchUpInside)
                    
                    
                    // 3) buttonMapSourceDownload
                    self.buttonMapSourceDownload = MyButton()
                    self.buttonMapSourceDownload?.tag = 13
                    self.buttonMapSourceDownload?.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
                    self.buttonMapSourceDownload?.translatesAutoresizingMaskIntoConstraints = false
                    
                    //Image
                    self.buttonMapSourceDownload?.setImage(UIImage(named: "buttonMapSourceDownload") as UIImage?,
                                                       for: UIControlState.normal)
                    self.buttonMapSourceDownload?.setImage(UIImage(named: "buttonMapSourceDownload"), for: UIControlState.highlighted)
                    self.buttonMapSourceDownload?.imageEdgeInsets = UIEdgeInsets(top: imageOrigin, left: imageOrigin, bottom: imageBottom, right: imageOrigin)
                    
                    //Text
                    self.buttonMapSourceDownload?.setTitle(NSLocalizedString("Download", comment: ""), for: UIControlState.normal)
                    self.buttonMapSourceDownload?.titleLabel?.font = titleLabelFont
                    self.buttonMapSourceDownload?.setTitleColor(self.view.tintColor, for: UIControlState.normal)
                    self.buttonMapSourceDownload?.setTitleColor(self.view.tintColor, for: UIControlState.highlighted)
                    self.buttonMapSourceDownload?.titleEdgeInsets = UIEdgeInsets(top: textTop, left: -imageSize.width, bottom: textBottom, right: 0.0)
                    self.buttonMapSourceDownload?.addTarget(self, action: #selector(MapViewController.btnMapSource(_:)), for: .touchUpInside)
                    
                    self.paneView?.addSubview(self.buttonMapSourceWMS!)
                    self.paneView?.addSubview(self.buttonMapSourceOffline!)
                    self.paneView?.addSubview(self.buttonMapSourceDownload!)
                    
                    // ================ Căn chỉnh buttonMapSourceOffline của Map source (giữa) ================
                    // Căn trên
                    NSLayoutConstraint(item: self.buttonMapSourceOffline!,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: mapSourceLabel,
                                       attribute: .bottom,
                                       multiplier: 1.0,
                                       constant: paddingTop).isActive = true
                    
                    // Căn giữa X
                    NSLayoutConstraint(item: self.buttonMapSourceOffline!,
                                       attribute: .centerX,
                                       relatedBy: .equal,
                                       toItem: self.paneView,
                                       attribute: .centerX,
                                       multiplier: 1.0,
                                       constant: 0).isActive = true
                    
                    // Chiều rộng button
                    NSLayoutConstraint(item: self.buttonMapSourceOffline!,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: imageSize.width).isActive = true
                    // Chiều cao button
                    NSLayoutConstraint(item: self.buttonMapSourceOffline!,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: imageSize.height+textHeight).isActive = true
                    
                    // ================ Căn chỉnh buttonMapSourceWMS (trái) ================
                    // Căn trên
                    NSLayoutConstraint(item: self.buttonMapSourceWMS!,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: mapSourceLabel,
                                       attribute: .bottom,
                                       multiplier: 1.0,
                                       constant: paddingTop).isActive = true
                    
                    // Căn trái so với pane
                    NSLayoutConstraint(item: self.buttonMapSourceWMS!,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: self.paneView,
                                       attribute: .leading,
                                       multiplier: 1.0,
                                       constant: 30).isActive = true
                    
                    // Chiều rộng button
                    NSLayoutConstraint(item: self.buttonMapSourceWMS!,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: imageSize.width).isActive = true
                    // Chiều cao button
                    NSLayoutConstraint(item: self.buttonMapSourceWMS!,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: imageSize.height+textHeight).isActive = true
                    
                    // ================ Căn chỉnh buttonMapSourceDownload (phải) ================
                    // Căn trên
                    NSLayoutConstraint(item: self.buttonMapSourceDownload!,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: mapSourceLabel,
                                       attribute: .bottom,
                                       multiplier: 1.0,
                                       constant: paddingTop).isActive = true
                    
                    // Căn phải so với pane
                    NSLayoutConstraint(item: self.buttonMapSourceDownload!,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: self.view,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: -30).isActive = true
                    
                    // Chiều rộng button
                    NSLayoutConstraint(item: self.buttonMapSourceDownload!,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: imageSize.width).isActive = true
                    // Chiều cao button
                    NSLayoutConstraint(item: self.buttonMapSourceDownload!,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: imageSize.height+textHeight).isActive = true
                    
                    
                    
                    
                    
                    if (self.mapView?.mapType == GMSMapViewType.normal) {
                        self.buttonMapTypeDefault?.pressedDown = true
                        self.buttonMapTypeSatellite?.pressedDown = false
                        self.buttonMapTypeTerrain?.pressedDown = false
                    } else if (self.mapView?.mapType == GMSMapViewType.satellite) {
                        self.buttonMapTypeDefault?.pressedDown = false
                        self.buttonMapTypeSatellite?.pressedDown = true
                        self.buttonMapTypeTerrain?.pressedDown = false
                    } else if (self.mapView?.mapType == GMSMapViewType.terrain) {
                        self.buttonMapTypeDefault?.pressedDown = false
                        self.buttonMapTypeSatellite?.pressedDown = false
                        self.buttonMapTypeTerrain?.pressedDown = true
                    }
                    
                    // Đặt highlighted cho các nút map source
                    if self.wmsTileLayer?.map == self.mapView {
                        self.buttonMapSourceWMS?.pressedDown = true
                        self.buttonMapSourceOffline?.pressedDown = false
                    } else if self.offlineTileLayer?.map == self.mapView {
                        self.buttonMapSourceWMS?.pressedDown = false
                        self.buttonMapSourceOffline?.pressedDown = true
                    }
                    
                    break
                case 11: // mapView
                    // Gỡ hết các subviews trên pane
                    self.paneView?.subviews.forEach { $0.removeFromSuperview() }
                    
                case 13: // Download map
                    // Gỡ hết các subviews trên pane
                    self.paneView?.subviews.forEach { $0.removeFromSuperview() }
                    
                    let imageSize : CGSize = CGSize(width: 80, height: 56)
                    let gap : CGFloat = 0
                    let borderSize : CGFloat = 1
                    let textHeight : CGFloat = 25
                    let buttonWidth : CGFloat = borderSize * 2 + gap * 2 + imageSize.width
                    let buttonHeight : CGFloat = borderSize * 2 + gap * 3 + imageSize.height + textHeight
                    let imageOrigin : CGFloat = borderSize + gap
                    let textTop : CGFloat = imageOrigin + imageSize.height + gap
                    let textBottom : CGFloat = borderSize + gap
                    let imageBottom : CGFloat = textBottom + textHeight + gap
                    let titleLabelFont =  UIFont(name: "Bauhaus-Light", size: 13.0)
                    
                    // Progress
                    // Create Progress View Control
                    self.progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.default)
                    self.progressView?.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
                    self.progressView?.translatesAutoresizingMaskIntoConstraints = false
                    self.progressView?.setProgress(0.0, animated: false)
                    self.paneView?.addSubview(self.progressView!)
                    
                    // Add Label
                    self.progressLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
                    self.progressLabel?.text = NSLocalizedString("Download Map", comment: "")
                    self.progressLabel?.translatesAutoresizingMaskIntoConstraints = false
                    self.paneView?.addSubview(self.progressLabel!)
                    
                    // ================ Căn chỉnh progressLabel (giữa) ================
                    // Căn trên
                    NSLayoutConstraint(item: self.progressLabel!,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: self.paneView,
                                       attribute: .top,
                                       multiplier: 1.0,
                                       constant: 25).isActive = true
                    // Căn giữa X
                    NSLayoutConstraint(item: self.progressLabel!,
                                       attribute: .centerX,
                                       relatedBy: .equal,
                                       toItem: self.paneView,
                                       attribute: .centerX,
                                       multiplier: 1.0,
                                       constant: 0).isActive = true
                    
                    // ================ Căn chỉnh progressView (giữa) ================
                    // Căn trên
                    NSLayoutConstraint(item: self.progressView!,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: self.progressLabel,
                                       attribute: .bottom,
                                       multiplier: 1.0,
                                       constant: 25).isActive = true
                    // Căn giữa X
                    NSLayoutConstraint(item: self.progressView!,
                                       attribute: .centerX,
                                       relatedBy: .equal,
                                       toItem: self.paneView,
                                       attribute: .centerX,
                                       multiplier: 1.0,
                                       constant: 0).isActive = true
                    // Chiều rộng
                    NSLayoutConstraint(item: self.progressView!,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: (self.paneView?.frame.width)!-30).isActive = true
                    
                    // 1) buttonDownload
                    self.buttonDownload = MyButton()
                    self.buttonDownload?.tag = 13 // Chưa dùng đến
                    self.buttonDownload?.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
                    self.buttonDownload?.translatesAutoresizingMaskIntoConstraints = false
                    
                    //Image
                    self.buttonDownload?.setImage(UIImage(named: "buttonMapSourceDownload") as UIImage?,
                                                          for: UIControlState.normal)
                    self.buttonDownload?.setImage(UIImage(named: "buttonMapSourceDownload"), for: UIControlState.highlighted)
                    self.buttonDownload?.imageEdgeInsets = UIEdgeInsets(top: imageOrigin, left: imageOrigin, bottom: imageBottom, right: imageOrigin)
                    
                    //Text
                    self.buttonDownload?.setTitle(NSLocalizedString("Download", comment: ""), for: UIControlState.normal)
                    self.buttonDownload?.titleLabel?.font = titleLabelFont
                    self.buttonDownload?.setTitleColor(self.view.tintColor, for: UIControlState.normal)
                    self.buttonDownload?.setTitleColor(self.view.tintColor, for: UIControlState.highlighted)
                    self.buttonDownload?.titleEdgeInsets = UIEdgeInsets(top: textTop, left: -imageSize.width, bottom: textBottom, right: 0.0)
                    self.buttonDownload?.addTarget(self, action: #selector(MapViewController.btnMapSourceDownload(_:)), for: .touchUpInside)
                    
                    self.paneView?.addSubview(self.buttonDownload!)
                    
                    // ================ Căn chỉnh buttonDownload của Map source (giữa) ================
                    // Căn dưới
                    NSLayoutConstraint(item: self.buttonDownload!,
                                       attribute: .bottom,
                                       relatedBy: .equal,
                                       toItem: self.bottomLayoutGuide,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: -15).isActive = true
                    
                    // Căn giữa X
                    NSLayoutConstraint(item: self.buttonDownload!,
                                       attribute: .centerX,
                                       relatedBy: .equal,
                                       toItem: self.paneView,
                                       attribute: .centerX,
                                       multiplier: 1.0,
                                       constant: 0).isActive = true
                    
                    // Chiều rộng button
                    NSLayoutConstraint(item: self.buttonDownload!,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: imageSize.width).isActive = true
                    // Chiều cao button
                    NSLayoutConstraint(item: self.buttonDownload!,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: imageSize.height+textHeight).isActive = true
                    
                    if !self.operationQueue.operations.isEmpty {
                        self.buttonDownload?.isHidden = true
                    }
                    break
                default:
                    
                    break
                }
            }
        } // Kết thúc hiện pane
        self.paneView?.layoutIfNeeded()
        
        
    }
    
    class PaneView: UIView {
        var shouldSetupConstraints = true
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup()
        }
        
        override func updateConstraints() {
            if(shouldSetupConstraints) {
                // AutoLayout constraints
                shouldSetupConstraints = false
            }
            super.updateConstraints()
        }
        
        func setup () {
            // Đổ bóng
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = 1
            self.layer.shadowOffset = CGSize.zero
            self.layer.shadowRadius = 10
            self.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
            self.backgroundColor = UIColor.white
            
            // Kẻ một đường ngang ở giữa
            let aPath = UIBezierPath()
            aPath.move(to: CGPoint(x:0, y:frame.size.height/2))
            aPath.addLine(to: CGPoint(x:frame.size.width, y:frame.size.height/2))
            //Keep using the method addLineToPoint until you get to the one where about to close the path
            
            aPath.close()
            
            let layer = CAShapeLayer()
            layer.path = aPath.cgPath
            layer.strokeColor = UIColor.gray.cgColor
            layer.fillColor = UIColor.gray.cgColor
            layer.lineWidth = 0.2
            
            self.layer.addSublayer(layer)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            setup()
        }
    }
    
    
    @IBAction func btnMapType(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            mapView?.mapType = GMSMapViewType.normal
            self.buttonMapTypeDefault?.pressedDown = true
            self.buttonMapTypeSatellite?.pressedDown = false
            self.buttonMapTypeTerrain?.pressedDown = false
            break
        case 2:
            mapView?.mapType = GMSMapViewType.satellite
            self.buttonMapTypeDefault?.pressedDown = false
            self.buttonMapTypeSatellite?.pressedDown = true
            self.buttonMapTypeTerrain?.pressedDown = false
            break
        case 3:
            mapView?.mapType = GMSMapViewType.terrain
            self.buttonMapTypeDefault?.pressedDown = false
            self.buttonMapTypeSatellite?.pressedDown = false
            self.buttonMapTypeTerrain?.pressedDown = true
            break
        default:
            break
        }
        if (self.interstitial.isReady) {
            self.interstitial.present(fromRootViewController: self)
        }
    }
    
    func pathOfActiveLayersBoundary() -> GMSPath {
        let path = GMSMutablePath()
        let boxRect = CGRectFromString(getLayersBoundingBoxForWMS())
        
        let minx = Double(boxRect.origin.x)
        let miny = Double(boxRect.origin.y)
        let maxx = Double(minx + Double(boxRect.width))
        let maxy = Double(miny + Double(boxRect.height))
        
        path.addLatitude(maxy, longitude: minx)
        path.addLatitude(maxy, longitude: maxx)
        path.addLatitude(miny, longitude: maxx)
        path.addLatitude(miny, longitude: minx)
        return path
    }
    
    func pathOfActiveLayersBoundaryForWFS() -> GMSPath {
        let path = GMSMutablePath()
        let boxRect = CGRectFromString(getLayersBoundingBoxForWFS())
        
        let minx = Double(boxRect.origin.x)
        let miny = Double(boxRect.origin.y)
        let maxx = Double(minx + Double(boxRect.width))
        let maxy = Double(miny + Double(boxRect.height))
        
        path.addLatitude(maxy, longitude: minx)
        path.addLatitude(maxy, longitude: maxx)
        path.addLatitude(miny, longitude: maxx)
        path.addLatitude(miny, longitude: minx)
        return path
    }
    
    // Tạo GMSPath từ bounds của mbtiles
    func pathForBounds(bounds: String) -> GMSPath {
        let path = GMSMutablePath()
        let arr = bounds.components(separatedBy: ",")
        if arr.count == 4 {
            let minx = Double(arr[0])
            let miny = Double(arr[1])
            let maxx = Double(arr[2])
            let maxy = Double(arr[3])
            path.addLatitude(maxy!, longitude: minx!)
            path.addLatitude(maxy!, longitude: maxx!)
            path.addLatitude(miny!, longitude: maxx!)
            path.addLatitude(miny!, longitude: minx!)
        }
        return path
    }
    
    @IBAction func btnMapSourceDownload(_ sender: UIButton) {
        // Khi hiện pane download, xuất hiện các đối tượng:
        // - Cho phép chọn độ sâu download từ mức zoom hiện tại đến mức zoom 20,21
        // - Cho phép nhập tên: title, abstract (tạm thời chỉ cho một bản offline)
        // - Nút Download xuất hiện (khi chưa nhấn download thì có thể chạm vào map để bỏ qua,
        // - Nhấn nút download thì sẽ xuất hiện progress, khóa các chức năng khác
        // - Hiện nút cancel để có thể bỏ qua, mở các chức năng khác
        self.operationQueue.isSuspended = false
        if !self.operationQueue.operations.isEmpty {
            // create the alert
            let alert = UIAlertController(title: NSLocalizedString("Downloading", comment: ""), message: NSLocalizedString("Please wait!", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertActionStyle.default, handler: {
                alert -> Void in
                return
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        } else if self.tiles.count == 0 { // Không còn tiles lỗi
            // Gỡ nút download
            
            let delayQueue = DispatchQueue.main
            let additionalTime: DispatchTimeInterval = .seconds(2)
            self.view.showHUD(self.paneView!)
            self.buttonDownload?.isHidden = true          
            
            // Tạo tên file mặc định tự tăng
            let fileName = NSLocalizedString("Download", comment: "")
            var tileName = fileName
            var mbtilesURL = docsURL.appendingPathComponent(tileName).appendingPathExtension(kMBTileFileExt)
            var counter = 0
            while FileManager.default.fileExists(atPath: mbtilesURL.path) {
                counter += 1
                tileName = "\(fileName)\(counter)"
                mbtilesURL = docsURL.appendingPathComponent(tileName).appendingPathExtension(kMBTileFileExt)
            }

            self.downloadTileDB = MBTileDB(path: mbtilesURL.path)
            DOWNLOADING_PATH_TO_DATABASE = mbtilesURL.path
            
            // Yêu cầu nhập mô tả tile mỗi lần tải
            let alertController = UIAlertController(title: NSLocalizedString("Type Your Download Description", comment: ""), message: "", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {
                alert -> Void in
                let textField = alertController.textFields![0] as UITextField
                delayQueue.asyncAfter(deadline: .now() + additionalTime) {
                    let minZoom: UInt = UInt((self.mapView?.camera.zoom)!)
                    let maxZoom: UInt = 20
                    
                    // Test make offline
                    let box = GMSCoordinateBounds(region: (self.mapView?.projection.visibleRegion())!)
                    let tileAbstract = (textField.text?.length)! > 0 ? textField.text : "GTField Map Offline"
                    
                    // Danh sách đường dẫn tải tiles
                    self.urlList = (self.wmsTileLayer?.tileUrlList(tileName, minZoom, maxZoom, box))!
                    
                    print("Min zoom", minZoom)
                    print("Max zoom", maxZoom)
                    print("Tiles", self.urlList.count)
                    
                    let bounds = "\(box.southWest.longitude),\(box.southWest.latitude),\(box.northEast.longitude),\(box.northEast.latitude)"
                    let centerx = (box.southWest.longitude + box.northEast.longitude)/2
                    let centery = (box.southWest.latitude + box.northEast.latitude)/2
                    let center = "\(centerx),\(centery)"
                    self.downloadTileDB?.saveToMetadata(name: "version", value: MB_TILES_VERSION)
                    self.downloadTileDB?.saveToMetadata(name: "bounds", value: bounds)
                    self.downloadTileDB?.saveToMetadata(name: "center", value: center)
                    self.downloadTileDB?.saveToMetadata(name: "format", value: "png")
                    self.downloadTileDB?.saveToMetadata(name: "description", value: tileAbstract!)
                    self.downloadTileDB?.saveToMetadata(name: "name", value: tileName)
                    
                    // Tiến hành download
                    self.totalTileDownloaded = 0
                    self.operationQueue.maxConcurrentOperationCount = 4
                    
                    
                    for url in self.urlList {
                        let tileRecord = TileRecord(name: url)
                        self.tiles.append(TileDownloader(tileRecord: tileRecord))
                    }
                    self.operationQueue.cancelAllOperations()
                    self.operationQueue.addOperations(self.tiles, waitUntilFinished: false)
                    self.operationQueue.addObserver(self, forKeyPath: "operations", options: .new, context: nil)
                    
                    self.view.hideHUD()
                }
            }))
            
            alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
                textField.placeholder = NSLocalizedString("Description of the layer", comment: "")
                textField.keyboardAppearance = .dark
                textField.autocapitalizationType = .sentences
            })
            self.present(alertController, animated: true, completion: nil)
            
        } else {  // Vẫn còn tiles bị lỗi chưa tải được
            // create the alert
            let alert = UIAlertController(title: NSLocalizedString("Downloading", comment: ""), message: NSLocalizedString("There are still", comment: "")+" \(self.tiles.count) "+NSLocalizedString("previous tiles not downloaded, would you like to try again?", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertActionStyle.default, handler: {
                alert -> Void in
                self.operationQueue = OperationQueue()
                self.totalTileDownloaded = 0
                self.operationQueue.maxConcurrentOperationCount = 4
                var newTiles = [TileDownloader]()
                for tileDownloader in self.tiles {
                    let tileRecord = TileRecord(name: tileDownloader.tileRecord.name)
                    newTiles.append(TileDownloader(tileRecord: tileRecord))
                }
                self.tiles = newTiles
                self.operationQueue.addOperations(self.tiles, waitUntilFinished: false)
                self.operationQueue.addObserver(self, forKeyPath: "operations", options: .new, context: nil)
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {
                alert -> Void in
                self.tiles.removeAll()
                self.btnMapSourceDownload(UIButton())
            }))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (object as? OperationQueue) == self.operationQueue && keyPath == "operations" {
            if operationQueue.operations.isEmpty {

                // Cho vào DispatchQueue.main.async để khắc phục lỗi removeObserver hai lần
                DispatchQueue.main.async(execute: {
                    if (!self.operationQueue.isSuspended) {
                        self.operationQueue.removeObserver(self, forKeyPath:"operations")
                        self.operationQueue.isSuspended = true
                    }
                
                
                    // Kiểm tra các tiles bị failed
                    var tilesFailed = 0
                    for tileDownloader in self.tiles {
                        if tileDownloader.tileRecord.state == .downloaded {
                            self.tiles.remove(at: self.tiles.index(of: tileDownloader)!)
                        } else {
                            tilesFailed += 1
                        }
                    }
                    print("Tiles còn lại",self.tiles.count)
                    
                    // Ẩn pane
                    self.togglePaneView(9999)
                    // create the alert
                    let alert = UIAlertController(title: NSLocalizedString("All tiles in the download list have been downloaded!", comment: ""), message: "\(tilesFailed) "+NSLocalizedString("failed!", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertActionStyle.default, handler: {
                        alert -> Void in
                        return
                    }))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                })
            } else {
                DispatchQueue.main.async(execute: {
                    
                    self.totalTileDownloaded += 1
                    self.progressLabel?.text = "\(self.totalTileDownloaded) of \(self.urlList.count) "+NSLocalizedString("tiles successfull downloaded!", comment: "")
                    let progress = Float(self.totalTileDownloaded) / Float(self.urlList.count)
                    self.progressView?.progress = progress
                })
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    @IBAction func btnMapSource(_ sender: UIButton) {
        switch sender.tag {
        case 11: // GeoServer
            // Kiểm tra nếu không kết nối được với GeoServer thì thông báo
            let img = self.imageViewForCheckingGeoServer.image
            if img == #imageLiteral(resourceName: "IconBroken") {
                // create the alert
                let alert = UIAlertController(title: NSLocalizedString("Could not connect to GeoServer!", comment: ""), message: NSLocalizedString("Please verify GeoServer Base Url", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertActionStyle.default, handler: {
                    alert -> Void in
                    return
                }))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            } else {
                
                wmsTileLayer?.map = nil
                offlineTileLayer?.map = nil
                
                // Create the GMSTileLayer
                let tileSize = 256
                
                wmsTileLayer = WMSTileLayer(tileSize)
                // Display on the map at a specific zIndex
                
                wmsTileLayer?.zIndex = 100
                wmsTileLayer?.map = mapView
                self.buttonMapSourceWMS?.pressedDown = true
                self.buttonMapSourceOffline?.pressedDown = false
                if self.wmsTileLayer?.map != nil {
                    self.opacitySlider?.isHidden = false
                    self.opacitySlider?.value = (self.wmsTileLayer?.opacity)!
                } else if self.offlineTileLayer?.map != nil {
                    self.opacitySlider?.isHidden = false
                    self.opacitySlider?.value = (self.offlineTileLayer?.opacity)!
                }
            }
            break
        case 12: // Offline
            wmsTileLayer?.map = nil
            offlineTileLayer?.map = nil
            
            // Create the GMSTileLayer
            let tileSize = 256
            
            offlineTileLayer = OfflineTileLayer(tileSize)
            
            // Nếu đã có map offline
            if offlineTileLayer != nil {
                // Display on the map at a specific zIndex
                offlineTileLayer?.zIndex = 100
                offlineTileLayer?.map = mapView
                self.buttonMapSourceOffline?.pressedDown = true
                self.buttonMapSourceWMS?.pressedDown = false
                if self.wmsTileLayer?.map != nil {
                    self.opacitySlider?.isHidden = false
                    self.opacitySlider?.value = (self.wmsTileLayer?.opacity)!
                } else if self.offlineTileLayer?.map != nil {
                    self.opacitySlider?.isHidden = false
                    self.opacitySlider?.value = (self.offlineTileLayer?.opacity)!
                }
            } else {
                // create the alert
                let alert = UIAlertController(title: NSLocalizedString("No offline data", comment: ""), message: NSLocalizedString("Please goto Configuration...!", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertActionStyle.default, handler: {
                    alert -> Void in
                    
                }))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
            break
        case 13: // Download map
            
            // Nếu chưa chọn bản đồ nguồn là GeoServer
            if wmsTileLayer == nil || wmsTileLayer?.map == nil {
                // create the alert
                let alert = UIAlertController(title: NSLocalizedString("No map source is selected", comment: ""), message: NSLocalizedString("Please select GeoServer for Map source first!", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertActionStyle.default, handler: {
                    alert -> Void in
                    
                }))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            } else {
                // Di chuyển đến khu vực có bản đồ nguồn
                // Nếu khu vực hiện tại không nằm trong bản đồ nguồn thì di chuyển đến,
                // nếu đang nằm trong thì giữ nguyên
                
                let region = mapView?.projection.visibleRegion()
                let bound = GMSCoordinateBounds(region: region!)
                
                if (bound.intersects(GMSCoordinateBounds(path: pathOfActiveLayersBoundary()))) {
                    
                } else {
                    mapView?.moveCamera(GMSCameraUpdate.fit(GMSCoordinateBounds.init(path: pathOfActiveLayersBoundary())))
                }
                
                // Đặt mức zoom hiện tại là 16
                mapView?.setMinZoom(15, maxZoom: 19)
                
                // Ẩn pane layer và hiện pane download
                togglePaneView(13) // 11= record
            }
            
            break
            
        case 21: // Map source Configuration...
            self.performSegue(withIdentifier: "segueConfigMapSource", sender: sender)
            break
            
        case 22: // remove wms
            wmsTileLayer?.map = nil
            wmsTileLayer = nil
            buttonMapSourceWMS?.pressedDown = false
            self.opacitySlider?.isHidden = true
            break
        case 23: // remove offline map
            offlineTileLayer?.map = nil
            offlineTileLayer = nil
            buttonMapSourceOffline?.pressedDown = false
            self.opacitySlider?.isHidden = true
            break
        default:
            break
        }
        if (self.interstitial.isReady) {
            self.interstitial.present(fromRootViewController: self)
        }
    }
    
    class MyButton: UIButton {
        private var _cornerButton: UIButton?
        var cornerButton: UIButton {
            get {
                return _cornerButton!
            }
            set (value) {
                _cornerButton = value
            }
        }
        
        private var _isCornerButtonEnabled: Bool = false
        var isCornerButtonEnabled: Bool {
            get {
                return _isCornerButtonEnabled
            }
            set (value) {
                _isCornerButtonEnabled = value
                if value {
                    _cornerButton = UIButton(frame: CGRect(x: frame.width-16, y: 0, width: 16, height: 16))
                    _cornerButton?.setImage(#imageLiteral(resourceName: "buttonX"), for: .normal)
                    _cornerButton?.isHidden = true
                    addSubview(_cornerButton!)
                } else {
                    _cornerButton?.removeFromSuperview()
                }
            }
        }
        
        private var _pressedDown: Bool = false
        var pressedDown: Bool {
            get {
                return _pressedDown
            }
            set(value) {
                _pressedDown = value
                if value {
                    imageView?.layer.borderColor = self.tintColor.cgColor
                    imageView?.layer.borderWidth = 2
                    imageView?.layer.cornerRadius = 8
                    if _isCornerButtonEnabled {
                        _cornerButton?.isHidden = false
                        //imageEdgeInsets = UIEdgeInsetsMake(-16,0,8,0)
                    }
                } else {
                    imageView?.layer.borderColor = self.tintColor.cgColor
                    imageView?.layer.borderWidth = 0
                    imageView?.layer.cornerRadius = 0
                    if _isCornerButtonEnabled {
                        _cornerButton?.isHidden = true
                        //imageEdgeInsets = UIEdgeInsetsMake(-24,0,0,0)
                    }
                }
            }
        }
    }
    
    func addResultViewBelow(_ view: UIView) {
        
    }
    
    func autocompleteDidSelectPlace(_ place: GMSPlace) {
        self.placePicker = nil
        UIView.animate(withDuration: 0.5, animations: {
            let delta = 0.05
            let northEast = CLLocationCoordinate2D(latitude: place.coordinate.latitude + delta, longitude: place.coordinate.longitude + delta)
            let southWest = CLLocationCoordinate2D(latitude: place.coordinate.latitude - delta, longitude: place.coordinate.longitude - delta)
            let bound = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            
            // Create a place picker.
            let config = GMSPlacePickerConfig(viewport: bound)
            
            //let config = GMSPlacePickerConfig(viewport: nil) Hiển thị các địa danh lân cận
            
            let placePicker = GMSPlacePickerViewController(config: config)
            placePicker.delegate = self
            placePicker.modalPresentationStyle = .popover
            
            self.present(placePicker, animated: true, completion: nil)
            
            // Store a reference to the place picker until it's finished picking. As specified in the docs
            // we have to hold onto it otherwise it will be deallocated before it can return us a result.
            self.placePicker = placePicker
            
        }) { (finished) in
            
        }
    }
    
    func autocompleteDidFail(_ error: Error) {
        print("autocompleteDidFail")
    }
    
    func autocompleteDidCancel() {
        print("autocompleteDidCancel")
    }
    
    func actionEditTrackSegment() {
//        let tractSegment: GPXTrackSegment = (selectedOverlay?.trackSegment)!
//        let alertController = UIAlertController(title: "Type your New description or Delete this track segment", message: "current description\n\(tractSegment.desc)", preferredStyle: .alert)
//        
//        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
//            alert -> Void in
//            let textField = alertController.textFields![0] as UITextField
//            tractSegment.desc = textField.text!
//            self.gpx?.save()
//        }))
//        alertController.addAction(UIAlertAction(title: "Delete", style: .default, handler: {
//            alert -> Void in
//            tractSegment.delete()
//            self.gpx?.save()
//        }))
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
//            textField.placeholder = "New description"
//        })
//        self.present(alertController, animated: true, completion: nil)
    }
    
    func actionEditPointSegment() {
//        let pointSegment: GPXPointSegment = (selectedPolygonOverlay?.pointSegment)!
//        let alertController = UIAlertController(title: "Type your New description or Delete this point segment", message: "current description\n\(pointSegment.desc)", preferredStyle: .alert)
//        
//        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
//            alert -> Void in
//            let textField = alertController.textFields![0] as UITextField
//            pointSegment.desc = textField.text!
//            self.gpx?.save()
//        }))
//        alertController.addAction(UIAlertAction(title: "Delete", style: .default, handler: {
//            alert -> Void in
//            pointSegment.delete()
//            self.gpx?.save()
//        }))
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
//            textField.placeholder = "New description"
//        })
//        self.present(alertController, animated: true, completion: nil)
    }
    
    //#pragma mark - GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker.userData != nil {
            let attributes:[String:String] = marker.userData as! [String : String]
            if attributes.count == 2 {
                let type = attributes["type"]!
                let index = UInt(attributes["id"]!)!
                if selectedOverlay != nil {
                    if type == "vertex" {
                        selectedOverlay?.trackSegment.setActiveVertex(index)
                    } else if type == "middle" {
                        selectedOverlay?.trackSegment.insertVertex(index, marker.position)
                    }
                } else if selectedPolygonOverlay != nil {
                    if type == "vertex" {
                        selectedPolygonOverlay?.pointSegment.setActiveVertex(index)
                    } else if type == "middle" {
                        selectedPolygonOverlay?.pointSegment.insertVertex(index, marker.position)
                    }
                }
            }
        } else {
            mapView.selectedMarker = marker
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        if marker.userData != nil {
            let attributes:[String:String] = marker.userData as! [String : String]
            if attributes.count == 2 {
                let markerImage = UIImage(named: "vertexCross")!.withRenderingMode(.alwaysTemplate)
                marker.icon = markerImage
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        print("didDrag ", marker.position.localizedCoordinateString())
    }
    
    // Có thể bỏ vì đã thêm activeVertex
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        print("didEndDragging ", marker.position.localizedCoordinateString())
        if marker.userData != nil {
            let attributes:[String:String] = marker.userData as! [String : String]
            if attributes.count == 2 {
                let type = attributes["type"]!
                let index = UInt(attributes["id"]!)!
                if selectedOverlay != nil {
                    if type == "vertex" {
                        selectedOverlay?.trackSegment.updateVertex(index, marker.position)
                    } else if type == "middle" {
                        selectedOverlay?.trackSegment.insertVertex(index, marker.position)
                    }
                } else if selectedPolygonOverlay != nil {
                    if type == "vertex" {
                        selectedPolygonOverlay?.pointSegment.updateVertex(index, marker.position)
                    } else if type == "middle" {
                        selectedPolygonOverlay?.pointSegment.insertVertex(index, marker.position)
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
                if let trackSegmentOverlay: GPXTrackSegmentOverlay = overlay as? GPXTrackSegmentOverlay,
            (self.gpx?.currentPointSegment?.actions != .selecting ||
             self.gpx?.currentPointSegment?.actions != .editing) {
            selectedOverlay?.trackSegment.actions = .none
            selectedOverlay = trackSegmentOverlay
            selectedOverlay?.trackSegment.actions = .selecting
            self.didSelectOverlay()
        } else if let pointSegmentOverlay: GPXPointSegmentOverlay = overlay as? GPXPointSegmentOverlay,
            (self.gpx?.currentPointSegment?.actions != .selecting ||
             self.gpx?.currentPointSegment?.actions != .editing) {
            selectedPolygonOverlay?.pointSegment.actions = .none
            selectedPolygonOverlay = pointSegmentOverlay
            selectedPolygonOverlay?.pointSegment.actions = .selecting
            self.didSelectOverlay()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if (searchField?.isEditing)! {
            
        } else {
            // Chỉ gọi để ẩn pane khi cần thiết
            if (self.mapView?.padding.bottom != 0.0) {
                togglePaneView(0)
            } else { // Nên kiểm tra điều kiện trước khi tìm kiếm
                if self.isRequesFeatureInfo {
                    getGFeatureFor(coordinate: coordinate)
                }
                if self.gpx?.currentPointSegment?.actions == .editing {
                    self.gpx?.currentPointSegment?.addPoint(GPXPoint(coordinate.latitude, coordinate.longitude, 0, Date().iso8601))
                } else if self.gpx?.currentTrackSegment?.actions == .editing {
                    self.gpx?.currentTrackSegment?.addTrackPoint(GPXTrackPoint(coordinate.latitude, coordinate.longitude, 0, Date().iso8601), GPXTrackSegment.GPXTrackSegmentActions.editing)
                } else {
                    if selectedOverlay != nil {
                        selectedOverlay?.trackSegment.actions = .none
                        selectedOverlay = nil
                    }
                    if selectedPolygonOverlay != nil {
                        selectedPolygonOverlay?.pointSegment.actions = .none
                        selectedPolygonOverlay = nil
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let wpt: GPXWaypoint = marker as? GPXWaypoint {
            print(wpt.desc)
            let alertController = UIAlertController(title: NSLocalizedString("Type your New description or Delete this marker", comment: ""), message: NSLocalizedString("current description", comment: "")+"\n\(wpt.desc)", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default, handler: {
                alert -> Void in
                let textField = alertController.textFields![0] as UITextField
                wpt.desc = textField.text!
                self.gpx?.save()
            }))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .default, handler: {
                alert -> Void in
                wpt.delete()
                self.gpx?.save()
            }))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
            
            alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
                textField.placeholder = NSLocalizedString("New description", comment: "")
            })
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     
    */
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        coordinateLabel?.text = mapView.projection.coordinate(for: mapView.center).latLngFormated(withTarget: true)
        let region = mapView.projection.visibleRegion()
        let bound = GMSCoordinateBounds(region: region)
        
        if (bound.intersects(GMSCoordinateBounds(path: pathOfActiveLayersBoundaryForWFS()))) {
            self.buttonFeatureInfo?.isHidden = false
        } else {
            self.buttonFeatureInfo?.isHidden = true
        }
        
        // Gỡ activeVertex
        if selectedOverlay != nil, selectedOverlay?.trackSegment.actions == .editing {
            selectedOverlay?.trackSegment.deActiveVertex()
        }
        if selectedPolygonOverlay != nil, selectedPolygonOverlay?.pointSegment.actions == .editing {
            selectedPolygonOverlay?.pointSegment.deActiveVertex()
        }
    }
    
    // MARK: - GeoServer Feature Detail View
    // --------------------------------------------------------------------------------------------
    func getGFeatureFor(coordinate: CLLocationCoordinate2D) {
        self.isRequesFeatureInfo = false // Xóa thông báo trên map
        
        let url = getFeatureForWFS(typeName: getWFSActiveLayers(), propertyName: getActiveLayersPropertyName(), maxFeatures: 1)
        
        // Đổi lat lon sang tile
        let zoom: UInt = 18
        let x = lon2Tilex(lon: coordinate.longitude, z: zoom)
        let y = lat2Tiley(lat: coordinate.latitude, z: zoom)
        var bbox = bboxForTile(x: x, y: y, zoom: zoom)
        bbox.append(",EPSG:900913")
        var urlComponents = URLComponents(string: (url?.absoluteString)!)
        urlComponents?.queryItems?.append(URLQueryItem(name: "bbox", value: bbox))
        
        var request = URLRequest(url: (urlComponents?.url)!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: {(data, response, error) in
            DispatchQueue.main.async(execute: {
                if error != nil {
                    
                } else {
                    do {
                        var options = AEXMLOptions()
                        options.parserSettings.shouldProcessNamespaces = false
                        options.parserSettings.shouldReportNamespacePrefixes = false
                        options.parserSettings.shouldResolveExternalEntities = false
                        let xmlDoc = try AEXMLDocument(xml: data!, options: options)
                        let layersAll = xmlDoc.root["wfs:member"][getWFSActiveLayers()].children.map({ (properties) -> [String : AnyObject] in
                            ["name":properties.name as AnyObject,"value":properties.value as AnyObject]
                        })
                        self.arrRes = layersAll
                        if self.arrRes.count > 0 {
                            self.performSegue(withIdentifier: "segueGWFView", sender: self)
                        }
                    } catch {
                        print("Error")
                    }
                }
            })
        }).resume()
    }
    
    /**
     Informs the manager to stop updating location, invalidates the timer, and
     updates the view.
     
     If the command comes from the phone, this method sends a state update to
     the watch to inform the watch that location updates have stopped.
     */
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
        manager.delegate = nil
        if #available(iOS 9.0, *), CLLocationManager.authorizationStatus() == .authorizedAlways {
            manager.allowsBackgroundLocationUpdates = false
        }
        isUpdatingLocation = false
    }
    
    func startUpdatingLocation(forChecking: Bool) {
        if isUpdatingLocation {
            return
        }
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            //This app is authorized to start location services at any time.
            manager.delegate = self
            manager.activityType = .fitness
            manager.pausesLocationUpdatesAutomatically = true
            manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            manager.distanceFilter = TRACK_DISTANCE_FILTER
            manager.headingFilter = kCLHeadingFilterNone
            manager.headingOrientation = .landscapeLeft
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
            if #available(iOS 9.0, *), CLLocationManager.authorizationStatus() == .authorizedAlways {
                manager.allowsBackgroundLocationUpdates = true
            } else {
                
            }
            if forChecking {
                self.stopUpdatingLocation()
            } else {
                isUpdatingLocation = true
            }
            // Cấu hình mapView
            self.mapView?.isMyLocationEnabled = true
            self.mapView?.settings.myLocationButton = true
            self.mapView?.settings.compassButton = true
            break
        case .denied:
            //The user explicitly denied the use of location services for this app or location services are currently disabled in Settings.
            let alert = UIAlertController(
                title: NSLocalizedString("IMPORTANT", comment: ""),
                message: "\(APP_NAME) "+NSLocalizedString("has been denied access your location. The location services access required for embed the GPS information within the picture or display your location on the map!. To enable access, please go to app settings and turn it on.", comment: ""),
                preferredStyle: UIAlertControllerStyle.alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (alert) -> Void in
                self.stopUpdatingLocation()
                self.btnClose(0)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Settings...", comment: ""), style: .cancel, handler: { (alert) -> Void in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                self.stopUpdatingLocation()
                self.btnClose(0)
            }))
            // show the alert
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            break
        case .restricted:
            //This app is not authorized to use location services. The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
            let alert = UIAlertController(
                title: NSLocalizedString("IMPORTANT", comment: ""),
                message: "\(APP_NAME) "+NSLocalizedString("is not authorized to use location services. You cannot change this app’s status, possibly due to active restrictions such as parental controls being in place", comment: ""),
                preferredStyle: UIAlertControllerStyle.alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (alert) -> Void in
                self.stopUpdatingLocation()
                self.btnClose(0)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Settings...", comment: ""), style: .cancel, handler: { (alert) -> Void in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                self.stopUpdatingLocation()
                self.btnClose(0)
            }))
            // show the alert
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            break
        default:
            //The user has not yet made a choice regarding whether this app can use location services.
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
            break
        }
    }
    
    // Với điều kiện là đã cho phép dịch vụ định vị
    func startUpdatingLocationAllowsBackground() {
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            self.startUpdatingLocation(forChecking: false)
            self.setupButtonRecording()
            break
        case .authorizedWhenInUse:
            let alert = UIAlertController(
                title: NSLocalizedString("IMPORTANT", comment: ""),
                message: NSLocalizedString("Alway access to the location services required for use only while you are recording the track at all times in your field work. To enable Alway access, please go to app settings and select \"Alway\" option.", comment: ""),
                preferredStyle: UIAlertControllerStyle.alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (alert) -> Void in
                
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Settings...", comment: ""), style: .cancel, handler: { (alert) -> Void in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }))
            // show the alert
            present(alert, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways: // Ghi lộ trình
            self.startUpdatingLocation(forChecking: false)
            self.setupButtonRecording()
            break
        case .authorizedWhenInUse: // Nếu đồng ý
            self.startUpdatingLocation(forChecking: true)
            break
        case .restricted: // Nếu dịch vụ định vị bị vô hiệu hóa toàn bộ
            let alert = UIAlertController(
                title: NSLocalizedString("IMPORTANT", comment: ""),
                message: "\(APP_NAME) "+NSLocalizedString("is not authorized to use location services. You cannot change this app’s status, possibly due to active restrictions such as parental controls being in place", comment: ""),
                preferredStyle: UIAlertControllerStyle.alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (alert) -> Void in
                self.stopUpdatingLocation()
                self.btnClose(0)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Settings...", comment: ""), style: .cancel, handler: { (alert) -> Void in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                self.stopUpdatingLocation()
                self.btnClose(0)
            }))
            // show the alert
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            break
        case .denied:
            let alert = UIAlertController(
                title: NSLocalizedString("IMPORTANT", comment: ""),
                message: "\(APP_NAME) "+NSLocalizedString("has been denied access your location. The location services access required for embed the GPS information within the picture or display your location on the map!. To enable access, please go to app settings and turn it on.", comment: ""),
                preferredStyle: UIAlertControllerStyle.alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (alert) -> Void in
                self.stopUpdatingLocation()
                self.btnClose(0)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Settings...", comment: ""), style: .cancel, handler: { (alert) -> Void in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                self.stopUpdatingLocation()
                self.btnClose(0)
            }))
            // show the alert
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            break
        case .notDetermined:
            break
        }
    }
    
    /**
     Increases that location count by the number of locations received by the
     manager. Updates the batch count with the added locations.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if gpx?.status == .tracking {
            gpx?.addTrackPoint(GPXTrackPoint(locations.first!), .tracking)
        }
    }
    
    /// Log any errors to the console.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error occured: \(error.localizedDescription).")
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("locationManagerDidPauseLocationUpdates")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("locationManagerDidResumeLocationUpdates")
    }
    
    // Export GPX
    internal func actionSendEmailGPX(_ fileURL: URL) {
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        if MFMailComposeViewController.canSendMail() {
            // set the subject
            composer.setSubject("[\(APP_NAME)] " + NSLocalizedString("Export Waypoints & Tracks to GPX file", comment: ""))
            
            //Add some text to the body and attach the file
            let body = "\(APP_FULL_NAME). " + NSLocalizedString("You can copy your files between your computer and apps on your iOS device using File Sharing.", comment: "") + " https://support.apple.com/en-us/HT201301<br />"
            
            composer.setMessageBody(body, isHTML: true)
            //composer.setToRecipients(["chuyentt@gmail.com"])
            do {
                let fileData: Data = try Data(contentsOf: URL(fileURLWithPath: fileURL.path), options: .mappedIfSafe)
                composer.addAttachmentData(fileData, mimeType:"application/gpx+xml", fileName: fileURL.lastPathComponent)
            } catch {
                
            }
            if let nav = self.navigationController {
                nav.present(composer, animated: true, completion: nil)
            } else {
                self.present(composer, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertView(title: NSLocalizedString("No email accounts configured", comment: ""), message: NSLocalizedString("Please add a mail account in Settings to send mail from, by Go to Settings > Mail > Accounts > Add Account", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
            alert.show()
        }
    }
    
    // GMSAutocompleteTableDataSourceDelegate
    /**
     * Called when a place has been selected from the available autocomplete predictions.
     * @param tableDataSource The |GMSAutocompleteTableDataSource| that generated the event.
     * @param place The |GMSPlace| that was returned.
     */
    public func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        searchField?.resignFirstResponder()
        self.autocompleteDidSelectPlace(place)
        searchField?.text = place.name
    }
    
    /**
     * Called when a non-retryable error occurred when retrieving autocomplete predictions or place
     * details. A non-retryable error is defined as one that is unlikely to be fixed by immediately
     * retrying the operation.
     * <p>
     * Only the following values of |GMSPlacesErrorCode| are retryable:
     * <ul>
     * <li>kGMSPlacesNetworkError
     * <li>kGMSPlacesServerError
     * <li>kGMSPlacesInternalError
     * </ul>
     * All other error codes are non-retryable.
     * @param tableDataSource The |GMSAutocompleteTableDataSource| that generated the event.
     * @param error The |NSError| that was returned.
     */
    public func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        searchField?.resignFirstResponder()
        self.autocompleteDidFail(error)
        searchField?.text = ""
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        resultsController?.tableView.reloadData()
    }
    
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        resultsController?.tableView.reloadData()
        
    }
    
    // UITextFieldDelegate
    
    // MARK:- ---> Textfield Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Thêm bảng kết quả
        if isLocalSearch == true {
            
        } else {
            self.addChildViewController(resultsController!)
            resultsController?.view.translatesAutoresizingMaskIntoConstraints = false
            resultsController?.view.alpha = 0.0
            self.view.addSubview((resultsController?.view)!)
            
            // Bố cục bảng kết quả
            // Căn trên so vơi toolsView
            NSLayoutConstraint(item: resultsController?.view! as Any,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: self.toolsView,
                               attribute: .bottom,
                               multiplier: 1.0,
                               constant: 2).isActive = true
            
            // Căn dưới
            NSLayoutConstraint(item: resultsController?.view! as Any,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: self.bottomLayoutGuide,
                               attribute: .bottom,
                               multiplier: 1,
                               constant: 0).isActive = true
            
            // Căn trái
            NSLayoutConstraint(item: resultsController?.view! as Any,
                               attribute: .leading,
                               relatedBy: .equal,
                               toItem: self.toolsView,
                               attribute: .leading,
                               multiplier: 1.0,
                               constant: 0).isActive = true
            // Căn phải
            NSLayoutConstraint(item: resultsController?.view! as Any,
                               attribute: .trailing,
                               relatedBy: .equal,
                               toItem: self.toolsView,
                               attribute: .trailing,
                               multiplier: 1.0,
                               constant: 0).isActive = true
            
            // Force a layout pass otherwise the table will animate in weirdly.
            self.view.layoutIfNeeded()
            
            // Reload the data.
            self.resultsController?.tableView.reloadData()
            
            // Animate in the results.
            UIView.animate(withDuration: 0.5, animations: {
                self.resultsController?.view.alpha = 1.0
            }) { (finished) in
                self.resultsController?.didMove(toParentViewController: self)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Ẩn view kết quả
        resultsController?.willMove(toParentViewController: nil)
        UIView.animate(withDuration: 0.5, animations: {
            self.resultsController?.view.alpha = 0.0
        }) { (finished) in
            self.resultsController?.view.removeFromSuperview()
            self.resultsController?.removeFromParentViewController()
        }
        btnBack(self)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("TextField should begin editing method called")
        return true;
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        return false;
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("TextField should snd editing method called")
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("While entering the characters this method gets called")
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return false;
    }
    
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
        //request.testDevices = ["b0363f55ef349672aa7932774e71491d",kGADSimulatorID]
        interstitial.load(request)
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

extension MapViewController : GMSPlacePickerViewControllerDelegate {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Create the next view controller we are going to display and present it.
        let nextScreen = PlaceDetailViewController(place: place)
        self.splitPaneViewController?.push(viewController: nextScreen, animated: true)
        
        // Set the camera on the map to look at the specified coordinate.
        self.mapView?.camera = GMSCameraPosition(target: place.coordinate, zoom: 18, bearing: 0, viewingAngle: 0)
        
        self.searchResultMarker?.position = place.coordinate
        self.searchResultMarker?.title = place.name
        self.searchResultMarker?.snippet = place.formattedAddress
        self.searchResultMarker?.map = mapView
        
        // Dismiss the place picker.
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didFailWithError error: Error) {
        // In your own app you should handle this better, but for the demo we are just going to log
        // a message.
        NSLog("An error occurred while picking a place: \(error)")
        self.placePicker = nil
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        NSLog("The place picker was canceled by the user")
        self.placePicker = nil
        // Dismiss the place picker.
        viewController.dismiss(animated: true, completion: nil)
    }
}
