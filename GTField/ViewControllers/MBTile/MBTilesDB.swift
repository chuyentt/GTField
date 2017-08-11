//
//  MBTilesDB.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 7/23/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import MapKit

class MBTileDB: NSObject {
    // table tiles
    let zoom_level = "zoom_level"
    let tile_column = "tile_column"
    let tile_row = "tile_row"
    let tile_data = "tile_data"
    
    // table metadata
    let name = "name"
    let value = "value"
    
    let tile_id = "tile_id"
    let grid_id = "grid_id"
    let key_name = "key_name"
    let key_json = "key_json"
    let grid_utfgrid = "grid_utfgrid"
    
    //static let shared: MBTileDB = MBTileDB(path: MB_TILES_PATH)
    //static let cached: MBTileDB = MBTileDB(path: MB_TILES_CACHED)
    var pathToDatabase: String!
    var isDBOpen: Bool = false
    
    var database: FMDatabase!
    
    init(path: String) {
        super.init()
        pathToDatabase = path
        if openDatabase() {
            isDBOpen = true
        }
    }
    
    func openDatabase() -> Bool {
        if database == nil {
            if FileManager.default.fileExists(atPath: pathToDatabase) {
                database = FMDatabase(path: pathToDatabase)
                database.traceExecution = true
                database.logsErrors = true
            } else { // Tao moi
                if createMBTileDatabase(override: true, path: pathToDatabase) {
                    database = FMDatabase(path: pathToDatabase)
                    database.traceExecution = true
                    database.logsErrors = true
                }
            }
        }
        
        if database != nil {
            guard database.open() else {
                print("Unable to open database")
                return false
            }
            return true
        }
        return false
    }
    
    func setPath(path: String) -> Bool {
        if path == pathToDatabase {
            return true
        }
        if FileManager.default.fileExists(atPath: path) {
            database = FMDatabase(path: path)
            database.traceExecution = true
            database.logsErrors = true
            if database != nil {
                guard database.open() else {
                    print("Unable to open database")
                    return false
                }
                pathToDatabase = path
                return true
            }
        }
        return false
    }
    
