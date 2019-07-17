//
//  ProfileSuggestionController.swift
//  
//
//  Created by Dennis John on 7/14/19.
//

import UIKit

protocol SuggestionMetricsDelegate {
    func setHeight(_ height:CGFloat)
}

class ProfileSuggestionController: UIViewController {

    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    var suggestionMetricsDelegate:SuggestionMetricsDelegate?
    //need to calculate the cell height based on the width
    //so the image is square ;)
    let padding:CGFloat = 48.0
    let labelHeight:CGFloat = 18.0
    var cellHeight:CGFloat = 0.0
    var cellWidth:CGFloat = 0.0 {
        didSet {
            cellHeight = cellWidth + padding + labelHeight //24 padding and 18 for the label height
            suggestionMetricsDelegate?.setHeight(cellHeight)
        }
    }
    var suggestedProfiles:[SuggestedProfile] = [
        SuggestedProfile(id: "0", name: "Dennis", profilePhotoURL: "https://pbs.twimg.com/profile_images/646397999262863360/cwg_ezVI_400x400.jpg"),
        SuggestedProfile(id: "0", name: "Dennis", profilePhotoURL: "https://pbs.twimg.com/profile_images/646397999262863360/cwg_ezVI_400x400.jpg"),
        SuggestedProfile(id: "0", name: "Dennis", profilePhotoURL: "https://pbs.twimg.com/profile_images/646397999262863360/cwg_ezVI_400x400.jpg"),
        SuggestedProfile(id: "0", name: "Dennis", profilePhotoURL: "https://pbs.twimg.com/profile_images/646397999262863360/cwg_ezVI_400x400.jpg"),
        SuggestedProfile(id: "0", name: "Dennis", profilePhotoURL: "https://pbs.twimg.com/profile_images/646397999262863360/cwg_ezVI_400x400.jpg"),
        SuggestedProfile(id: "0", name: "Dennis", profilePhotoURL: "https://pbs.twimg.com/profile_images/646397999262863360/cwg_ezVI_400x400.jpg"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileCollectionView.dataSource = self
        profileCollectionView.delegate = self
        profileCollectionView.reloadData()
    }
}

extension ProfileSuggestionController: UICollectionViewDelegate {
    
}

extension ProfileSuggestionController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggestedProfiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileSuggestionCell", for: indexPath) as! ProfileSuggestionCell
        
        cell.imageURL = suggestedProfiles[indexPath.row].profilePhotoURL
        cell.name = suggestedProfiles[indexPath.row].name
        return cell
    }
    
    
}

extension ProfileSuggestionController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
