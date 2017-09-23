//
//  SubscriptionService.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 9/17/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import Foundation
import StoreKit

class SubscriptionService: NSObject {
    
    static let sessionIdSetNotification = Notification.Name("SubscriptionServiceSessionIdSetNotification")
    static let optionsLoadedNotification = Notification.Name("SubscriptionServiceOptionsLoadedNotification")
    static let restoreSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
    static let purchaseSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
    
    
    static let shared = SubscriptionService()
    
    var hasReceiptData: Bool {
        return loadReceipt() != nil
    }
    
    var currentSessionId: String? {
        didSet {
            NotificationCenter.default.post(name: SubscriptionService.sessionIdSetNotification, object: currentSessionId)
        }
    }
    
    var currentSubscription: PaidSubscription?
    
    var options: [Subscription]? {
        didSet {
            NotificationCenter.default.post(name: SubscriptionService.optionsLoadedNotification, object: options)
        }
    }
    
    func loadSubscriptionOptions() {
        
        let productIDPrefix = Bundle.main.bundleIdentifier!
        
        let donate = productIDPrefix + ".Donate"
        let unlimited  = productIDPrefix + ".Unlimited"
        
        let yearly = productIDPrefix + ".Yearly"
        let monthly  = productIDPrefix + ".Monthly"
        
        let productIDs = Set([donate, unlimited, yearly, monthly])
        
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func purchase(subscription: Subscription) {
        let payment = SKPayment(product: subscription.product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func uploadReceipt(completion: ((_ success: Bool) -> Void)? = nil) {
        if let receiptData = loadReceipt() {
//            SelfieService.shared.upload(receipt: receiptData) { [weak self] (result) in
//                guard let strongSelf = self else { return }
//                switch result {
//                case .success(let result):
//                    strongSelf.currentSessionId = result.sessionId
//                    strongSelf.currentSubscription = result.currentSubscription
//                    completion?(true)
//                case .failure(let error):
//                    print("🚫 Receipt Upload Failed: \(error)")
//                    completion?(false)
//                }
//            }
        }
    }
    
    private func loadReceipt() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
    
    return formatter
}()

public struct PaidSubscription {
    
    public enum Level {
        case donate
        case unlimited
        case yearly
        case monthly
        
        init?(productId: String) {
            if productId.contains("Donate") {
                self = .donate
            } else if productId.contains("Unlimited") {
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
        return (purchaseDate...expiresDate).contains(Date())
    }
    
    init?(json: [String: Any]) {
        guard
            let productId = json["product_id"] as? String,
            let purchaseDateString = json["purchase_date"] as? String,
            let purchaseDate = dateFormatter.date(from: purchaseDateString),
            let expiresDateString = json["expires_date"] as? String,
            let expiresDate = dateFormatter.date(from: expiresDateString)
            else {
                return nil
        }
        
        self.productId = productId
        self.purchaseDate = purchaseDate
        self.expiresDate = expiresDate
        self.level = Level(productId: productId) ?? .unlimited // if we've botched the productId give them all access :]
        
    }
}

// MARK: - SKProductsRequestDelegate

extension SubscriptionService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        options = response.products.map { Subscription(product: $0) }.sorted(by: { (s1, s2) -> Bool in
            s1.product.price.doubleValue > s2.product.price.doubleValue
        })
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKProductsRequest {
            print("Subscription Options Failed Loading: \(error.localizedDescription)")
        }
    }
}