    // Tạo db của tiles với các bảng: grid_key, grid_utfgrid, images, keymap, map, metadata
    // và views: grid_data, grids, tiles
    func createTileDatabase(override: Bool, path: String) -> Bool {
        var created = false
        
        if override || !FileManager.default.fileExists(atPath: path) {
            database = FMDatabase(path: path)
            
            if database != nil {
                // Open the database.
                if database.open() {
                    let map_query = "CREATE TABLE map (\(zoom_level) INTEGER, \(tile_column) INTEGER, \(tile_row) INTEGER, \(tile_id) TEXT, \(grid_id) TEXT)"
                    let grid_key_query = "CREATE TABLE grid_key (\(grid_id) TEXT, \(key_name) TEXT)"
                    let keymap_query = "CREATE TABLE keymap (\(key_name) TEXT, \(key_json) TEXT)"
                    let grid_utfgrid_query = "CREATE TABLE grid_utfgrid (\(grid_id) TEXT, \(grid_utfgrid) BLOB)"
                    let images_query = "CREATE TABLE images (\(tile_data) BLOB, \(tile_id) TEXT)"
                    let metadata_query = "CREATE TABLE metadata (\(name) TEXT, \(value) TEXT)"
                    let name_query = "CREATE UNIQUE INDEX name ON metadata (name)"
                    
                    let map_index_query = "CREATE UNIQUE INDEX map_index ON map (zoom_level, tile_column, tile_row)"
                    let grid_key_lookup_query = "CREATE UNIQUE INDEX grid_key_lookup ON grid_key (grid_id, key_name)"
                    let keymap_lookup_query = "CREATE UNIQUE INDEX keymap_lookup ON keymap (key_name)"
                    let grid_utfgrid_lookup_query = "CREATE UNIQUE INDEX grid_utfgrid_lookup ON grid_utfgrid (grid_id)"
                    let images_id_query = "CREATE UNIQUE INDEX images_id ON images (tile_id)"
                    
                    let tiles_view_query = "CREATE VIEW tiles AS SELECT map.zoom_level AS zoom_level, map.tile_column AS tile_column, map.tile_row AS tile_row, images.tile_data AS tile_data FROM map JOIN images ON images.tile_id = map.tile_id"
                    let grids_view_query = "CREATE VIEW grids AS SELECT map.zoom_level AS zoom_level, map.tile_column AS tile_column, map.tile_row AS tile_row, grid_utfgrid.grid_utfgrid AS grid FROM map JOIN grid_utfgrid ON grid_utfgrid.grid_id = map.grid_id"
                    let grid_data_view_query = "CREATE VIEW grid_data AS SELECT map.zoom_level AS zoom_level, map.tile_column AS tile_column, map.tile_row AS tile_row, keymap.key_name AS key_name, keymap.key_json AS key_json FROM map JOIN grid_key ON map.grid_id = grid_key.grid_id JOIN keymap ON grid_key.key_name = keymap.key_name"
                    do {
                        try database.executeUpdate(map_query, values: nil)
                        try database.executeUpdate(grid_key_query, values: nil)
                        try database.executeUpdate(keymap_query, values: nil)
                        try database.executeUpdate(grid_utfgrid_query, values: nil)
                        try database.executeUpdate(images_query, values: nil)
                        try database.executeUpdate(metadata_query, values: nil)
                        
                        try database.executeUpdate(map_index_query, values: nil)
                        try database.executeUpdate(grid_key_lookup_query, values: nil)
                        try database.executeUpdate(keymap_lookup_query, values: nil)
                        try database.executeUpdate(grid_utfgrid_lookup_query, values: nil)
                        try database.executeUpdate(images_id_query, values: nil)
                        try database.executeUpdate(name_query, values: nil)
                        
                        try database.executeUpdate(tiles_view_query, values: nil)
                        try database.executeUpdate(grids_view_query, values: nil)
                        try database.executeUpdate(grid_data_view_query, values: nil)
                        
                        created = true
                        pathToDatabase = path
                    }
                    catch {
                        print("Could not create table.")
                        print(error.localizedDescription)
                    }
                    let minx: Double = -180
                    let miny: Double = 0
                    let maxx: Double = 180
                    let maxy: Double = 90
                    
                    let bounds = "\(minx),\(miny),\(maxx),\(maxy)"
                    let center = "\((maxx+minx)/2),\((maxy+miny)/2)"
                    saveToMetadata(name: "version", value: MB_TILES_VERSION)
                    saveToMetadata(name: "bounds", value: bounds)
                    saveToMetadata(name: "center", value: center)
                    saveToMetadata(name: "format", value: "png")
                    saveToMetadata(name: "description", value: APP_FULL_NAME)
                    database.close()
                    database.close()
                }
                else {
                    print("Could not open the database.")
                }
            }
        }
        return created
    }
    
    // Tạo db của mbtiles với 2 bảng: metadata và tiles
    func createMBTileDatabase(override: Bool, path: String) -> Bool {
        var created = false
        
        if override || !FileManager.default.fileExists(atPath: path) {
            database = FMDatabase(path: path)
            
            if database != nil {
                // Open the database.
                if database.open() {
                    let createMetadataTableQuery = "create table metadata (\(name) tex, \(value) text)"
                    let createIndexMetadataTableQuery = "create unique index if not exists name on metadata(\(name))"
                    let createTilesTableQuery = "create table tiles (\(zoom_level) integer, \(tile_column) integer, \(tile_row) integer, \(tile_data) BLOB)"
                    let createIndexTilesTableQuery = "create unique index if not exists tile_index on tiles(\(zoom_level),\(tile_column),\(tile_row))"
                    
                    do {
                        try database.executeUpdate(createTilesTableQuery, values: nil)
                        try database.executeUpdate(createIndexTilesTableQuery, values: nil)
                        try database.executeUpdate(createMetadataTableQuery, values: nil)
                        try database.executeUpdate(createIndexMetadataTableQuery, values: nil)
                        created = true
                        pathToDatabase = path
                    }
                    catch {
                        print("Could not create table.")
                        print(error.localizedDescription)
                    }
                    
                    //let minx: Double = -180
                    //let miny: Double = 0
                    //let maxx: Double = 180
                    //let maxy: Double = 90
                    
                    //let bounds = "\(minx),\(miny),\(maxx),\(maxy)"
                    //let center = "\((maxx+minx)/2),\((maxy+miny)/2)"
                    //saveToMetadata(name: "name", value: "MBTiles")
                    saveToMetadata(name: "type", value: "overlay")
                    saveToMetadata(name: "version", value: MB_TILES_VERSION)
                    saveToMetadata(name: "description", value: APP_FULL_NAME)
                    saveToMetadata(name: "format", value: "png")
                    
                    //saveToMetadata(name: "bounds", value: bounds)
                    
                    //saveToMetadata(name: "center", value: center)
                    //saveToMetadata(name: "minzoom", value: "0")
                    //saveToMetadata(name: "maxzoom", value: "21")
                    database.close()
                }
                else {
                    print("Could not open the database.")
                }
            }
        }
        return created
    }
    
