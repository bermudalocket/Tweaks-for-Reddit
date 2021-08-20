//
//  KarmaMemory+CoreDataProperties.swift
//  Tweaks_for_Reddit_Core
//
//  Created by Michael Rippe on 6/27/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//
//

import Foundation
import CoreData


extension KarmaMemory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KarmaMemory> {
        return NSFetchRequest<KarmaMemory>(entityName: "KarmaMemory")
    }

    @NSManaged public var karma: Int64
    @NSManaged public var user: String?

}

extension KarmaMemory : Identifiable {

}
