//
//  HydrationHelper.swift
//  Morpheus
//
//  Created by Dennis John on 7/8/19.
//  Copyright © 2019 Dennis John. All rights reserved.
//

import Foundation

struct BootstrapData {
    var showing:ViewState
    var activeTab:Int
    var activeBrowser:Int
    var tabs: Dictionary<Int, Dictionary<Int, String>>
}

enum ViewState:Int {
    case homeScreen
    case multiDex
    case browser
}

class HydrationHelper {
    
    static var instance = HydrationHelper()
    
    private init() {
        
    }
    
    func setUrl(forTab tab: Int, forBrowser browser: Int, url: String) {
        let decoded  = UserDefaults.standard.object(forKey: "UserTabs") as? Data
        var currentTabs = decoded != nil ? NSKeyedUnarchiver.unarchiveObject(with: decoded!) as? Dictionary<Int, Dictionary<Int, String>> : nil
        
        if currentTabs == nil {
            currentTabs = Dictionary<Int, Dictionary<Int, String>>()
        }
        if currentTabs![tab] == nil {
            currentTabs![tab] = Dictionary<Int, String>()
        }
        currentTabs![tab]![browser] = url
        let encoded = NSKeyedArchiver.archivedData(withRootObject: currentTabs!)
        UserDefaults.standard.set(encoded, forKey: "UserTabs")
    }
    
    func setActiveTab(index:Int) {
        UserDefaults.standard.set(index, forKey: "ActiveTab")
    }
    
    func setActiveBrowser(index:Int) {
        UserDefaults.standard.set(index, forKey: "ActiveBrowser")
    }
    
    func setShowing(viewState:ViewState) {
        UserDefaults.standard.set(viewState.rawValue, forKey: "ViewState")
    }
    
    func getBootstrapData()->BootstrapData {
        if let decoded  = UserDefaults.standard.object(forKey: "UserTabs") as? Data,
        let decodedTabs = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? Dictionary<Int, Dictionary<Int, String>> {
            let viewState = ViewState(rawValue: UserDefaults.standard.integer(forKey: "ViewState")) ?? ViewState.homeScreen
            let activeTab = UserDefaults.standard.integer(forKey: "ActiveTab")
            let activeBrowser = UserDefaults.standard.integer(forKey: "ActiveBrowser")
        
            return BootstrapData(showing: viewState, activeTab: activeTab, activeBrowser: activeBrowser, tabs: decodedTabs)
        } else {
            return BootstrapData(showing: .homeScreen, activeTab: 0, activeBrowser: 0, tabs: Dictionary<Int, Dictionary<Int, String>>())
        }
    }
    
}
