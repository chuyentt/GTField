//
//  WebViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 7/27/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadWebSite()
        
        let shareItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(close))
        
        self.navigationItem.rightBarButtonItems = [shareItem]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: { () -> Void in
        })
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
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
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
