//
//  HelpViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 7/13/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadWebSite()

        self.title = "GTField Help"
        
        let shareItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(HelpViewController.close))
        
        self.navigationItem.rightBarButtonItems = [shareItem]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        self.dismiss(animated: true, completion: { () -> Void in
        })
    }

    func loadWebSite() {
        var myURL = URL(string: HELP_EN_URL)
        
        let prefferedLanguage = Locale.preferredLanguages[0] as String
        let arr = prefferedLanguage.lowercased().components(separatedBy: "-")
        if arr.contains("vn") || arr.contains("vi") {
            myURL = URL(string: HELP_VI_URL)
        }
        
        let myURLRequest:URLRequest = URLRequest(url: myURL!)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
