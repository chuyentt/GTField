//
//  WebViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 7/27/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit

enum WebViewContent {
    case `default`
    case `agreement`
}

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    var urlString: String?
    var webViewContent: WebViewContent = .default
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadWebSite()
        
        let shareItem = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(close))
        
        self.navigationItem.rightBarButtonItems = [shareItem]
        if self.webViewContent == .agreement {
            let btnAgree = UIBarButtonItem(title: NSLocalizedString("Agree", comment: ""), style: .done, target: self, action: #selector(agreeAction))
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            self.toolbarItems = [spacer, btnAgree, spacer]
            self.navigationController?.setToolbarHidden(false, animated: false)
            self.navigationController?.toolbar.barStyle = UIBarStyle.default
            self.navigationController?.toolbar.isTranslucent = true
            self.navigationController?.toolbar.barTintColor = BAR_TINT_COLOR_DEFAULT
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: { () -> Void in
            if self.webViewContent == .agreement {
                if !getAgreement() {
                    let alert = UIAlertController(title: NSLocalizedString("Agreement", comment: ""),
                                                  message: nil,
                                                  preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .destructive, handler: { (action: UIAlertAction!) in
                        setAgreement(false)
                        exit(0)
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Agree", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
                        setAgreement(true)
                    }))
                    alert.show()
                }
            }
        })
    }
    
    @objc func agreeAction() {
        setAgreement(true)
        self.close()
    }
    
    func loadWebSite() {
        let myURLRequest:URLRequest = URLRequest(url: URL(string: urlString!)!)
        webView.loadRequest(myURLRequest)
    }
    
    // UIWebViewDelegate
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.view.showHUD(self.webView)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.webView.hideHUD()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if let scheme = request.url?.scheme {
            if scheme == "gtfield" {
                print("we got a gtfield request: \(scheme)")
                if let result = webView.stringByEvaluatingJavaScript(from: "GTField.someJavascriptFunc()") {
                    print("result: \(result)")
                }
                return false
            }
        }
        return true
    }
    
    @IBAction func refreshButtonTapped(sender: AnyObject) {
        webView.reload()
    }
}
