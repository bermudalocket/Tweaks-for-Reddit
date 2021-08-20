//
//  IAPState+CoreDataProperties.swift
//  Tweaks_for_Reddit_Core
//
//  Created by Michael Rippe on 6/27/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//
//

import Foundation
import CoreData


extension IAPState {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IAPState> {
        return NSFetchRequest<IAPState>(entityName: "IAPState")
    }

    @NSManaged public var liveCommentPreviews: Bool
    @NSManaged public var timestamp: Date?

}

extension IAPState : Identifiable {

}
