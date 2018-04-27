//
//  SubscriptionService.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 9/17/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import Foundation
import GTFieldService
import StoreKit

class SubscriptionService: NSObject {
    
    static let sessionIdSetNotification = Notification.Name("SubscriptionServiceSessionIdSetNotification")
    static let optionsLoadedNotification = Notification.Name("SubscriptionServiceOptionsLoadedNotification")
    static let restoreSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
    static let purchaseSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
    static let activeNotification = Notification.Name("SubscriptionServiceActiveNotification")
    static let inactiveNotification = Notification.Name("SubscriptionServiceInactiveNotification")
    
    
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
        
        let unlimited  = productIDPrefix + ".Unlimited"
        let yearly = productIDPrefix + ".Yearly"
        let monthly  = productIDPrefix + ".Monthly"
        
        let productIDs = Set([unlimited, yearly, monthly])
        
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
            GTFieldService.shared.upload(receipt: receiptData) { [weak self] (result) in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let result):
                    strongSelf.currentSessionId = result.sessionId
                    strongSelf.currentSubscription = result.currentSubscription
                    completion?(true)
                    if let currentSubscription = result.currentSubscription {
                        if currentSubscription.isActive {
                            setProVersion(true)
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: SubscriptionService.activeNotification, object: nil)
                            }
                            // Lần đầu tiên đăng ký, kích hoạt gói thành công
                            print("uploadReceipt success setProVersion(true)", currentSubscription.productId)
                        } else {
                            // Hết hạn
                            setProVersion(false)
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: SubscriptionService.inactiveNotification, object: nil)
                            }
                            print("uploadReceipt inActive setProVersion(false)", currentSubscription.productId)
                        }
                    }
                case .failure(let error):
                    print("🚫 Receipt Upload Failed: \(error)")
                    completion?(false)
//                    if !getUnlimited() {
//                        setProVersion(false)
//                    }
//                    DispatchQueue.main.async {
//                        NotificationCenter.default.post(name: SubscriptionService.inactiveNotification, object: nil)
//                    }
                    print("uploadReceipt failure setProVersion(false)")
                }
            }
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

// MARK: - SKProductsRequestDelegate

extension SubscriptionService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        options = response.products.map { Subscription(product: $0) }.sorted(by: { (s1, s2) -> Bool in
            s1.product.price.doubleValue > s2.product.price.doubleValue
        })
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKProductsRequest {
            let alert = UIAlertController(title: error.localizedDescription,
                                          message: nil,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .default, handler: nil))
            
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindowLevelAlert + 1;
            alertWindow.makeKeyAndVisible()
            alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
            print("Subscription Options Failed Loading: \(error.localizedDescription)")
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        
    }
}
