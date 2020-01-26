//
//  NSControl.StateValue+fromBool.swift
//  redditweaks Extension
//
//  Created by bermudalocket on 1/24/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Cocoa

extension NSControl.StateValue {

    static func fromBool(_ value: Bool) -> NSControl.StateValue {
        return value ? .on : off
    }

}
