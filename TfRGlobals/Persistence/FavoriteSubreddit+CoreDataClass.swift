//
//  FavoriteSubreddit+CoreDataClass.swift
//  TfRGlobals
//
//  Created by Michael Rippe on 6/27/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//
//

import Foundation
import CoreData

@objc(FavoriteSubreddit)
public class FavoriteSubreddit: NSManagedObject {

}

public class FavoriteSubredditMock: FavoriteSubreddit {

    var stubbedName: String?
    var stubbedPosition: Int?

    public convenience init(name: String = " ", position: Int = 0) {
        self.init()
        self.stubbedName = name
        self.stubbedPosition = position
    }

    public override var name: String? {
        get {
            stubbedName
        }
        set {
            stubbedName = newValue
        }
    }

    override public var internalPosition: Int16 {
        get {
            Int16(stubbedPosition ?? 0)
        }
        set {
            stubbedPosition = Int(newValue)
        }
    }

}
