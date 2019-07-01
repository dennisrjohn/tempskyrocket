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

class BrowserContainerController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var toolView: UIView!
    
    @IBOutlet weak var tollViewContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var magicButton: UIButton!
    
    var indexBrowser = CacheBrowserController();
    
    var searchResults = [SearchItem]()
    var browserControllers = [CacheBrowserController]()
    var pageTitles = [String: String]()
    
    var searchTerm:String?
    
    var currentViewingIndex = 0;
    var currentLoadingIndex = 0;
    
    var navHidden = false
    var barsHidden:Bool = false
    
//    var navBarController:NavBarControllerBase?
    
    var engines = [(name: "Google", searchURL: "https://www.google.com/search?q=%%searchTerm%%"),
                   (name: "Amazon", searchURL: "https://www.amazon.com/s?k=%%searchTerm%%"),
                   (name: "Bing Image Search", searchURL: "https://www.bing.com/images/search?q=%%searchTerm%%"),
                   (name: "Stack Overflow", searchURL: "https://stackoverflow.com/search?q=%%searchTerm%%"),
                   (name: "Reddit", searchURL: "https://www.reddit.com/search/?q=%%searchTerm%%")]
    var webViews = [CacheBrowserController]()
    
    
    var audioPlayer: AVAudioPlayer?
    
    var longPressTimer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolView.addBorders(edges: [.top], color: UIColor.lightGray)
        try? VideoBackground.shared.play(view: toolView, videoName: "xflame", videoType: "mp4")
        
        tollViewContainerHeightConstraint.constant = 100 + UIApplication.shared.keyWindow!.safeAreaInsets.bottom
//        let topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
//        locationField.delegate = self
//        locationField.barTintColor = UIColor.whiteColor()
//        locationField.layer.borderWidth = 1;
//        locationField.layer.borderColor = UIColor.whiteColor().CGColor;
//        let textFieldInsideSearchBar = locationField.valueForKey("searchField") as? UITextField
//
//        textFieldInsideSearchBar?.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0)
//        locationField.text = searchTerm
        
        scrollView.delegate = self
        
        indexBrowser.view.alpha = 0.0
        view.insertSubview(indexBrowser.view, at: 0)//I'm really not sure why, but this allows the screen to go fullscreen on app start.
        
        for _ in engines {
            let newBrowser = CacheBrowserController()
            newBrowser.visibilityDelegate = self
            newBrowser.delegate = self
            browserControllers.append(newBrowser)
            scrollView.addSubview(newBrowser.view)
            webViews.append(newBrowser)
        }
        scrollView.layoutSubviews()
        
        addGestureRecognizers()
        
        showSearch()
//        loadNavBar()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return barsHidden
    }
    
    
    func addGestureRecognizers() {
//        let leftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(penguinSwiped))
//        leftRecognizer.direction = .left
//        penguinButton.addGestureRecognizer(leftRecognizer)
//        let rightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(penguinSwiped))
//        rightRecognizer.direction = .right
//        penguinButton.addGestureRecognizer(rightRecognizer)
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(penguinTapped))
//        tapRecognizer.numberOfTapsRequired = 1
//        penguinButton.addGestureRecognizer(tapRecognizer)
//        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(penguinDoubleTapped))
//        doubleTapRecognizer.numberOfTapsRequired = 2
//        penguinButton.addGestureRecognizer(doubleTapRecognizer)
//        tapRecognizer.require(toFail: doubleTapRecognizer)
        
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
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x + view.bounds.width, y: 0), animated: true)
        }
    }
    @objc func magicButtonDoubleTapped(recognizer: UITapGestureRecognizer) {
        if (currentViewingIndex > 0) {
            scrollView.setContentOffset(CGPoint(x: max(scrollView.contentOffset.x - view.bounds.width, 0), y: 0), animated: true)
        }
    }
    
