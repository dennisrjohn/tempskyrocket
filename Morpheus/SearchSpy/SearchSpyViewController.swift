//
//  SearchSpyViewController.swift
//  XBrowser
//
//  Created by Dennis John on 6/1/19.
//  Copyright © 2019 Lips Labs. All rights reserved.
//

import UIKit
import AVKit
import Lottie

protocol SpyDelegate {
    func stealURL(url:String)
}

class SearchSpyViewController: UIViewController, SpyDelegate {

    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var backgroundAnimationView: AnimationView!
    
    var delegate: SpyDelegate?
    
    var audioPlayer: AVAudioPlayer?
    
    var addItemTimer: Timer?
    
    var currentSearchIndex = 0
    
    let searches = ["Jose Antonio Reyes", "Swamp Thing", "Champions League final", "When They See Us", "Robert Pattinson", "Spelling Bee", "Red Sox vs Yankees", "Jennifer Aniston", "Kenny Rogers", "Wiz Khalifa", "Call of Duty: Modern Warfare", "Good Omens", "Bad Lip Reading", "Tiger Woods", "John Witherspoon", "Death Stranding", "Alex Trebek"]
    
    var searchesForDisplay = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let animation = Animation.named("Animation5", bundle: Bundle.main)
        backgroundAnimationView.animation = animation
        backgroundAnimationView.loopMode = .loop
        backgroundAnimationView.contentMode = .scaleAspectFit
        backgroundAnimationView.play()
        
        do {
            if let fileURL = Bundle.main.path(forResource: "voices", ofType: "mp3") {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
                audioPlayer?.setVolume(0.0, fadeDuration: 0.0)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.play()
                audioPlayer?.setVolume(0.4, fadeDuration: 5.0)
            } else {
                print("No file with specified name exists")
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }
        
        searchesForDisplay = [searches[currentSearchIndex]]
        currentSearchIndex = 1
        
        addItemTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] (timer) in
            if let s = self {
                if (s.currentSearchIndex < s.searches.count){
                    s.searchesForDisplay.insert(s.searches[s.currentSearchIndex], at: 0)
                    s.currentSearchIndex += 1
                    s.resultsTableView.reloadData()
                } else {
                    s.addItemTimer?.invalidate()
                }
            }
        }
        
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        resultsTableView.reloadData()
    }
    
    func cleanup() {
        addItemTimer?.invalidate()
        audioPlayer?.stop()
        backgroundAnimationView.stop()
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: cleanup)
    }
    
    func stealURL(url: String) {
        delegate?.stealURL(url: url)
        dismiss(animated: true, completion: cleanup)
    }

}

extension SearchSpyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "spyCell") as! SearchSpyCell
        cell.delegate = self
        if (indexPath.row == 0) {
            cell.searchLabel.text = ""
            cell.searchLabel.typeOn(string: searchesForDisplay[indexPath.row])
        } else {
            cell.searchLabel.text = searchesForDisplay[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchesForDisplay.count
    }
}


extension UILabel {
    func typeOn(string: String) {
        let characterArray = Array(string)
        var characterIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { (timer) in
            self.text?.append(characterArray[characterIndex])
            characterIndex += 1
            if characterIndex == characterArray.count {
                timer.invalidate()
            }
        }
    }
}

class SearchSpyCell: UITableViewCell {
    @IBOutlet weak var searchLabel:UILabel!
    
    var delegate:SpyDelegate?
    
    @IBAction func sealTapped(sender: UIButton) {
        if let stealURL = searchLabel.text {
            delegate?.stealURL(url: stealURL)
        }
    }
}
