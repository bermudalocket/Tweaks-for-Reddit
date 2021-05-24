//
//  TFRCoreDataDecryptor.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 5/16/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import CoreData

@objc(TFRCoreDataDecryptor)
class TFRCoreDataDecryptor: ValueTransformer {

    static let name = NSValueTransformerName(.init(describing: TFRCoreDataDecryptor.self))

    public static func register() {
        let transformer = TFRCoreDataDecryptor()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }

    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }

    override class func allowsReverseTransformation() -> Bool {
        true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let string = value as? String,
              let data = try? NSKeyedArchiver.archivedData(withRootObject: string, requiringSecureCoding: true) else {
            return nil
        }
        return data
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else {
            return nil
        }
        guard let string = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSString.self, from: Data(referencing: data)) else {
            return nil
        }
        return string
    }

}
