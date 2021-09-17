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
import Composable_Architecture
import TFRCore
import Tweaks_for_Reddit_Popover
import UserNotifications

typealias MainAppStore = Store<MainAppState, MainAppAction, TFREnvironment>

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

    case openSafariToExtensionsWindow
    case checkSafariExtensionState
    case setSafariExtensionState(_ state: Bool)

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
            state.receiptValidationStatus = .checking
            guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
                return Just(MainAppAction.setReceiptValidationStatus(.noReceiptFile)).eraseToAnyPublisher()
            }
            guard let receiptData = try? Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped) else {
                return Just(MainAppAction.setReceiptValidationStatus(.receiptMalformed)).eraseToAnyPublisher()
            }
            let receipt = AppStoreValidationRequest(receipt: receiptData.base64EncodedString(options: []), identifier: TweaksForReddit.identifier)
            var request = URLRequest(url: URL(string: "https://www.bermudalocket.com/verify-receipt")!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let body = try? JSONEncoder().encode(receipt) else {
                return AnyPublisher(value: MainAppAction.setReceiptValidationStatus(ReceiptValidationStatus.networkError))
            }
            request.httpBody = body
            return URLSession.shared.dataTaskPublisher(for: request)
                .map { (data, response) -> ReceiptValidationStatus in
                    guard let res = response as? HTTPURLResponse, res.statusCode == 200,
                          let result = try? JSONDecoder().decode([AppStoreValidationResponse].self, from: data) else {
                              return .networkError
                    }
                    if result.contains(where: { $0.id == "livecommentpreview" }) {
                        return .valid
                    } else {
                        return .invalid
                    }
                }
                .replaceError(with: .networkError)
                .map(MainAppAction.setReceiptValidationStatus)
                .eraseToAnyPublisher()

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

        // MARK: - Safari

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
                    window.makeKey()
                    window.orderFrontRegardless()
                }
            }

        // MARK: - OAuth

        case .beginOAuth:
            state.oauthState = .started
            let id = UUID().uuidString
            env.defaults.set(id, forKey: "oauthState")
            if let window = NSApplication.shared.mainWindow {
                window.level = .floating
                window.setFrameOrigin(NSPoint(x: 50, y: (window.screen?.visibleFrame.size.height ?? 150) - 50))
            }
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
