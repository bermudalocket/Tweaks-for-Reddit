//
//  FavoriteSubreddit+CoreDataProperties.swift
//  TFRCore
//
//  Created by Michael Rippe on 6/27/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//
//

import Foundation
import CoreData


extension FavoriteSubreddit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteSubreddit> {
        return NSFetchRequest<FavoriteSubreddit>(entityName: "FavoriteSubreddit")
    }

    @NSManaged public var internalPosition: Int16
    @NSManaged public var name: String?

}

extension FavoriteSubreddit : Identifiable {

}
