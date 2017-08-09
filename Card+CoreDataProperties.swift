//
//  Card+CoreDataProperties.swift
//  FlashCardSwift
//
//  Created by Scott Gromme on 7/6/17.
//  Copyright © 2017 Billys Awesome App House. All rights reserved.
//

import Foundation
import CoreData


extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var back: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var front: String?
    @NSManaged public var show: Bool
    @NSManaged public var randomsort: Double
    @NSManaged public var set: Set?

}
