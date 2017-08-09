//
//  Set+CoreDataProperties.swift
//  FlashCardSwift
//
//  Created by Scott Gromme on 7/5/17.
//  Copyright © 2017 Billys Awesome App House. All rights reserved.
//

import Foundation
import CoreData


extension Set {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Set> {
        return NSFetchRequest<Set>(entityName: "Set")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var descriptionSet: String?
    @NSManaged public var importURL: String?
    @NSManaged public var name: String?
    @NSManaged public var randomize: Bool
    @NSManaged public var cards: NSOrderedSet?

}

// MARK: Generated accessors for cards
extension Set {

    @objc(insertObject:inCardsAtIndex:)
    @NSManaged public func insertIntoCards(_ value: Card, at idx: Int)

    @objc(removeObjectFromCardsAtIndex:)
    @NSManaged public func removeFromCards(at idx: Int)

    @objc(insertCards:atIndexes:)
    @NSManaged public func insertIntoCards(_ values: [Card], at indexes: NSIndexSet)

    @objc(removeCardsAtIndexes:)
    @NSManaged public func removeFromCards(at indexes: NSIndexSet)

    @objc(replaceObjectInCardsAtIndex:withObject:)
    @NSManaged public func replaceCards(at idx: Int, with value: Card)

    @objc(replaceCardsAtIndexes:withCards:)
    @NSManaged public func replaceCards(at indexes: NSIndexSet, with values: [Card])

    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: Card)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: Card)

    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSOrderedSet)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSOrderedSet)

}
