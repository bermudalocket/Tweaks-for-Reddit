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

    // MARK: - singleton

    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        _ = shared.view
        return shared
    }()

    // MARK: - static fields

    static let extensionVersion = "1.2"

    // MARK: - instance fields

    var numberOfFilteredPosts: Int = 0 {
        didSet {
            SFSafariApplication.setToolbarItemsNeedUpdate()
        }
    }

    // MARK: - outlets

    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var toggleableFeaturesStackView: NSStackView!

    // MARK: - actions
    @IBAction func openRepoInBrowser(_ sender: NSButton) {
        guard let repoUrl = URL(string: "https://www.github.com/bermudalocket/redditweaks") else {
            return
        }
        NSWorkspace.shared.open(repoUrl)
    }

    // MARK: - functions

    override func viewDidLoad() {
        self.versionLabel.stringValue = "v\(SafariExtensionViewController.extensionVersion)"
        Feature.features.forEach { feature in
            let button = NSButton(checkboxWithTitle: feature.description, target: self, action: #selector(featureDidChangeState(_:)))
            button.state = .fromBool(UserDefaults.standard.bool(forKey: feature.name))
            self.toggleableFeaturesStackView.addArrangedSubview(button)
        }
    }

    @objc func featureDidChangeState(_ sender: NSButton) {
        guard let feature = Feature.fromDescription(sender.title) else {
            return
        }
        NSLog("featureDidChangeState: \(feature.name) -> \(sender.state.rawValue)")
        UserDefaults.standard.set(sender.state == .on, forKey: feature.name)
        guard let script = sender.state == .on ? feature.javascript : feature.javascriptOff else {
            return
        }
        SafariExtensionHandler.sendScriptToSafariPage(script)
    }

    func pageLoaded(_ url: URL) {
        Feature.features.forEach { feature in
            NSLog("feature: \(feature.name)")
            let state = UserDefaults.standard.bool(forKey: feature.name)
            if state {
                NSLog("sending")
                SafariExtensionHandler.sendScriptToSafariPage(feature.javascript)
            }
        }
    }

    private func saveState() {
        for subview in self.toggleableFeaturesStackView.subviews {
            guard let subview = subview as? NSButton, let feature = Feature.fromDescription(subview.title) else {
                return
            }
            UserDefaults.standard.set(subview.state == .on, forKey: feature.name)
        }
    }

}
