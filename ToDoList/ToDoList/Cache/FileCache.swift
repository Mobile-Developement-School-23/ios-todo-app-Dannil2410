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
    
    private var firstCsvString = ToDoItem.elementsOrder + "\n"
    
    func appendItem(_ item: ToDoItem) {
        if let index = items.map({$0.id}).firstIndex(of: item.id) {
            items[index] = item
        } else {
            items.append(item)
        }
    }
    
    func deleteItem(for id: String) {
        if let index = items.map({$0.id}).firstIndex(of: id) {
            items.remove(at: index)
        }
    }
    
    private func getFilePath(fileName: String, type: FileType) -> String? {
        guard let applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        
        return applicationSupportDirectory
            .appendingPathComponent(fileName + type.rawValue)
            .path
    }
    
    func saveItemsToFileSystem(fileName: String, type: FileType) throws {
        guard let filePath = getFilePath(fileName: fileName, type: type),
              let url = URL(string: filePath) else { return }
        
        var itemsToDataList: Data
        
        switch type {
        case .json:
            itemsToDataList = try JSONSerialization
                .data(withJSONObject: items.map({$0.json}))
        case .csv:
            var itemsWithFirstCsvString: [String] = [firstCsvString]
            itemsWithFirstCsvString.append(contentsOf: items.map({ $0.csv }))
            itemsToDataList = try JSONSerialization
                .data(withJSONObject: itemsWithFirstCsvString)
        }
        
        try itemsToDataList.write(to: url, options: [])
    }
    
    private func loadJsonDataFromFileSystem(fileName: String, type: FileType) throws -> Any? {
        guard let filePath = getFilePath(fileName: fileName, type: type),
              let url = URL(string: filePath) else { return nil }
        
        if FileManager.default.fileExists(atPath: filePath) {
            let data = try Data(contentsOf: url)
            return try JSONSerialization.jsonObject(with: data)
        }
        
        return nil
    }
    
    func loadItemsFromFileSystem(fileName: String, type: FileType) throws {
        if let data = try loadJsonDataFromFileSystem(fileName: fileName, type: type)
        {
            switch type {
            case .json:
                if let jsonList = data as? [Any] {
                    items = jsonList.map({ToDoItem.parse(json: $0)}).compactMap { $0 }
                }
            case .csv:
                if let csvString = data as? String {
                    var csvList = csvString.components(separatedBy: "\n")
                    guard csvList[0].components(separatedBy: ",").count == 7 else { return }
                    firstCsvString = csvList.removeFirst() + "\n"
                    items = csvList.map({ToDoItem.parse(csv: $0)}).compactMap { $0 }
                }
            }
        }
    }
}
