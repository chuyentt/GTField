//
//  ConfigMapSourceViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 6/12/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit

class ConfigMapSourceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Dùng để delegate
    var mapViewController: MapViewController?
    
    @IBOutlet var tableView: UITableView!
    // Kiểm tra GeoServer
    var imageViewForCheckingGeoServer = UIImageView(image: #imageLiteral(resourceName: "IconGeoServerBaseUrlOffline"))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("Map Source Configuration", comment: "")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var statusBarStyle: UIStatusBarStyle? {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle ?? super.preferredStatusBarStyle
    }
    
    @IBAction func actionDone(_ sender: Any) {
        self.dismiss(animated: true) {
            self.statusBarStyle = .lightContent
        }
    }
    
    
    // MARK: - TableView
    // --------------------------------------------------------------------------------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! ConfigMapSourceTableViewCell
        switch indexPath.section {
        case 0:
            cell.lblCellTitle?.text = getGeoServerBaseUrl()
            cell.imgCell?.image = #imageLiteral(resourceName: "IconGeoServerBaseUrlOffline")
            // Tự động kết nối với máy chủ geoserver, 
            // nếu không thành công thì thay icon offline
            cell.imgCell.imageForGeoServerBaseUrlChecking()
            self.imageViewForCheckingGeoServer = cell.imgCell
            cell.tag = 0
            break
        case 1:
            cell.lblCellTitle?.text = getWMSActiveLayers()
            cell.imgCell?.image = #imageLiteral(resourceName: "IconWMSLayers")
            cell.tag = 1
            break
        case 2:
            cell.lblCellTitle?.text = getWFSActiveLayers()
            cell.imgCell?.image = #imageLiteral(resourceName: "IconWFSLayers")
            cell.tag = 2
            break
        case 3:
            let offlineActiveTilesPath = getOfflineActiveTilesPath()
            // Kiểm tra xem có phải là dữ liệu cũ không Download01
            if offlineActiveTilesPath == "" || offlineActiveTilesPath == "Download01" {
                cell.lblCellTitle?.text = NSLocalizedString("Select an offline data", comment: "")
            } else {
                let offlineTileURL = docsURL.appendingPathComponent(offlineActiveTilesPath)
                let mbtileDB = MBTileDB(path: offlineTileURL.path)
                let size = sizeForLocalFilePath(filePath: offlineTileURL.path)
                let date: Date?
                do {
                    let attrs = try FileManager.default.attributesOfItem(atPath: offlineTileURL.path)
                    date = attrs[FileAttributeKey.creationDate] as? Date
                } catch {
                    date = Date()
                }
                var filename = mbtileDB.metadataValueFor(name: "name")
                
                let desc = mbtileDB.metadataValueFor(name: "description")
                if desc.length > 0 {
                    filename = desc
                }
                cell.lblCellTitle?.numberOfLines = 0
                cell.lblCellTitle?.text = "\(filename)\n\(offlineTileURL.lastPathComponent) (\(size))"
                cell.lblCellSubtitle.text = "\(date?.local ?? "")\n \(size)"
                cell.imgCell?.image = #imageLiteral(resourceName: "IconOfflineData")
                cell.tag = 3
            }            
            break
        default:
            break
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        switch indexPath.section {
        case 0:
            let alertController = UIAlertController(title: NSLocalizedString("Type Your GeoServer Host", comment: ""), message: "", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default, handler: {
                alert -> Void in
                let textField = alertController.textFields![0] as UITextField
                if setGeoServerBaseUrl(urlString: textField.text!) {
                    self.tableView.reloadData()
                } else {
                    // create the alert
                    let alert = UIAlertController(title: NSLocalizedString("Invalid input URL", comment: ""), message: NSLocalizedString("e.g.: http://192.168.1.153:8080", comment: ""), preferredStyle: UIAlertController.Style.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
                        alert -> Void in
                        self.present(alertController, animated: true, completion: nil)
                    }))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
                textField.placeholder = NSLocalizedString("e.g.: http://192.168.1.153:8080", comment: "")
            })
            self.present(alertController, animated: true, completion: nil)
            break
        case 1:
            // Kiểm tra kết nối trước
            if (self.imageViewForCheckingGeoServer.image == #imageLiteral(resourceName: "IconGeoServerBaseUrlOffline")) {
                // create the alert
                let alert = UIAlertController(title: NSLocalizedString("Could not connect to GeoServer!", comment: ""), message: NSLocalizedString("Please verify GeoServer Base Url", comment: ""), preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertAction.Style.default, handler: {
                    alert -> Void in
                    return
                }))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            } else {
                performSegue(withIdentifier: "segueGeoServerLayers", sender: cell)
            }
            break
        case 2:
            // Kiểm tra kết nối trước
            if (self.imageViewForCheckingGeoServer.image == #imageLiteral(resourceName: "IconGeoServerBaseUrlOffline")) {
                // create the alert
                let alert = UIAlertController(title: NSLocalizedString("Could not connect to GeoServer!", comment: ""), message: NSLocalizedString("Please verify GeoServer Base Url", comment: ""), preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertAction.Style.default, handler: {
                    alert -> Void in
                    return
                }))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            } else {
                performSegue(withIdentifier: "segueGeoServerLayers", sender: cell)
            }
            break
        case 3:
            let vc = MBTileTableViewController(nibName: nil, bundle: nil)
            vc.delegate = self.mapViewController
            let navController = UINavigationController(rootViewController: vc)
            self.present(navController, animated: true) { () -> Void in }
            break
        default:
            break
        }
    }
    
//    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
//        let header = view as! UITableViewHeaderFooterView
//        let font = UIFont(name: "Bauhaus-Medium", size: 11)
//        header.textLabel?.font = font
//        header.textLabel?.textColor = UIColor.lightGray
//    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("GeoServer Base Url", comment: "")
        case 1:
            return NSLocalizedString("WMS Layer or Layer-Group", comment: "")
        case 2:
            return NSLocalizedString("WFS Layer", comment: "")
        case 3:
            return NSLocalizedString("Offline data", comment: "")
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("Support GeoServer installed on your system, by giving ip address of system like \"http://192.168.1.52:8080\" instead of \"http://localhost:8080\"", comment: "")
        case 1:
            return NSLocalizedString("This is an overlay layer on your base", comment: "")
        case 2:
            return NSLocalizedString("This is layer for accessing information (require internet connection)", comment: "")
        case 3:
            return NSLocalizedString("Support MBTiles file format (GTField can get mbtiles file from your Email, iCloud Drive, Google Drive, Dropbox or downloaded from the Internet)", comment: "")
        default:
            return nil
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! ConfigMapSourceTableViewCell
        if (segue.identifier == "segueGeoServerLayers") {
            let vc: GSLayersViewController = segue.destination as! GSLayersViewController
            vc.layerName = (cell.lblCellTitle?.text)!
            if cell.tag == 1 {
                vc.layerFor = "WMS"
            } else {
                vc.layerFor = "WFS"
            }
        }
    }

}