//    func loadNavBar() {
//        navBarController = DefaultNavBarController()
//        navBarController?.delegate = self
//        view.addSubview(navBarController!.view)
//        positionNavBar()
//    }
//
//    func positionNavBar() {
//        navBarController?.view.frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.size.height - navBarController!.barHeight, width: UIScreen.mainScreen().bounds.size.width, height: navBarController!.barHeight)
//
//    }
    
    func processSearch() {
        currentLoadingIndex = 0
        currentViewingIndex = 0
        if searchTerm != nil {
            if verifyUrl(urlString: formattedURLString(string: searchTerm!)) {
                pageTitles = [String: String]()
                searchResults = [SearchItem(url: formattedURLString(string: searchTerm!))]
            } else {
                searchResults = []
                pageTitles = [String: String]()
                if let escapedSearchTerm = searchTerm!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    searchResults = [SearchItem]()
                    for engine in engines {
                        let replacedURL = engine.searchURL.replacingOccurrences(of: "%%searchTerm%%", with: escapedSearchTerm)
                        searchResults.append(SearchItem(url: replacedURL))
                    }
                }
                
                //                HtmlParser.getGoogleSearchPage(searchTerm: escapedSearchTerm!, complete: searchComplete)
                //                let searchURL = URL(string: "https://www.google.com/search?client=safari&rls=en&q=pizza&ie=UTF-8&oe=UTF-8")
                //                indexBrowser.url = searchURL
                //                indexBrowser.view.layoutSubviews()
                
                
            }
            
        }
        
        if searchResults.count > 0 {
            showURLS()
        }
    }
    
//    func searchComplete(results:[String]) {
//        for result in results {
//            let newItem = SearchItem(url: result)
//            searchResults.append(newItem)
//        }
//
//        showURLS()
//    }
    
    override func viewWillLayoutSubviews() {
        var offset:CGFloat = 0.0
        
        let screenWidth = UIScreen.main.bounds.size.width
        
        for controller in browserControllers {
            controller.view.frame = CGRect(x: offset, y: 0, width: screenWidth, height: scrollView.frame.size.height)
            offset += screenWidth
        }
        scrollView.contentSize = CGSize(width: CGFloat(browserControllers.count) * screenWidth, height: scrollView.frame.size.height)
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
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        for (index, result) in searchResults.enumerated() {
            result.isLoading = true
            webViews[index].url = URL(string: result.url)
        }
    }
    
    func clearCurrentResults() {
        
    }
    
    
    
    
    func setNavigation() {
//        backButton.enabled = browserControllers[currentViewingIndex].canGoBack
//        forwardButton.enabled = browserControllers[currentViewingIndex].canGoForward
//
//        var toLeading:CGFloat = 0;
//
//        if backButton.enabled {
//            toLeading = 48
//        }
//
//        if forwardButton.enabled {
//            toLeading = 91
//        }
//
//        if toLeading != locationFieldLeading.constant {
//            locationField.layoutIfNeeded()
//            UIView.animateWithDuration(0.2, animations: {
//                //                self.locationFieldLeading.constant = toLeading
//                //                self.locationField.layoutIfNeeded()
//            })
//        }
//
//        let hasNext = currentViewingIndex < browserControllers.count - 1
//        let hasPrevious = currentViewingIndex > 0
//
//        navBarController?.setHasNext(hasNext)
//        navBarController?.setHasPrevious(hasPrevious)
//        navBarController?.setItemCounts(currentViewingIndex + 1, totalItems: browserControllers.count)
//
//        //reset the visibility delegate
        for (index, controller) in browserControllers.enumerated() {
            controller.visibilityDelegate = index == currentViewingIndex ? self : nil
        }
//
//        showPageTitle()
    }
    
    @IBAction func goForward(sender: AnyObject) {
        browserControllers[currentViewingIndex].goForward()
    }
    
    @IBAction func goBack(sender: AnyObject) {
        browserControllers[currentViewingIndex].goBack()
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
        currentViewingIndex = Int(scrollView.contentOffset.x / UIScreen.main.bounds.width)
        
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

//extension BrowserContainerController: NavBarDelegate {
//    func goPreviousResult() {
//        let screenWidth = UIScreen.mainScreen().bounds.size.width
//        let xOffset = scrollView.contentOffset.x
//        scrollView.setContentOffset(CGPoint(x: xOffset - screenWidth, y: 0.0), animated: true)
//    }
//
//    func goNextResult() {
//        let screenWidth = UIScreen.mainScreen().bounds.size.width
//        let xOffset = scrollView.contentOffset.x
//        scrollView.setContentOffset(CGPoint(x: xOffset + screenWidth, y: 0.0), animated: true)
//    }
//
//    func showMenu(menu:UIViewController) {
//        menu.view.frame = view.frame
//        view.addSubview(menu.view)
//    }
//}
