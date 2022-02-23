//
//  URL+expressibleAsStringLiteral.swift
//  TFRCore
//
//  Created by Michael Rippe on 2/20/22.
//  Copyright © 2022 bermudalocket. All rights reserved.
//

import Foundation

extension URL: ExpressibleByStringLiteral {

    public init(stringLiteral value: StringLiteralType) {
        self = URL(string: value)!
    }

}
