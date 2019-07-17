//
//  SuggestedProfile.swift
//  Morpheus
//
//  Created by Dennis John on 7/16/19.
//  Copyright © 2019 Dennis John. All rights reserved.
//

import Foundation

class SuggestedProfile {
    var id:String!
    var name:String!
    var profilePhotoURL:String?
    var socialUsername:String?
    var socialURL:String?
    var socialDescription:String?
    
    init(id: String, name:String, profilePhotoURL:String, socialUsername:String? = nil, socialURL:String? = nil, socialDescription:String? = nil) {
        self.id = id
        self.name = name
        self.profilePhotoURL = profilePhotoURL
        self.socialUsername = socialUsername
        self.socialURL = socialURL
        self.socialDescription = socialDescription
    }
}
