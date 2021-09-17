//
//  Listing.swift
//  Listing
//
//  Created by Michael Rippe on 9/13/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

public struct Listing<T>: Decodable where T: Decodable {
    public let kind: String
    public let data: ListingGuts<T>

    public struct ListingGuts<T>: Decodable where T: Decodable {
        public let after: String?
        public let count: Int
        public let contents: [ListingGutsChildren<T>]

        public struct ListingGutsChildren<T>: Decodable where T: Decodable {
            public let kind: String
            public let data: T
        }

        public enum CodingKeys: String, CodingKey {
            case after
            case count = "dist"
            case contents = "children"
        }
    }
}
