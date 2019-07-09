//
//  BrowserContainerController.swift
//  Cake
//
//  Created by Dennis John on 9/2/16.
//  Copyright © 2016 Lips Labs. All rights reserved.
//

import UIKit
import AVKit
import SwiftVideoBackground
import WebKit

class SearchItem {
    var url:String
    var isLoaded:Bool
    var isLoading:Bool
    
    init(url:String) {
        self.url = url
        self.isLoaded = false
        self.isLoading = false
    }
}

protocol CacheBrowserDelegate {
    func pageLoaded()
    func setNavigation()
    func responseLinks(links:[String])
    func cachePageTitle(pageURL:String, title:String)
    func hideStatusBar()
    func showStatusBar()
}

protocol NavBarVisibilityDelegate {
    func hideNavBar()
    func showNavBar()
    func showProgress(progress:Float)
}

protocol EngineDelegate {
    func fullscreenEngine(at index:Int, screenshotBounds:CGRect, screenshotImage:UIImage?)
}

class BrowserContainerController: UIViewController {
    
    @IBOutlet weak var resultsScrollView: UIScrollView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var multiDexContainerView: UIView!
    
    @IBOutlet weak var toolViewContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var magicButton: UIButton!
    
    var indexBrowser = CacheBrowserController();
    var multiDexController:MultiDexController?
    
    var searchResults = [SearchItem]()
    var pageTitles = [String: String]()
    
    var searchTerm:String?
    
    var currentViewingIndex = 0 {
        didSet {
            HydrationHelper.instance.setActiveBrowser(index: currentViewingIndex)
        }
    };
    var currentLoadingIndex = 0;
    
    var navHidden = false
    var barsHidden:Bool = false
    
    var engines = [(name: "Google", searchURL: "https://www.google.com/search?q=%%searchTerm%%"),
                   (name: "Amazon", searchURL: "https://www.amazon.com/s?k=%%searchTerm%%"),
                   (name: "Bing Image Search", searchURL: "https://www.bing.com/images/search?q=%%searchTerm%%"),
                   (name: "Stack Overflow", searchURL: "https://stackoverflow.com/search?q=%%searchTerm%%"),
                   (name: "Reddit", searchURL: "https://www.reddit.com/search/?q=%%searchTerm%%")]
    var webViews = [CacheBrowserController]()
    
    
    var audioPlayer: AVAudioPlayer?
    var longPressTimer:Timer?
    
    var toolBarHeight:CGFloat {
        get {
            return 100 + UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }
    }
    
    var screenshotQueue:[Int] = []
    var queueRunning = false
    var screenShotTimer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolView.addBorders(edges: [.top], color: UIColor.lightGray)
        try? VideoBackground.shared.play(view: toolView, videoName: "xflame", videoType: "mp4")
        
        toolViewContainerHeightConstraint.constant = toolBarHeight
        
        resultsScrollView.delegate = self
        
        indexBrowser.view.alpha = 0.0
        
