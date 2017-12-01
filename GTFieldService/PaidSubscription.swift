//
//  PaidSubscription.swift
//  GTFieldService
//
//  Created by Chuyen Trung Tran on 10/7/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import Foundation

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
    
    return formatter
}()

public struct PaidSubscription {
    
    public enum Level {
        case unlimited
        case yearly
        case monthly
        
        init?(productId: String) {
            if productId.contains("Unlimited") {
                self = .unlimited
            } else if productId.contains("Yearly") {
                self = .yearly
            } else if productId.contains("Monthly") {
                self = .monthly
            } else {
                return nil
            }
        }
    }
    
    public let productId: String
    public let purchaseDate: Date
    public let expiresDate: Date
    public let level: Level
    
    public var isActive: Bool {
        // is current date between purchaseDate and expiresDate?
        if self.level == .unlimited {
            return true
        } else {
            return (purchaseDate...expiresDate).contains(Date())
        }
    }
    
    init?(json: [String: Any]) {
        guard let productId = json["product_id"] as? String,
            let purchaseDateString = json["purchase_date"] as? String,
            let purchaseDate = dateFormatter.date(from: purchaseDateString),
            let expiresDateString = json["expires_date"] as? String,
            let expiresDate = dateFormatter.date(from: expiresDateString) else {
                return nil
        }
        
        self.productId = productId
        self.purchaseDate = purchaseDate
        self.expiresDate = expiresDate
        if productId.contains("Unlimited") {
            self.level = .unlimited
        } else {
            self.level = Level(productId: productId) ?? .unlimited
        }
    }
}
