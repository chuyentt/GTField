//
//  ListItem.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 9/6/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import Foundation

struct ListItem {
    let code: String
    let name: String
    let value: String
}

struct DatumParameters {
    func proj4() -> String {
        if datumItems.index(where: { (_item) -> Bool in
            (_item.code == code)
        }) != nil {
            return " +datum=\(code) +units=m +no_defs"
        } else {
            return " +towgs84=\(deltaX),\(deltaY),\(deltaZ),\(rotationX),\(rotationY),\(rotationZ),\(scaleFactor) +units=m +no_defs"
        }
    }
    var code: String
    var name: String
    var deltaX: Double
    var deltaY: Double
    var deltaZ: Double
    var rotationX: Double
    var rotationY: Double
    var rotationZ: Double
    var scaleFactor: Double
}

struct ProjectionParameters {
    func proj4() -> String {
        if code == "centralMeridian" {
            return " +lon_0=\(value)"
        } else if code == "standardParallel" {
            return " +lat_ts=\(value)"
        } else if code == "falseEasting" {
            return " +x_0=\(value)"
        } else if code == "falseNorthing" {
            return " +y_0=\(value)"
        } else if code == "originLatitude" {
            return " +lat_0=\(value)"
        } else if code == "scaleFactor" {
            return " +k=\(value)"
        } else if code == "standardParallel1" {
            return " +lat_1=\(value)"
        } else if code == "standardParallel2" {
            return " +lat_2=\(value)"
        } else if code == "originLongitude" {
            return " +lon_0=\(value)"
        } else if code == "originHeight" {
            return " +h_0=\(value)"
        } else if code == "orientation" {
            return " +o_0=\(value)"
        }
        return " +\(code)=\(value)"
    }
    let code: String
    var value: Double
    let format: Int // 0: double, 1: lat degree, 2: lon degree
}

struct EllipsoidParameters {
    func proj4() -> String {
        return " +ellps_code=\(code)"
    }
    let code: String
    let name: String
    let a: Double
    let rf: Double
}