        for (index, _) in engines.enumerated() {
            let newBrowser = CacheBrowserController()
            newBrowser.engineIndex = index
            newBrowser.visibilityDelegate = self
            newBrowser.delegate = self
            newBrowser.screenShotDelegate = self
            resultsScrollView.addSubview(newBrowser.view)
            webViews.append(newBrowser)
        }
        resultsScrollView.layoutSubviews()
        if #available(iOS 11, *) {
            resultsScrollView.contentInsetAdjustmentBehavior = .never
        }
        
        
        let containerFrame = view.frame
        let safeY = UIApplication.shared.keyWindow!.safeAreaInsets.top
        resultsScrollView.frame = CGRect(x: 0.0, y: 0.0, width: containerFrame.width, height: containerFrame.height - toolBarHeight)
        multiDexContainerView.frame = CGRect(x: 0.0, y: safeY, width: containerFrame.width, height: containerFrame.height - toolBarHeight - safeY)
        
        addGestureRecognizers()
        
        let bootstrapData = HydrationHelper.instance.getBootstrapData()
        
        if (bootstrapData.tabs.keys.count == 0) {
            showSearch()
        } else {
            searchResults = [SearchItem]()
            multiDexController?.engines = engines
            resultsScrollView.isScrollEnabled = true
            
            let currentTab = bootstrapData.tabs[0]!
            var keys = Array(currentTab.keys)
            keys.sort()
            for key in keys {
                if let nextURL = currentTab[key] {
                    searchResults.append(SearchItem(url: nextURL))
                }
            }
            showURLS()
        }
        
        bootstrapData.showing == .multiDex ? showMultiDex() : showResults(index: bootstrapData.activeBrowser)
        
        
    }
    
    
    
    func showResults(index:Int) {
        let containerFrame = view.frame
        resultsScrollView.frame = CGRect(x: 0.0, y: 0.0, width: containerFrame.width, height: containerFrame.height - toolBarHeight)
        resultsScrollView.setContentOffset(CGPoint(x: (view.bounds.width * CGFloat(index)), y: 0), animated: false)
        multiDexContainerView.isHidden = true
        HydrationHelper.instance.setShowing(viewState: .browser)
    }
    
    func showMultiDex() {
        let containerFrame = view.frame
        let safeY = UIApplication.shared.keyWindow!.safeAreaInsets.top
        resultsScrollView.frame = CGRect(x: 0.0, y: containerFrame.height, width: containerFrame.width, height: containerFrame.height - toolBarHeight)
        multiDexContainerView.isHidden = false
        HydrationHelper.instance.setShowing(viewState: .multiDex)
    }
    
    override var prefersStatusBarHidden: Bool {
        return barsHidden
    }
    
    
    func addGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(magicButtonTapped))
        tapRecognizer.numberOfTapsRequired = 1
        magicButton.addGestureRecognizer(tapRecognizer)
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(showSearch))
        doubleTapRecognizer.numberOfTapsRequired = 2
        magicButton.addGestureRecognizer(doubleTapRecognizer)
        tapRecognizer.require(toFail: doubleTapRecognizer)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(startSpy(_:)))
        magicButton.addGestureRecognizer(longGesture)
        
    }
    
    @objc func showSearch() {
        if let searchController = storyboard?.instantiateViewController(withIdentifier: "searchController") as? SearchPopupController {
            searchController.delegate = self
            present(searchController, animated: true, completion: nil)
        }
    }
    
    @objc func penguinSwiped(gestureRecognizer: UISwipeGestureRecognizer) {
        showSearch()
    }
    @objc func magicButtonTapped(recognizer: UITapGestureRecognizer) {
        if (currentViewingIndex < searchResults.count - 1){
            resultsScrollView.setContentOffset(CGPoint(x: resultsScrollView.contentOffset.x + view.bounds.width, y: 0), animated: true)
        }
    }
    @objc func magicButtonDoubleTapped(recognizer: UITapGestureRecognizer) {
        if (currentViewingIndex > 0) {
            resultsScrollView.setContentOffset(CGPoint(x: max(resultsScrollView.contentOffset.x - view.bounds.width, 0), y: 0), animated: true)
        }
    }
    
    @IBAction func buttonOneTapped(_ sender: Any) {
    }
    
    @IBAction func buttonTwoTapped(_ sender: Any) {
        showMultiDex()
        queueScreenshot(index: currentViewingIndex)
        for i in 0...webViews.count - 1 {
            queueScreenshot(index: i)
        }
    }
    
    @IBAction func buttonThreeTapped(_ sender: Any) {
    }
    @IBAction func buttonFourTapped(_ sender: Any) {
    }
    
    
    func processSearch() {
        currentLoadingIndex = 0
        currentViewingIndex = 0
        HydrationHelper.instance.setActiveBrowser(index: 0)
        if searchTerm != nil {
            if verifyUrl(urlString: formattedURLString(string: searchTerm!)) {
                pageTitles = [String: String]()
                searchResults = [SearchItem(url: formattedURLString(string: searchTerm!))]
                resultsScrollView.isScrollEnabled = false
                showResults(index: 0)
            } else {
                searchResults = []
                pageTitles = [String: String]()
                if let escapedSearchTerm = searchTerm!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    searchResults = [SearchItem]()
                    for engine in engines {
                        let replacedURL = engine.searchURL.replacingOccurrences(of: "%%searchTerm%%", with: escapedSearchTerm)
                        searchResults.append(SearchItem(url: replacedURL))
                    }
                    
                    multiDexController?.screenShots = [:]
                    multiDexController?.engines = engines
                    
                    resultsScrollView.isScrollEnabled = true
                    showMultiDex()
                }
            }
            
        }
        
        if searchResults.count > 0 {
            showURLS()
        }
    }
    
    override func viewWillLayoutSubviews() {
        var offset:CGFloat = 0.0
        
        let screenWidth = UIScreen.main.bounds.size.width
        
        for controller in webViews {
            controller.view.frame = CGRect(x: offset, y: 0, width: screenWidth, height: resultsScrollView.frame.size.height)
            offset += screenWidth
        }
        resultsScrollView.contentSize = CGSize(width: CGFloat(webViews.count) * screenWidth, height: resultsScrollView.frame.size.height)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "multidexSegue" {
            if let childVC = segue.destination as? MultiDexController {
                //Some property on ChildVC that needs to be set
                childVC.engineDelegate = self
                multiDexController = childVC
            }
        }
    }
    
    func verifyUrl(urlString: String) -> Bool {
        
        let urlRegEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[urlRegEx])
        
        return predicate.evaluate(with: urlString)
    }
    
    func formattedURLString(string:String)->String {
        if !string.contains("://") {
            return "http://\(string)"
        }
        return string
    }
    
    func sanitizeURL(urlString: String?) -> String {
        if let urlString = urlString {
            if let url  = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(url) {
                    return urlString
                }
            }
            return "http://\(urlString)"
        }
        return urlString!
    }
    
    func showURLS() {
        
        clearCurrentResults()
        resultsScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        for (index, result) in searchResults.enumerated() {
            result.isLoading = true
            webViews[index].url = URL(string: result.url)
        }
    }
    
    func clearCurrentResults() {
        
    }
    
    func setNavigation() {
        for (index, controller) in webViews.enumerated() {
            controller.visibilityDelegate = index == currentViewingIndex ? self : nil
        }
//
//        showPageTitle()
    }
    
    @IBAction func goForward(sender: AnyObject) {
        webViews[currentViewingIndex].goForward()
    }
    
    @IBAction func goBack(sender: AnyObject) {
        webViews[currentViewingIndex].goBack()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func startSpy(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .ended {
            if sender.isEnabled {
                audioPlayer?.stop()
            }
            longPressTimer?.invalidate()
        }
        else if sender.state == .began {
            longPressTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] (timer) in
                sender.isEnabled = false
                sender.isEnabled = true
                self?.onShowSearchSpy()
            }
            do {
                if let fileURL = Bundle.main.path(forResource: "powerup", ofType: "mp3") {
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
                    audioPlayer?.play()
                } else {
                    print("No file with specified name exists")
                }
            } catch let error {
                print("Can't play the audio file failed with an error \(error.localizedDescription)")
            }
        }
    }
    
    func onShowSearchSpy() {
        let storyboard = UIStoryboard(name: "XBrowser", bundle: nil)
        if let spyController = storyboard.instantiateViewController(withIdentifier: "SearchSpy") as? SearchSpyViewController {
            spyController.delegate = self
            present(spyController, animated: true, completion: nil)
        }
    }
}

