//
//  SearchPopupController.swift
//  TacticalNuclearPenguin
//
//  Created by Dennis John on 6/13/18.
//  Copyright © 2018 Dennis John. All rights reserved.
//

import UIKit

protocol SearchDelegate {
    func getResults(searchTerm:String?)
}

class SearchPopupController: UIViewController {

    @IBOutlet weak var searchTermBox: UITextField!
    var delegate:SearchDelegate?
    
    @IBAction func goTapped(_ sender: Any) {
        if searchTermBox.text != nil && searchTermBox.text != "" {
            delegate?.getResults(searchTerm: searchTermBox.text)
        }
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
