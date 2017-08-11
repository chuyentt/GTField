//
//  WMSTileLayer.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 6/11/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import GoogleMaps
//import AEXML

extension CGRect {
    func contains(x: UInt, y: UInt, zoom: UInt) -> Bool {
        let lat = tiley2Lat(y: y, z: zoom)
        let lon = tilex2Lon(x: x, z: zoom)
        return self.contains(CGPoint(x: lon, y: lat))
    }
}

class WMSTileLayer: GMSTileLayer {
    var urlComponents: URLComponents = URLComponents()
    var layersBbox: CGRect = CGRect()
    var cacheTileDB: MBTileDB?
    
    init(_ tileSize: Int = 256) {
        super.init()

        // Cách này có vẻ nhanh hơn
        //self.tileSize = Int(256*3)

        // Lấy ở hệ thống
        let layersBboxStr = getLayersBoundingBoxForWMS()
        self.layersBbox = CGRectFromString(layersBboxStr).insetBy(dx: -0.001, dy: -0.001)

        // Tạo url chuẩn
        self.urlComponents = URLComponents(string: (getGeoServerTilesUrl()?.absoluteString)!)!
        self.urlComponents.queryItems?.append(URLQueryItem(name: "width", value: "\(tileSize)"))
        self.urlComponents.queryItems?.append(URLQueryItem(name: "height", value: "\(tileSize)"))
        
        // Tạo cached.mbtiles nếu chưa có
        cacheTileDB = MBTileDB(path: MB_TILES_CACHED)
        if cacheTileDB != nil, (cacheTileDB?.isDBOpen)! {
            print("Open success: ", MB_TILES_CACHED)
        } else {
            if (cacheTileDB?.createMBTileDatabase(override: true, path: MB_TILES_CACHED))! {
                print("Create success: ", MB_TILES_CACHED)
            }
        }
    }
    
    override var map: GMSMapView? {
        didSet {
            if map != nil {
                map?.moveCamera(GMSCameraUpdate.fit(GMSCoordinateBounds.init(path: (pathForBoundary()))))
            } else {
                if cacheTileDB != nil {
                    cacheTileDB?.database.close()
                }
            }
        }
    }
    
    override func requestTileFor(x: UInt, y: UInt, zoom: UInt, receiver: GMSTileReceiver) {
        let flippedY = (1 << zoom) - y - 1
        if self.layersBbox.contains(x: x, y: y, zoom: zoom) {
            if let tileData = cacheTileDB?.tile(z: zoom, x: x, y: flippedY) {
                receiver.receiveTileWith(x: x, y: y, zoom: zoom, image: UIImage(data: tileData))
            } else {
                let url = urlFor(x: x, y: y, zoom: zoom)
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                let session = URLSession.shared
                session.dataTask(with: request, completionHandler: {(data, response, error) in
                    DispatchQueue.main.async(execute: {
                        if error != nil {
                            print("Error downloading tile")
                            receiver.receiveTileWith(x: x, y: y, zoom: zoom, image: kGMSTileLayerNoTile)
                        } else {
                            if let image = UIImage(data: data!) {
                                // Lưu tile vào cache
                                self.cacheTileDB?.saveToMBTile(z: zoom, x: x, y: flippedY, tileData: data!, override: true)
                                receiver.receiveTileWith(x: x, y: y, zoom: zoom, image: image)
                            } else {
                                receiver.receiveTileWith(x: x, y: y, zoom: zoom, image: kGMSTileLayerNoTile)
                            }
                        }
                    })
                }).resume()
            }
        } else {
            receiver.receiveTileWith(x: x, y: y, zoom: zoom, image: kGMSTileLayerNoTile)
        }
    }
    
    func urlFor(x: UInt, y: UInt, zoom: UInt) -> URL {
        let bbox = bboxForTile(x: x, y: y, zoom: zoom)
        var urlComp = self.urlComponents
        urlComp.queryItems?.append(URLQueryItem(name: "bbox", value: bbox))
        return urlComp.url!
    }

    /**
     Tạo danh sách các tileUrl để download
     - result [[String]]: [["destination","url"]
    */
    func tileUrlList(_ name: String, _ minZoom: UInt, _ maxZoom: UInt, _ box: GMSCoordinateBounds) -> [String] {
        if self.map == nil {
            return []
        }

        var urlList = [String]()
        urlList.removeAll()
        
        var minx = lon2Tilex(lon: box.southWest.longitude, z: minZoom)
        var miny = lat2Tiley(lat: box.northEast.latitude, z: minZoom)
        var maxx = lon2Tilex(lon: box.northEast.longitude, z: minZoom) + 1
        var maxy = lat2Tiley(lat: box.southWest.latitude, z: minZoom) + 1
        
        // Duyệt các tile
        for z in minZoom...maxZoom {
            for x in minx...maxx {
                for y in miny...maxy {
                    let flippedY = (1 << z) - y - 1
                    let fileUrl = "\(z)-\(x)-\(flippedY)"
                    urlList.append(fileUrl)
                }
            }
            minx *= 2
            miny *= 2
            maxx *= 2
            maxy *= 2
        }
        return urlList
    }
    
    func pathForBoundary() -> GMSPath {
        let path = GMSMutablePath()
        let boxRect = layersBbox
        
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
