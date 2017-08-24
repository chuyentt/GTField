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

    var itemList: NSMutableArray = [kNoItem]
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
        let list: NSArray = GPXFileManager.fileList as NSArray
        if list.count != 0 {
            self.itemList.removeAllObjects()
            self.itemList.addObjects(from: list as [AnyObject])
            self.itemFound = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func close() {
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
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
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
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
        let filename = itemList.object(at: (indexPath as NSIndexPath).row) as? NSString as String? ?? ""
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
                let font = cell.detailTextLabel?.font
                cell.detailTextLabel?.numberOfLines = 0
                cell.detailTextLabel?.font = font?.withSize(15)
                cell.detailTextLabel?.text = "\(date?.local ?? "")\n \(size)"
            } else {
                cell.detailTextLabel?.text = ""
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
                self.actionSendEmailGPX(fileURL)
        }))
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Delete", comment: ""),
            style: .default,
            handler: { (action: UIAlertAction!) in
                self.actionDeleteFileAtIndex((indexPath as NSIndexPath).row)
        }))
        present(alert, animated: true, completion: nil)
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
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            actionDeleteFileAtIndex((indexPath as NSIndexPath).row)
        }
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
}

extension GPXTableViewController: GPXFilesTableViewControllerDelegate {
    func didLoadGPXFileWithName(_ gpxFilename: String, gpxRoot: AEXMLElement) {

    }
}

extension GPXTableViewController:MFMailComposeViewControllerDelegate {
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
