//
//  TabScreenshotHelper.swift
//  Morpheus
//
//  Created by Dennis John on 7/24/19.
//  Copyright © 2019 Dennis John. All rights reserved.
//

import Foundation
import UIKit

class TabScreenshotHelper {
    static var instance = TabScreenshotHelper()
    
    private init() {
        
    }
    
    func saveImage(image: UIImage, forTab tab:Int) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("tab\(tab).png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func getSavedImage(forTab tab: Int) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("tab\(tab).png").path)
        }
        return nil
    }
}
