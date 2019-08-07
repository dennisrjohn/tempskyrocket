//
//  HydrationHelper.swift
//  Morpheus
//
//  Created by Dennis John on 7/8/19.
//  Copyright © 2019 Dennis John. All rights reserved.
//

import Foundation

struct BootstrapData: Codable {
    var activeTab:Int = -1 //the tab list view is index 0, so start on the first actual tab, which is index 1
    var tabs: [TabData]
}

struct TabData: Codable {
    var activeBrowser:Int = 0
    var searchTerm:String = ""
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
    
    var data:BootstrapData?
    
    private init() {
        
    }
    
    func setUrl(forTab tabIndex: Int, forBrowser browser: Int, url: String) {
        var decodedData = getDecodedData()
        decodedData.tabs[tabIndex].browserURLs[browser] = url
        data = decodedData
        save()
    }
    
    func setSearchTerm(forTab tabIndex: Int, searchTerm: String) {
        var decodedData = getDecodedData()
        decodedData.tabs[tabIndex].searchTerm = searchTerm
        data = decodedData
        save()
    }
    
    func addTab() {
        var decodedData = getDecodedData()
        let newTabData = TabData(activeBrowser: 0, searchTerm: "", showing: .homeScreen, browserURLs: Dictionary<Int, String>())
        decodedData.tabs.append(newTabData)
        decodedData.activeTab = decodedData.tabs.count - 1
        data = decodedData
        save()
    }
    
    func deleteTab(atIndex index: Int) {
        var decodedData = getDecodedData()
        let oldTabCount = decodedData.tabs.count
        decodedData.tabs.remove(at: index)
        data = decodedData
        save()
        
        for i in (index + 1)...(oldTabCount) {
            TabScreenshotHelper.instance.moveScreenshot(fromIndex: i, toIndex: i - 1)
        }
        //move the screenshots
    }
    
    func setActiveTab(index:Int) {
        var decodedData = getDecodedData()
        decodedData.activeTab = index
        data = decodedData
        save()
    }
    
    func setActiveBrowser(index:Int, forTab tabIndex:Int) {
        var decodedData = getDecodedData()
        decodedData.tabs[tabIndex].activeBrowser = index
        data = decodedData
        save()
    }
    
    func setShowing(viewState:ViewState, forTab tabIndex:Int) {
        var decodedData = getDecodedData()
        decodedData.tabs[tabIndex].showing = viewState
        data = decodedData
        save()
    }
    
    func getBootstrapTabs()->BootstrapData {
        return getDecodedData()
    }
    
    func getBootstrapData(forTab tabIndex:Int)->TabData {
        var decodedData = getDecodedData()
        if decodedData.tabs.count > tabIndex {
            return decodedData.tabs[tabIndex]
        } else {
            let newTabData = TabData(activeBrowser: 0, searchTerm: "", showing: .homeScreen, browserURLs: Dictionary<Int, String>())
            decodedData.tabs.append(newTabData)
            return newTabData
        }
    }
    
    private func getDecodedData()->BootstrapData {
        if let instanceData = data {
            return instanceData
        }
        if let json  = UserDefaults.standard.object(forKey:  "BootstrapData") as? Data,
            let decodedJSON = try? JSONDecoder().decode(BootstrapData?.self, from: json) {
            data = decodedJSON
            return decodedJSON
        }
        let newTabData = TabData(activeBrowser: 0, searchTerm: "", showing: .homeScreen, browserURLs: Dictionary<Int, String>())
        data = BootstrapData(activeTab: 0, tabs: [newTabData])
        save()
        return data!
    }
    
    private func save() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let encoded = try! encoder.encode(data)
//        let encoded = NSKeyedArchiver.archivedData(withRootObject: data)
        UserDefaults.standard.set(encoded, forKey: "BootstrapData")
    }
    
}
