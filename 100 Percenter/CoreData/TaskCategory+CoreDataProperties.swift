//
//  TaskCategory+CoreDataProperties.swift
//  100 Percenter
//
//  Created by Igor Magun on 2019-11-12.
//  Copyright © 2019 Igor Magun. All rights reserved.
//
//

import Foundation
import CoreData


extension TaskCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskCategory> {
        return NSFetchRequest<TaskCategory>(entityName: "TaskCategory")
    }

    @NSManaged public var completedTasks: Int64
    @NSManaged public var hasSubCategories: Bool
    @NSManaged public var name: String?
    @NSManaged public var percentageCompleted: Double
    @NSManaged public var uniqueID: Int64
    @NSManaged public var belongsToGame: Game?
    @NSManaged public var taskBelongsToCategory: NSOrderedSet?

}

// MARK: Generated accessors for taskBelongsToCategory
extension TaskCategory {

    @objc(insertObject:inTaskBelongsToCategoryAtIndex:)
    @NSManaged public func insertIntoTaskBelongsToCategory(_ value: Task, at idx: Int)

    @objc(removeObjectFromTaskBelongsToCategoryAtIndex:)
    @NSManaged public func removeFromTaskBelongsToCategory(at idx: Int)

    @objc(insertTaskBelongsToCategory:atIndexes:)
    @NSManaged public func insertIntoTaskBelongsToCategory(_ values: [Task], at indexes: NSIndexSet)

    @objc(removeTaskBelongsToCategoryAtIndexes:)
    @NSManaged public func removeFromTaskBelongsToCategory(at indexes: NSIndexSet)

    @objc(replaceObjectInTaskBelongsToCategoryAtIndex:withObject:)
    @NSManaged public func replaceTaskBelongsToCategory(at idx: Int, with value: Task)

    @objc(replaceTaskBelongsToCategoryAtIndexes:withTaskBelongsToCategory:)
    @NSManaged public func replaceTaskBelongsToCategory(at indexes: NSIndexSet, with values: [Task])

    @objc(addTaskBelongsToCategoryObject:)
    @NSManaged public func addToTaskBelongsToCategory(_ value: Task)

    @objc(removeTaskBelongsToCategoryObject:)
    @NSManaged public func removeFromTaskBelongsToCategory(_ value: Task)

    @objc(addTaskBelongsToCategory:)
    @NSManaged public func addToTaskBelongsToCategory(_ values: NSOrderedSet)

    @objc(removeTaskBelongsToCategory:)
    @NSManaged public func removeFromTaskBelongsToCategory(_ values: NSOrderedSet)

}
