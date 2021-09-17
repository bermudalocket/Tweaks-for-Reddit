//
//  Post.swift
//  Post
//
//  Created by Michael Rippe on 9/11/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

public struct Post: Codable, Equatable, Hashable {
    public let subreddit: String
    public let title: String
    public let permalink: String

    /// The name of this post, e.g. t3_abcdef
    public let name: String

    public init(subreddit: String, title: String, permalink: String, name: String) {
        self.subreddit = subreddit
        self.title = title
        self.permalink = permalink
        self.name = name
    }
}
