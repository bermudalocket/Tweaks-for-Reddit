//
//  MainAppStore.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/21/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import AppKit.NSWorkspace
import Foundation
import StoreKit
import Composable_Architecture
import Tweaks_for_Reddit_Core
import Tweaks_for_Reddit_Popover
import UserNotifications

typealias MainAppStore = Store<MainAppState, MainAppAction, TFREnvironment>

extension MainAppStore {
    static let live = MainAppStore(initialState: .live, reducer: mainAppReducer, environment: .live)
    static let mock = MainAppStore(initialState: .mock, reducer: mainAppReducer, environment: .mock)
}

struct MainAppState: Equatable {
    var tab: SelectedTab? = .welcome
    var error: String?
    var isSafariExtensionEnabled = false

    var enableOAuth = true
    var didCompleteOAuth = false

    var notificationsEnabled = false
    var didPurchaseLiveCommentPreviews = false

    var canMakePurchases = SKPaymentQueue.canMakePayments()
}

extension MainAppState {
    static let live = MainAppState(canMakePurchases: SKPaymentQueue.canMakePayments())
    static let mock = MainAppState(canMakePurchases: true)
}

enum MainAppAction: Equatable {
    case persistState
    case loadSavedState

    case nextTab
    case setTab(_ tab: SelectedTab?)

    case openSafariToExtensionsWindow
    case checkSafariExtensionState
    case setSafariExtensionState(_ state: Bool)

    case requestNotificationAuthorization
    case checkNotificationsEnabled
    case setNotificationsEnabled(_ state: Bool)

    case purchaseLiveCommentPreviews
    case restorePurchases
    case setDidPurchaseLiveCommentPreviews
    case resetIAP

    case beginOAuth
    case setOAuthState(_ enabled: Bool)
    case exchangeCodeForTokens(incomingUrl: URL)
    case saveTokens(_ tokens: Tokens)

    case validateReceipt

    case openTestFlight

    case displayError(_ error: String)
}

import Combine
import SafariServices

let mainAppReducer = Reducer<MainAppState, MainAppAction, TFREnvironment> { state, action, env in
    logReducer("mainAppReducer rcv: \(action)")
    switch action {
        case .openTestFlight:
            NSWorkspace.shared.open(URL(string: "https://testflight.apple.com/join/Ym1a1PE1")!)

        case .resetIAP:
            while env.coreData.iapState != nil {
                env.coreData.container.viewContext.delete(env.coreData.iapState!)
            }
            try? env.coreData.container.viewContext.save()

        case .restorePurchases:
            env.appStore.restorePurchases()

        case .purchaseLiveCommentPreviews:
            env.appStore.purchase(.liveCommentPreview)

        case .setDidPurchaseLiveCommentPreviews:
            state.didPurchaseLiveCommentPreviews = env.coreData.iapState?.liveCommentPreviews ?? false

        case .validateReceipt:
            guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
                  FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
                return Just(MainAppAction.displayError("No receipt file exists.")).eraseToAnyPublisher()
            }
            guard let receiptData = try? Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped) else {
                return Just(MainAppAction.displayError("Local receipt file is malformed.")).eraseToAnyPublisher()
            }
            let receipt = AppStoreValidationRequest(receipt: receiptData.base64EncodedString(options: []), identifier: TweaksForReddit.identifier)
            var request = URLRequest(url: URL(string: "https://www.bermudalocket.com/verify-receipt")!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let body = try? JSONEncoder().encode(receipt) else {
                return Just(MainAppAction.displayError("Failed to encode receipt validation request.")).eraseToAnyPublisher()
            }
            request.httpBody = body
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    return
                }
                guard let result = try? JSONDecoder().decode([AppStoreValidationResponse].self, from: data) else {
                    return
                }
                for receipt in result where receipt.id == "livecommentpreview" {
                    var iapState = IAPState(context: env.coreData.container.viewContext)
                    iapState.timestamp = Date()
                    iapState.liveCommentPreviews = true
                    try? env.coreData.container.viewContext.save()
                }
            }.resume()

        case .nextTab:
            guard let tab = state.tab else {
                return Just(MainAppAction.setTab(.welcome)).eraseToAnyPublisher()
            }
            var nextTab = SelectedTab.welcome
            switch tab {
                case .welcome:
                    nextTab = .connectToSafari
                case .connectToSafari:
                    nextTab = .notifications
                case .notifications:
                    nextTab = .oauth
                case .oauth:
                    nextTab = .toolbar
                case .toolbar:
                    nextTab = .iCloud
                case .iCloud:
                    nextTab = .liveCommentPreview
                case .liveCommentPreview:
                    nextTab = .welcome
//                    nextTab = .testFlight
//                case .testFlight:
//                    nextTab = .testFlight
            }
            return Just(MainAppAction.setTab(nextTab)).eraseToAnyPublisher()

        case .requestNotificationAuthorization:
            UNUserNotificationCenter.current().requestAuthorization(options: .alert) { state, error in
                log("Notification request completion: \(state)")
                if let error = error {
                    log("Notification request error: \(error)")
                }
            }
            
        case .setNotificationsEnabled(let notificationState):
            state.notificationsEnabled = notificationState

        case .checkNotificationsEnabled:
            return Future<Bool, Never> { promise in
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    return promise(.success(settings.authorizationStatus == .authorized))
                }
            }
            .map(MainAppAction.setNotificationsEnabled)
            .eraseToAnyPublisher()

        case .setOAuthState(let isEnabled):
            env.defaults.set(isEnabled, forKey: "enableOAuthFeatures")

        case .openSafariToExtensionsWindow:
            SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.bermudalocket.redditweaks.extension")

        case .checkSafariExtensionState:
            return Future<Bool, Never> { promise in
                SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: "com.bermudalocket.redditweaks.extension") { safariState, _ in
                    return promise(.success(safariState?.isEnabled ?? false))
                }
            }
            .map(MainAppAction.setSafariExtensionState)
            .eraseToAnyPublisher()

        case .setSafariExtensionState(let safariState):
            state.isSafariExtensionEnabled = safariState

        case .displayError(let error):
            state.error = error

        case .persistState:
            env.defaults.set(state.tab?.rawValue, forKey: "selectedTab")
            env.defaults.set(state.didCompleteOAuth, forKey: "didCompleteOAuth")

        case .loadSavedState:
            if let lastTab = env.defaults.getObject("selectedTab") as? SelectedTab {
                state.tab = lastTab
            }
            if let didCompleteOAuth = env.defaults.getObject("didCompleteOAuth") as? Bool {
                state.didCompleteOAuth = didCompleteOAuth
            }
            if let oauthState = env.defaults.getObject("enableOAuthFeatures") as? Bool {
                state.enableOAuth = oauthState
            }

        case .setTab(let tab):
            state.tab = tab

        case .beginOAuth:
            let state = UUID().uuidString
            env.defaults.set(state, forKey: "oauthState")
            _ = env.oauth.begin(state: state)

        case .exchangeCodeForTokens(incomingUrl: let url):
            guard let code = url.queryParameters?["code"]?.replacingOccurrences(of: "#_", with: "") else {
                return .init(value: .displayError("No code"))
            }
            return env.oauth
                .exchangeCodeForTokens(code: code)
                .map { MainAppAction.saveTokens($0) }
                .catch { error in
                    Just(MainAppAction.displayError("\(error)"))
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()

        case .saveTokens(let tokens):
            env.keychain.setTokens(tokens)
            state.didCompleteOAuth = true
    }
    return .none
}
