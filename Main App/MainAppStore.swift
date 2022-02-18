//
//  MainAppStore.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/21/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import AppKit
import Foundation
import StoreKit
import TFRCompose
import TFRCore
import Tweaks_for_Reddit_Popover
import UserNotifications

typealias MainAppStore = Store<MainAppState, MainAppAction, TFREnvironment>

extension MainAppStore {
    func setSafariExtensionEnabled(_ enabled: Bool) {
        state.isSafariExtensionEnabled = enabled
    }
}

struct MainAppState: Equatable {
    var tab: SelectedTab? = .welcome

    var isSafariExtensionEnabled = false

    var oauthState = OAuthState.notStarted
    var didCompleteOAuth = false

    var notificationsEnabled = false

    let canMakePurchases = SKPaymentQueue.canMakePayments()
    var receiptValidationStatus = ReceiptValidationStatus.none
    var isRestoringPurchases = false
    var isShowingScreenshot = false

    var isShowingWhatsNew = false
}

enum OAuthState {
    case notStarted, started, exchanging, failed, completed
}

enum MainAppAction: Equatable {
    case save
    case initialize
    case dismissWhatsNew

    case nextTab
    case setTab(_ tab: SelectedTab?)
    case handleDeeplink(_ url: URL)

    case requestNotificationAuthorization
    case checkNotificationsEnabled
    case setNotificationsEnabled(_ state: Bool)

    case showScreenshot(_ state: Bool)
    case purchaseLiveCommentPreviews
    case restorePurchases
    case setDidRestorePurchases(_ state: Bool)
    case validateReceipt
    case setReceiptValidationStatus(_ status: ReceiptValidationStatus)

    case beginOAuth
    case setOAuthState(_ state: OAuthState)
    case exchangeCodeForTokens(incomingUrl: URL)
    case saveTokens(_ tokens: Tokens)
    case checkForMessages
    case updateMessages(messages: [UnreadMessage])

    case openTestFlight
}

enum ReceiptValidationStatus {
    case none, checking, valid, invalid, networkError, noReceiptFile, receiptMalformed
}

import Combine
import SafariServices

let mainAppReducer = Reducer<MainAppState, MainAppAction, TFREnvironment> { state, action, env in
    logReducer("mainAppReducer rcv: \(action)")
    switch action {
        case .handleDeeplink(let url):
            guard url.absoluteString.starts(with: "rdtwks://") else {
                return .none
            }
            var action: MainAppAction
            switch url.host {
                case "iap":
                    action = .setTab(.liveCommentPreview)
                case "oauth":
                    action = .exchangeCodeForTokens(incomingUrl: url)
                case "auth":
                    action = .setTab(.oauth)
                default:
                    return .none
            }
            return AnyPublisher(value: action)

        case .dismissWhatsNew:
            state.isShowingWhatsNew = false
            env.defaults.set(TweaksForReddit.version, forKey: .lastWhatsNewVersion)

        case .openTestFlight:
            NSWorkspace.shared.open(URL(string: "https://testflight.apple.com/join/Ym1a1PE1")!)

        // MARK: - Purchases

        case .showScreenshot(let show):
            state.isShowingScreenshot = show

        case .setReceiptValidationStatus(let receiptValidationStatus):
            state.receiptValidationStatus = receiptValidationStatus
            env.defaults.set(receiptValidationStatus == .valid, forKey: .didPurchaseLiveCommentPreviews)

        case .restorePurchases:
            state.receiptValidationStatus = .none
            state.isRestoringPurchases = true
            return env.appStore
                .restorePurchases()
                .map(MainAppAction.setDidRestorePurchases)
                .eraseToAnyPublisher()

        case let .setDidRestorePurchases(didRestorePurchases):
            state.isRestoringPurchases = !didRestorePurchases
            return AnyPublisher(value: .validateReceipt)

        case .purchaseLiveCommentPreviews:
            env.appStore.purchase(.liveCommentPreview)

        case .validateReceipt:
            if NSUbiquitousKeyValueStore.default.bool(forKey: "livecommentpreview") {
                state.receiptValidationStatus = .valid
            } else {
                state.receiptValidationStatus = .invalid
            }

        // MARK: - Tabs

        case .setTab(let tab):
            state.tab = tab
            if let tab = tab {
                env.defaults.set(tab.rawValue, forKey: .selectedTab)
            }

        case .nextTab:
            guard let tab = state.tab else {
                return AnyPublisher(value: MainAppAction.setTab(.welcome))
            }
            return AnyPublisher(value: MainAppAction.setTab(tab.next))

        // MARK: - Notifications

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

        // MARK: - Lifecycle

        case .save:
            env.defaults.set(state.tab?.rawValue, forKey: .selectedTab)
            env.defaults.set(state.didCompleteOAuth, forKey: .didCompleteOAuth)

        case .initialize:
            if let lastTab = env.defaults.get(.selectedTab) as? SelectedTab {
                state.tab = lastTab
            }
            if let didCompleteOAuth = env.defaults.get(.didCompleteOAuth) as? Bool {
                state.didCompleteOAuth = didCompleteOAuth
            }
            if let lastVersion = env.defaults.get(.lastWhatsNewVersion) as? String {
                let numeric = Int(lastVersion.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "")) ?? -1
                let thisVersionNumeric = Int(TweaksForReddit.version.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "")) ?? Int.max
                state.isShowingWhatsNew = (numeric < thisVersionNumeric)
            }
            if !env.defaults.exists(.firstLaunch) {
                env.defaults.set(!env.defaults.exists(.lastReviewRequestTimestamp), forKey: .firstLaunchIsDefinite)
                env.defaults.set(Date().timeIntervalSince1970, forKey: .firstLaunch)
            }
            DispatchQueue.main.async { //After(deadline: .now().advanced(by: .milliseconds(1))) {
                if let window = NSApplication.shared.windows.first {
                    window.isMovableByWindowBackground = true
                    window.makeKeyAndOrderFront(nil)
                    window.level = .floating
                }
            }

        // MARK: - OAuth

        case .beginOAuth:
            state.oauthState = .started
            let id = UUID().uuidString
            env.defaults.set(id, forKey: "oauthState")
            env.reddit.begin(state: id)

        case .setOAuthState(let oauthState):
            state.oauthState = oauthState

        case .updateMessages(let messages):
            messages.forEach(NotificationService.shared.send(msg:))

        case .checkForMessages:
            guard let tokens = env.keychain.getTokens() else {
                return AnyPublisher(value: MainAppAction.setOAuthState(.failed))
            }
            return env.reddit.getMessages(tokens: tokens)
                .replaceError(with: [])
                .map(MainAppAction.updateMessages(messages:))
                .eraseToAnyPublisher()

        case .exchangeCodeForTokens(incomingUrl: let url):
            state.oauthState = .exchanging
            guard let code = url.queryParameters?["code"]?.replacingOccurrences(of: "#_", with: "") else {
                return AnyPublisher(value: MainAppAction.setOAuthState(.failed))
            }
            return env.reddit
                .exchangeCodeForTokens(code: code)
                .map { MainAppAction.saveTokens($0) }
                .catch { error in
                    Just(MainAppAction.setOAuthState(.failed))
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()

        case .saveTokens(let tokens):
            env.keychain.setTokens(tokens)
            state.oauthState = .completed
            state.didCompleteOAuth = true

    }
    return .none
}
