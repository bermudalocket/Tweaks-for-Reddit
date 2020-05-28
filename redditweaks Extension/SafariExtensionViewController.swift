//
//  SafariExtensionViewController.swift
//  redditweaks2 Extension
//
//  Created by bermudalocket on 10/21/19.
//  Copyright © 2019 bermudalocket. All rights reserved.
//

import Cocoa
import SafariServices
import SnapKit

class SafariExtensionViewController: SFSafariExtensionViewController {

    let model: Model

    init(model: Model) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    lazy var titleView: NSTextField = {
        let view = NSTextField(labelWithString: "redditweaks")
        view.font = .systemFont(ofSize: 32, weight: .heavy)
        return view
    }()

    lazy var versionView: NSTextField = {
        let appVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "???"
        let view = NSTextField(labelWithString: "v\(appVersionString)")
        view.font = .systemFont(ofSize: 14, weight: .regular)
        return view
    }()

    lazy var featuresList: NSStackView = {
        let view = NSStackView()
        view.alignment = .leading
        view.orientation = .vertical
        return view
    }()

    lazy var githubButton: NSButton = {
        let button = NSButton(title: "GitHub", target: self, action: #selector(openGithub))
        button.bezelStyle = .inline
        return button
    }()

    lazy var customSubredditsLabel: NSTextField = {
        let text = NSTextField(labelWithString: "Custom Subreddits")
        text.font = .systemFont(ofSize: 12)
        return text
    }()

    lazy var customSubredditsTextField: NSTextField = {
        let string = UserDefaults.standard.string(forKey: "customSubsArray")?
                                          .replacingOccurrences(of: "'", with: "")
                                          .replacingOccurrences(of: ",", with: ", ")
            ?? "iosprogramming, marilyn_manson"
        let text = NSTextField(string: string)
        text.delegate = self
        return text
    }()

    lazy var shortcutsCheckboxes: NSStackView = {
        let view = NSStackView()
        view.alignment = .leading
        view.orientation = .vertical
        let shortcuts = ["home", "popular", "all", "random", "myrandom", "friends", "mod", "users"]
        let disabled = UserDefaults.standard.array(forKey: "disabledShortcuts") as? [Int] ?? []
        shortcuts.forEach {
            let checkbox = NSButton(checkboxWithTitle: $0, target: self, action: #selector(changeShortcutState(_:)))
            let index = shortcuts.firstIndex(of: $0) ?? -1
            let state = disabled.contains(index as Int)
            checkbox.state = .fromBool(state)
            view.addArrangedSubview(checkbox)
        }
        return view
    }()

    override func loadView() {
        let mainContainer = NSView()

        let container = NSView()
        mainContainer.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview().inset(16)
        }

        container.addSubview(self.titleView)
        self.titleView.snp.makeConstraints { make in
            make.width.top.leading.equalToSuperview()
        }

        container.addSubview(self.versionView)
        self.versionView.snp.makeConstraints { make in
            make.top.equalTo(self.titleView.snp.bottom)
            make.leading.equalTo(self.titleView.snp.leading)
        }

        container.addSubview(self.githubButton)
        self.githubButton.snp.makeConstraints { make in
            make.top.equalTo(self.versionView.snp.bottom).offset(8)
            make.leading.equalToSuperview()
        }

        container.addSubview(self.featuresList)
        self.featuresList.snp.makeConstraints { make in
            make.top.equalTo(self.githubButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }

        container.addSubview(self.customSubredditsLabel)
        self.customSubredditsLabel.snp.makeConstraints { make in
            make.top.equalTo(self.featuresList.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }

        container.addSubview(self.customSubredditsTextField)
        self.customSubredditsTextField.snp.makeConstraints { make in
            make.top.equalTo(self.customSubredditsLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        container.addSubview(self.shortcutsCheckboxes)
        self.shortcutsCheckboxes.snp.makeConstraints { make in
            make.top.equalTo(self.customSubredditsTextField.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }

        mainContainer.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(600)
        }

        self.view = mainContainer
    }

    override func viewDidLoad() {
        self.model.features.sorted {
            $0.key.description < $1.key.description
        }.forEach { (feature, state) in
            let button = NSButton(checkboxWithTitle: feature.description, target: self, action: #selector(changeFeatureState(_:)))
            button.state = .fromBool(state)
            self.featuresList.addArrangedSubview(button)
        }
    }

    @objc func openGithub() {
        NSWorkspace.shared.open(URL(string: "https://www.github.com/bermudalocket/redditweaks")!)
    }

    @objc func changeFeatureState(_ sender: NSButton) {
        if let feature = Feature.fromDescription(sender.title) {
            self.model.changeFeatureState(feature, state: sender.state == .on)
        }
    }

    func changeFeatureState(feature: Feature) {
        self.model.changeFeatureState(feature, state: true)
    }

    @objc func changeShortcutState(_ sender: NSButton) {
        let shortcut = sender.title
        let shortcuts = ["home", "popular", "all", "random", "myrandom", "friends", "mod", "users"]
        let index = shortcuts.firstIndex(of: shortcut)!
        let state = sender.state == .on
        if var disabled = UserDefaults.standard.array(forKey: "disabledShortcuts") as? [Int] {
            if (state) {
                disabled.append(Int(index))
            } else {
                disabled.removeAll { $0 == index }
            }
            UserDefaults.standard.set(disabled, forKey: "disabledShortcuts")
        } else {
            UserDefaults.standard.set([index], forKey: "disabledShortcuts")
        }
        self.changeFeatureState(feature: .customSubredditBar)
    }

}

extension SafariExtensionViewController: NSTextFieldDelegate {

    func controlTextDidChange(_ obj: Notification) {
        guard let text = obj.object as? NSTextField else {
            return
        }
        let subs = text.stringValue
        if subs.count > 0 {
            let subsString = subs.replacingOccurrences(of: " ", with: "")
                .split(separator: ",")
                .compactMap { "'\($0)'" }
                .joined(separator: ",")
            UserDefaults.standard.set(subsString, forKey: "customSubsArray")
        }
    }

}
