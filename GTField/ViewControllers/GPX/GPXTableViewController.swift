//
//  GPXTableViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 7/13/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
//import AEXML
import MessageUI

let kNoItem = NSLocalizedString("No Item", comment: "")

class GPXTableViewController: UITableViewController {

    var itemList: NSMutableArray = []
    var itemFound = false;
    var selectedRowIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Your GPX files", comment: "")
        
        let navBarFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
        //let navigationBar : UINavigationBar = UINavigationBar(frame: navBarFrame)
        self.tableView.frame = CGRect(x: navBarFrame.width + 1, y: 0, width: self.view.frame.width, height:
            self.view.frame.height - navBarFrame.height)
        
        let shareItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(GPXTableViewController.close))
        
        self.navigationItem.rightBarButtonItems = [shareItem]
        
        //get gpx files
        self.view.showLoading()
        DispatchQueue.main.async() {
            let list: NSArray = GPXFileManager.fileList as NSArray
            if list.count != 0 {
                self.itemList.removeAllObjects()
                self.itemList.addObjects(from: list as [AnyObject])
                self.itemFound = true
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        self.view.hideLoading()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func close() {
        self.dismiss(animated: true, completion: { () -> Void in
        })
    }

    internal func actionDeleteFileAtIndex(_ rowIndex: Int) {
        //Delete File
        guard let filename: String = itemList.object(at: rowIndex) as? String else {
            return
        }
        
        GPXFileManager.removeFile(filename)
        //Delete from list and Table
        itemList.removeObject(at: rowIndex)
        let indexPath = IndexPath(row: rowIndex, section: 0)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemList.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("GPX specification", comment: "")
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "Cell")
        let filename = itemList.object(at: (indexPath as NSIndexPath).row) as? NSString as String? ?? ""
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        cell.textLabel?.text = filename
        
        // Lấy thời gian, kích thước file...
        
        let fileURL: URL = docsURL.appendingPathComponent(filename)
        let pathExtension = fileURL.pathExtension
        if let data = try? Data(contentsOf: URL(fileURLWithPath: fileURL.path)) {
            switch pathExtension {
            case kGPXFileExt:
                var options = AEXMLOptions()
                options.parserSettings.shouldProcessNamespaces = false
                options.parserSettings.shouldReportNamespacePrefixes = false
                options.parserSettings.shouldResolveExternalEntities = false
                let gpxDoc = try! AEXMLDocument(xml: data, options: options)
                let metadataElement = gpxDoc.root["metadata"]
                
                if metadataElement.error == nil {
                    let date = metadataElement["time"].value?.dateFromISO8601
                    let size = sizeForLocalFilePath(filePath: fileURL.path)
                    let font = cell.detailTextLabel?.font
                    cell.detailTextLabel?.numberOfLines = 0
                    cell.detailTextLabel?.font = font?.withSize(15)
                    cell.detailTextLabel?.text = "\(date?.local ?? "")\n \(size)"
                } else {
                    cell.detailTextLabel?.text = ""
                }
            case kKmlFileExt, kGeoJSONExt, kGeoJSONExt1, kMBTileFileExt:
                let date = creationDateForLocalFilePath(filePath: fileURL.path)
                let size = sizeForLocalFilePath(filePath: fileURL.path)
                //let font = cell.detailTextLabel?.font
                //cell.detailTextLabel?.font = font?.withSize(15)
                cell.detailTextLabel?.text = "\(date.local )\n \(size)"
                break
            default:
                break
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filename = itemList.object(at: (indexPath as NSIndexPath).row) as? NSString as String? ?? ""
        let fileURL: URL = docsURL.appendingPathComponent(filename)
        let pathExtension = fileURL.pathExtension
        switch pathExtension {
        case kGPXFileExt:
            let filename = itemList.object(at: (indexPath as NSIndexPath).row) as? NSString as String? ?? ""
            let alert = UIAlertController(
                title: NSLocalizedString("Select option", comment: ""),
                message: nil,
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: { (action: UIAlertAction!) in
                    // Cancel
            }))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Send by email", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    let fileURL: URL = docsURL.appendingPathComponent(filename)
                    self.actionSendEmailGPX(fileURL, "application/gpx+xml")
            }))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Delete", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    self.actionDeleteFileAtIndex((indexPath as NSIndexPath).row)
            }))
            present(alert, animated: true, completion: nil)
        case kKmlFileExt:
            let alert = UIAlertController(
                title: NSLocalizedString("Select option", comment: ""),
                message: nil,
                preferredStyle: .alert)
            
                alert.addAction(UIAlertAction(
                    title: NSLocalizedString("Send by email", comment: ""),
                    style: .default,
                    handler: { (action: UIAlertAction!) in
                        self.actionSendEmailGPX(fileURL, "application/vnd.google-earth.kml+xml")
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
                        self.actionSendEmailGPX(fileURL, "application/geo+json")
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
    
    override func tableView(_ tableView: UITableView,
                            shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        // Allow editing for all rows except the initial "empty list"-placeholder row.
        // The string comparison is not optimal, but does the job.
        return itemFound
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return itemFound
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            actionDeleteFileAtIndex((indexPath as NSIndexPath).row)
        }
    }

    // Export GPX
    internal func actionSendEmailGPX(_ fileURL: URL,_ mimeType: String) {
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        
        if MFMailComposeViewController.canSendMail() {
            // set the subject
            composer.setSubject("[\(APP_NAME)] " + NSLocalizedString("Export to a file", comment: ""))
            
            //Add some text to the body and attach the file
            let body = "\(APP_FULL_NAME). " + NSLocalizedString("You can copy your files between your computer and apps on your iOS device using File Sharing.", comment: "") + " https://support.apple.com/en-us/HT201301<br />"
            
            composer.setMessageBody(body, isHTML: true)
            //composer.setToRecipients(["chuyentt@gmail.com"])
            do {
                let fileData: Data = try Data(contentsOf: URL(fileURLWithPath: fileURL.path), options: .mappedIfSafe)
                composer.addAttachmentData(fileData, mimeType: mimeType, fileName: fileURL.lastPathComponent)
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
            
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindow.Level.alert + 1;
            alertWindow.makeKeyAndVisible()
            alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

extension GPXTableViewController: GPXFilesTableViewControllerDelegate {
    func didLoadKMLFileWithName(_ kmlFilename: String) {
        
    }
    
    func didLoadGeoJSONFileWithName(_ geoJSONFilename: String) {
        
    }
    
    func didLoadGPXFileWithName(_ gpxFilename: String, gpxRoot: AEXMLElement, add: Bool) {

    }
    
    func didLoadMBTileFilePath(_ mbtileFilePath: String) {
        
    }
}

extension GPXTableViewController:MFMailComposeViewControllerDelegate {
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
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
