//
//  UserData.swift
//  Tweaks for Reddit Core
//
//  Created by Michael Rippe on 6/17/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

public struct UserData: Decodable, Equatable {

    public let username: String?

    public let snoovatarImageURL: String?
    public let snoovatarSize: [Int]?
    public let goldExpiration: Double?
    public let newModMailExists: Bool?
    public let hasModMail: Bool?
    public let coins: Int?

    public let postKarma: Int?
    public let commentKarma: Int?

    public let inboxCount: Int?
    public let hasMail: Bool?

    enum CodingKeys: String, CodingKey {
        case username = "name"
        case snoovatarImageURL = "snoovatar_img"
        case snoovatarSize = "snoovatar_size"
        case goldExpiration = "gold_expiration"
        case newModMailExists = "new_modmail_exists"
        case hasModMail = "has_mod_mail"
        case coins = "coins"
        case postKarma = "link_karma"
        case commentKarma = "comment_karma"
        case inboxCount = "inbox_count"
        case hasMail = "has_mail"
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
        snoovatarSize: [ 380, 600 ],
        goldExpiration: 1626459655,
        newModMailExists: true,
        hasModMail: true,
        coins: 2600,
        postKarma: 6082,
        commentKarma: 10786,
        inboxCount: 3,
        hasMail: true
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
