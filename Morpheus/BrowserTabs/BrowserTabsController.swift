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
    func addTab()
    func removeTab(at index:Int)
}

extension BrowserTabDelegate {
    func switchTab(toIndex: Int) {}
    func showAllTabs() {}
    func addTab() {}
    func removeTab(at index:Int) {}
}

struct TabInfo {
    var index:Int
    var thumbnail:UIImage?
    var title:String?
}

class BrowserTabsController: UIViewController {

    @IBOutlet weak var tabsCollectionView: UICollectionView!
    @IBOutlet weak var addTabButton: UIButton!
    
    var delegate:BrowserTabDelegate?
    var tabs = [TabInfo]() {
        didSet {
            tabsCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTabButton.layer.masksToBounds = true
        addTabButton.layer.cornerRadius = 5.0
        
        let nib = UINib(nibName: "TabImageCell", bundle: nil)
        tabsCollectionView.register(nib, forCellWithReuseIdentifier: "tabCell")
        
        tabsCollectionView.dataSource = self
        tabsCollectionView.delegate = self
        
        tabsCollectionView.reloadData()

    }
    @IBAction func addTab(_ sender: Any) {
        delegate?.addTab()
    }
    
    @IBAction func goToTab(_ sender: Any) {
        delegate?.switchTab(toIndex: 0)
    }
}

extension BrowserTabsController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tabCell", for: indexPath) as! TabImageCell
        
        let tab = tabs[indexPath.row]
        cell.setImage(tab.thumbnail)
        cell.delegate = delegate
        cell.tabIndex = tab.index
        
        return cell
    }
}


extension BrowserTabsController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.switchTab(toIndex: indexPath.row)
    }
}


extension BrowserTabsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let imageWidth = (tabsCollectionView.bounds.width / 2) //4 pixels padding on each side of the cell
        let widthRatio = imageWidth / view.bounds.width
        let imageHeight = (view.bounds.height * widthRatio)
        
        return CGSize(width: imageWidth, height: imageHeight)
    }
}
