//
//  KeychainService.swift
//  TFRCore
//
//  Created by Michael Rippe on 6/23/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import Security
import KeychainAccess

public protocol KeychainService {
    func getTokens() -> Tokens?
    func setTokens(_ tokens: Tokens)
}

class KeychainServiceLive: KeychainService {

    private let keychain = Keychain(service: "com.bermudalocket.tweaksforreddit", accessGroup: "2VZ489BR9H.group.com.bermudalocket.tweaksforreddit")
            .synchronizable(true)
            .accessibility(.afterFirstUnlock, authenticationPolicy: .userPresence)

    private func get(_ key: String) -> String? {
        try? keychain.get(key)
    }

    private func set(_ key: String, value: String) {
        try? keychain.set(value, key: key)
    }

    func getTokens() -> Tokens? {
        guard let accessToken = get("accessToken") else {
            logError("Access token not found")
            return nil
        }
        guard let refreshToken = get("refreshToken") else {
            logError("Refresh token not found")
            return nil
        }
        return Tokens(accessToken: accessToken, refreshToken: refreshToken)
    }

    func setTokens(_ tokens: Tokens) {
        do {
            guard let accessToken = tokens.accessToken, let refreshToken = tokens.refreshToken else {
                throw RedditError.noToken
            }
            set("accessToken", value: accessToken)
            set("refreshToken", value: refreshToken)
        } catch {
            logService("Keychain error saving: \(error)", service: .keychain)
        }
    }

}

public class KeychainServiceMock: KeychainService {

    public init() { }
    
    private var tokens = Tokens(accessToken: "access-token-mocked", refreshToken: "refresh-token-mocked")

    public func getTokens() -> Tokens? {
        tokens
    }

    public func setTokens(_ tokens: Tokens) {
        self.tokens = tokens
    }

}
