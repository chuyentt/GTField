//
//  GSLayersViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 6/13/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
//import AEXML

class GSLayersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var layerName: String = String()
    var layerFor: String = String()
    
    @IBOutlet weak var buttonRefresh: UIBarButtonItem!
    
    private var uiBusy = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)

    // Array of dictionary
    // Danh sách thông tin layers
    var arrRes = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func loadView() {
        super.loadView()
        xmlParser()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionRefresh(_ sender: Any) {
        xmlParser()
    }
    
    // MARK: - XMLParser
    // --------------------------------------------------------------------------------------------
    func xmlParser() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiBusy)
        uiBusy.hidesWhenStopped = true
        uiBusy.startAnimating()
        self.title = "Waiting for request layers"
        if layerFor == "WMS" {
            let url = getCapabilitiesForWMS()
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"
            let session = URLSession.shared
            session.dataTask(with: request, completionHandler: {(data, response, error) in
                DispatchQueue.main.async(execute: {
                    self.uiBusy.stopAnimating()
                    self.navigationItem.rightBarButtonItem = self.buttonRefresh
                    self.title = ""
                    if error != nil {
                        
                    } else {
                        do {
                            var options = AEXMLOptions()
                            options.parserSettings.shouldProcessNamespaces = false
                            options.parserSettings.shouldReportNamespacePrefixes = false
                            options.parserSettings.shouldResolveExternalEntities = false
                            let xmlDoc = try AEXMLDocument(xml: data!, options: options)
                            
                            let layersAll = xmlDoc.root["Capability"]["Layer"]["Layer"].all.map({ (properties: [AEXMLElement]) -> [[String : AnyObject]] in
                                
                                var layers : Array<[String:AnyObject]> = Array()
                                for layer in properties {
                                    layers.append(["Name":layer["Name"].value as AnyObject,
                                                   "Title":layer["Title"].value as AnyObject,
                                                   "Abstract":layer["Abstract"].value as AnyObject,
                                                   "EX_GeographicBoundingBox":[
                                                    "{\"westBoundLongitude\":\(layer["EX_GeographicBoundingBox"]["westBoundLongitude"].value!),\"southBoundLatitude\":\(layer["EX_GeographicBoundingBox"]["southBoundLatitude"].value!),\"eastBoundLongitude\":\(layer["EX_GeographicBoundingBox"]["eastBoundLongitude"].value!),\"northBoundLatitude\":\(layer["EX_GeographicBoundingBox"]["northBoundLatitude"].value!)}"] as AnyObject
                                                   ])
                                }
                                return layers as [[String:AnyObject]]
                            })
                            self.arrRes = layersAll!
                            if self.arrRes.count > 0 {
                                self.tableView.reloadData()
                            }
                        } catch {
                            print("Error")
                        }
                    }
                })
            }).resume()

        } else {
            let url = getCapabilitiesForWFS()
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"
            let session = URLSession.shared
            session.dataTask(with: request, completionHandler: {(data, response, error) in
                DispatchQueue.main.async(execute: {
                    self.uiBusy.stopAnimating()
                    self.navigationItem.rightBarButtonItem = self.buttonRefresh
                    self.title = ""
                    if error != nil {
                        
                    } else {
                        do {
                            var options = AEXMLOptions()
                            options.parserSettings.shouldProcessNamespaces = false
                            options.parserSettings.shouldReportNamespacePrefixes = false
                            options.parserSettings.shouldResolveExternalEntities = false
                            let xmlDoc = try AEXMLDocument(xml: data!, options: options)
                            
                            let layersAll = xmlDoc.root["FeatureTypeList"]["FeatureType"].all.map({ (properties: [AEXMLElement]) -> [[String : AnyObject]] in
                                
                                var layers : Array<[String:AnyObject]> = Array()
                                for layer in properties {
                                    layers.append(["Name":layer["Name"].value as AnyObject,
                                                   "Title":layer["Title"].value as AnyObject,
                                                   "Abstract":layer["Abstract"].value as AnyObject,
                                                   "WGS84BoundingBox":[
                                                    "{\"LowerCorner\":\"\(layer["ows:WGS84BoundingBox"]["ows:LowerCorner"].value!)\",\"UpperCorner\":\"\(layer["ows:WGS84BoundingBox"]["ows:UpperCorner"].value!)\"}"] as AnyObject
                                        ])
                                }
                                return layers as [[String:AnyObject]]
                            })
                            self.arrRes = layersAll!
                            if self.arrRes.count > 0 {
                                self.tableView.reloadData()
                            }
                        } catch {
                            print("Error")
                        }
                    }
                })
                
            }).resume()
        }
    }
    
    // MARK: - TableView
    // --------------------------------------------------------------------------------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrRes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        var dict = arrRes[(indexPath as NSIndexPath).section]
        cell.textLabel?.text = dict["Name"] as? String
        if cell.textLabel?.text == layerName {
            cell.detailTextLabel?.text = "Active"
            cell.detailTextLabel?.backgroundColor = self.view.tintColor
        } else {
            cell.detailTextLabel?.text = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let dict = arrRes[(indexPath as NSIndexPath).section]
        switch layerFor {
        case "WMS":
            setWMSActiveLayers(wmsActiveLayers: (cell?.textLabel?.text)!)
            let bbox: NSArray = dict["EX_GeographicBoundingBox"] as! NSArray
            let bboxStr: String = bbox.firstObject as! String
            
            let boxDict: NSDictionary = try! JSONSerialization.jsonObject(with: bboxStr.data(using: .utf8)!, options: []) as! NSDictionary
            
            let minx = boxDict["westBoundLongitude"] as! Double
            let miny = boxDict["southBoundLatitude"] as! Double
            let maxx = boxDict["eastBoundLongitude"] as! Double
            let maxy = boxDict["northBoundLatitude"] as! Double
            setLayersBoundingBoxForWMS(layersBboxStr: "{{\(minx),\(miny)},{\(maxx-minx),\(maxy-miny)}}")
            
            // Xóa cache mỗi lần khởi tạo
            let tileRoot = applicationDocumentsDirectory().appendingPathComponent(TILE_CACHED)
            let tilesFolder = tileRoot.appendingPathComponent(CACHED_NAME)
            _ = deleteFolderFor(tilesFolder.path)
            
            // Xóa cache.mbtiles
            do {
                try FileManager.default.removeItem(atPath: MB_TILES_CACHED)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error), xóa cache.mbtiles")
            }
            let mbTileDB = MBTileDB(path: MB_TILES_CACHED)
            
            let bounds = "\(minx),\(miny),\(maxx),\(maxy)"
            mbTileDB.saveToMetadata(name: "bounds", value: bounds)
            mbTileDB.saveToMetadata(name: "name", value: "GTField Download")
            
            break
        case "WFS":
            setWFSActiveLayers(wfsActiveLayers: (cell?.textLabel?.text)!)
            let bbox: NSArray = dict["WGS84BoundingBox"] as! NSArray
            let bboxStr: String = bbox.firstObject as! String
            let boxDict: NSDictionary = try! JSONSerialization.jsonObject(with: bboxStr.data(using: .utf8)!, options: []) as! NSDictionary
            let lowerCornerStr: String = boxDict["LowerCorner"] as! String
            let upperCornerStr: String = boxDict["UpperCorner"] as! String
            let lowerCornerStrArray = lowerCornerStr.components(separatedBy: .whitespaces)
            let upperCornerStrArray = upperCornerStr.components(separatedBy: .whitespaces)
            let minx = Double(lowerCornerStrArray[0])!
            let miny = Double(lowerCornerStrArray[1])!
            let maxx = Double(upperCornerStrArray[0])!
            let maxy = Double(upperCornerStrArray[1])!
            setLayersBoundingBoxForWFS(layersBboxStr: "{{\(minx),\(miny)},{\(maxx-minx),\(maxy-miny)}}")
            break
        default:
            break
        }
        layerName = (cell?.textLabel?.text)!
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dict = arrRes[section]
        return dict["Title"] as? String
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let dict = arrRes[section]
        return dict["Abstract"] as? String
    }
}
