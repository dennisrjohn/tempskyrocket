//
//  TabContainerController.swift
//  Morpheus
//
//  Created by Dennis John on 7/20/19.
//  Copyright © 2019 Dennis John. All rights reserved.
//

import UIKit

class TabContainerController: UIViewController {

    var currentControllerIndex = 0
    var tabController:BrowserTabsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabController()
        
        let bootstrapTabs = HydrationHelper.instance.getBootstrapTabs()
        
        for (index, _) in bootstrapTabs.tabs.enumerated() {
            addNewTab(index)
        }
        
        if (currentControllerIndex - 1 != bootstrapTabs.activeTab){
            if (bootstrapTabs.activeTab == -1) {
                showAllTabs()
            } else {
                switchTab(toIndex: bootstrapTabs.activeTab)
            }
        }
        
        if let initialTab = children[currentControllerIndex] as? BrowserContainerController {
            if !initialTab.initted {
                initialTab.initialize()
            }
        }
    }
    
    func setupTabController() {
        tabController = storyboard!.instantiateViewController(withIdentifier: "browserTabs") as? BrowserTabsController
        tabController!.delegate = self
        let frame = view.frame
        add(tabController!, frame: frame)
    }
    
    func addNewTab(_ index:Int?) {
        let newTab = storyboard!.instantiateViewController(withIdentifier: "browserContainerController") as! BrowserContainerController
        newTab.browserTabDelegate = self
        newTab.tabIndex = index ?? children.count - 1
        let frame = view.frame
        add(newTab, frame: frame)
        currentControllerIndex = children.count - 1
    }

}

extension TabContainerController: BrowserTabDelegate {
    func switchTab(toIndex: Int) {
        //the tabs are all indexed, but we need to add 1
        //because the BrowserTabController is index 0 of the children
        let transitionFrom = children[currentControllerIndex]
        let transitionTo = children[toIndex + 1]
        currentControllerIndex = toIndex + 1
        
        if let newController = transitionTo as? BrowserContainerController {
            if !newController.initted {
                newController.initialize()
            }
        }
        
        HydrationHelper.instance.setActiveTab(index: toIndex)
        
        transition(from: transitionFrom, to: transitionTo, duration: 0.0, options: .autoreverse, animations: nil, completion: nil)
        
    }
    
    func showAllTabs() {
        let transitionFrom = children[currentControllerIndex]
        let transitionTo = children[0]
        currentControllerIndex = 0
        
        HydrationHelper.instance.setActiveTab(index: -1)
        
        reloadTabView()
        
        transition(from: transitionFrom, to: transitionTo, duration: 0.0, options: .curveLinear, animations: nil, completion: nil)
    }
    
    func reloadTabView() {
        var tabInfo = [TabInfo]()
        //ignore the first child, it's the tab controller
        for index in 1...children.count - 1 {
            let thumbnail = TabScreenshotHelper.instance.getSavedImage(forTab: index - 1)
            tabInfo.append(TabInfo(index: index, thumbnail: thumbnail, title: nil))
        }
        tabController?.tabs = tabInfo
    }
    
    func addTab() {
        HydrationHelper.instance.addTab()
        addNewTab(nil)
    }
    
    func removeTab(at index: Int) {
        let tabToRemove = children[index]//it's a tab index...
        HydrationHelper.instance.deleteTab(atIndex: index - 1)
        tabToRemove.remove()
        reloadTabView()
    }
}

@nonobjc extension UIViewController {
    func add(_ child: UIViewController, frame: CGRect? = nil) {
        addChild(child)
        
        if let frame = frame {
            child.view.frame = frame
        }
        
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
