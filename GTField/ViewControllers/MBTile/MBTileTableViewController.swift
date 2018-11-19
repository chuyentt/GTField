//
//  MBTileTableViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 7/25/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
//import AEXML
import MessageUI
import CoreServices

class MBTileTableViewController: UITableViewController {
    
    var itemList: NSMutableArray = [kNoItem]
    var itemFound = false;
    var selectedRowIndex = -1
    weak var delegate: MBTileTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBarFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
        self.tableView.frame = CGRect(x: navBarFrame.width + 1, y: 0, width: self.view.frame.width, height:
            self.view.frame.height - navBarFrame.height)
        
        let shareItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        
        self.navigationItem.rightBarButtonItems = [shareItem]
        
        let list: NSArray = MBTileFileManager.fileList as NSArray
        if list.count != 0 {
            self.itemList.removeAllObjects()
            self.itemList.addObjects(from: list as [AnyObject])
            self.itemFound = true
        }
        
        // Thêm chức năng mở file từ Documents
        let buttonMore = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(moreAction(_:)))
        self.navigationItem.leftBarButtonItem = buttonMore
        
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
        
        MBTileFileManager.removeFile(filename)
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
        return NSLocalizedString("MBTiles specification", comment: "")
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "Cell")
        var filename = itemList.object(at: (indexPath as NSIndexPath).row) as? NSString as String? ?? ""
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.textLabel?.text = filename
        
        // Lấy thời gian, kích thước file...
        if filename != kNoItem {
            let fileURL: URL = docsURL.appendingPathComponent(filename).appendingPathExtension(kMBTileFileExt)
            let size = sizeForLocalFilePath(filePath: fileURL.path)
            let date: Date?
            do {
                let attrs = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                date = attrs[FileAttributeKey.creationDate] as? Date
            } catch {
                date = Date()
            }
            let mbtileDB = MBTileDB(path: fileURL.path)
            let desc = mbtileDB.metadataValueFor(name: "description")
            if desc.length > 0 {
                filename = desc
            }
            cell.textLabel?.text = "\(filename)\n\(fileURL.lastPathComponent)"
            cell.detailTextLabel?.text = "\(date?.local ?? "")\n \(size)"
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
            title: NSLocalizedString("Edit the description", comment: ""),
            style: .default,
            handler: { (action: UIAlertAction!) in
                let fileURL: URL = docsURL.appendingPathComponent(filename).appendingPathExtension(kMBTileFileExt)
                let mbtileDB = MBTileDB(path: fileURL.path)
                var desc = mbtileDB.metadataValueFor(name: "description")
                // Yêu cầu nhập mô tả tile mỗi lần tải
                let alertController = UIAlertController(title: NSLocalizedString("Type Your Download Description", comment: ""), message: "", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {
                    alert -> Void in
                    desc = (alertController.textFields?.first?.text)!
                    if desc.length > 0 {
                        mbtileDB.saveToMetadata(name: "description", value: desc)
                        self.tableView.reloadData()
                    }
                }))
                alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
                    textField.placeholder = NSLocalizedString("Description of the offline map", comment: "")
                    textField.text = desc
                    textField.keyboardAppearance = .dark
                    textField.autocapitalizationType = .sentences
                })
                self.present(alertController, animated: true, completion: nil)
                
                self.actionSendEmailMBTile(fileURL)
        }))
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Send by email", comment: ""),
            style: .default,
            handler: { (action: UIAlertAction!) in
                let fileURL: URL = docsURL.appendingPathComponent(filename).appendingPathExtension(kMBTileFileExt)
                self.actionSendEmailMBTile(fileURL)
        }))
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Set default offline data", comment: ""),
            style: .default,
            handler: { (action: UIAlertAction!) in
                let fileURL: URL = docsURL.appendingPathComponent(filename).appendingPathExtension(kMBTileFileExt)
                self.delegate?.didLoadMBTileFilePath(fileURL.lastPathComponent)
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
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            actionDeleteFileAtIndex((indexPath as NSIndexPath).row)
        }
    }
    
    // Export MBTile
    internal func actionSendEmailMBTile(_ fileURL: URL) {
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        
        if MFMailComposeViewController.canSendMail() {
            // set the subject
            composer.setSubject("[\(APP_NAME)] " + NSLocalizedString("Export Offline Map", comment: ""))
            
            //Add some text to the body and attach the file
            let body = "\(APP_FULL_NAME). " + NSLocalizedString("You can copy your files between your computer and apps on your iOS device using File Sharing.", comment: "") + " https://support.apple.com/en-us/HT201301<br />"
            
            composer.setMessageBody(body, isHTML: true)
            //composer.setToRecipients(["chuyentt@gmail.com"])
            do {
                let fileData: Data = try Data(contentsOf: URL(fileURLWithPath: fileURL.path), options: .mappedIfSafe)
                composer.addAttachmentData(fileData, mimeType:"application/vnd.mbtiles", fileName: fileURL.lastPathComponent)
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

extension MBTileTableViewController: MBTileTableViewControllerDelegate {
    func didLoadMBTileFilePath(_ mbtileFilePath: String) {
        
    }
}

protocol MBTileTableViewControllerDelegate: class {
    func didLoadMBTileFilePath(_ mbtileFilePath: String)
}

extension MBTileTableViewController:MFMailComposeViewControllerDelegate {
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


extension MBTileTableViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        switch url.pathExtension {
        case kMBTileFileExt:
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

