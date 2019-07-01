//
//  CacheBroswerController.swift
//  Cake
//
//  Created by Dennis John on 9/2/16.
//  Copyright © 2016 Lips Labs. All rights reserved.
//

import UIKit
import WebKit
import NVActivityIndicatorView

class CacheBrowserController: UIViewController {

    var webview:WKWebView?
    
    var delegate:CacheBrowserDelegate?
    var visibilityDelegate:NavBarVisibilityDelegate?
    
    var isIndexBrowser = false
    
    var loadNotificationSentURL = "";
    
    var lastScrollOffset:CGFloat = 0.0
    
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    var url:URL? {
        didSet {
            if let newURL = url {
                if webview == nil {
                    setupWebView()
                }
                
                webview!.load(URLRequest(url: newURL))
            }
        }
    }
    
    var canGoBack:Bool {
        get {
            return webview?.canGoBack ?? false
        }
    }
    
    var canGoForward:Bool {
        get {
            return webview?.canGoForward ?? false
        }
    }
    
    func goForward() {
        webview?.goForward()
    }
    
    func goBack() {
        webview?.goBack()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        activityIndicator.color = UIColor.lightGray
//        activityIndicator.type = .ballScale
//        if !isIndexBrowser {
//            activityIndicator.startAnimating()
//        }
        
        if webview == nil {
            setupWebView()
        }
        view.clipsToBounds = false
        view.insertSubview(webview!, at: 0)
        
    }
    
    func setupWebView() {

        let userContentController = WKUserContentController()
        let loadScript = "window.webkit.messageHandlers.doneLoading.postMessage(document.URL+'{()}'+document.title);"
        
        let userScript = WKUserScript(source: loadScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        
        userContentController.addUserScript(userScript)
        userContentController.add(self, name: "doneLoading")
        
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        
        let screenWidth = UIScreen.main.bounds.size.width
        let safeTop = UIApplication.shared.keyWindow!.safeAreaInsets.top
        webview = WKWebView(frame: CGRect(x: 0, y: safeTop, width: screenWidth, height: view.frame.size.height - safeTop), configuration: configuration)
        webview?.scrollView.delegate = self
        webview!.navigationDelegate = self
        webview?.uiDelegate = self
        webview?.clipsToBounds = false
        webview?.scrollView.clipsToBounds = false
        
        if !isIndexBrowser {
            webview!.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        }
    }
    
    deinit {
        
    }
    
    override func viewWillLayoutSubviews() {
        let screenWidth = UIScreen.main.bounds.size.width
        let safeTop = UIApplication.shared.keyWindow!.safeAreaInsets.top
        webview?.frame = CGRect(x: 0, y: safeTop, width: screenWidth, height: view.frame.size.height - safeTop)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getLinksUsingJavascript() {
        webview?.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                                   completionHandler: { (html: Any?, error: Error?) in
                                    if let response = html as? String {
                                        debugPrint(response);
                                        let links = HtmlParser.parseGoogleResults(html: response)
                                        
                                        if links.count > 0 {
                                            self.delegate?.responseLinks(links: links)
                                        }
                                    }
        })
    }
    
    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if let targetURL = navigationAction.request.url {
        
            if navigationAction.targetFrame == nil {
                if targetURL.description.lowercased().range(of: "http://") == nil && targetURL.description.lowercased().range(of: "https://") ==  nil {
                    if UIApplication.shared.canOpenURL(targetURL) {
                        UIApplication.shared.openURL(targetURL)
                    }
                } else {
                    webview?.load(navigationAction.request)
                }
            }
        }
        return nil
        
    }
    
    

}

extension CacheBrowserController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if isIndexBrowser {
            getLinksUsingJavascript()
        } else {
//            activityIndicator.stopAnimating()
            let data = (message.body as! String).components(separatedBy: "{()}")
            
            delegate?.cachePageTitle(pageURL: url!.absoluteString, title: data[1])
            
            if loadNotificationSentURL != data[0] {
                delegate?.pageLoaded()
                loadNotificationSentURL = data[0]
            }
        }
    }
}

extension CacheBrowserController: WKUIDelegate {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            visibilityDelegate?.showProgress(progress: Float(webview!.estimatedProgress))
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

extension CacheBrowserController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !isIndexBrowser {
            delegate?.setNavigation()
        }
    }
}

extension CacheBrowserController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        
        if currentOffset > 0 && currentOffset != lastScrollOffset {
            delegate?.hideStatusBar()
        } else if currentOffset != lastScrollOffset {
            delegate?.showStatusBar()
        }
        
//        if currentOffset > 10 && currentOffset > lastScrollOffset {
//            visibilityDelegate?.hideNavBar()
//        } else  {
//            visibilityDelegate?.showNavBar()
//        }
        
        lastScrollOffset = currentOffset
        
    }
}