extension BrowserContainerController:NavBarVisibilityDelegate {
    func hideNavBar() {
//        if !navHidden {
//            navHidden = true
//            UIView.animate(withDuration: 0.3) {
//                self.toolViewBottomConstraint.constant = 80.0 + UIApplication.shared.keyWindow!.safeAreaInsets.bottom
//                self.buttonBottomConstraint.constant = -143.0 - UIApplication.shared.keyWindow!.safeAreaInsets.bottom
//                self.view.layoutIfNeeded()
//            }
//        }
    }
    
    func showNavBar() {
//        if navHidden {
//            navHidden = false
//            UIView.animate(withDuration: 0.3) {
//                self.toolViewBottomConstraint.constant = 0.0
//                self.buttonBottomConstraint.constant = 15.0
//                self.view.layoutIfNeeded()
//            }
//        }
    }
    
    func showProgress(progress:Float) {

    }

    func showPageTitle() {
//        if let title = pageTitles[searchResults[currentViewingIndex].url] {
//            navBarController?.setPageTitle(title)
//        }
    }
}

extension BrowserContainerController: SearchDelegate {
    func getResults(searchTerm: String?) {
        if let term = searchTerm {
            self.searchTerm = term
            processSearch()
        }
    }
}

//extension BrowserContainerController: UISearchBarDelegate {
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        searchTerm = searchBar.text
//        processSearch()
//    }
//}

