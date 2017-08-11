//
//  TileDownloader.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 6/29/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit

// This enum contains all the possible states a photo record can be in
enum TileRecordState {
    case new, downloaded, failed
}

class TileRecord {
    let name: String
    var state = TileRecordState.new
    var image = #imageLiteral(resourceName: "NoTile")
    
    init(name: String) {
        self.name = name
    }
}

class TileDownloader: Operation {
    let tileRecord: TileRecord
    
    init(tileRecord: TileRecord) {
        self.tileRecord = tileRecord
    }
    
    override func main() {
        if self.isCancelled {
            return
        }
        // Xác định đường dẫn theo bbox
        let arr = tileRecord.name.components(separatedBy: "-")
        let z: UInt = UInt(arr[0])!
        let x: UInt = UInt(arr[1])!
        let y: UInt = UInt(arr[2])!
        let flippedY = (1 << z) - y - 1
        let bbox = bboxForTile(x: x, y: flippedY, zoom: z)
        let tileSize = 256 // Tương thích cho các app khác
        var urlComponents = URLComponents(string: (getGeoServerTilesUrl()?.absoluteString)!)!
        urlComponents.queryItems?.append(URLQueryItem(name: "width", value: "\(tileSize)"))
        urlComponents.queryItems?.append(URLQueryItem(name: "height", value: "\(tileSize)"))
        urlComponents.queryItems?.append(URLQueryItem(name: "bbox", value: bbox))
        let data = try? Data(contentsOf: urlComponents.url!)
        if data != nil, let image = UIImage(data:data!) {
            self.tileRecord.image = image
            self.tileRecord.state = .downloaded
            
            let offlineTileDB = MBTileDB(path: DOWNLOADING_PATH_TO_DATABASE)
            offlineTileDB.saveToMBTile(z: z, x: x, y: y, tileData: data!, override: true)
        } else {
            self.tileRecord.state = .failed
            self.tileRecord.image = #imageLiteral(resourceName: "NoTile")
            print("Failed")
        }
    }
    
//    func urlFor(x: UInt, y: UInt, zoom: UInt) -> URL {
//        let bbox = bboxForTile(x: x, y: y, zoom: zoom)
//        var urlComp = self.urlComponents
//        urlComp.queryItems?.append(URLQueryItem(name: "bbox", value: bbox))
//        return urlComp.url!
//    }
}