    func metadataValueFor(name: String) -> String {
        let query = "select value from metadata where name = ?"
        do {
            let results = try database.executeQuery(query, values: [name])
            if results.next() {
                return results.string(forColumn: "value")
            } else {
                print(database.lastError())
            }
        } catch {
            print(error.localizedDescription)
        }
        return String()
    }
    
    func tile(z: UInt, x: UInt, y: UInt) -> Data? {
        let queue = FMDatabaseQueue(path: pathToDatabase)
        var data: Data?
        
        queue?.inTransaction({ (database, rollback) in
            let query = "select tile_data from tiles where zoom_level = ? and tile_column = ? and tile_row = ?"
            do {
                let results = try database?.executeQuery(query, values: [Int(z), Int(x), Int(y)])
                while(results?.next())!{
                    //do your task
                    print("Read OK, ",z,x,y)
                    data = results!.data(forColumn: self.tile_data)
                }
            } catch {
                print(error.localizedDescription,z,x,y)
            }
        })
        return data
    }
    
    func saveToMBTile(z: UInt, x: UInt, y: UInt, tileData: Data, override: Bool) {
        // y = flippedY = (1 << z) - y - 1
        let data = NSData(data: tileData)
        if override {
            if openDatabase() {
                let queue = FMDatabaseQueue(path: pathToDatabase)
                queue?.inTransaction({ (database, rollback) in
                    do {
                        try database?.executeUpdate("INSERT OR REPLACE INTO tiles (zoom_level, tile_column, tile_row, tile_data) values (?, ?, ?, ?)", values: [z,x,y,data])
                    } catch {
                        print("Failed to insert initial data into the database.")
                        print((database?.lastError())!)
                    }
                })
            }
        } else if (tile(z: z, x: x, y: y) == nil) {
            if openDatabase() {
                let queue = FMDatabaseQueue(path: pathToDatabase)
                queue?.inTransaction({ (database, rollback) in
                    do {
                        try database?.executeUpdate("INSERT OR REPLACE INTO tiles (zoom_level, tile_column, tile_row, tile_data) values (?, ?, ?, ?)", values: [z,x,y,data])
                    } catch {
                        print("Failed to insert initial data into the database.")
                        print((database?.lastError())!)
                    }
                })
            }
        }
    }
    
    func saveToMetadata(name: String, value: String) {
        if openDatabase() {
            do {
                try database.executeUpdate("INSERT OR REPLACE INTO metadata (name, value) values (?, ?)", values: [name, value])
            } catch {
                print("Failed to insert initial data into the database.")
                print(database.lastError(), database.lastErrorMessage())
            }
        }
    }
    
    func saveToTile(z: UInt, x: UInt, y: UInt, tileData: NSData, override: Bool) {
        //images tile_data, tile_id (md5?)
        //map zoom_level, tile_column, tile_row, tile_id, grid_id(nul)
        
        // Chưa có tài liệu tham khảo
    }

}

