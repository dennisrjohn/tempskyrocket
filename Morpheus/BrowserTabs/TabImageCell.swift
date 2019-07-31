//
//  TabImageCell.swift
//  Morpheus
//
//  Created by Dennis John on 7/24/19.
//  Copyright © 2019 Dennis John. All rights reserved.
//

import UIKit

class TabImageCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    var delegate:BrowserTabDelegate?
    var tabIndex:Int = 0
    
    var currentImage:(date:Date, image:UIImage)?
    
    func setImage(_ image: UIImage?) {
        self.image.image = image
    }
    
    @IBAction func closeTab(_ sender: Any) {
        delegate?.removeTab(at: tabIndex)
    }
    
    override func awakeFromNib() {
        print(contentView.bounds)
    }
}
