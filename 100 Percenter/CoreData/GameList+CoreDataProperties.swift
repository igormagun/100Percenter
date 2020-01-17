//
//  GameList+CoreDataProperties.swift
//  100 Percenter
//
//  Created by Igor Magun on 2019-11-12.
//  Copyright © 2019 Igor Magun. All rights reserved.
//
//

import Foundation
import CoreData


extension GameList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameList> {
        return NSFetchRequest<GameList>(entityName: "GameList")
    }

    @NSManaged public var orderedListOfGames: NSOrderedSet?

}

// MARK: Generated accessors for orderedListOfGames
extension GameList {

    @objc(insertObject:inOrderedListOfGamesAtIndex:)
    @NSManaged public func insertIntoOrderedListOfGames(_ value: Game, at idx: Int)

    @objc(removeObjectFromOrderedListOfGamesAtIndex:)
    @NSManaged public func removeFromOrderedListOfGames(at idx: Int)

    @objc(insertOrderedListOfGames:atIndexes:)
    @NSManaged public func insertIntoOrderedListOfGames(_ values: [Game], at indexes: NSIndexSet)

    @objc(removeOrderedListOfGamesAtIndexes:)
    @NSManaged public func removeFromOrderedListOfGames(at indexes: NSIndexSet)

    @objc(replaceObjectInOrderedListOfGamesAtIndex:withObject:)
    @NSManaged public func replaceOrderedListOfGames(at idx: Int, with value: Game)

    @objc(replaceOrderedListOfGamesAtIndexes:withOrderedListOfGames:)
    @NSManaged public func replaceOrderedListOfGames(at indexes: NSIndexSet, with values: [Game])

    @objc(addOrderedListOfGamesObject:)
    @NSManaged public func addToOrderedListOfGames(_ value: Game)

    @objc(removeOrderedListOfGamesObject:)
    @NSManaged public func removeFromOrderedListOfGames(_ value: Game)

    @objc(addOrderedListOfGames:)
    @NSManaged public func addToOrderedListOfGames(_ values: NSOrderedSet)

    @objc(removeOrderedListOfGames:)
    @NSManaged public func removeFromOrderedListOfGames(_ values: NSOrderedSet)

}
