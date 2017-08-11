//
//  Data+Extensions.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 6/11/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import Foundation

extension Data {
    func isImage() -> Bool {
        var c: __uint8_t = 0x00
        self.copyBytes(to: &c, count: 1)
        
        switch (c) {
            case 0xFF:
                return true
                //return @"image/jpeg";
            case 0x89:
                return true
                //return @"image/png";
            case 0x47:
                return true
                //return @"image/gif";
            case 0x49:
                return true
            case 0x4D:
                return true
                //return @"image/tiff";
            default:
                return false
        }
    }
}
