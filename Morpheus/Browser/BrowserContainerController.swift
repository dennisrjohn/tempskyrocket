//
//  BrowserContainerController.swift
//  Cake
//
//  Created by Dennis John on 9/2/16.
//  Copyright © 2016 Lips Labs. All rights reserved.
//

import UIKit
import AVKit
//import SwiftVideoBackground
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
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var resultsScrollView: UIScrollView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var multiDexContainerView: UIView!
    @IBOutlet weak var homeScreenContainerView: UIView!
    
    @IBOutlet weak var toolViewContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var magicButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var browserTabDelegate:BrowserTabDelegate?
    var statusBarDelegate:TopStatusBarDelegate?
    
//    var indexBrowser = CacheBrowserController();
    var multiDexController:MultiDexController?
    var homeScreenController:HomeScreenController?
    
    var searchResults = [SearchItem]()
    var pageTitles = [String: String]()
    
    var searchTerm:String?
    var tabIndex:Int = 0
    
    var currentViewingIndex = 0 {
        didSet {
            HydrationHelper.instance.setActiveBrowser(index: currentViewingIndex, forTab: tabIndex)
        }
    };
    var currentLoadingIndex = 0;
    
    var navHidden = false
    var barsHidden:Bool = false
    
    var engines = [(name: "Google", searchURL: "https://www.google.com/search?q=%%searchTerm%%"),
                   (name: "Wikipedia", searchURL: "https://en.wikipedia.org/wiki/Special:Search?search=%%searchTerm%%"),
                   (name: "YouTube", searchURL: "https://www.youtube.com/results?search_query=%%searchTerm%%"),
                   (name: "Google Images", searchURL:"https://google.com/search?q=%%searchTerm%%&tbm=isch"),
                   (name: "Amazon", searchURL: "https://www.amazon.com/s?k=%%searchTerm%%"),
                   (name: "Google News", searchURL:"https://google.com/search?q=%%searchTerm%%&tbm=nws"),
                   (name: "Reddit", searchURL: "https://www.reddit.com/search/?q=%%searchTerm%%"),
                   (name: "DuckDuckGo", searchURL: "https://duckduckgo.com/?q=%%searchTerm%%"),
                   (name: "Bing Images", searchURL: "https://www.bing.com/images/search?q=%%searchTerm%%"),
                   (name: "Yahoo", searchURL: "https://search.yahoo.com/search?p=%%searchTerm%%"),
                   (name: "Yandex", searchURL: "https://yandex.com/search/?text=%%searchTerm%%"),
                   (name: "Twitter", searchURL: "https://twitter.com/search?q=%%searchTerm%%"),
                   (name: "Bing Video", searchURL: "https://www.bing.com/videos/search?q=%%searchTerm%%"),
                   (name: "DuckDuckGo Video", searchURL: "https://duckduckgo.com/?q=%%searchTerm%%&iax=videos&ia=videos"),
                   (name: "Bing News", searchURL: "https://www.bing.com/news/search?q=%%searchTerm%%"),
                   (name: "Ecosia", searchURL: "https://www.ecosia.org/search?q=%%searchTerm%%")]
    var webViews = [CacheBrowserController]()
    
    
    var audioPlayer: AVAudioPlayer?
    var longPressTimer:Timer?
    
    var toolBarHeight:CGFloat {
        get {
            return 60 + UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }
    }
    
    var screenshotQueue:[Int] = []
    var queueRunning = false
    var screenShotTimer:Timer?
    
    var initted = false
    
    var resultsShowing:Bool {
        get {
            return multiDexContainerView.isHidden && homeScreenContainerView.isHidden
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolView.addBorders(edges: [.top], color: UIColor.lightGray)
//        try? VideoBackground.shared.play(view: toolView, videoName: "xflame", videoType: "mp4")
        
        toolViewContainerHeightConstraint.constant = toolBarHeight
        
        resultsScrollView.delegate = self
        
//        indexBrowser.view.alpha = 0.0
        
        for (index, _) in engines.enumerated() {
            let newBrowser = CacheBrowserController()
            newBrowser.tabIndex = tabIndex
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
        
        checkOrientation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let widthDiff = size.width / view.bounds.width
        let heightDiff = size.height / view.bounds.height
        let currentContentOffset = resultsScrollView.contentOffset
        
        if (size.width > size.height) {
            resultsScrollView.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
            if (resultsShowing){
                toolViewContainerHeightConstraint.constant = 0
            }
        } else {
            resultsScrollView.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
            toolViewContainerHeightConstraint.constant = toolBarHeight
        }
        resultsScrollView.setContentOffset(CGPoint(x: currentContentOffset.x * widthDiff, y: currentContentOffset.y * heightDiff), animated: false)
    }
    
    func checkOrientation() {
        if resultsShowing {
            AppDelegate.AppUtility.lockOrientation(.allButUpsideDown)
        } else {
            AppDelegate.AppUtility.lockOrientation(.portrait)
        }
        
        checkStatusBar()
    }
    
    func checkStatusBar() {
        if !multiDexContainerView.isHidden {
            containerView.backgroundColor = UIColor.darkGray
            statusBarDelegate?.setStatusBarStyle(.lightContent)
        } else {
            containerView.backgroundColor = UIColor.white
            statusBarDelegate?.setStatusBarStyle(.default)
        }
    }
    
    func initialize() {
        let bootstrapData = HydrationHelper.instance.getBootstrapData(forTab: tabIndex)
        
        if (bootstrapData.browserURLs.keys.count == 0) {
            showSearch()
        } else {
            searchResults = [SearchItem]()
            multiDexController?.engines = engines
            multiDexController?.searchTerm = bootstrapData.searchTerm
            resultsScrollView.isScrollEnabled = true
            
            var keys = Array(bootstrapData.browserURLs.keys)
            keys.sort()
            for key in keys {
                if let nextURL = bootstrapData.browserURLs[key] {
                    searchResults.append(SearchItem(url: nextURL))
                }
            }
            showURLS()
        }
        
        switch bootstrapData.showing {
        case .browser:
            showResults(index: bootstrapData.activeBrowser)
        case .multiDex:
            showMultiDex()
        default:
            showSearch()
        }
        
        setNavigation()
        
        initted = true
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return barsHidden
    }
    
    func showResults(index:Int) {
        hideHome()
        let containerFrame = view.frame
        resultsScrollView.frame = CGRect(x: 0.0, y: 0.0, width: containerFrame.width, height: containerFrame.height - toolBarHeight)
        resultsScrollView.setContentOffset(CGPoint(x: (view.bounds.width * CGFloat(index)), y: 0), animated: false)
        multiDexContainerView.isHidden = true
        setNavigation()
        checkStatusBar()
        HydrationHelper.instance.setShowing(viewState: .browser, forTab: tabIndex)
    }
    
    func showMultiDex() {
        hideHome()
        let containerFrame = view.frame
        resultsScrollView.frame = CGRect(x: 0.0, y: containerFrame.height, width: containerFrame.width, height: containerFrame.height - toolBarHeight)
        multiDexContainerView.isHidden = false
        setNavigation()
        checkStatusBar()
        HydrationHelper.instance.setShowing(viewState: .multiDex, forTab: tabIndex)
    }
    
    @objc func showSearch() {
        HydrationHelper.instance.setShowing(viewState: .homeScreen, forTab: tabIndex)
        homeScreenContainerView.isHidden = false
        multiDexContainerView.isHidden = true
        setNavigation()
        checkStatusBar()
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.homeScreenContainerView.alpha = 1.0
        })
        
    }
    
    func hideHome() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.homeScreenContainerView.alpha = 0.0
        }, completion: { [weak self] _ in
            self?.homeScreenContainerView.isHidden = true
        })
    }
    
    func addGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(showSearch))
        tapRecognizer.numberOfTapsRequired = 1
        magicButton.addGestureRecognizer(tapRecognizer)
