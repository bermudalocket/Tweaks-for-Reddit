//
//  SafariExtensionViewController.swift
//  redditweaks2 Extension
//
//  Created by bermudalocket on 10/21/19.
//  Copyright © 2019 bermudalocket. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {

    // MARK: singleton
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        _ = shared.view // force outlets to be set
        shared.preferredContentSize = NSSize(width:320, height:240)
        shared.nsfwFilterActive = UserDefaults.standard.bool(forKey: "nsfwFilterActive") // default = false
        shared.nsfwFilterContext = UserDefaults.standard.object(forKey: "nsfwFilterContext") as? FilterContext ?? .global
        return shared
    }()

    // MARK: outlets
    @IBOutlet weak var nsfwCountField: NSTextField!
    @IBOutlet weak var nsfwFilterSwitch: NSSwitch!
    @IBOutlet weak var nsfwFilterContextTabs: NSSegmentedControl!

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
            if self.nsfwCountField != nil {
                self.nsfwCountField.stringValue = String(newValue) + " blocked"
                SFSafariApplication.getActiveWindow { window in
                    window?.getToolbarItem { toolbarItem in
                        toolbarItem?.setBadgeText((newValue > 0 ? String(newValue) : nil))
                    }
                }
            }
        }
    }
    
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
        UserDefaults.standard.set(FilterContext.getId(for: self.nsfwFilterContext), forKey: "nsfwFilterContext")
        self.updateFilter(fromContextUpdate: true)
    }

    @IBAction func toggleNSFW(_ sender: NSSwitch) {
        self.nsfwFilterActive = (sender.state == .on)
        if !self.nsfwFilterActive {
            self.count = 0
        }
        self.updateFilter()
        UserDefaults.standard.set(self.nsfwFilterActive, forKey: "nsfwFilterActive")
    }

    func updateFilter(fromContextUpdate: Bool = false) {
        SFSafariApplication.getActiveWindow { window in
            window?.getActiveTab { tab in
                tab?.getActivePage { page in
                    page?.getPropertiesWithCompletionHandler { props in
                        guard let url = props?.url else {
                            return
                        }
                        if FilterContext.matches(url.absoluteString, context: self.nsfwFilterContext) {
                            page?.dispatchMessageToScript(withName: "filter-nsfw-state", userInfo: ["state": self.nsfwFilterActive])
                        } else {
                            // remove filter from current page if it doesn't match the new context
                            if fromContextUpdate {
                                page?.dispatchMessageToScript(withName: "filter-nsfw-state", userInfo: ["state": false])
                            }
                        }
                    }
                }
            }
        }
    }

}
