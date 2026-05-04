//
//  GPXFileManager.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 7/12/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import Foundation

//GPX File extension
let kGPXFileExt = "gpx"
let kKMLFileExt = "kml"
let kGeoJSONExt = "json"
let kGeoJSONExt1 = "geojson"
let kMBTileFileExt = "mbtiles"

//
// Class to handle actions with gpx files (save, delete, etc..)
//
//
class GPXFileManager: NSObject {
    class var fileList: [AnyObject] {
        get {
            var Files: [String] = []
            
            do {
                // if you want to filter the directory contents you can do like this:
                if let directoryURLs = try? FileManager.default.contentsOfDirectory(at: docsURL,
                                                                                    includingPropertiesForKeys: nil,
                                                                                    options: FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants) {
                    
                    for url: URL in directoryURLs {
                        if url.pathExtension.lowercased() == kGPXFileExt ||
                            url.pathExtension.lowercased() == kKMLFileExt ||
                            url.pathExtension.lowercased() == kGeoJSONExt ||
                            url.pathExtension.lowercased() == kGeoJSONExt1 ||
                            url.pathExtension.lowercased() == kMBTileFileExt {
                            Files.append(url.lastPathComponent)
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
        let fileURL: URL = docsURL.appendingPathComponent(name)
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
                print("[ERROR] GPXFileManager:removeFile: \(fileURL) : \(e.localizedDescription)")
            }
        }
    }
    
    class func save(_ filename: String, gpxContents: String) {
        //check if name exists
        let finalFileURL: URL = docsURL.appendingPathComponent(filename)
        //save file
        print("Saving file at path: \(finalFileURL)")
        // write gpx to file
        var writeError: NSError?
        let saved: Bool
        do {
            try gpxContents.write(toFile: finalFileURL.path, atomically: true, encoding: String.Encoding.utf8)
            saved = true
        } catch let error as NSError {
            writeError = error
            saved = false
        }
        if !saved {
            if let error = writeError {
                print("[ERROR] GPXFileManager:save: \(error.localizedDescription)")
            }
        }
    }
}
