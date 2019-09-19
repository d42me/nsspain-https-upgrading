//
//  ViewController.swift
//  HTTPS Upgrading
//
//  Created by Dominik Scherm on 18.09.19.
//  Copyright © 2019 FirstBlink. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cookie = HTTPCookie(properties: [
            .domain: "localhost",
            .path: "/",
            .port: "3000",
            .name: "connect.sid",
            .version: 1,
            .value: "s%3AR706qiHWL1YwIqtfXDJqbgUmOQlHY-Yb.0QfY6zXuMOrrqTxIa1%2F%2BZt4AeDZx6za5sY9Ct1Kifj4"])
        
        // Private browsing
        let websiteDataStore = WKWebsiteDataStore.nonPersistent()
        websiteDataStore.httpCookieStore.setCookie(cookie!) {
            
            let jsonString = """
            [{
                "trigger": {
                    "url-filter": ".*"
                },
                "action": {
                    "type": "make-https"
                }
            }]
            """
            
            WKContentRuleListStore.default()?.compileContentRuleList(forIdentifier: "demoRuleList", encodedContentRuleList: jsonString, completionHandler: { (list, error) in
                guard let contentRuleList = list else {return}
                
                let config = WKWebViewConfiguration()
                config.websiteDataStore = websiteDataStore
                config.userContentController.add(contentRuleList)
                
                self.webView = WKWebView(frame: self.view.frame, configuration: config)
                self.view = self.webView
                self.webView!.navigationDelegate = self
                self.webView!.load(URLRequest(url: URL(string: "http://api.dnddev.com")!))
            })
        }
    }
}

extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        self.webView!.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                print(cookie)
            }
        }
    }
}
