//
//  Game+CoreDataProperties.swift
//  100 Percenter
//
//  Created by Igor Magun on 2019-11-12.
//  Copyright © 2019 Igor Magun. All rights reserved.
//
//

import Foundation
import CoreData


extension Game {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game")
    }

    @NSManaged public var completedTasks: Int64
    @NSManaged public var icon: String?
    @NSManaged public var largeIcon: String?
    @NSManaged public var name: String?
    @NSManaged public var percentageCompleted: Double
    @NSManaged public var uniqueID: Int64
    @NSManaged public var belongsToList: GameList?
    @NSManaged public var categoryBelongsToGame: NSOrderedSet?
    @NSManaged public var taskBelongsToGame: NSSet?

}

// MARK: Generated accessors for categoryBelongsToGame
extension Game {

    @objc(insertObject:inCategoryBelongsToGameAtIndex:)
    @NSManaged public func insertIntoCategoryBelongsToGame(_ value: TaskCategory, at idx: Int)

    @objc(removeObjectFromCategoryBelongsToGameAtIndex:)
    @NSManaged public func removeFromCategoryBelongsToGame(at idx: Int)

    @objc(insertCategoryBelongsToGame:atIndexes:)
    @NSManaged public func insertIntoCategoryBelongsToGame(_ values: [TaskCategory], at indexes: NSIndexSet)

    @objc(removeCategoryBelongsToGameAtIndexes:)
    @NSManaged public func removeFromCategoryBelongsToGame(at indexes: NSIndexSet)

    @objc(replaceObjectInCategoryBelongsToGameAtIndex:withObject:)
    @NSManaged public func replaceCategoryBelongsToGame(at idx: Int, with value: TaskCategory)

    @objc(replaceCategoryBelongsToGameAtIndexes:withCategoryBelongsToGame:)
    @NSManaged public func replaceCategoryBelongsToGame(at indexes: NSIndexSet, with values: [TaskCategory])

    @objc(addCategoryBelongsToGameObject:)
    @NSManaged public func addToCategoryBelongsToGame(_ value: TaskCategory)

    @objc(removeCategoryBelongsToGameObject:)
    @NSManaged public func removeFromCategoryBelongsToGame(_ value: TaskCategory)

    @objc(addCategoryBelongsToGame:)
    @NSManaged public func addToCategoryBelongsToGame(_ values: NSOrderedSet)

    @objc(removeCategoryBelongsToGame:)
    @NSManaged public func removeFromCategoryBelongsToGame(_ values: NSOrderedSet)

}

// MARK: Generated accessors for taskBelongsToGame
extension Game {

    @objc(addTaskBelongsToGameObject:)
    @NSManaged public func addToTaskBelongsToGame(_ value: Task)

    @objc(removeTaskBelongsToGameObject:)
    @NSManaged public func removeFromTaskBelongsToGame(_ value: Task)

    @objc(addTaskBelongsToGame:)
    @NSManaged public func addToTaskBelongsToGame(_ values: NSSet)

    @objc(removeTaskBelongsToGame:)
    @NSManaged public func removeFromTaskBelongsToGame(_ values: NSSet)

}
