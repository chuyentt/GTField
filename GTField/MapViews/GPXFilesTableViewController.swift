//
//  GPXFilesTableViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 7/12/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import Foundation
import GoogleMaps
import MobileCoreServices

let kNoFiles = NSLocalizedString("No Item", comment: "")

import UIKit

import GoogleMobileAds
import MessageUI
import Firebase

protocol GPXFilesTableViewControllerDelegate: class {
    
    //GPXFilesTableView controller will be dismissed after calling this method
    //gpxFile is the name without extension
    func didLoadGPXFileWithName(_ gpxFilename: String, gpxRoot: AEXMLElement, add: Bool)
    func didLoadKMLFileWithName(_ kmlFilename: String)
    func didLoadGeoJSONFileWithName(_ geoJSONFilename: String)
    func didLoadMBTileFilePath(_ mbtileFilePath: String)
}

class GPXFilesTableViewController: UITableViewController, UINavigationBarDelegate, GADBannerViewDelegate {
    
    var fileList: NSMutableArray = []
    var gpxFilesFound = false;
    var selectedRowIndex = -1
    weak var delegate: GPXFilesTableViewControllerDelegate?
    var adMobBannerView = GADBannerView()
    private let interstitialHelper = InterstitialHelper()
    private let rewardedHelper = RewardedAdHelper()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Your GPX files", comment: "")
        
