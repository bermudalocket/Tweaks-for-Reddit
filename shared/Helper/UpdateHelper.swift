//
//  UpdateHelper.swift
//  redditweaks Extension
//
//  Created by Michael Rippe on 3/2/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final class UpdateHelper: ObservableObject {

    private static let updateQueue = DispatchQueue(label: "redditweaks Update Helper",
                                                   qos: .background,
                                                   attributes: .concurrent,
                                                   autoreleaseFrequency: .inherit,
                                                   target: nil)

    enum UpdateError: Error {
        case error
        case urlSessionError(String)
    }

    /// A timestamp created with Date's timeIntervalSince1970 representing the last check
    @AppStorage("lastCheckedForUpdate") private(set) var lastCheckedForUpdate: Double = -1

    /// UI
    @Published var isCheckingForUpdate = false
    @Published var updateIsAvailable = false
    @Published var updateHelperError: UpdateError?

    final var canCheckForUpdate: Bool {
        Date.now() - lastCheckedForUpdate > .minutes(10)
    }

    final func pollUpdate(forced: Bool = false) {
        if !forced && canCheckForUpdate {
            return
        }
        DispatchQueue.main.async {
            self.isCheckingForUpdate = true
        }
        guard let url = URL(string: "https://github.com/bermudalocket/redditweaks/releases/latest") else {
            return
        }
        UpdateHelper.updateQueue.async {
            URLSession.shared.dataTask(with: url) { [self] data, response, error in

                // let update animation play for more than a split second
                Thread.sleep(forTimeInterval: 1)

                DispatchQueue.main.async {
                    if let error = error {
                        updateHelperError = .urlSessionError("\(error)")
                        isCheckingForUpdate = false
                        return
                    }
                    guard let version = response?.url?.lastPathComponent else {
                        updateHelperError = .error
                        isCheckingForUpdate = false
                        return
                    }
                    let githubVersionAsInt = Int(version.replacingOccurrences(of: ".", with: "")) ?? 0
                    let currentVersionAsInt = Int(Redditweaks.version.replacingOccurrences(of: ".", with: "")) ?? 0

                    updateHelperError = nil
                    updateIsAvailable = githubVersionAsInt > currentVersionAsInt
                    isCheckingForUpdate = false
                    lastCheckedForUpdate = Date.now()
                }

            }.resume()
        }
    }

}
