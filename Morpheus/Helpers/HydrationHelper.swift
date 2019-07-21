//
//  HydrationHelper.swift
//  Morpheus
//
//  Created by Dennis John on 7/8/19.
//  Copyright © 2019 Dennis John. All rights reserved.
//

import Foundation

struct BootstrapData: Codable {
    var activeTab:Int = 0 //the tab list view is index 0, so start on the first actual tab, which is index 1
    var tabs: [TabData]
}

struct TabData: Codable {
    var activeBrowser:Int = 0
    var showing:ViewState = .homeScreen
    var browserURLs = Dictionary<Int, String>()
}

enum ViewState:Int, Codable {
    case homeScreen
    case multiDex
    case browser
}

class HydrationHelper {
    
    static var instance = HydrationHelper()
    
    private init() {
        
    }
    
    func setUrl(forTab tabIndex: Int, forBrowser browser: Int, url: String) {
        var decodedData = getDecodedData()
        decodedData.tabs[tabIndex].browserURLs[browser] = url
        save(data: decodedData)
    }
    
    func addTab() {
        var decodedData = getDecodedData()
        let newTabData = TabData(activeBrowser: 0, showing: .homeScreen, browserURLs: Dictionary<Int, String>())
        decodedData.tabs.append(newTabData)
        decodedData.activeTab = decodedData.tabs.count - 1
        save(data: decodedData)
    }
    
    func setActiveTab(index:Int) {
        var decodedData = getDecodedData()
        decodedData.activeTab = index
        save(data: decodedData)
    }
    
    func setActiveBrowser(index:Int, forTab tabIndex:Int) {
        var decodedData = getDecodedData()
        decodedData.tabs[tabIndex].activeBrowser = index
        save(data: decodedData)
    }
    
    func setShowing(viewState:ViewState, forTab tabIndex:Int) {
        var decodedData = getDecodedData()
        decodedData.tabs[tabIndex].showing = viewState
        save(data: decodedData)
    }
    
    func getBootstrapTabs()->BootstrapData {
        return getDecodedData()
    }
    
    func getBootstrapData(forTab tabIndex:Int)->TabData {
        var decodedData = getDecodedData()
        if decodedData.tabs.count > tabIndex {
            return decodedData.tabs[tabIndex]
        } else {
            let newTabData = TabData(activeBrowser: 0, showing: .homeScreen, browserURLs: Dictionary<Int, String>())
            decodedData.tabs.append(newTabData)
            save(data: decodedData)
            return newTabData
        }
    }
    
    private func getDecodedData()->BootstrapData {
        if let json  = UserDefaults.standard.object(forKey:  "BootstrapData") as? Data,
            let decodedJSON = try? JSONDecoder().decode(BootstrapData?.self, from: json) {
            return decodedJSON
        }
        let newTabData = TabData(activeBrowser: 0, showing: .homeScreen, browserURLs: Dictionary<Int, String>())
        let initialData = BootstrapData(activeTab: 0, tabs: [newTabData])
        save(data: initialData)
        return initialData
    }
    
    private func save(data:BootstrapData) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let encoded = try! encoder.encode(data)
//        let encoded = NSKeyedArchiver.archivedData(withRootObject: data)
        UserDefaults.standard.set(encoded, forKey: "BootstrapData")
    }
    
}
