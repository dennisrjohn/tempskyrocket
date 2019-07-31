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
    @IBOutlet weak var titleLabel: UILabel!
    
    var delegate:BrowserTabDelegate?
    var tabs = [TabInfo]() {
        didSet {
            titleLabel.text = tabs.count > 0 ? "Tabs - \(tabs.count)" : "Tabs"
            tabsCollectionView.reloadData()
        }
    }
    
//    let kFirstItemTransform: CGFloat = 0.05
    
    
    var tabImageSize:CGSize {
        get {
            let safeAreaInsets = UIApplication.shared.keyWindow!.safeAreaInsets
            let imageWidth = tabsCollectionView.bounds.width
            let widthRatio = imageWidth / view.bounds.width
            let safeAreaAdjustments =  (safeAreaInsets.top + safeAreaInsets.bottom)
            let imageHeight = ((view.bounds.height - safeAreaAdjustments) * widthRatio)
            return CGSize(width: imageWidth, height: imageHeight)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTabButton.layer.masksToBounds = true
        addTabButton.layer.cornerRadius = 5.0
        
        let nib = UINib(nibName: "TabImageCell", bundle: nil)
        tabsCollectionView.register(nib, forCellWithReuseIdentifier: "tabCell")
        
//        let stickyLayout = tabsCollectionView.collectionViewLayout as! StickyCollectionViewFlowLayout
//        stickyLayout.firstItemTransform = kFirstItemTransform
        
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
        return tabImageSize;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: NSInteger) -> CGFloat {
        return (tabImageSize.height * 0.6) * -1
    }
}
