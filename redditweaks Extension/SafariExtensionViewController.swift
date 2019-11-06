//
//  SafariExtensionViewController.swift
//  redditweaks2 Extension
//
//  Created by bermudalocket on 10/21/19.
//  Copyright © 2019 bermudalocket. All rights reserved.
//

import Cocoa
import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    // MARK: singleton
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        _ = shared.view // force outlets to be set
        shared.preferredContentSize = NSSize(width:320, height:240)
        shared.nsfwFilterActive = UserDefaults.standard.bool(forKey: "nsfwFilterActive") // default = false
        shared.nsfwFilterContext = UserDefaults.standard.object(forKey: "nsfwFilterContext") as? FilterContext ?? .global
        shared.hideRedditPremiumAd.state = (UserDefaults.standard.bool(forKey: "hideRedditPremiumAd") ? .on : .off)
        shared.hideNewRedditButton.state = (UserDefaults.standard.bool(forKey: "hideNewRedditButton") ? .on : .off)
        return shared
    }()

    // MARK: outlets
    @IBOutlet weak var nsfwFilterContextTabs: NSSegmentedControl!
    @IBOutlet weak var nsfwFilterSwitch: NSButton!
    @IBOutlet weak var hideNewRedditButton: NSButton!
    @IBOutlet weak var hideRedditPremiumAd: NSButton!
    
    // MARK: properties
    var nsfwFilterActive = false {
        willSet {
            self.nsfwFilterSwitch.state = (newValue ? .on : .off)
        }
    }
    var nsfwFilterContext: FilterContext = .global {
        willSet {
            self.nsfwFilterContextTabs.selectSegment(withTag: FilterContext.getId(for: newValue))
        }
    }
    var count: Int = 0 {
        willSet {
            self.nsfwFilterSwitch.title = "\(newValue) hidden"
            SFSafariApplication.getActiveWindow { window in
                window?.getToolbarItem { toolbarItem in
                    toolbarItem?.setBadgeText((newValue > 0 ? String(newValue) : nil))
                }
            }
        }
    }
    
    // MARK: actions
    @IBAction func changeFilterContext(_ sender: NSSegmentedControl) {
        let index = sender.selectedSegment
        guard let label = sender.label(forSegment: index) else {
            return
        }
        if label == "Global" {
            self.nsfwFilterContext = .global
        } else if label == "r/All" {
            self.nsfwFilterContext = .rAll
        } else if label == "Subs" {
            self.nsfwFilterContext = .subs
        }
        self.updateFilter(fromContextUpdate: true)
    }
    
    @IBAction func toggleNewRedditButton(_ sender: NSButton) {
        self.updateFilter()
    }
    
    @IBAction func togglePremiumAd(_ sender: NSButton) {
        self.updateFilter()
    }
    
    @IBAction func toggleNSFW(_ sender: NSButton) {
        self.nsfwFilterActive = (sender.state == .on)
        if !self.nsfwFilterActive {
            self.count = 0
        }
        self.updateFilter()
    }

    private func saveState() {
        UserDefaults.standard.set(self.nsfwFilterActive, forKey: "nsfwFilterActive")
        UserDefaults.standard.set(FilterContext.getId(for: self.nsfwFilterContext), forKey: "nsfwFilterContext")
        UserDefaults.standard.set(self.hideNewRedditButton.state == .on, forKey: "hideNewRedditButton")
        UserDefaults.standard.set(self.hideRedditPremiumAd.state == .on, forKey: "hideRedditPremiumAd")
    }

    // MARK: functions
    func updateFilter(fromContextUpdate: Bool = false) {
        self.saveState()
        self.count = 0
        SFSafariApplication.getActiveWindow { window in
            window?.getActiveTab { tab in
                tab?.getActivePage { page in
                    page?.getPropertiesWithCompletionHandler { props in
                        guard let page = page, let url = props?.url else {
                            return
                        }
                        page.dispatchMessageToScript(withName: "redditweaks.state",
                            userInfo: [
                                "nsfw": self.nsfwFilterSwitch.state == .on && FilterContext.matches(url.absoluteString, context: self.nsfwFilterContext),
                                "hideNewRedditButton": self.hideNewRedditButton.state == .on,
                                "hideRedditPremiumAd": self.hideRedditPremiumAd.state == .on
                            ]
                        )
                    }
                }
            }
        }
    }

}
