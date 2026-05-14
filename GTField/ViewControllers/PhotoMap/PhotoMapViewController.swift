//
//  PhotoMapViewController.swift
//  PhotoMap
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/11/23.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Primary map view controller.
 */

import UIKit
import MapKit
import ImageIO
import MessageUI
import GoogleMobileAds
import Firebase

func synchronized(_ object: AnyObject, block: () -> Void) {
    objc_sync_enter(object)
    block()
    objc_sync_exit(object)
}


@objc(PhotoMapViewController)
class PhotoMapViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, GADBannerViewDelegate {
    
    var adMobBannerView = GADBannerView()
    private let interstitialHelper = InterstitialHelper()
    
    private var photos: [PhotoAnnotation] = [PhotoAnnotation]()
    private var allAnnotationsMapView: MKMapView?
    
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet var bottomTableView: NSLayoutConstraint!
    
    @IBOutlet var myCollectionView: UICollectionView!
    
    private var buttonZoomFit: UIBarButtonItem?
    private var buttonAction: UIBarButtonItem?
    
    // Dùng để zoom tới photos
    private var photosRect: MKMapRect = MKMapRect.null

    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
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
            
            self.navigationItem.rightBarButtonItem = buttonZoomFit
            
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
            
            self.navigationItem.rightBarButtonItem = buttonAction
            self.tableView.reloadData()
        }
    }

    //#MARK: -
    
    private func photoSetFromPath(_ path: String) -> [PhotoAnnotation] {
        DispatchQueue.main.async() {
            self.view?.showLoading()
            //self.mapView?.showHUD(self.mapView!)
        }
        
        
        var photos = [PhotoAnnotation]()
        
        // The bulk of our work here is going to be loading the files and looking up metadata
        // Thus, we see a major speed improvement by loading multiple photos simultaneously
        //
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 8
        
        // Get the document directory url
        let documentsUrl =  applicationDocumentsDirectory().appendingPathComponent(path)
        print(documentsUrl.path)
        var photoURLs: Array<URL>!
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            
            photoURLs = directoryContents.filter{ $0.pathExtension == "jpg" }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        print("Tong so anh:", photoURLs.count)
        
        for photoURL in photoURLs ?? [] {
            queue.addOperation {
                // RIPR: photoURL có thể không đọc được (sandbox, file deleted).
                // try! sẽ crash thread BG, app treo. Đổi sang guard + skip.
                guard let imageData = try? Data(contentsOf: photoURL),
                      let dataProvider = CGDataProvider(data: imageData as CFData),
                      let imageSource = CGImageSourceCreateWithDataProvider(dataProvider, nil),
                      let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: AnyObject] else {
                    return
                }
                //print(photoURL.lastPathComponent)
                // check if the image is geotagged
                if let gpsInfo = imageProperties[kCGImagePropertyGPSDictionary as String] as? [String: AnyObject] {
                    let keys = gpsInfo.keys
                    if keys.contains(kCGImagePropertyGPSLatitude as String),
                        keys.contains(kCGImagePropertyGPSLongitude as String),
                        keys.contains(kCGImagePropertyGPSAltitude as String),
                        keys.contains(kCGImagePropertyGPSLatitudeRef as String),
                        keys.contains(kCGImagePropertyGPSLongitudeRef as String),
                        keys.contains(kCGImagePropertyGPSDestBearing as String),
                        keys.contains(kCGImagePropertyGPSDateStamp as String),
                        keys.contains(kCGImagePropertyGPSTimeStamp as String) {
                        
                        let latitude = gpsInfo[kCGImagePropertyGPSLatitude as String] as! Double
                        
                        let longitude = gpsInfo[kCGImagePropertyGPSLongitude as String] as! Double
                        var coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        if gpsInfo[kCGImagePropertyGPSLatitudeRef as String] as? String == "S" {
                            coord.latitude = -coord.latitude
                        }
                        if gpsInfo[kCGImagePropertyGPSLongitudeRef as String] as? String == "W" {
                            coord.longitude = -coord.longitude
                        }
                        
                        let annotationPoint = MKMapPoint.init(coord)
                        let pointRect = MKMapRect.init(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1)
                        self.photosRect = self.photosRect.union(pointRect)
                        
                        var descXML = String()
                        // Đọc comment từ exif
                        if let exifInfo = imageProperties[kCGImagePropertyExifDictionary as String] as? [String: AnyObject] {
                            if let comment = exifInfo[kCGImagePropertyExifUserComment as String] as? String {
                                descXML = comment
                            }
                        }
                        
                        let photo = PhotoAnnotation(imageFile: photoURL.lastPathComponent, descXML: descXML, gpsInfo: gpsInfo,coordinate: coord, mapView: self.mapView!, allAnnotationsMapView: self.allAnnotationsMapView!)
                        
                        synchronized(photos as AnyObject) {
                            photos.append(photo)
                        }
                    }
                }
            }
        }
        
        queue.waitUntilAllOperationsAreFinished()
        
        // Zoom tới đường bao các ảnh
        zoomToPhotosRect(self)
        
        DispatchQueue.main.async() {
            self.view?.hideLoading()
            //self.mapView?.hideHUD()
        }
        
        return photos
    }
    
    private func populateMapWithAllPhotoAnnotations() {
        
        // add a temporary loading view
        let loadingStatus = LoadingStatus.defaultLoadingStatusWithWidth(self.view.frame.width)
        self.view.addSubview(loadingStatus)
        
        // loading/processing photos might take a while -- do it asynchronously
        DispatchQueue.global(qos: .default).async {
            let photos = self.photoSetFromPath("Photos")
            
            self.photos = photos
            
            DispatchQueue.main.async {
                self.allAnnotationsMapView!.addAnnotations(self.photos)
                self.updateVisibleAnnotations()
                
                loadingStatus.removeFromSuperviewWithFade()
            }
        }
    }
    
    private func annotationInGrid(_ gridMapRect: MKMapRect, usingAnnotations annotations: Set<PhotoAnnotation>) -> MKAnnotation {
        
        // first, see if one of the annotations we were already showing is in this mapRect
        let visibleAnnotatonsInBucket = self.mapView!.annotations(in: gridMapRect)
        if let annotationForGridSet = annotations.first(where: { annotation in
            visibleAnnotatonsInBucket.contains(annotation)
        })  {
            return annotationForGridSet
        }
        
        // otherwise,                                        the annotations based on their distance from the center of the grid square,
        // then choose the one closest to the center to show
        let centerMapPoint = MKMapPoint.init(x: gridMapRect.midX, y: gridMapRect.midY)
        let sortedAnnotations = annotations.sorted {obj1, obj2 in
            let mapPoint1 = MKMapPoint.init(obj1.coordinate)
            let mapPoint2 = MKMapPoint.init(obj2.coordinate)
            
            let distance1 = mapPoint1.distance(to: centerMapPoint)
            let distance2 = mapPoint2.distance(to: centerMapPoint)
            
            return distance1 < distance2
        }
        
        return sortedAnnotations[0]
    }
    
    private func updateVisibleAnnotations() {
        
        // This value to controls the number of off screen annotations are displayed.
        // A bigger number means more annotations, less chance of seeing annotation views pop in but decreased performance.
        // A smaller number means fewer annotations, more chance of seeing annotation views pop in but better performance.
        let marginFactor: Double = 2.0
        
        // Adjust this roughly based on the dimensions of your annotations views.
        // Bigger numbers more aggressively coalesce annotations (fewer annotations displayed but better performance).
        // Numbers too small result in overlapping annotations views and too many annotations on screen.
        let bucketSize: CGFloat = 60.0
        
        // find all the annotations in the visible area + a wide margin to avoid popping annotation views in and out while panning the map.
        let visibleMapRect = self.mapView!.visibleMapRect
        let adjustedVisibleMapRect = visibleMapRect.insetBy(dx: -marginFactor * visibleMapRect.size.width, dy: -marginFactor * visibleMapRect.size.height)
        
        // determine how wide each bucket will be, as a MKMapRect square
        let leftCoordinate = self.mapView!.convert(CGPoint.zero, toCoordinateFrom: self.view)
        let rightCoordinate = self.mapView!.convert(CGPoint(x: bucketSize, y: 0), toCoordinateFrom: self.view)
        let gridSize = MKMapPoint.init(rightCoordinate).x - MKMapPoint.init(leftCoordinate).x
        var gridMapRect = MKMapRect.init(x: 0, y: 0, width: gridSize, height: gridSize)
        
        // condense annotations, with a padding of two squares, around the visibleMapRect
        let startX = floor(adjustedVisibleMapRect.minX / gridSize) * gridSize
        let startY = floor(adjustedVisibleMapRect.minY / gridSize) * gridSize
        let endX = floor(adjustedVisibleMapRect.maxX / gridSize) * gridSize
        let endY = floor(adjustedVisibleMapRect.maxY / gridSize) * gridSize
        
        // for each square in our grid, pick one annotation to show
        gridMapRect.origin.y = startY
        while gridMapRect.minY <= endY {
            gridMapRect.origin.x = startX
            
            while gridMapRect.minX <= endX {
                let allAnnotationsInBucket = self.allAnnotationsMapView?.annotations(in: gridMapRect)
                let visibleAnnotationsInBucket = self.mapView!.annotations(in: gridMapRect)
                
                // we only care about PhotoAnnotations
                var filteredAnnotationsInBucket = allAnnotationsInBucket == nil ?
                    Set<PhotoAnnotation>()
                    : Set<PhotoAnnotation>(allAnnotationsInBucket!.lazy.compactMap {obj in
                    obj as? PhotoAnnotation
                    })
                
                if filteredAnnotationsInBucket.count > 0 {
                    let annotationForGrid = self.annotationInGrid(gridMapRect, usingAnnotations: filteredAnnotationsInBucket) as! PhotoAnnotation
                    
                    filteredAnnotationsInBucket.remove(annotationForGrid)
                    
                    // give the annotationForGrid a reference to all the annotations it will represent
                    annotationForGrid.containedAnnotations = Array(filteredAnnotationsInBucket)
                    
                    self.mapView!.addAnnotation(annotationForGrid)
                    
                    for annotation in filteredAnnotationsInBucket {
                        // give all the other annotations a reference to the one which is representing them
                        annotation.clusterAnnotation = annotationForGrid
                        annotation.containedAnnotations = []
                        
                        // remove annotations which we've decided to cluster
                        if visibleAnnotationsInBucket.contains(annotation) {
                            let actualCoordinate = annotation.coordinate
                            UIView.animate(withDuration: 0.3, animations: {
                                annotation.setCoordinate(annotation.clusterAnnotation!.coordinate)
                            }, completion: {finished in
                                    annotation.setCoordinate(actualCoordinate)
                                    self.mapView!.removeAnnotation(annotation)
                            }) 
                        }
                    }
                }
                
                gridMapRect.origin.x += gridSize
            }
            
            gridMapRect.origin.y += gridSize
        }
    }
    
    
    //#MARK: - UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        buttonZoomFit = UIBarButtonItem(title: NSLocalizedString("Zoom All", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(zoomToPhotosRect(_:)))
        buttonAction = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(btnAction(_:)))
        
        self.navigationItem.rightBarButtonItem = buttonZoomFit
        
        //self.photos = NSMutableArray()
        
        allAnnotationsMapView = MKMapView(frame: CGRect.zero)
        
        // now load all photos from Resources and add them as annotations to the map view
        self.populateMapWithAllPhotoAnnotations()
        
        if ADS_ENABLED && !getProVersion() {
            if UIDevice.current.userInterfaceIdiom == .pad {
                
            } else {
                
            }
            let request = GADRequest()
            interstitialHelper.load()
            initAdMobBanner()
        } else {
            hideBanner(banner: adMobBannerView)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        interstitialHelper.show(from: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // Initialize Google AdMob banner
    func initAdMobBanner() {
        switch DEVICE_WIDTH {
        case "320": //5,SE
            adMobBannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: 256, height: 40)))
            break
        case "375": //6,7
            adMobBannerView = GADBannerView(adSize: GADAdSizeBanner)
            break
        case "414": //6+,7+
            adMobBannerView = GADBannerView(adSize: GADAdSizeBanner)
            break
        case "768": //iPad
            adMobBannerView = GADBannerView(adSize: GADAdSizeFullBanner)
            break
        default:
            adMobBannerView = GADBannerView(adSize: GADAdSizeBanner)
            break
        }
        
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
    
    @IBAction private func btnAction(_ sender: AnyObject) {
        let count = self.photos.count
        let alertController = UIAlertController(title: NSLocalizedString("Select option", comment: ""), message: nil, preferredStyle: .actionSheet)
        
        let exportCSVButton = UIAlertAction(title: NSLocalizedString("Export all", comment: "")+" (\(count)) "+NSLocalizedString("photo's location to csv", comment: ""), style: .default, handler: { (action) -> Void in
            
            DispatchQueue.global().async() {
                self.view.showLoading()
            }
            
            let fileName = getFileNameByGPSTime(ext: "csv")
            
            let directory = NSTemporaryDirectory()
            
            // This returns a URL? even though it is an NSURL class method
            let fileURL = NSURL.fileURL(withPathComponents: [directory, fileName])
            
            let stream = OutputStream(toFileAtPath: (fileURL?.path)!, append: false)!
            let csv = try! CSVWriter(stream: stream)
            
            try! csv.write(row: ["Photo", "Latitude", "Longitude", "Altitude"])
            
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            
            for photo in self.photos {
                queue.addOperation {
                    try! csv.write(row: [photo.imgName!, photo.coordinate.latitude.toString(6), photo.coordinate.longitude.toString(6), photo.altitude.toString(1)])
                }
            }
            queue.waitUntilAllOperationsAreFinished()
            csv.stream.close()

            DispatchQueue.main.async() {
                self.view.hideLoading()
            }
            // TODO: email
            self.actionSendEmailCSV(fileURL!)
        })
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) -> Void in
            
        })
        
        alertController.addAction(exportCSVButton)
        alertController.addAction(cancelButton)
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.barButtonItem = sender as? UIBarButtonItem
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    internal func actionSendEmailCSV(_ fileURL: URL) {
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        if MFMailComposeViewController.canSendMail() {
            // set the subject
            composer.setSubject("[\(APP_NAME)] "+NSLocalizedString("Export photo's location to CSV file", comment: ""))
            
            //Add some text to the body and attach the file
            let body = "\(APP_FULL_NAME). " + NSLocalizedString("You can copy your files between your computer and apps on your iOS device using File Sharing.", comment: "") + " https://support.apple.com/en-us/HT201301<br />"
            
            composer.setMessageBody(body, isHTML: true)
            //composer.setToRecipients(["chuyentt@gmail.com"])
            do {
                let fileData: Data = try Data(contentsOf: URL(fileURLWithPath: fileURL.path), options: .mappedIfSafe)
                composer.addAttachmentData(fileData, mimeType:"text/csv", fileName: fileURL.lastPathComponent)
            } catch {
                
            }
            if let nav = self.navigationController {
                nav.present(composer, animated: true, completion: nil)
            } else {
                self.present(composer, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(
                title: NSLocalizedString("No email accounts configured", comment: ""),
                message: NSLocalizedString("Please add a mail account in Settings to send mail from, by Go to Settings > Mail > Accounts > Add Account", comment: ""),
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .default, handler: nil))
            
            alert.show()
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        let alert: UIAlertController
        switch result.rawValue {
        case MFMailComposeResult.sent.rawValue:
            alert = UIAlertController(
                title: NSLocalizedString("Sent", comment: ""),
                message: error?.localizedDescription,
                preferredStyle: UIAlertController.Style.alert
            )
            break
        default:
            alert = UIAlertController(
                title: NSLocalizedString("Whoops", comment: ""),
                message: error?.localizedDescription,
                preferredStyle: UIAlertController.Style.alert
            )
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .default, handler: nil))
        alert.show()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func zoomToPhotosRect(_: AnyObject) {
        
        // clear any annotations in preparation for zooming
        self.mapView!.removeAnnotations(self.mapView!.annotations)
        
        self.mapView?.setVisibleMapRect(photosRect, animated: true)
    }
    
    //#MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        self.updateVisibleAnnotations()
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
        for annotationView in views as [MKAnnotationView] {
            if !(annotationView.annotation is PhotoAnnotation) {
                continue
            }
            
            let annotation = annotationView.annotation as! PhotoAnnotation
            
            if annotation.clusterAnnotation != nil {
                // animate the annotation from it's old container's coordinate, to its actual coordinate
                let actualCoordinate = annotation.coordinate
                let containerCoordinate = annotation.clusterAnnotation!.coordinate
                
                // since it's displayed on the map, it is no longer contained by another annotation,
                // (We couldn't reset this in -updateVisibleAnnotations because we needed the reference to it here
                // to get the containerCoordinate)
                annotation.clusterAnnotation = nil
                
                annotation.setCoordinate(containerCoordinate)
                
                UIView.animate(withDuration: 0.3, animations: {
                    annotation.setCoordinate(actualCoordinate)
                }) 
            }
        }
    }
    
    func mapView(_ aMapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationIdentifier = "Photo"
        
        if aMapView != self.mapView {
            return nil
        }
        
        if annotation is PhotoAnnotation {
            var annotationView = self.mapView!.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) 
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            }
            //let pinImageName = "pin" + annotationIdentifier
            
            annotationView!.canShowCallout = true
            annotationView?.image = (annotation as! PhotoAnnotation).thumbnail //UIImage(named: pinImageName)
            let disclosureButton = UIButton(type: .detailDisclosure)
            annotationView!.rightCalloutAccessoryView = disclosureButton
            return annotationView
        }
        
        return nil
    }
    
    func photosShowFor(photo: PhotoAnnotation) {
        var photosToShow = [photo]
        photosToShow.append(contentsOf: photo.containedAnnotations)
        
        let viewController = PhotosViewController()
        viewController.edgesForExtendedLayout = UIRectEdge()
        viewController.photosToShow = photosToShow
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    // user tapped the call out accessory 'i' button
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let annotation = view.annotation as! PhotoAnnotation
        
        annotation.containedAnnotations.sort { (ann1, ann2) -> Bool in
            ann1.title! < ann2.title!
        }
        photosShowFor(photo: annotation)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is PhotoAnnotation {
            let annotation = view.annotation as! PhotoAnnotation
            annotation.updateSubtitleIfNeeded()
        }
    }
    
    // ----------------------------------------------------------------------------------
    // Main Sections Collection View
    // ----------------------------------------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PhotoTableViewCell
        let photo = self.photos[indexPath.row]
        photo.updateSubtitleFor(label: cell.lblPhotoAddress)
        cell.thumbnailView.image = photo.thumbnail
        cell.lblPhotoName.text = photo.imgName
        cell.lblPhotoDate.text = photo.dateTime
        cell.lblPhotoSize.text = photo.size
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = self.photos[indexPath.row]
        photosShowFor(photo: photo)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return self.photos.count > 0
    }
    
    func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        let photo = self.photos[indexPath.row]
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let alert = UIAlertController(
                title: NSLocalizedString("Warning delete", comment: ""),
                message: NSLocalizedString("This photo will be deleted from this app on your device", comment: ""),
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: { (action: UIAlertAction!) in
                    // Cancel
            }))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("OK", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    photo.delete(all: false)
                    
                    // gỡ khỏi photos
                    self.photos.remove(at: indexPath.row)
                    
                    // Đã bổ sung mapView và allAnnotationMapView vào PhotoAnnotation để kiểm soát việc xóa
                    tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                    tableView.reloadData()
            }))
            present(alert, animated: true, completion: nil)
        }
    }
}