        let shareItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(GPXFilesTableViewController.closeGPXFilesTableViewController))
        self.navigationItem.rightBarButtonItems = [shareItem]
        
        // Thêm chức năng mở file từ Documents
        let buttonMore = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(moreAction(_:)))
        self.navigationItem.leftBarButtonItem = buttonMore
        
        //get gpx files
        self.view.showLoading()
        DispatchQueue.main.async() {
            let list: NSArray = GPXFileManager.fileList as NSArray
            if list.count != 0 {
                self.fileList.removeAllObjects()
                self.fileList.addObjects(from: list as [AnyObject])
                self.gpxFilesFound = true
            }
        }
        
        if ADS_ENABLED && !getProVersion() {
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                
            } else {
                
            }
            
            initAdMobBanner()
        } else {
            hideBanner(banner: adMobBannerView)
        }
    }
    
    // Mở file từ mục tài liệu
    @IBAction func moreAction(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeItem)], in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .pageSheet
        UINavigationBar.appearance().barTintColor = BAR_TINT_COLOR_DEFAULT
        UINavigationBar.appearance().tintColor = UIColor.darkGray
        self.present(documentPicker, animated: true, completion: {
            configMainView()
        })
    }
    
    @objc func closeGPXFilesTableViewController() {
        print("closeGPXFIlesTableViewController()")
        self.dismiss(animated: true, completion: { () -> Void in
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        interstitialHelper.show(from: self)
        self.view.hideLoading()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table view data source
    
    override func numberOfSections(in tableView: UITableView?) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of rows in the section.
        return fileList.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("GPX specification", comment: "")
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Allow editing for all rows except the initial "empty list"-placeholder row.
        // The string comparison is not optimal, but does the job.
        return gpxFilesFound
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            actionDeleteFileAtIndex((indexPath as NSIndexPath).row)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "Cell")
        //cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
        //cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"Something" ]];
        let filename = fileList.object(at: (indexPath as NSIndexPath).row) as? NSString as String? ?? ""
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.textLabel?.text = filename
        
        
        // Lấy thời gian, kích thước file...
        
        let fileURL: URL = docsURL.appendingPathComponent(filename)
        cell.detailTextLabel?.text = fileInfoDetail(filePath: fileURL.path)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filename = fileList.object(at: (indexPath as NSIndexPath).row) as? NSString as String? ?? ""
        let fileURL: URL = docsURL.appendingPathComponent(filename)
        let pathExtension = fileURL.pathExtension
        switch pathExtension.lowercased() {
        case kGPXFileExt:
            // self.showAlert(fileList.objectAtIndex(indexPath.row) as NSString, rowToUseInAlert: indexPath.row)
            let alert = UIAlertController(
                title: NSLocalizedString("Select option", comment: ""),
                message: nil,
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Send by email", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    self.actionSendEmailWithAttachment(indexPath.row, "application/gpx+xml")
            }))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Send by email (dxf)", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    self.actionSendEmailDxfWithAttachment(indexPath.row)
            }))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Load in Map", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    self.actionLoadFileAtIndex(indexPath.row, add: false)
            }))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Add in Map", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    self.actionLoadFileAtIndex(indexPath.row, add: true)
            }))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: { (action: UIAlertAction!) in
                    // Cancel
            }))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Delete", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    self.actionDeleteFileAtIndex(indexPath.row)
            }))
            present(alert, animated: true, completion: nil)
            self.selectedRowIndex = (indexPath as NSIndexPath).row
            break
        case kKMLFileExt:
            let alert = UIAlertController(
                title: NSLocalizedString("Select option", comment: ""),
                message: nil,
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Send by email", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    self.actionSendEmailWithAttachment(indexPath.row, "application/vnd.google-earth.kml+xml")
            }))
            
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Load in Map", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    DispatchQueue.main.async() {
                        self.delegate?.didLoadKMLFileWithName(filename)
                    }
                    self.closeGPXFilesTableViewController()
            }))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: { (action: UIAlertAction!) in
                    // Cancel
            }))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Delete", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    self.actionDeleteFileAtIndex(indexPath.row)
            }))
            present(alert, animated: true, completion: nil)
            self.selectedRowIndex = (indexPath as NSIndexPath).row
            break
        case kGeoJSONExt, kGeoJSONExt1:
            let alert = UIAlertController(
                title: NSLocalizedString("Select option", comment: ""),
                message: nil,
                preferredStyle: .alert)
            
                alert.addAction(UIAlertAction(
                    title: NSLocalizedString("Send by email", comment: ""),
                    style: .default,
                    handler: { (action: UIAlertAction!) in
                        self.actionSendEmailWithAttachment(indexPath.row, "application/geo+json")
                }))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Load in Map", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    DispatchQueue.main.async() {
                        self.delegate?.didLoadGeoJSONFileWithName(filename)
                    }
                    self.closeGPXFilesTableViewController()
            }))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: { (action: UIAlertAction!) in
                    // Cancel
            }))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Delete", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    self.actionDeleteFileAtIndex(indexPath.row)
            }))
            present(alert, animated: true, completion: nil)
            self.selectedRowIndex = (indexPath as NSIndexPath).row
            break
        case kMBTileFileExt:
            let alert = UIAlertController(
                title: NSLocalizedString("Select option", comment: ""),
                message: nil,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Set default offline data", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    self.delegate?.didLoadMBTileFilePath(filename)
            }))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: { (action: UIAlertAction!) in
                    // Cancel
            }))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Delete", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    self.actionDeleteFileAtIndex(indexPath.row)
            }))
            present(alert, animated: true, completion: nil)
            self.selectedRowIndex = (indexPath as NSIndexPath).row
            break
        default:
            break
        }
        
    }
    
    // MARK: UITableView delegate methods
    
    override func tableView(_ tableView: UITableView,
                            shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        // Allow editing for all rows except the initial "empty list"-placeholder row.
        // The string comparison is not optimal, but does the job.
        return gpxFilesFound
    }
    
    internal func actionDeleteFileAtIndex(_ rowIndex: Int) {
        //Delete File
        guard let filename: String = fileList.object(at: rowIndex) as? String else {
            return
        }
        
        GPXFileManager.removeFile(filename)
        //Delete from list and Table
        fileList.removeObject(at: rowIndex)
        let indexPath = IndexPath(row: rowIndex, section: 0)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        tableView.reloadData()
    }
    
    internal func actionLoadFileAtIndex(_ rowIndex: Int, add: Bool) {
        guard let filename: String = fileList.object(at: rowIndex) as? String else {
            return
        }
        
        print("load gpx File: \(filename)")
        let fileURL: URL = docsURL.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: fileURL.path))
            
            else {
                return
        }
        do {
            var options = AEXMLOptions()
            options.parserSettings.shouldProcessNamespaces = false
            options.parserSettings.shouldReportNamespacePrefixes = false
            options.parserSettings.shouldResolveExternalEntities = false
            // RIPR: GPX có thể bị rỗng/không hợp lệ → try! crash khi mở file ngoài.
            guard let gpxDoc = try? AEXMLDocument(xml: data, options: options) else {
                self.closeGPXFilesTableViewController()
                return
            }
            self.delegate?.didLoadGPXFileWithName(filename, gpxRoot: gpxDoc.root, add: add)
        }
        self.closeGPXFilesTableViewController()
    }
    
    internal func actionSendEmailWithAttachment(_ rowIndex: Int,_ mimeType: String) {
        guard let filename: String = fileList.object(at: rowIndex) as? String else {
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        
        if MFMailComposeViewController.canSendMail() {
            let fileURL: URL = docsURL.appendingPathComponent(filename)
            
            // set the subject
            composer.setSubject("[\(APP_NAME)] " + NSLocalizedString("Export to a file", comment: ""))
            
            //Add some text to the body and attach the file
            let body = "\(APP_FULL_NAME). " + NSLocalizedString("You can copy your files between your computer and apps on your iOS device using File Sharing.", comment: "") + " https://support.apple.com/en-us/HT201301<br />"
            
            composer.setMessageBody(body, isHTML: true)
            do {
                let fileData: Data = try Data(contentsOf: URL(fileURLWithPath: fileURL.path), options: .mappedIfSafe)
                composer.addAttachmentData(fileData, mimeType: mimeType, fileName: fileURL.lastPathComponent)
                //Display the comopser view controller
                self.present(composer, animated: true, completion: nil)
            } catch {
            }
            
//            if let nav = self.navigationController {
//                nav.present(composer, animated: true, completion: nil)
//            } else {
                self.present(composer, animated: true, completion: nil)
//            }
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
    
    internal func actionSendEmailDxfWithAttachment(_ rowIndex: Int) {
        // Nếu user chưa Pro: yêu cầu xem Rewarded Ad trước khi export DXF.
        if ADS_ENABLED && !getProVersion() && !getUnlimited() {
            rewardedHelper.show(from: self) { [weak self] (didEarn: Bool) in
                guard didEarn, let self = self else { return }
                self.performDxfExport(rowIndex)
            }
            return
        }
        performDxfExport(rowIndex)
    }

    private func performDxfExport(_ rowIndex: Int) {
        guard let filename: String = fileList.object(at: rowIndex) as? String else {
            return
        }
        
        
        let gpxFileURL: URL = docsURL.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: gpxFileURL.path))
            else {
                return
        }
        var options = AEXMLOptions()
        options.parserSettings.shouldProcessNamespaces = false
        options.parserSettings.shouldReportNamespacePrefixes = false
        options.parserSettings.shouldResolveExternalEntities = false
        // RIPR: gửi mail kèm GPX hỏng → try! crash. Bỏ qua attachment nếu lỗi.
        guard let gpxDoc = try? AEXMLDocument(xml: data, options: options) else { return }
        
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        
        if MFMailComposeViewController.canSendMail() {
            // Dùng tên file gpx đổi sang dxf
            let fileURL_: URL = docsURL.appendingPathComponent(filename).deletingPathExtension().appendingPathExtension("dxf")
            // Lấy tên file dxf
            let fileName = fileURL_.lastPathComponent
            // Lấy thư mục temporary
            let directory = NSTemporaryDirectory()
            
            // This returns a URL? even though it is an NSURL class method
            let fileURL = NSURL.fileURL(withPathComponents: [directory, fileName])
            
            let stream = OutputStream(toFileAtPath: (fileURL?.path)!, append: false)!
            // RIPR: nếu disk đầy / quyền sai, mọi try! dưới đây sẽ crash app khi export DXF.
            // Bọc toàn bộ block trong do/catch + show alert lỗi để user biết, không chết app.
            do {
                let dxf = try CSVWriter(stream: stream)

                let dxfLayer = "0\r\nSECTION\r\n2\r\nTABLES\r\n0\r\nTABLE\r\n2\r\nLAYER\r\n70\r\n5\r\n0\r\nLAYER\r\n2\r\n0\r\n70\r\n0\r\n62\r\n7\r\n6\r\nCONTINUOUS\r\n0\r\nLAYER\r\n2\r\nWP_NAME\r\n70\r\n0\r\n62\r\n5\r\n6\r\nCONTINUOUS\r\n0\r\nLAYER\r\n2\r\nWP_ALTITUDE\r\n70\r\n0\r\n62\r\n1\r\n6\r\nCONTINUOUS\r\n0\r\nLAYER\r\n2\r\nWP_DESCRIPTION\r\n70\r\n0\r\n62\r\n3\r\n6\r\nCONTINUOUS\r\n0\r\nLAYER\r\n2\r\nWP_POINT\r\n70\r\n0\r\n62\r\n6\r\n6\r\nCONTINUOUS\r\n0\r\nENDTAB\r\n0\r\nENDSEC"
                let dxfBlockAttribute = "0\r\nSECTION\r\n2\r\nBLOCKS\r\n0\r\nBLOCK\r\n8\r\n0\r\n2\r\nGTField\r\n70\r\n2\r\n10\r\n0\r\n20\r\n0\r\n30\r\n0\r\n3\r\nGTField\r\n0\r\nPOINT\r\n8\r\nWP_POINT\r\n10\r\n0\r\n20\r\n0\r\n30\r\n0\r\n0\r\nATTDEF\r\n8\r\nWP_DESCRIPTION\r\n10\r\n0\r\n20\r\n-2.5\r\n30\r\n0\r\n40\r\n2.5\r\n1\r\nNODESCRIPTION\r\n11\r\n0\r\n21\r\n0\r\n31\r\n0\r\n3\r\nDescription\r\n2\r\nDESCRIPTION\r\n70\r\n0\r\n74\r\n3\r\n0\r\nATTDEF\r\n5\r\n211\r\n8\r\nWP_ALTITUDE\r\n10\r\n0\r\n20\r\n0\r\n30\r\n0\r\n40\r\n2.5\r\n1\r\n0\r\n3\r\nElevation\r\n2\r\nELEVATION\r\n70\r\n0\r\n0\r\nATTDEF\r\n8\r\nWP_NAME\r\n10\r\n0\r\n20\r\n0\r\n30\r\n0\r\n40\r\n2.5\r\n1\r\nNONAME\r\n72\r\n2\r\n11\r\n0\r\n21\r\n0\r\n31\r\n0\r\n3\r\nWPName\r\n2\r\nNAME\r\n70\r\n0\r\n74\r\n2\r\n0\r\nENDBLK\r\n8\r\n0\r\n0\r\nENDSEC"
                let dxfEntities = "0\r\nSECTION\r\n2\r\nENTITIES"
                let dxfEnd = "0\r\nENDSEC\r\n0\r\nEOF"
                try dxf.write(row: [dxfLayer])
                try dxf.write(row: [dxfBlockAttribute])
                try dxf.write(row: [dxfEntities])

                // Đọc tất cả các đối tượng
                // Parse các điểm mốc wpt
                let gpxRoot = gpxDoc.root
                if let wpts = gpxRoot["wpt"].all {
                    for wpt in wpts {
                        let w = GPXWaypoint(xmlElement: wpt)
                        try dxf.write(row: [w.dxfBlockInsert])
                    }
                }
                // Parse các polyine
                if let trks = gpxRoot["trk"].all {
                    for track in trks {
                        let trackSegElements = track["trkseg"].all
                        if trackSegElements != nil {
                            for trksegElement in trackSegElements! {
                                let trkseg:GPXTrackSegment = GPXTrackSegment(xmlElement: trksegElement, map: GMSMapView())
                                try dxf.write(row: [trkseg.dxfAcDbPolyline])
                            }
                        }
                    }
                }
                // Parse các polygon
                let pointSegElements = gpxRoot["ptseg"].all
                if pointSegElements != nil {
                    for pointElement in pointSegElements! {
                        let pointSeg = GPXPointSegment(xmlElement: pointElement, map: GMSMapView())
                        try dxf.write(row: [pointSeg.dxfAcDbPolyline])
                    }
                }
                try dxf.write(row: [dxfEnd])
                dxf.stream.close()
            } catch {
                let a = UIAlertController(title: NSLocalizedString("Export DXF failed", comment: ""),
                                          message: error.localizedDescription, preferredStyle: .alert)
                a.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: nil))
                a.show()
                return
            }

            
            // set the subject
            composer.setSubject("[\(APP_NAME)] " + NSLocalizedString("Export Waypoints & Tracks to DXF file", comment: ""))
            
            //Add some text to the body and attach the file
            let body = "\(APP_FULL_NAME). " + NSLocalizedString("You can copy your files between your computer and apps on your iOS device using File Sharing.", comment: "") + " https://support.apple.com/en-us/HT201301<br />"
            
            composer.setMessageBody(body, isHTML: true)
            do {
                let fileData: Data = try Data(contentsOf: URL(fileURLWithPath: fileURL!.path), options: .mappedIfSafe)
                composer.addAttachmentData(fileData, mimeType:"application/dxf", fileName: (fileURL?.lastPathComponent)!)
                //Display the comopser view controller
                self.present(composer, animated: true, completion: nil)
            } catch {
            }
            
            //            if let nav = self.navigationController {
            //                nav.present(composer, animated: true, completion: nil)
            //            } else {
            self.present(composer, animated: true, completion: nil)
            //            }
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
    
    // Initialize Google AdMob banner
    func initAdMobBanner() {
        adMobBannerView = GADBannerView(adSize: GADAdSizeBanner)
        self.view.addSubview(adMobBannerView)
        adMobBannerView.adUnitID = ADMOB_UNIT_ID_Banner
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        let request = GADRequest()
        interstitialHelper.load()
        rewardedHelper.load()
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

extension GPXFilesTableViewController: MFMailComposeViewControllerDelegate {
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
}

extension GPXFilesTableViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        switch url.pathExtension {
        case kGPXFileExt, kKMLFileExt, kGeoJSONExt, kGeoJSONExt1, kMBTileFileExt:
            if copyFileFrom(url: url) != nil {
                self.tableView.reloadData()
            }
            break
        default:
            let alertController = UIAlertController(title: NSLocalizedString("This file does not support", comment: ""), message: urls.first?.lastPathComponent, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            alertController.modalPresentationStyle = .popover
            
            present(alertController, animated: true, completion: nil)
            break
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
}