//        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(showSearch))
//        doubleTapRecognizer.numberOfTapsRequired = 2
//        magicButton.addGestureRecognizer(doubleTapRecognizer)
//        tapRecognizer.require(toFail: doubleTapRecognizer)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(startSpy(_:)))
        magicButton.addGestureRecognizer(longGesture)
        
    }
    
    
//    @objc func penguinSwiped(gestureRecognizer: UISwipeGestureRecognizer) {
//        showSearch()
//    }
//    @objc func magicButtonTapped(recognizer: UITapGestureRecognizer) {
//        if (currentViewingIndex < searchResults.count - 1){
//            resultsScrollView.setContentOffset(CGPoint(x: resultsScrollView.contentOffset.x + view.bounds.width, y: 0), animated: true)
//        }
//    }
//    @objc func magicButtonDoubleTapped(recognizer: UITapGestureRecognizer) {
//        if (currentViewingIndex > 0) {
//            resultsScrollView.setContentOffset(CGPoint(x: max(resultsScrollView.contentOffset.x - view.bounds.width, 0), y: 0), animated: true)
//        }
//    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        webViews[currentViewingIndex].goBack()
    }
    
    @IBAction func showMultiDexTapped(_ sender: Any) {
        showMultiDex()
        queueScreenshot(index: currentViewingIndex)
        for i in 0...webViews.count - 1 {
            queueScreenshot(index: i)
        }
    }
    
    @IBAction func shareTapped(_ sender: Any) {
        shareCurrentContext()
    }
    @IBAction func tabsTapped(_ sender: Any) {
        let safeArea = UIApplication.shared.keyWindow!.safeAreaInsets
        let yOffset = safeArea.top * -1
        let targetHeight = view.bounds.size.height - safeArea.top - safeArea.bottom
        let bounds = CGRect(x: 0.0, y: yOffset, width: view.bounds.width, height: targetHeight)
        
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        
        let image = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: bounds.width, height: bounds.height), true, 0.0)
        image.draw(at: CGPoint(x: 0, y: yOffset))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        _ = TabScreenshotHelper.instance.saveImage(image: croppedImage!, forTab: tabIndex)
        
        browserTabDelegate?.showAllTabs()
        
    }
    
    
    func processSearch() {
        currentLoadingIndex = 0
        currentViewingIndex = 0
        HydrationHelper.instance.setActiveBrowser(index: 0, forTab: tabIndex)
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
                    multiDexController?.searchTerm = searchTerm!
                    HydrationHelper.instance.setSearchTerm(forTab: tabIndex, searchTerm: searchTerm!)
                    
                    resultsScrollView.isScrollEnabled = true
                    showMultiDex()
                }
            }
            
        }
        
        if searchResults.count > 0 {
            showURLS()
        }
        checkStatusBar()
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
        } else if segue.identifier == "homeScreenSegue" {
            if let childVC = segue.destination as? HomeScreenController {
                //Some property on ChildVC that needs to be set
                childVC.searchDelegate = self
                homeScreenController = childVC
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
        backButton.isEnabled = webViews[currentViewingIndex].canGoBack &&
            multiDexContainerView.isHidden &&
            homeScreenContainerView.isHidden
        backButton.alpha = backButton.isEnabled ? 1 : 0.6
        
        checkOrientation()
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
    
    func shareCurrentContext() {
        if (multiDexContainerView.isHidden && homeScreenContainerView.isHidden) {
            //we're showing a page, share the URL
            if let urlToShare = webViews[currentViewingIndex].url {
                let shareController = UIActivityViewController(activityItems: [urlToShare], applicationActivities: nil)
                present(shareController, animated: true, completion: nil)
            }
        } else if (!multiDexContainerView.isHidden) {
            //showing multidex - maybe share a screenshot?
            if let screenshot = view.takeScrennshot() {
                let shareController = UIActivityViewController(activityItems: ["Check out MultiDex, a cool new way to search in the Super Popular Browser", screenshot], applicationActivities: nil)
                present(shareController, animated: true, completion: nil)
            }
            
        } else {
            //showing home screen, should share the dynamic link url
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
