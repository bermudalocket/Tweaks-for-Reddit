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

enum UpdateError: Error {
    case error
    case urlSessionError(String)
}

final class UpdateHelper: ObservableObject {

    @Published var isCheckingForUpdate = false

    private final var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    @AppStorage("lastCheckedForUpdate") private var internalLastCheckedForUpdate: Double = -1

    final var lastCheckedForUpdate: String {
        if internalLastCheckedForUpdate == -1 {
            return "never"
        }
        let date = Date(timeIntervalSince1970: internalLastCheckedForUpdate)
        return "Last checked: \(dateFormatter.string(from: date))"
    }

    @Published var updateIsAvailable = false

    @Published var updateHelperError: UpdateError?

    final func pollUpdate(forced: Bool = false) {
        if !forced && Date().timeIntervalSince1970 - internalLastCheckedForUpdate < 10_000 {
            return
        }
        DispatchQueue.main.async {
            self.isCheckingForUpdate = true
        }
        let url = URL(string: "https://github.com/bermudalocket/redditweaks/releases/latest")!
        URLSession.shared.dataTask(with: url) { [self] data, response, error in
            Thread.sleep(forTimeInterval: 1) // let update animation play for more than a split second
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
                if Int(version.replacingOccurrences(of: ".", with: "")) ?? 0 > Int(Redditweaks.version.replacingOccurrences(of: ".", with: "")) ?? 0 {
                    updateIsAvailable = true
                } else {
                    updateIsAvailable = false
                }
                isCheckingForUpdate = false
                internalLastCheckedForUpdate = Date().timeIntervalSince1970
            }
        }.resume()
    }

}
