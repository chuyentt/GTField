//
//  HelpViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 7/13/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import WebKit

class HelpViewController: UIViewController, WKNavigationDelegate {

    private var webView: WKWebView!

    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebSite()
        self.title = "GTField Help"
        let shareItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(close))
        self.navigationItem.rightBarButtonItems = [shareItem]
    }

    @objc func close() { self.dismiss(animated: true) }

    func loadWebSite() {
        var urlStr = HELP_EN_URL
        let lang = Locale.preferredLanguages[0].lowercased()
        if lang.contains("vn") || lang.contains("vi") { urlStr = HELP_VI_URL }
        guard let url = URL(string: urlStr) else { return }
        webView.load(URLRequest(url: url))
    }

    // WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.view.showHUD(webView)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.view.hideHUD()
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.scheme == "gtfield" { decisionHandler(.cancel); return }
        decisionHandler(.allow)
    }

    @IBAction func refreshButtonTapped(sender: AnyObject) { webView.reload() }
}
