//
//  SQLiteHelper.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 12.07.2023.
//

import Foundation
import SQLite

protocol FirstIndexByGettable: AnyObject {
    func firstIndexBy(id: String, in itemsList: [ToDoItem]) -> Int?
}

extension FirstIndexByGettable {
    func firstIndexBy(id: String, in itemsList: [ToDoItem]) -> Int? {
        return itemsList.map({$0.id}).firstIndex(of: id)
    }
}

final class SQLiteHelper: Persistencable, FirstIndexByGettable {

    private(set) var items = [ToDoItem]()

    private var database: Connection?
    private let toDoItems = Table("ToDoItem")

    private let id = Expression<String>("id")
    private let text = Expression<String>("text")
    private let importance = Expression<String>("importance")
    private let deadLine = Expression<Date?>("deadline")
    private let isDone = Expression<Int>("done")
    private let startTime = Expression<Date>("created_at")
    private let changeTime = Expression<Date?>("changed_at")

    init() throws {
        guard let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first else { return }

        let database = try Connection("\(path)/ToDoItemAppBase.sqlite3")
        self.database = database
    }

    func createTable() throws {
        let createTable = toDoItems.create { table in
            table.column(id, primaryKey: true)
            table.column(text)
            table.column(importance)
            table.column(deadLine)
            table.column(isDone)
            table.column(startTime)
            table.column(changeTime)
        }

        try database?.run(createTable)
    }

    func append(_ item: ToDoItem) {
        if let index = firstIndexBy(id: item.id, in: items) {
            items[index] = item
        } else {
            items.append(item)
        }
    }

    func save() throws {
        for item in items {
            try insert(item: item)
        }
    }

    func load() throws {
        guard let base = database else { return }
        for item in try base.prepare(toDoItems.order(startTime.desc)) {
            append(
                ToDoItem(
                    id: item[id],
                    text: item[text],
                    importance: Importance(rawValue: item[importance]) ?? .common,
                    deadLineTimeIntervalSince1970: item[deadLine]?.timeIntervalSince1970,
                    isDone: item[isDone] == 1 ? true : false,
                    startTimeIntervalSince1970: item[startTime].timeIntervalSince1970,
                    changeTimeIntervalSince1970: item[changeTime]?.timeIntervalSince1970
                )
            )
        }
    }

    func insert(item: ToDoItem) throws {
        guard let base = database else { return }
        try base
            .run(
                toDoItems
                    .insert(
                        or: .replace,
                        id <- item.id,
                        text <- item.text,
                        importance <- item.importance.rawValue,
                        deadLine <- item.deadLine,
                        isDone <- item.isDone ? 1 : 0,
                        startTime <- item.startTime,
                        changeTime <- item.changeTime
                    ))
        append(item)
    }

    func delete(for deletedId: String) throws {
        guard let base = database else { return }
        let deletedItem = toDoItems.filter(id == deletedId)
        print(try base.run(deletedItem.delete()))
        if let index = firstIndexBy(id: deletedId, in: items) {
            items.remove(at: index)
        }
    }

    func updateItemsIntoDatabase(using serverItems: [ToDoItem]) throws {
        let itemsSet = Set(items.map({ $0.id }))
        let serverItemsSet = Set(serverItems.map({ $0.id }))

        if itemsSet.count > serverItemsSet.count {
            let deleteItems = itemsSet.subtracting(serverItemsSet)
            print(deleteItems)
            for id in deleteItems {
                try delete(for: id)
            }
        } else {
            let addItems = serverItemsSet.subtracting(itemsSet)
            for id in addItems {
                if let item = serverItems.first(where: { $0.id == id }) {
                    try insert(item: item)
                }
            }
        }
    }
}
