//
//  HomeScreenController.swift
//  Morpheus
//
//  Created by Dennis John on 7/13/19.
//  Copyright © 2019 Dennis John. All rights reserved.
//

import UIKit

class HomeScreenController: UIViewController {

    @IBOutlet weak var searchInput: UITextField!
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var profileSuggestionsContainer: UIView!
    @IBOutlet weak var suggestionHeightConstraint: NSLayoutConstraint!
    
    var searchDelegate:SearchDelegate?
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    func setInsets(top:CGFloat, bottom:CGFloat) {
        scrollViewTopConstraint.constant = top
        scrollViewBottomConstraint.constant = bottom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchInput.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "suggestionsSegue" {
            if let childVC = segue.destination as? ProfileSuggestionController {
                let containerInsets:CGFloat = 32.0 * 2.0
                let cellPadding:CGFloat = 38.0
                
                let areaWidth = view.bounds.width - (containerInsets + cellPadding)
                let cellWidth = areaWidth / 3.0
                
                childVC.suggestionMetricsDelegate = self
                childVC.cellWidth = cellWidth
                
            }
        }
    }
}

extension HomeScreenController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchDelegate?.getResults(searchTerm: searchInput.text)
        textField.resignFirstResponder()
        return true
    }
}

extension HomeScreenController: SuggestionMetricsDelegate {
    func setHeight(_ height: CGFloat) {
        suggestionHeightConstraint.constant = height * 2
    }
}
