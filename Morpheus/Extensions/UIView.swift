//
//  UIView.swift
//  Morpheus
//
//  Created by Dennis John on 7/14/19.
//  Copyright © 2019 Dennis John. All rights reserved.
//
import UIKit

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
