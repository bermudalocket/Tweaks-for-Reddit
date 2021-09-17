//
//  UserData.swift
//  TFRCore
//
//  Created by Michael Rippe on 6/17/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

public struct UserData: Codable, Equatable {

    public let username: String?
    public let snoovatarImageURL: String?
    public let postKarma: Int?
    public let commentKarma: Int?
    public let inboxCount: Int?

    enum CodingKeys: String, CodingKey {
        case username = "name"
        case snoovatarImageURL = "snoovatar_img"
        case postKarma = "link_karma"
        case commentKarma = "comment_karma"
        case inboxCount = "inbox_count"
    }

}

extension UserData {
    public var snoovatarUrl: URL? {
        guard let url = snoovatarImageURL else {
            return nil
        }
        return URL(string: url)
    }
}

extension UserData {
    public static let mock = UserData(
        username: "thebermudamocket",
        snoovatarImageURL: "https://i.redd.it/snoovatar/snoovatars/2d193ec6-03ef-4a80-a651-637f7ed0dd93.png",
        postKarma: 1234,
        commentKarma: 98765,
        inboxCount: 3
    )
}

/*

 {
 "kind": "t2",
 "data": {
     "snoovatar_img": "https://i.redd.it/snoovatar/snoovatars/2d193ec6-03ef-4a80-a651-637f7ed0dd93.png",
     "snoovatar_size": [
        380,
        600
     ],
     "gold_expiration": 1626459655,
     "new_modmail_exists": false,
     "has_mod_mail": false,
     "coins": 2600,
     "awarder_karma": 116,
     "awardee_karma": 526,
     "link_karma": 6082,
     "total_karma": 17510,
     "comment_karma": 10786,
     "inbox_count": 0,
     "has_mail": false,
     "created": 1414988589,
     }
 }

 */
