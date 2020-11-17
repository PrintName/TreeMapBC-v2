//
//  Species+CoreDataProperties.swift
//  
//
//  Created by Allen Li on 11/16/20.
//
//

import Foundation
import CoreData


extension Species {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Species> {
        return NSFetchRequest<Species>(entityName: "Species")
    }

    @NSManaged public var botanicalName: String?
    @NSManaged public var commonName: String?
    @NSManaged public var trees: NSSet?

}

// MARK: Generated accessors for trees
extension Species {

    @objc(addTreesObject:)
    @NSManaged public func addToTrees(_ value: Tree)

    @objc(removeTreesObject:)
    @NSManaged public func removeFromTrees(_ value: Tree)

    @objc(addTrees:)
    @NSManaged public func addToTrees(_ values: NSSet)

    @objc(removeTrees:)
    @NSManaged public func removeFromTrees(_ values: NSSet)

}
