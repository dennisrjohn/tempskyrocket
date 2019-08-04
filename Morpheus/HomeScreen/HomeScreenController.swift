//
//  HomeScreenController.swift
//  Morpheus
//
//  Created by Dennis John on 7/13/19.
//  Copyright © 2019 Dennis John. All rights reserved.
//

import UIKit
import WebKit

protocol SearchDelegate {
    func getResults(searchTerm: String?)
}

class HomeScreenController: UIViewController {

    @IBOutlet weak var searchInput: UITextField!
    @IBOutlet weak var homeScreenWebView: WKWebView!
    
    var searchDelegate:SearchDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchInput.delegate = self
        
        homeScreenWebView.load(URLRequest(url: URL(string: "https://www.besuperpopular.com/")!))
    }
    
}

extension HomeScreenController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchDelegate?.getResults(searchTerm: searchInput.text)
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
}

