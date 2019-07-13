//
//  MultiDexController.swift
//  Morpheus
//
//  Created by Dennis John on 7/1/19.
//  Copyright © 2019 Dennis John. All rights reserved.
//

import UIKit

class MultiDexController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    var engineDelegate:EngineDelegate?
    
    var engines:[(name:String, searchURL:String)] = [] {
        didSet {
            if imageCollectionView != nil {
                imageCollectionView.reloadData()
            }
            view.isHidden = engines.count == 0
        }
    }
    
    var screenShots:[Int:(date:Date, image:UIImage?)] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        if engines.count > 0 {
            imageCollectionView.reloadData()
        }
    }
    
    
    func replaceImageAtIndex(index:Int, image:(date:Date, image:UIImage?)) {
        if (image.image != nil){
            screenShots[index] = image
            UIView.performWithoutAnimation {
                imageCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return engines.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        
        let engine = engines[indexPath.row]
        cell.titleLabel.text = engine.name
        if (screenShots.keys.contains(indexPath.row)) {
            cell.setImageIfNecessary(screenShots[indexPath.row]!)
        } else {
            cell.image.image = nil
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let imageWidth = (imageCollectionView.bounds.width / 2) //4 pixels padding on each side of the cell
        let widthRatio = imageWidth / view.bounds.width
        let imageHeight = view.bounds.height * widthRatio
        
        return CGSize(width: imageWidth - 8, height: imageHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        engineDelegate?.fullscreenEngine(at: indexPath.row, screenshotBounds: CGRect.zero, screenshotImage: screenShots[indexPath.row]?.image)
    }
}

class ImageCell:UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    var currentImage:(date:Date, image:UIImage)?
    
    func setImageIfNecessary(_ image: (date:Date, image:UIImage?)) {
        if (currentImage == nil || currentImage!.date < image.date) && image.image != nil {
            self.image.image = image.image
        }
    }
}

class CellView:UIView {
    
    override func draw(_ rect: CGRect) {
        let radius:CGFloat = 10.0
        
        // add the shadow to the base view
        layer.cornerRadius = radius
        layer.masksToBounds = true
        backgroundColor = UIColor.clear
        superview?.layer.shadowColor = UIColor.black.cgColor
        superview?.layer.shadowOffset = CGSize(width: 9, height: 10)
        superview?.layer.shadowOpacity = 0.5
        superview?.layer.shadowRadius = 2.0
        superview?.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
        superview?.layer.shouldRasterize = true
        superview?.layer.rasterizationScale = UIScreen.main.scale
        
        // add the border to subview
        let borderView = UIView()
        borderView.frame = bounds
        borderView.layer.cornerRadius = radius
        borderView.layer.borderColor = UIColor.gray.cgColor
        borderView.layer.borderWidth = 1.0
        borderView.layer.masksToBounds = true
        addSubview(borderView)
        
        // add any other subcontent that you want clipped
        let otherSubContent = UIImageView()
        otherSubContent.image = UIImage(named: "lion")
        otherSubContent.frame = borderView.bounds
        borderView.addSubview(otherSubContent)
    }
}
