//
//  ProfileHeaderController.swift
//  Morpheus
//
//  Created by Dennis John on 7/17/19.
//  Copyright © 2019 Dennis John. All rights reserved.
//

import UIKit
import Nuke

class ProfileHeaderController: UIViewController {
    @IBOutlet weak var statsView: UIView!
    @IBOutlet weak var profileImageOuterBorder: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statsView.layer.masksToBounds = false
        statsView.clipsToBounds = true
        profileImageOuterBorder.layer.masksToBounds = false
        profileImageOuterBorder.clipsToBounds = true
        profileImageView.layer.masksToBounds = false
        profileImageView.clipsToBounds = true
        
        profileImageView.layer.borderWidth = 4
        profileImageView.layer.borderColor = UIColor.white.cgColor
        
        if let url = URL(string: "https://pbs.twimg.com/profile_images/646397999262863360/cwg_ezVI_400x400.jpg"){
            Nuke.loadImage(with: url, into: profileImageView)
        }
    }
    
    override func viewWillLayoutSubviews() {
        statsView.layer.cornerRadius = statsView.frame.height/2
        profileImageOuterBorder.layer.cornerRadius = view.frame.height/2
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
    }

}
