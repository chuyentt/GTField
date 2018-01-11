//
//  OfflineTileLayer.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 6/18/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
//import AEXML

class OfflineTileLayer: GMSTileLayer {
    var urlComponents: URLComponents = URLComponents()
    var boundaryString: String = ""
    var layersBbox: CGRect = CGRect()
    var offlineTileDB: MBTileDB?
    var pathToDatabase: String?
    
    // Mặc định là OSM (gốc ở dưới) so với TMS (gốc ở trên)
    var geometryFlipped: Bool = true
    
    // Khởi tạo với đường dẫn mặc định
    init?(_ tileSize: Int = 256) {
        super.init()
        self.tileSize = 256*Int(UIScreen.main.scale)
        if getOfflineActiveTilesPath() == "" {
            return nil
        }
        self.pathToDatabase = docsURL.appendingPathComponent(getOfflineActiveTilesPath()).path
        offlineTileDB = MBTileDB(path: pathToDatabase!)
        if offlineTileDB != nil, (offlineTileDB?.isDBOpen)! {
            let format = offlineTileDB?.metadataValueFor(name: "format")
            if format?.lowercased().length != 0 && (format?.lowercased() != "png" && format?.lowercased() != "jpg") {
                let alert = UIAlertController(title: NSLocalizedString("This format", comment: "")+" \"\(format ?? "")\" "+NSLocalizedString("does not support", comment: ""), message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: nil))
                alert.show()
                return nil
            }
        }
    }
    
    override var map: GMSMapView? {
        didSet {
            if map != nil {
                offlineTileDB = MBTileDB(path: pathToDatabase!)
                if offlineTileDB != nil, (offlineTileDB?.isDBOpen)! {
                    let bounds = offlineTileDB?.metadataValueFor(name: "bounds")
                    let arr:Array = (bounds?.components(separatedBy: ","))!
                    if arr.count == 4 {
                        let minx = Double(arr[0])!
                        let miny = Double(arr[1])!
                        let maxx = Double(arr[2])!
                        let maxy = Double(arr[3])!
                        
                        self.boundaryString = "{{\(minx),\(miny)},{\(maxx-minx),\(maxy-miny)}}"
                        self.layersBbox = CGRectFromString(self.boundaryString).insetBy(dx: -0.005, dy: -0.005)
                        map?.moveCamera(GMSCameraUpdate.fit(GMSCoordinateBounds.init(path: (pathForBoundary()))))
                    } else {
                        // Kiểm tra xem có trường center và minzoom, maxzoom
                        let center = offlineTileDB?.metadataValueFor(name: "center")
                        let arr:Array = (center?.components(separatedBy: ","))!
                        if arr.count == 2 {
                            let cx = Double(arr[0])!
                            let cy = Double(arr[1])!
                            let minzoom = Float((offlineTileDB?.metadataValueFor(name: "minzoom"))!)
                            map?.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: cy, longitude: cx), zoom: minzoom!))
                            
                            let bounds = map?.cameraTargetBounds
                            let minx: Double = (bounds?.southWest.longitude)!
                            let miny: Double = (bounds?.southWest.latitude)!
                            let maxx: Double = (bounds?.northEast.longitude)!
                            let maxy: Double = (bounds?.northEast.latitude)!
                            self.boundaryString = "{{\(minx),\(miny)},{\(maxx-minx),\(maxy-miny)}}"
                            self.layersBbox = CGRectFromString(self.boundaryString).insetBy(dx: -0.005, dy: -0.005)
                        } else {
                            let alert = UIAlertController(title: NSLocalizedString("Missing metadata table or missing bounds value in metadata", comment: ""), message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: nil))
                            alert.show()
                        }
                    }
                }
            } else {
                if offlineTileDB != nil {
                    offlineTileDB?.database.close()
                }
            }
        }
    }
    
    override func requestTileFor(x: UInt, y: UInt, zoom: UInt, receiver: GMSTileReceiver) {
        let flippedY = (1 << zoom) - y - 1
        if self.layersBbox.contains(x: x, y: y, zoom: zoom),
            let tileData = offlineTileDB?.tile(z: zoom, x: x, y: flippedY) {
            receiver.receiveTileWith(x: x, y: y, zoom: zoom, image: UIImage(data: tileData))
        } else {
            receiver.receiveTileWith(x: x, y: y, zoom: zoom, image: kGMSTileLayerNoTile)
        }
    }
    
    // Lấy tên file theo tile
    private func fileUrlFor(x: UInt, y: UInt, zoom: UInt) -> URL {
        
        let tilesFolder = self.urlComponents.url!
        
        // Tạo thư mục cho mỗi mức zoom
        let zPath = tilesFolder.appendingPathComponent("\(zoom)")
        _ = createDirectoryAtURL(url: zPath)
        
        // Tạo thư mục cho mỗi x
        let xPath = zPath.appendingPathComponent("\(x)")
        _ = createDirectoryAtURL(url: xPath)
        
        // Tạo tên file cho mỗi y
        let yPath = xPath.appendingPathComponent("\(y).png")
        return yPath
    }
    
    func pathForBoundary() -> GMSPath {
        let path = GMSMutablePath()
        let boxRect = CGRectFromString(self.boundaryString)
        
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

    
}
