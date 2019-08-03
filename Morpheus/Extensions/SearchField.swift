//
//  SearchField.swift
//  Morpheus
//
//  Created by Dennis John on 7/17/19.
//  Copyright © 2019 Dennis John. All rights reserved.
//

import UIKit

class SearchField: UITextField {
    override func awakeFromNib() {
        //Basic texfield Setup
        borderStyle = .none
        backgroundColor = UIColor.white // Use anycolor that give you a 2d look.
        
        //To apply corner radius
        layer.cornerRadius = 20.0
        
        //To apply border
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        
        //To apply Shadow
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 2.0
        layer.shadowOffset = CGSize(width: 0, height: 3) // Use any CGSize
        layer.shadowColor = UIColor.black.cgColor
        
        //To apply padding
        let paddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
    }
}
