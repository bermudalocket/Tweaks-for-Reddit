//
//  TFREnvironment.swift
//  Tweaks for Reddit Core
//
//  Created by Michael Rippe on 6/25/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import SafariServices

public struct TFREnvironment {
    public var oauth: OAuthClient
    public var coreData: CoreDataService
    public var defaults: DefaultsService
    public var keychain: KeychainService
    public var appStore: AppStoreService
}

extension TFREnvironment {
    public static let live = Self(
        oauth: OAuthClientLive(),
        coreData: .live,
        defaults: DefaultsServiceLive(),
        keychain: KeychainServiceLive(),
        appStore: AppStoreServiceLive()
    )
    public static let mock = Self(
        oauth: OAuthClientMock(),
        coreData: .mock,
        defaults: DefaultsServiceMock(),
        keychain: KeychainServiceMock(),
        appStore: AppStoreServiceLive()
    )
}
