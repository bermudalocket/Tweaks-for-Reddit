//
//  AppState.swift
//  redditweaks
//
//  Created by Michael Rippe on 2/25/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI
import Combine

enum FavoriteSubredditListHeight: Int, CaseIterable {
    case small = 125, medium = 200, large = 320

    var displayName: String {
        switch self {
            case .small: return "Small"
            case .medium: return "Medium"
            case .large: return "Large"
        }
    }
}

final class AppState: ObservableObject {

    // MARK: - task storage

    private var cancellables = [URLSessionDataTask]()

    // MARK: - saved GUI state

    @AppStorage("verifySubreddits") var doSubredditVerification = true
    @AppStorage("favoriteSubredditListHeight") var favoriteSubredditListHeight = FavoriteSubredditListHeight.medium

    // MARK: - features

    @Published var features: [Feature: Bool] = {
        var map = [Feature: Bool]()
        Feature.features.forEach { feature in
            map[feature] = Redditweaks.defaults.bool(forKey: feature.key)
        }
        map[.liveCommentPreview] = PersistenceController.shared.iapState.livecommentpreviews
        return map
    }()

    // MARK: - preview

    public static let preview = AppState()

    final func bindingForFeature(_ feature: Feature) -> Binding<Bool> {
        .init(get: {
            self.features[feature] ?? false
        }, set: { bool in
            var copy = [Feature: Bool]()
            self.features.forEach { copy[$0] = $1 }
            copy[feature] = bool
            Redditweaks.defaults.setValue(bool, forKey: feature.key)
            self.features = copy
        })
    }

}

extension AppState {

    func verifySubreddit(subreddit: String, isValid: Binding<Bool>, isSearching: Binding<Bool>) {
        if !doSubredditVerification {
            isValid.projectedValue.wrappedValue = true
            return
        }
        isSearching.projectedValue.wrappedValue = true
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        let url = URL(string: "https://www.reddit.com/r/\(subreddit)")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil,
                  let res = response as? HTTPURLResponse,
                  res.statusCode == 200,
                  let data = data,
                  let result = String(data: data, encoding: .utf8)
            else {
                isValid.projectedValue.wrappedValue = false
                isSearching.projectedValue.wrappedValue = false
                return
            }
            let outcome = !result.contains("there doesn't seem to be anything here")
            isValid.projectedValue.wrappedValue = outcome
            isSearching.projectedValue.wrappedValue = false
        }
        cancellables.append(task)
        task.resume()
    }
}
