//
//  KeychainService.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/23/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import Security

public protocol KeychainService {
    func getTokens() -> Tokens?
    func setTokens(_ tokens: Tokens)
}

public class KeychainServiceLive: KeychainService {

    private func get(_ key: String) -> String? {
        var query = [String: Any]()
        query[String(kSecClass)] = kSecClassGenericPassword
        query[String(kSecAttrSynchronizable)] = kCFBooleanTrue
        query[String(kSecAttrService)] = "com.bermudalocket.tweaksforreddit"
        query[String(kSecAttrAccessGroup)] = "2VZ489BR9H.com.bermudalocket.tweaksforreddit"
        query[String(kSecMatchLimit)] = kSecMatchLimitOne
        query[String(kSecReturnData)] = kCFBooleanTrue
        query[String(kSecAttrAccount)] = key

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess {
            guard let data = result as? Data else {
                return nil
            }
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    private func set(_ key: String, value: String) {
        var query = [String: Any]()
        query[String(kSecClass)] = kSecClassGenericPassword
        query[String(kSecAttrSynchronizable)] = kCFBooleanTrue
        query[String(kSecAttrService)] = "com.bermudalocket.tweaksforreddit"
        query[String(kSecAttrAccessGroup)] = "2VZ489BR9H.com.bermudalocket.tweaksforreddit"
        query[String(kSecReturnData)] = kCFBooleanTrue

        if let _ = get(key) {
            // update existing
            var newQuery = query
            newQuery[String(kSecValueData)] = value
            let status = SecItemUpdate(query as CFDictionary, newQuery as CFDictionary)
            if status == errSecSuccess {
                logService("Set keychain item \(key)", service: .keychain)
            } else {
                logService("Error setting keychain item: \(status)", service: .keychain)
            }
        } else {
            // create new
            let status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                logService("Error getting item from keychain: \(key)", service: .keychain)
            } else {
                logService("Set keychain item: \(key)", service: .keychain)
            }
        }
    }

    public func getTokens() -> Tokens? {
        guard let accessToken = get("accessToken"), let refreshToken = get("refreshToken") else {
            logService("One or more tokens requested are nil", service: .keychain)
            return nil
        }
        return Tokens(accessToken: accessToken, refreshToken: refreshToken)
    }

    public func setTokens(_ tokens: Tokens) {
        do {
            guard let accessToken = tokens.accessToken, let refreshToken = tokens.refreshToken else {
                throw OAuthError.noToken
            }
            set("accessToken", value: accessToken)
            set("refreshToken", value: refreshToken)
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
