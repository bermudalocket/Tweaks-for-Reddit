//
//  Redditweaks.swift
//  redditweaks Extension
//  5.0
//  10.16
//
//  Created by bermudalocket on 7/9/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Combine
import Foundation

class Redditweaks {

    public static let repoURL = URL(string: "https://www.github.com/bermudalocket/redditweaks/issues/new/choose")!

    enum RedditweaksError: Error {
        case networkError
    }

    private static var cancellables = Set<AnyCancellable>()

    public static let defaults = UserDefaults(suiteName: "com.bermudalocket.redditweaks") ?? UserDefaults.standard

    public static let favoriteSubredditsPublisher = CurrentValueSubject<[String], Never>(favoriteSubreddits)

    public static var favoriteSubreddits: [String] {
        get {
            guard let favorites = defaults.array(forKey: "favoriteSubreddits") as? [String] else {
                return []
            }
            return favorites
        }
        set {
            favoriteSubredditsPublisher.send(newValue)
            defaults.setValue(newValue, forKey: "favoriteSubreddits")
        }
    }

    public static func addFavoriteSubreddit(_ favoriteSub: String) {
        var favoriteSubreddit = favoriteSub
        if favoriteSubreddit.starts(with: "r/") {
            favoriteSubreddit.removeFirst(2)
        }
        favoriteSubreddits.append(favoriteSubreddit)
    }

    public static func removeFavoriteSubreddit(_ favoriteSubreddit: String) {
        favoriteSubreddits.removeAll {
            $0 == favoriteSubreddit
        }
    }

    public static func verifySubredditExists(_ subreddit: String) -> Future<Bool, Error> {
        Future { promise in
            guard let url = URL(string: "https://www.reddit.com/\(subreddit)") else {
                return promise(.failure(RedditweaksError.networkError))
            }
            URLSession.shared.dataTaskPublisher(for: url)
                .sink(receiveCompletion: { completion in },
                      receiveValue: { data, response in
                        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                            return promise(.failure(RedditweaksError.networkError))
                        }
                        guard let html = String(data: data, encoding: .utf8) else {
                            return promise(.failure(RedditweaksError.networkError))
                        }
                        return promise(.success(!html.contains("there doesn't seem to be anything here")))
                }).store(in: &cancellables)
        }
    }

}

extension String {
    public static func utf8Decoded(_ data: Data) -> String? {
        String(data: data, encoding: .utf8)
    }
}
