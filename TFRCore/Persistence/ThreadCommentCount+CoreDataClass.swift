//
//  ThreadCommentCount+CoreDataClass.swift
//  TFRCore
//
//  Created by Michael Rippe on 6/27/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ThreadCommentCount)
public class ThreadCommentCount: NSManagedObject, Identifiable {

    @NSManaged public var internalCount: Int64
    @NSManaged public var thread: String?
    @NSManaged public var timestamp: Date?

}

extension ThreadCommentCount {
    public var count: Int {
        get { Int(internalCount) }
        set { internalCount = Int64(newValue) }
    }
}
