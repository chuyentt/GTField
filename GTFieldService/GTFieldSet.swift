//
//  GTFieldSet.swift
//  GTFieldService
//
//  Created by Chuyen Trung Tran on 10/7/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import Foundation
import UIKit

public struct GTField {
    public let name: String
    public let image: UIImage
}

public struct GTFieldSet {
    public let name: String
    public let gtfields: [GTField]
    
    init(name: String, gtfields: [GTField]) {
        self.name = name
        self.gtfields = gtfields
    }
    
    init?(name: String, nameAndFileMap: [String: String]) {
        let bundle = Bundle(for: GTFieldService.self)
        let url = bundle.bundleURL.appendingPathComponent("GTFields", isDirectory: true)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        
        let gtfields = nameAndFileMap.map { (name, fileName) -> GTField in
            let imageUrl = url.appendingPathComponent(fileName)
            let imageData = try! Data(contentsOf: imageUrl)
            let image = UIImage(data: imageData)!
            let gtfield = GTField(name: name, image: image)
            return gtfield
        }
        
        self.name = name
        self.gtfields = gtfields
    }
//    
//    func setLimitedToYearlyGTField() -> GTFieldSet {
//        if let firstGTField = gtfields.first {
//            return GTFieldSet(name: name, gtfields: [firstGTField])
//        } else {
//            return self
//        }
//    }
}
