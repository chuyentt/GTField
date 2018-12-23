//
//  UIImageView+Extensions.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 6/11/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import ImageIO
//import AEXML

extension UIImageView {
    
    /**
     Tự kiểm tra xem có kết nối thành công với GeoServer hay không
     - result icon online hoặc offline
    */
    public func imageForGeoServerBaseUrlChecking() -> Void {
        var request = URLRequest(url: getCapabilitiesForWMS()!)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: {(data, response, error) in
            DispatchQueue.main.async(execute: {
                if error != nil {
                    self.image = #imageLiteral(resourceName: "IconGeoServerBaseUrlOffline")
                } else {
                    do {
                        var options = AEXMLOptions()
                        options.parserSettings.shouldProcessNamespaces = false
                        options.parserSettings.shouldReportNamespacePrefixes = false
                        options.parserSettings.shouldResolveExternalEntities = false
                        let xmlDoc = try AEXMLDocument(xml: data!, options: options)
                        if xmlDoc.root.name.contains("WMS_Capabilities") {
                            self.image = #imageLiteral(resourceName: "IconGeoServerBaseUrl")
                        } else {
                            self.image = #imageLiteral(resourceName: "IconGeoServerBaseUrlOffline")
                        }
                    } catch {
                        print("Error")
                    }
                }
            })
        }).resume()
    }
    
    /**
     Tự kiểm tra xem có kết nối thành công với GeoServer hay không
     - result icon online hoặc offline
     */
    public func iconForGeoServerBaseUrl() -> Void {
        self.image = #imageLiteral(resourceName: "IconBroken")
        var request = URLRequest(url: getCapabilitiesForWMS()!)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: {(data, response, error) in
            DispatchQueue.main.async(execute: {
                if error != nil {
                    self.image = #imageLiteral(resourceName: "IconBroken")
                } else {
                    do {
                        var options = AEXMLOptions()
                        options.parserSettings.shouldProcessNamespaces = false
                        options.parserSettings.shouldReportNamespacePrefixes = false
                        options.parserSettings.shouldResolveExternalEntities = false
                        let xmlDoc = try AEXMLDocument(xml: data!, options: options)
                        if xmlDoc.root.name.contains("WMS_Capabilities") {
                            self.image = #imageLiteral(resourceName: "IconLink")
                        } else {
                            self.image = #imageLiteral(resourceName: "IconBroken")
                        }
                    } catch {
                        print("Error")
                    }
                }
            })
        }).resume()
    }
    
    // Tự động tải ảnh về, đến khi xong thì sẽ hiển thị (Đã test)
    // Ví dụ aboutImageView.imageFor(urlString: "https://images.g2crowd.com/uploads/attachment/file/29288/uploads_2Fcf11932b-cc04-4ea5-a6de-143e79ee1852_2FApple_OSX_Mountain_Lion_screenshot1.jpg")
    
    public func imageFor(_ urlString: String) -> Void {
        guard let url = URL(string: urlString) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: {(data, response, error) in
            DispatchQueue.main.async(execute: {
                if error != nil {
                    self.image = nil // Or kUIImageNoImage
                } else {
                    if let image = UIImage(data: data!) {
                        self.image = image
                    } else {
                        self.image = nil // Or kUIImageNoImage
                    }
                }
            })
        }).resume()
    }
    
    public func imageFor(_ urlString: String, _ destinationPath: String) -> Void {
        guard let url = URL(string: urlString) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: {(data, response, error) in
            DispatchQueue.main.async(execute: {
                if error != nil {
                    self.image = nil // Or kUIImageNoImage
                } else {
                    //if let image = UIImage(data: data!) {
                        //self.image = image
                        try! data?.write(to: URL(fileURLWithPath: destinationPath))
//                    } else {
//                        self.image = nil // Or kUIImageNoImage
//                    }
                }
            })
        }).resume()
    }
}