extension BrowserContainerController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollComplete()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollComplete()
    }
    
    func scrollComplete() {
        currentViewingIndex = Int(resultsScrollView.contentOffset.x / UIScreen.main.bounds.width)
        setNavigation()
//        showNavBar()
    }
}

extension BrowserContainerController: CacheBrowserDelegate {
    func pageLoaded() {
        
        searchResults[currentLoadingIndex].isLoaded = true
        searchResults[currentLoadingIndex].isLoading = false

        setNavigation()
        
    }
    
    func responseLinks(links: [String]) {
        
        for result in links {
            let newItem = SearchItem(url: result)
            searchResults.append(newItem)
        }
        
        showURLS()
    }
    
    func cachePageTitle(pageURL: String, title: String) {
        pageTitles[pageURL] = title
//        showPageTitle()
    }
    
    func hideStatusBar() {
        barsHidden = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func showStatusBar() {
        barsHidden = false
        setNeedsStatusBarAppearanceUpdate()
    }
}

extension BrowserContainerController: SpyDelegate {
    func stealURL(url: String) {
        getResults(searchTerm: url)
    }
}

extension BrowserContainerController: ScreenshotDelegate {
    func queueScreenshot(index:Int) {
        if !resultsScrollView.isScrollEnabled || multiDexContainerView.isHidden {
            return
        }
        if (!screenshotQueue.contains(index)) {
            screenshotQueue.append(index)
            print(screenshotQueue)
        }
        if (!queueRunning) {
            queueRunning = true
            processNextScreenshot()
        }
    }
    
    func processNextScreenshot() {
        if !queueRunning { return }
        
        if (screenshotQueue.count > 0){
            let nextScreen = screenshotQueue.removeFirst()
            resultsScrollView.setContentOffset(CGPoint(x: (view.bounds.width * CGFloat(nextScreen)), y: 0), animated: false)
            screenShotTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: {[weak self] outerTimer in
                let snapshotConfiguration = WKSnapshotConfiguration()
                snapshotConfiguration.snapshotWidth = 400
                self?.webViews[nextScreen].webview?.takeSnapshot(with: snapshotConfiguration, completionHandler: {[weak self] (image, error) in
                    self?.multiDexController?.replaceImageAtIndex(index: nextScreen, image: (date: Date(), image: image))
//                    self?.screenShotTimer = Timer.scheduledTimer(withTimeInterval: 0.1
//                        , repeats: false, block: {[weak self] timer in
                        self?.processNextScreenshot()
//                    })
                })
//                if let screenshot = self?.resultsScrollView.screenShot {
//                    if (self?.queueRunning ?? false){
//                        self?.multiDexController?.replaceImageAtIndex(index: nextScreen, image: (date: Date(), image: screenshot))
//                        self?.screenShotTimer = Timer.scheduledTimer(withTimeInterval: 0.1
//                            , repeats: false, block: {[weak self] timer in
//                            self?.processNextScreenshot()
//                        })
//                    }
//                }
            })
        } else {
            queueRunning = false
        }
    }
}

extension BrowserContainerController:EngineDelegate {
    func fullscreenEngine(at index:Int, screenshotBounds: CGRect, screenshotImage: UIImage?) {
        showResults(index: index)
        currentViewingIndex = index
        screenShotTimer?.invalidate()
        screenshotQueue = []
        queueRunning = false
    }
}

extension UIView {
    var screenShot: UIImage?  {
        if #available(iOS 10, *) {
            let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
            return renderer.image { (context) in
                self.layer.render(in: context.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 5);
            if let _ = UIGraphicsGetCurrentContext() {
                drawHierarchy(in: bounds, afterScreenUpdates: true)
                let screenshot = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return screenshot
            }
            return nil
        }
    }
}
