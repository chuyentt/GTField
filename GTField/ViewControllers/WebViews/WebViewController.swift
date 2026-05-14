//
//  WebViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 7/27/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import WebKit

enum WebViewContent {
    case `default`
    case `agreement`
}

class WebViewController: UIViewController, WKNavigationDelegate {
    
    private var webView: WKWebView!
    var urlString: String?
    var webViewContent: WebViewContent = .default

    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebSite()
        let shareItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        self.navigationItem.rightBarButtonItems = [shareItem]
        if self.webViewContent == .agreement {
            let btnAgree = UIBarButtonItem(title: NSLocalizedString("Agree", comment: ""), style: .done, target: self, action: #selector(agreeAction))
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            self.toolbarItems = [spacer, btnAgree, spacer]
            self.navigationController?.setToolbarHidden(false, animated: false)
            self.navigationController?.toolbar.barStyle = .default
            self.navigationController?.toolbar.isTranslucent = true
            self.navigationController?.toolbar.barTintColor = BAR_TINT_COLOR_DEFAULT
        }
    }

    @objc func close() {
        self.dismiss(animated: true) {
            if self.webViewContent == .agreement, !getAgreement() {
                let alert = UIAlertController(title: NSLocalizedString("Agreement", comment: ""), message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .destructive) { _ in setAgreement(false); exit(0) })
                alert.addAction(UIAlertAction(title: NSLocalizedString("Agree", comment: ""), style: .default) { _ in setAgreement(true) })
                alert.show()
            }
        }
    }

    @objc func agreeAction() { setAgreement(true); close() }

    func loadWebSite() {
        guard let str = urlString, let url = URL(string: str) else { return }
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
        if navigationAction.request.url?.scheme == "gtfield" {
            decisionHandler(.cancel); return
        }
        decisionHandler(.allow)
    }

    @IBAction func refreshButtonTapped(sender: AnyObject) { webView.reload() }
}
