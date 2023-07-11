//
//  FileCache.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 13.06.2023.
//

import Foundation

enum FileType: String {
    case json = ".json"
    case csv = ".csv"
}

class FileCache {
    private(set) var items = [ToDoItem]()

    private var firstCsvString = ToDoItem.elementsOrder

    static func firstIndexOf(id: String, in itemsList: [ToDoItem]) -> Int? {
        return itemsList.map({$0.id}).firstIndex(of: id)
    }

    func appendItem(_ item: ToDoItem) {
        if let index = FileCache.firstIndexOf(id: item.id, in: items) {
            items[index] = item
        } else {
            items.append(item)
        }
    }

    func deleteItem(for id: String) {
        if let index = FileCache.firstIndexOf(id: id, in: items) {
            items.remove(at: index)
        }
    }

    func deleteAll() {
        items = []
    }

    private func getFilePath(fileName: String, type: FileType) -> URL? {
        guard let documentDirectory = FileManager
            .default
            .urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first else { return nil }

        return documentDirectory
            .appendingPathComponent(fileName + type.rawValue)

    }

    func saveItemsToFileSystem(fileName: String, type: FileType) throws {
        guard let filePath = getFilePath(fileName: fileName, type: type) else { return }
        print(filePath)

        var itemsToData: Data?

        switch type {
        case .json:
            itemsToData = try JSONSerialization
                .data(withJSONObject: items.map({$0.json}))
        case .csv:
            var itemsWithFirstCsvString: [String] = [firstCsvString]
            itemsWithFirstCsvString.append(contentsOf: items.map({ $0.csv }))
            itemsToData = itemsWithFirstCsvString.joined(separator: "\n").data(using: .utf8)
        }

        guard let itemsToData = itemsToData else { return } // можно в будущем пробросить ошибку
        try itemsToData.write(to: filePath, options: [])
    }

    private func loadDataFromFileSystem(fileName: String, type: FileType) throws -> Any? {
        guard let filePath = getFilePath(fileName: fileName, type: type) else { return nil }

        if FileManager.default.fileExists(atPath: filePath.path) {
            let data = try Data(contentsOf: filePath)
            switch type {
            case .json:
                return try JSONSerialization.jsonObject(with: data)
            case .csv:
                return try String(contentsOf: filePath, encoding: .utf8)
            }
        }

        return nil
    }

    func loadItemsFromFileSystem(fileName: String, type: FileType) throws {
        if let data = try loadDataFromFileSystem(fileName: fileName, type: type) {
            switch type {
            case .json:
                if let jsonList = data as? [Any] {
                    items = jsonList.map({ToDoItem.parse(json: $0)}).compactMap { $0 }
                }
            case .csv:
                if let csvString = data as? String {
                    var csvList = csvString.components(separatedBy: "\n")
                    guard csvList[0].components(separatedBy: ",").count == 7 else { return }
                    firstCsvString = csvList.removeFirst()
                    items = csvList.map({ToDoItem.parse(csv: $0)}).compactMap { $0 }
                }
            }
        }
    }
}
