//
//  ThreadCommentCount+CoreDataProperties.swift
//  TFRCore
//
//  Created by Michael Rippe on 6/27/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//
//

import Foundation
import CoreData


extension ThreadCommentCount {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ThreadCommentCount> {
        return NSFetchRequest<ThreadCommentCount>(entityName: "ThreadCommentCount")
    }

    @NSManaged public var internalCount: Int64
    @NSManaged public var thread: String?
    @NSManaged public var timestamp: Date?

}

extension ThreadCommentCount : Identifiable {

}
