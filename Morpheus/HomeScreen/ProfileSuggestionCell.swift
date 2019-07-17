//
//  ProfileSuggestionCell.swift
//  Morpheus
//
//  Created by Dennis John on 7/16/19.
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
//        imageView.layer.borderWidth = 1
//        imageView.layer.masksToBounds = false
//        imageView.layer.borderColor = UIColor.black.cgColor
//        imageView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
//        imageView.layer.cornerRadius = imageView.frame.height/2
    }
}
