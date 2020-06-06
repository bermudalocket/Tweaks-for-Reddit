//
//  ViewController.swift
//  redditweaks2
//
//  Created by bermudalocket on 10/21/19.
//  Copyright © 2019 bermudalocket. All rights reserved.
//

import Cocoa
import SafariServices.SFSafariApplication

import AVFoundation

class ViewController: NSViewController {

    static let shared: ViewController = {
        ViewController()
    }()

    @IBOutlet var appNameLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.appNameLabel.stringValue = "redditweaks"
    }

    @IBAction func openSafariExtensionPreferences(_ sender: AnyObject?) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.bermudalocket.redditweaks-Extension") {
            if let error = $0 {
                // Insert code to inform the user that something went wrong.
                NSLog("error: \(error.localizedDescription)")
            }
        }
    }

}
