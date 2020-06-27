//
//  Model.swift
//  redditweaks Extension
//
//  Created by Michael Rippe on 5/2/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Cocoa
import Combine
import Foundation
import SafariServices
import SwiftUI
import WebKit

struct FeatureToggleView: View {

    let feature: Feature

    let stateChangePublisher: CurrentValueSubject<Bool, Never>

    @State private var enabled = false {
        didSet(newValue) {
            self.stateChangePublisher.send(newValue)
        }
    }

    init(feature: Feature) {
        let userDefaultsState = UserDefaults.standard.bool(forKey: feature.name)
        self.feature = feature
        self.stateChangePublisher = CurrentValueSubject<Bool, Never>(userDefaultsState)
        self.enabled = userDefaultsState
    }

    var body: some View {
        Toggle(self.feature.description, isOn: self.$enabled)
    }

}

struct PopoverView: View {

    @State private var code: String = ""

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }

    private var tweaksFont: Font {
        if #available(macOS 11, *) {
            return .system(.title2, design: .rounded)
        } else if #available(macOS 10.16, *) {
            return .system(.title2, design: .rounded)
        } else {
            return .system(.title, design: .rounded)
        }
    }

    private var title: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("redditweaks")
                    .font(.largeTitle).fontWeight(.heavy)
                Spacer()
            }
            Text("v\(self.version)")
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
        .padding(.top, 4)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundColor(Color(.controlBackgroundColor))
        )
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                self.title
                VStack(alignment: .leading) {
                    Text(self.code == "" ? "Tweaks" : self.code)
                        .font(tweaksFont)
                    ForEach(Feature.sortedFeatures, id: \.self) { feature in
                        FeatureToggleView(feature: feature)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .foregroundColor(Color(.controlBackgroundColor))
                )
                Spacer()
            }
            .padding()
        }
        .frame(width: 300, height: 500)
    }
}

class PopoverViewWrapper: SFSafariExtensionViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
        self.view = NSHostingView(rootView: PopoverView())
        self.preferredContentSize = NSSize(width: 500, height: 800)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class SafariExtensionHandler: SFSafariExtensionHandler {

    static let shared = SafariExtensionHandler()

    let model = Model()

    lazy var viewController = PopoverViewWrapper()

    override func popoverViewController() -> SFSafariExtensionViewController {
        self.viewController
    }

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String: Any]?) {
        if messageName == "redditweaks.onDomLoaded" {
            self.model.features
                .filter { $0.value }
                .map { $0.key }
                .forEach(self.sendScriptToSafariPage(_:))
        }
    }

    internal func sendScriptToSafariPage(_ feature: Feature) {
        SFSafariApplication.getActiveWindow { window in
            guard let window = window else {
                NSLog("Couldn't send script to page b/c getActiveWindow was nil")
                return
            }
            window.getActiveTab { tab in
                guard let tab = tab else {
                    NSLog("Couldn't send script to page b/c getActiveTab was nil")
                    return
                }
                tab.getActivePage { page in
                    guard let page = page else {
                        NSLog("Couldn't send script to page b/c getActivePage was nil")
                        return
                    }
                    guard var script = self.model.features[feature]! ? feature.javascript : feature.javascriptOff else {
                        NSLog("Couldn't send script to page b/c the script itself was nil")
                        return
                    }
                    if feature.name == "customSubredditBar",
                            let subs = UserDefaults.standard.string(forKey: "customSubsArray"),
                            let disabled = UserDefaults.standard.array(forKey: "disabledShortcuts") {
                        let disabledShortcuts = disabled.compactMap { "\($0 as? Int ?? -1)" }.joined(separator: ",")
                        script = script.replacingOccurrences(of: "%SUBS%", with: subs)
                        script = script.replacingOccurrences(of: "%DISABLEDSHORTCUTS%", with: disabledShortcuts)
                    }
                    page.dispatchMessageToScript(withName: "redditweaks.script", userInfo: [
                        "script": script
                    ])
                }
            }
        }
    }

}

struct SafariExtensionHandler_Previews: PreviewProvider {
    static var previews: some View {
        PopoverView()
    }
}
