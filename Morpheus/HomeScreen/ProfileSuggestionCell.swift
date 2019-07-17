//
//  ProfileSuggestionCell.swift
//  Morpheus
//
//  Created by Dennis John on 7/17/19.
//  Copyright © 2019 Dennis John. All rights reserved.
//

import UIKit
import Nuke

class ProfileSuggestionCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var imageURL:String? {
        didSet {
            if let i = imageURL, let url = URL(string: i) {
                Nuke.loadImage(with: url, into: imageView)
            }
        }
    }
    
    var name:String = "" {
        didSet {
            nameLabel.text = name
        }
    }
    
    override func awakeFromNib() {
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.layer.borderWidth = 4
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor(red: 229.0/255.0, green: 234.0/255.0, blue: 50.0/255.0, alpha: 1.0).cgColor
        imageView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        imageView.layer.cornerRadius = (contentView.frame.width - 16.0)/2
    }

}