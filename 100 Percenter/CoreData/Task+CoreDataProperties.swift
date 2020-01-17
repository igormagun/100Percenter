//
//  Task+CoreDataProperties.swift
//  100 Percenter
//
//  Created by Igor Magun on 2019-11-12.
//  Copyright © 2019 Igor Magun. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var completed: Bool
    @NSManaged public var name: String?
    @NSManaged public var uniqueID: Int64
    @NSManaged public var belongsToCategory: TaskCategory?
    @NSManaged public var belongsToGame: Game?

}
