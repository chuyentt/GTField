//
//  InfoViewController.swift
//  appyMap
//
//  Created by AppyStudio on 09/2015.
//  Copyright (c) 2015 Nicola Canali. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI

class InfoViewController: UIViewController, SKPaymentTransactionObserver, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var lblVersione: UILabel!
    @IBOutlet weak var aboutImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"
        lblVersione.text = "\(APP_VERSION) build (\(APP_BUILD))"
        //aboutImageView.imageFor(urlString: "test.jpg")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnFeedback(_ sender: Any) {
        actionSendEmail()
    }
    
    @IBAction func btnRestore(_ sender: Any) {
//        Tạm thời bỏ qua
//        SKPaymentQueue.default().add(self)
//        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
     
        for transaction:SKPaymentTransaction in queue.transactions {
            
            if transaction.payment.productIdentifier == IAP_ID
            {
                let userDefaults = UserDefaults.standard
                userDefaults.set(true, forKey: "proUser")
                userDefaults.synchronize()
            }
        }
        
        let alert = UIAlertView(title: "Thank You", message: "Your purchase were restored.", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Buy")
    }
    
    internal func actionSendEmail() {
        let composer = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            if let nav = self.navigationController {
                nav.present(composer, animated: true, completion: nil)
            } else {
                self.present(composer, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertView(title: NSLocalizedString("No email accounts configured", comment: ""), message: NSLocalizedString("Please add a mail account in Settings to send mail from, by Go to Settings > Mail > Accounts > Add Account", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
            alert.show()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        
        composer.setToRecipients(["chuyentt@gmail.com"])
        composer.setSubject("[Feedback] \(APP_FULL_NAME)")
        let body = "Hi Chuyen, \n"
        composer.setMessageBody(body, isHTML: true)
        
        return composer
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.sent.rawValue:
            let alert = UIAlertView(title: NSLocalizedString("Sent", comment: ""), message: nil, delegate: nil, cancelButtonTitle: NSLocalizedString("Close", comment: ""))
            alert.show()
            break
        default:
            let alert = UIAlertView(title: NSLocalizedString("Whoops", comment: ""), message: nil, delegate: nil, cancelButtonTitle: NSLocalizedString("Close", comment: ""))
            alert.show()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
