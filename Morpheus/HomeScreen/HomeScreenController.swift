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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HomeScreenController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchDelegate?.getResults(searchTerm: searchInput.text)
        return true
    }
}
