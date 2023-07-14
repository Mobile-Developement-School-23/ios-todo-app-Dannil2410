//
//  CoreDataToDoItem+CoreDataProperties.swift
//  
//
//  Created by Даниил Кизельштейн on 14.07.2023.
//
//

import Foundation
import CoreData

extension CoreDataToDoItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataToDoItem> {
        return NSFetchRequest<CoreDataToDoItem>(entityName: "CoreDataToDoItem")
    }

    @NSManaged public var id: String
    @NSManaged public var text: String
    @NSManaged public var importance: String
    @NSManaged public var deadline: Date?
    @NSManaged public var isDone: Bool
    @NSManaged public var startTime: Date
    @NSManaged public var changeTime: Date?

}
