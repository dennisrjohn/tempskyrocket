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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addTabController()
        startDefault()
    }
    
    func addTabController() {
        let tabController = storyboard!.instantiateViewController(withIdentifier: "browserTabs") as! BrowserTabsController
        tabController.delegate = self
        let frame = view.frame
        add(tabController, frame: frame)
    }
    
    func startDefault() {
        let defaultTab = storyboard!.instantiateViewController(withIdentifier: "browserContainerController") as! BrowserContainerController
        defaultTab.browserTabDelegate = self
        let frame = view.frame
        add(defaultTab, frame: frame)
        currentControllerIndex = 1
    }

}

extension TabContainerController: BrowserTabDelegate {
    func switchTab(toIndex: Int) {
        //the tabs are all indexed, but we need to add 1
        //because the BrowserTabController is index 0 of the children
        let transitionFrom = children[currentControllerIndex]
        let transitionTo = children[toIndex + 1]
        currentControllerIndex = toIndex + 1
        
        transition(from: transitionFrom, to: transitionTo, duration: 0.0, options: .autoreverse, animations: nil, completion: nil)
        
    }
    
    func showAllTabs() {
        let transitionFrom = children[currentControllerIndex]
        let transitionTo = children[0]
        currentControllerIndex = 0
        
        transition(from: transitionFrom, to: transitionTo, duration: 0.0, options: .autoreverse, animations: nil, completion: nil)
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
