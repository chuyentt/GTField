//
//  MBTileFileManager.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 7/22/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit

let kMBTileFileExt = "mbtiles"

class MBTileFileManager: NSObject {
    // Duyệt sâu đến các subdirectory
    class var mbtilesList: [String: URL] {
        get {
            var urls = [String: URL]()
            var mbtileDB: MBTileDB?
            
            let fileEnumerator = FileManager.default.enumerator(at: docsURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions(), errorHandler: nil)
            let mbtilesFiles:[URL] = fileEnumerator?.filter {
                ($0 as! URL).pathExtension == kMBTileFileExt && ($0 as! URL).lastPathComponent != "cached.mbtiles"
                } as! [URL]
            
            for url: URL in mbtilesFiles {
                mbtileDB = MBTileDB(path: url.path)
                var name = mbtileDB?.metadataValueFor(name: "name")
                if name?.length == 0 {
                    name = url.deletingPathExtension().lastPathComponent
                }
                urls[name!] = url
            }
            return urls
        }
    }
    
    
    //Gets the list of .gpx files in Documents directory
    class var fileList: [AnyObject] {
        get {
            var Files: [String] = []
            
            do {
                // if you want to filter the directory contents you can do like this:
                if let directoryURLs = try? FileManager.default.contentsOfDirectory(at: docsURL,
                                                                                    includingPropertiesForKeys: nil,
                                                                                    options: FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants) {
                    
                    for url: URL in directoryURLs {
                        if url.pathExtension == kMBTileFileExt {
                            Files.append(url.deletingPathExtension().lastPathComponent)
                        }
                    }
                }
            }
            return Files.sorted(by: { (s1, s2) -> Bool in
                s1 > s2 // Sắp xếp mới lên trên
            }) as [AnyObject]
        }
    }
    
    class func fileExists(_ name: String) -> Bool {
        let fileURL: URL = docsURL.appendingPathComponent(name)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    class func removeFile(_ name: String) {
        let fileURL: URL = docsURL.appendingPathComponent(name).appendingPathExtension(kMBTileFileExt)
        let defaultManager = FileManager.default
        var error: NSError?
        let deleted: Bool
        do {
            try defaultManager.removeItem(atPath: fileURL.path)
            deleted = true
        } catch let error1 as NSError {
            error = error1
            deleted = false
        }
        if !deleted {
            if let e = error {
                print("[ERROR] MBTileFileManager:removeFile: \(fileURL) : \(e.localizedDescription)")
            }
        }
    }
}
