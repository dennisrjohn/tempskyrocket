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
    func removeTab()
}

extension BrowserTabDelegate {
    func switchTab(toIndex: Int) {}
    func showAllTabs() {}
    func addTab() {}
    func removeTab() {}
}

struct TabInfo {
    var index:Int
    var thumbnail:String?
    var title:String?
}

class BrowserTabsController: UIViewController {

    var delegate:BrowserTabDelegate?
    var tabs = [TabInfo]() {
        didSet {
            tabsCollectionView.reloadData()
        }
    }
    @IBOutlet weak var tabsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! TabImageCell
        
        let tab = tabs[indexPath.row]
        cell.titleLabel.text = String(tab.index)
        
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
        let imageHeight = (view.bounds.height * widthRatio) * 0.6
        
        return CGSize(width: imageWidth - 8, height: imageHeight)
    }
}

class TabImageCell:UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    var currentImage:(date:Date, image:UIImage)?
    
    func setImageIfNecessary(_ image: (date:Date, image:UIImage?)) {
        if (currentImage == nil || currentImage!.date < image.date) && image.image != nil {
            self.image.image = image.image
        }
    }
}
