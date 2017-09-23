//
//  GPXFilesTableViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 7/12/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import Foundation

let kNoFiles = NSLocalizedString("No Item", comment: "")

import UIKit
import MessageUI
//import AEXML
import Firebase

protocol GPXFilesTableViewControllerDelegate: class {
    
    //GPXFilesTableView controller will be dismissed after calling this method
    //gpxFile is the name without extension
    func didLoadGPXFileWithName(_ gpxFilename: String, gpxRoot: AEXMLElement)
}

class GPXFilesTableViewController: UITableViewController, UINavigationBarDelegate, GADBannerViewDelegate {
    
    var fileList: NSMutableArray = [kNoFiles]
    var gpxFilesFound = false;
    var selectedRowIndex = -1
    weak var delegate: GPXFilesTableViewControllerDelegate?
    var adMobBannerView = GADBannerView()
    var interstitial = GADInterstitial(adUnitID: ADMOB_UNIT_ID_Interstitial)
    
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
        
        //get gpx files
        let list: NSArray = GPXFileManager.fileList as NSArray
        if list.count != 0 {
            self.fileList.removeAllObjects()
            self.fileList.addObjects(from: list as [AnyObject])
            self.gpxFilesFound = true
        }
        
        if ADS_ENABLED == true {
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                
            } else {
                
            }
            
            initAdMobBanner()
        } else {
            hideBanner(banner: adMobBannerView)
        }
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
        if (self.interstitial.isReady) {
            self.interstitial.present(fromRootViewController: self)
        }
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
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            actionDeleteFileAtIndex((indexPath as NSIndexPath).row)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
        //cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
        //cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"Something" ]];
        let filename = fileList.object(at: (indexPath as NSIndexPath).row) as? NSString as String? ?? ""
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.textLabel?.text = filename
        
        
        // Lấy thời gian, kích thước file...
        
        let fileURL: URL = docsURL.appendingPathComponent(filename)
        if let data = try? Data(contentsOf: URL(fileURLWithPath: fileURL.path)) {
            var options = AEXMLOptions()
            options.parserSettings.shouldProcessNamespaces = false
            options.parserSettings.shouldReportNamespacePrefixes = false
            options.parserSettings.shouldResolveExternalEntities = false
            let gpxDoc = try! AEXMLDocument(xml: data, options: options)
            let metadataElement = gpxDoc.root["metadata"]
            
            if metadataElement.error == nil {
                let date = metadataElement["time"].value?.dateFromISO8601
                let size = sizeForLocalFilePath(filePath: fileURL.path)
                //let font = cell.detailTextLabel?.font
                //cell.detailTextLabel?.font = font?.withSize(15)
                cell.detailTextLabel?.text = "\(date?.local ?? "")\n \(size)"
            } else {
                cell.detailTextLabel?.text = ""
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // self.showAlert(fileList.objectAtIndex(indexPath.row) as NSString, rowToUseInAlert: indexPath.row)
        let sheet = UIActionSheet()
        sheet.title = NSLocalizedString("Select option", comment: "")
        sheet.addButton(withTitle: NSLocalizedString("Send by email", comment: ""))
        sheet.addButton(withTitle: NSLocalizedString("Load in Map", comment: ""))
        sheet.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        sheet.addButton(withTitle: NSLocalizedString("Delete", comment: ""))
        sheet.cancelButtonIndex = 2
        sheet.destructiveButtonIndex = 3
        
        
        sheet.delegate = self
        sheet.show(in: self.view)
        self.selectedRowIndex = (indexPath as NSIndexPath).row
    }
    
    // MARK: UITableView delegate methods
    
    override func tableView(_ tableView: UITableView,
                            shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        // Allow editing for all rows except the initial "empty list"-placeholder row.
        // The string comparison is not optimal, but does the job.
        return gpxFilesFound
    }
    
    // MARK: Action Sheet - Actions
    internal func actionSheetCancel(_ actionSheet: UIActionSheet) {
        print("actionsheet cancel")
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
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        tableView.reloadData()
    }
    
    internal func actionLoadFileAtIndex(_ rowIndex: Int) {
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
            let gpxDoc = try! AEXMLDocument(xml: data, options: options)
            self.delegate?.didLoadGPXFileWithName(filename, gpxRoot: gpxDoc.root)
        }
        self.closeGPXFilesTableViewController()
    }
    
    internal func actionSendEmailWithAttachment(_ rowIndex: Int) {
        guard let filename: String = fileList.object(at: rowIndex) as? String else {
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        
        if MFMailComposeViewController.canSendMail() {
            let fileURL: URL = docsURL.appendingPathComponent(filename)
            
            // set the subject
            composer.setSubject("[\(APP_NAME)] " + NSLocalizedString("Export Waypoints & Tracks to GPX file", comment: ""))
            
            //Add some text to the body and attach the file
            let body = "\(APP_FULL_NAME). " + NSLocalizedString("You can copy your files between your computer and apps on your iOS device using File Sharing.", comment: "") + " https://support.apple.com/en-us/HT201301<br />"
            
            composer.setMessageBody(body, isHTML: true)
            do {
                let fileData: Data = try Data(contentsOf: URL(fileURLWithPath: fileURL.path), options: .mappedIfSafe)
                composer.addAttachmentData(fileData, mimeType:"application/gpx+xml", fileName: fileURL.lastPathComponent)
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
                preferredStyle: UIAlertControllerStyle.alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
//            
//            let alert = UIAlertView(title: NSLocalizedString("No email accounts configured", comment: ""), message: NSLocalizedString("Please add a mail account in Settings to send mail from, by Go to Settings > Mail > Accounts > Add Account", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
//            alert.show()
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
        interstitial.load(request)
        //request.testDevices = ["b0363f55ef349672aa7932774e71491d",kGADSimulatorID]
        adMobBannerView.load(request)
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

extension GPXFilesTableViewController: UIActionSheetDelegate{
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        print("action sheet clicked button at index \(buttonIndex)")
        switch buttonIndex {
        case 0:
            self.actionSendEmailWithAttachment(self.selectedRowIndex)
        case 1:
            self.actionLoadFileAtIndex(self.selectedRowIndex)
        case 2:
            print("ActionSheet: Cancel")
        case 3: //Delete
            self.actionDeleteFileAtIndex(self.selectedRowIndex)
        default: //cancel
            print("action Sheet do nothing")
        }
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
                preferredStyle: UIAlertControllerStyle.alert
            )
            break
        default:
            alert = UIAlertController(
                title: NSLocalizedString("Whoops", comment: ""),
                message: error?.localizedDescription,
                preferredStyle: UIAlertControllerStyle.alert
            )
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .default, handler: nil))
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
