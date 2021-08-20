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

    var canMakePurchases = SKPaymentQueue.canMakePayments()
}

extension MainAppState {
    static let live = MainAppState(canMakePurchases: SKPaymentQueue.canMakePayments())
    static let mock = MainAppState(canMakePurchases: true)
    static let mockSadPath = MainAppState(canMakePurchases: false)
}

enum MainAppAction: Equatable {
    case persistState
    case loadSavedState

    case setTab(_ tab: SelectedTab?)

    case openSafariToExtensionsWindow
    case updateSafariExtensionState
    case setSafariExtensionState(_ state: Bool)

    case requestNotificationsPermission

    case beginOAuth
    case setOAuthState(_ enabled: Bool)
    case exchangeCodeForTokens(incomingUrl: URL)
    case saveTokens(_ tokens: Tokens)

    case displayError(_ error: String)
}

import Combine
import SafariServices

let mainAppReducer = Reducer<MainAppState, MainAppAction, TFREnvironment> { state, action, env in
    logReducer("mainAppReducer rcv: \(action)")
    switch action {
        case .setOAuthState(let isEnabled):
            env.defaults.set(isEnabled, forKey: "enableOAuthFeatures")

        case .openSafariToExtensionsWindow:
            SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.bermudalocket.redditweaks.extension")

        case .updateSafariExtensionState:
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

        case .requestNotificationsPermission:
            UNUserNotificationCenter.current().requestAuthorization(options: .alert) { _, _ in }

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
