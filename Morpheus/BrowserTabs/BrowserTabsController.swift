//
//  BrowserTabsController.swift
//  Morpheus
//
//  Created by Dennis John on 7/20/19.
//  Copyright © 2019 Dennis John. All rights reserved.
//

import UIKit

protocol BrowserTabDelegate {
    func switchTab(toIndex: Int)
    func showAllTabs()
}

extension BrowserTabDelegate {
    func switchTab(toIndex: Int) {}
    func showAllTabs() {}
}

class BrowserTabsController: UIViewController {

    var delegate:BrowserTabDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func goToTab(_ sender: Any) {
        delegate?.switchTab(toIndex: 0)
    }
}
