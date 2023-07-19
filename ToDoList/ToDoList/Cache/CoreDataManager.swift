//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 14.07.2023.
//

import UIKit
import CoreData

@MainActor
final class CoreDataManager: NSObject, FirstIndexByGettable {

    // MARK: - Private properties

    private override init() {}

    static let shared = CoreDataManager()

    private(set) var items = [ToDoItem]()

    // MARK: - Core Data stack

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoList")
        container
            .loadPersistentStores(
                completionHandler: { (storeDescription, error) in
                    if let error = error as NSError? {
                        fatalError("Unresolved error \(error), \(error.userInfo)")
                    } else {
                        print("Database url - ", storeDescription.url ?? "")
                    }
                })
        return container
    }()

    // MARK: - context for reading

    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - context for writing

    private func backgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    // MARK: - Private functions

    private func append(_ item: ToDoItem) {
        if let index = firstIndexBy(id: item.id, in: items) {
            items[index] = item
            update(for: item)
        } else {
            items.append(item)
            insert(for: item)
        }
    }

    // MARK: - Public functions

    public func insert(for item: ToDoItem) {
        let context = backgroundContext()

        guard let entityDescription = NSEntityDescription
            .entity(
                forEntityName: "CoreDataToDoItem",
                in: backgroundContext()
            ) else { return }

        let createdItem = CoreDataToDoItem(entity: entityDescription, insertInto: context)
        do {
            createdItem.id = item.id
            createdItem.text = item.text
            createdItem.importance = item.importance.rawValue
            createdItem.deadline = item.deadLine
            createdItem.isDone = item.isDone
            createdItem.startTime = item.startTime
            createdItem.changeTime = item.changeTime

            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    public func load() {
        let request = CoreDataToDoItem.fetchRequest()

        guard let items = try? context.fetch(request) as [CoreDataToDoItem] else { return }
        self.items = items.map({
            ToDoItem(
                id: $0.id,
                text: $0.text,
                importance: Importance(rawValue: $0.importance) ?? .common,
                deadLineTimeIntervalSince1970: $0.deadline?.timeIntervalSince1970,
                isDone: $0.isDone,
                startTimeIntervalSince1970: $0.startTime.timeIntervalSince1970,
                changeTimeIntervalSince1970: $0.changeTime?.timeIntervalSince1970)
        }).sorted {$0.startTime > $1.startTime}
    }

    public func update(for item: ToDoItem) {
        let request = CoreDataToDoItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", item.id)

        let context = backgroundContext()
        do {
            let items = try context.fetch(request)
            guard let updatedItem = items.first else { return }

            updatedItem.id = item.id
            updatedItem.text = item.text
            updatedItem.importance = item.importance.rawValue
            updatedItem.deadline = item.deadLine
            updatedItem.isDone = item.isDone
            updatedItem.startTime = item.startTime
            updatedItem.changeTime = item.changeTime

            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    public func delete(for id: String) {
        if let index = firstIndexBy(id: id, in: self.items) {
            self.items.remove(at: index)
        }

        let request = CoreDataToDoItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)

        let context = backgroundContext()

        do {
            let items = try context.fetch(request)
            guard let deletedItem = items.first else { return }

            context.delete(deletedItem)
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    public func updateItemsIntoDatabase(using serverItems: [ToDoItem]) {
        let itemsSet = Set(items.map({ $0.id }))
        let serverItemsSet = Set(serverItems.map({ $0.id }))

        if itemsSet.count > serverItemsSet.count {
            let deleteItems = itemsSet.subtracting(serverItemsSet)
            for id in deleteItems {
                delete(for: id)
            }
        }
        for id in serverItemsSet {
            if let item = serverItems.first(where: { $0.id == id }) {
                append(item)
            }
        }
    }
}
