//
//  UnreadMessages.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/24/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

public struct UnreadMessagesResponse: Decodable {

    public let kind: String
    public let data: UnreadMessagesData

    public struct UnreadMessagesData: Decodable {
        public let modhash: String?
        public let dist: Int
        public let children: [UnreadMessageParent]

        public struct UnreadMessageParent: Decodable {
            public let kind: String
            public let data: UnreadMessage
        }
    }

}

public struct UnreadMessage: Decodable, Equatable, Hashable {
    public let author: String
    public let body: String
    public let subreddit: String
    public let subject: String // "comment reply", "post reply", ...
    public let context: String
    public let created: Double

    public init(author: String, body: String, subreddit: String, subject: String, context: String, created: Double) {
        self.author = author
        self.body = body
        self.subreddit = subreddit
        self.subject = subject
        self.context = context
        self.created = created
    }
}

extension UnreadMessage {
    public var createdTimestamp: Date {
        Date(timeIntervalSince1970: self.created)
    }
}
