//
//  NotificationService.swift
//  Tweaks for Reddit Core
//
//  Created by Michael Rippe on 8/20/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import AppKit
import Foundation
import UserNotifications

public class NotificationService: NSObject, UNUserNotificationCenterDelegate {

    public static let shared = NotificationService()

    private override init() {
        super.init()
        let action = UNNotificationAction(identifier: "OPEN_URL", title: "Open URL", options: .init(rawValue: 0))
        let category = UNNotificationCategory(identifier: "MESSAGES", actions: [action], intentIdentifiers: [], options: .init())
        UNUserNotificationCenter.current().setNotificationCategories([category])
        UNUserNotificationCenter.current().delegate = self
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let urlStr = response.notification.request.content.userInfo["URL"] as? String,
              let url = URL(string: "https://www.reddit.com" + urlStr) else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    public func send(msg: UnreadMessage) {
        let id = String(msg.hashValue)
        let recentlyDelivered = (TweaksForReddit.defaults.array(forKey: "recentlyDelivered") as? [String]) ?? []
        if recentlyDelivered.contains(where: { $0 == id }) {
            return
        }

        let notification = UNMutableNotificationContent()
        notification.title = "New message"
        notification.subtitle = msg.author + " in r/" + msg.subreddit
        notification.sound = .default
        notification.body = msg.body
        notification.userInfo = [ "URL": msg.context ]
        notification.categoryIdentifier = "MESSAGES"
//        if #available(macOS 12.0, *) {
//            notification.interruptionLevel = .active
//        }

        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            if notifications.filter({ $0.request.identifier == id }).count == 0 {
                let request = UNNotificationRequest(identifier: id, content: notification, trigger: .none)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        log("Notification error: \(error.localizedDescription)")
                    }
                }
                TweaksForReddit.defaults.set(recentlyDelivered + [id], forKey: "recentlyDelivered")
            }
        }

    }

}
