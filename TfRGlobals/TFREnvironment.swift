//
//  AppEnvironment.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/25/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import SafariServices

public struct TFREnvironment {
    public var oauth: OAuthClient
    public var iap: IAPHelper
    public var coreData: CoreDataService
    public var defaults: DefaultsService
    public var keychain: KeychainService
}

extension TFREnvironment {
    public static let live = Self(
        oauth: OAuthClientLive(),
        iap: .shared,
        coreData: .live,
        defaults: DefaultsServiceLive(),
        keychain: KeychainServiceLive()
    )
    public static let mock = Self(
        oauth: OAuthClientMock(),
        iap: .shared,
        coreData: .mock,
        defaults: DefaultsServiceMock(),
        keychain: KeychainServiceMock()
    )
}

public struct TFRExtensionEnvironment {
    public var oauth: OAuthClient
    public var iap: IAPHelper
    public var coreData: CoreDataService
    public var defaults: DefaultsService
    public var keychain: KeychainService
    public var safari: SFSafariExtensionHandler

    public static func create(with: SFSafariExtensionHandler) -> TFRExtensionEnvironment {
        Self(
            oauth: OAuthClientLive(),
            iap: .shared,
            coreData: .live,
            defaults: DefaultsServiceLive(),
            keychain: KeychainServiceLive(),
            safari: with
        )
    }
}

public class SFSafariExtensionHandlerMock: SFSafariExtensionHandler {

}
