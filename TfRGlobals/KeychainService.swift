//
//  KeychainService.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/23/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import KeychainAccess

public protocol KeychainService {
    func getTokens() -> Tokens?
    func setTokens(_ tokens: Tokens)
}

public class KeychainServiceLive: KeychainService {

    private let keychain = Keychain(
        service: "com.bermudalocket.tweaksforreddit",
        accessGroup: "2VZ489BR9H.com.bermudalocket.tweaksforreddit"
    )
    .synchronizable(true)

    public func getTokens() -> Tokens? {
        do {
            let accessToken = try keychain.getString("accessToken")
            let refreshToken = try keychain.getString("refreshToken")
            return Tokens(accessToken: accessToken, refreshToken: refreshToken)
        } catch {
            logService("Keychain error: \(error)", service: .keychain)
        }
        return nil
    }

    public func setTokens(_ tokens: Tokens) {
        do {
            guard let accessToken = tokens.accessToken, let refreshToken = tokens.refreshToken else {
                throw OAuthError.noToken
            }
            try keychain.set(accessToken, key: "accessToken")
            try keychain.set(refreshToken, key: "refreshToken")
        } catch {
            logService("Keychain error saving: \(error)", service: .keychain)
        }
    }

}

public class KeychainServiceMock: KeychainService {

    private var tokens: Tokens?

    public func getTokens() -> Tokens? {
        tokens
    }

    public func setTokens(_ tokens: Tokens) {
        self.tokens = tokens
    }

}

public enum TokenType: String {
    case accessToken = "accessToken"
    case refreshToken = "refreshToken"
    case test = "testToken"

    public var tag: Data {
        "com.bermudalocket.tfr.\(self.rawValue)".data(using: .utf8)!
    }
}
