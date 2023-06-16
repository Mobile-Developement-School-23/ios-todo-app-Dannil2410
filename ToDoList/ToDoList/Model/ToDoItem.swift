//
//  ToDoItem.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 12.06.2023.
//

import Foundation

enum Importance: String, CaseIterable {
    case important = "важная"
    case unimportant = "неважная"
    case common = "обычная"
}

struct ToDoItem {
    let id: String
    let text: String
    let importance: Importance
    let deadLine: Date?
    let isDone: Bool
    let startTime: Date
    let changeTime: Date?
    private let timeOffset: Double = 10800 //нужен ли???
    static let splitter: String = ","
    static let elementsOrder: String = "id,text,importance,deadline,isDone,startTime,changeTime"
    
    init(id: String = UUID().uuidString, text: String, importance: String?, deadLineTimeIntervalSince1970: Double?, isDone: Bool, startTimeIntervalSince1970: Double = Date.now.timeIntervalSince1970, changeTimeIntervalSince1970: Double?) {
        
        self.id = id
        self.text = text
        
        self.importance = importance == "важная" ? Importance.important : (importance == "неважная" ? Importance.unimportant : Importance.common)
        
        if let deadLine = deadLineTimeIntervalSince1970 {
            self.deadLine = Date(timeIntervalSince1970: deadLine)
        } else {
            self.deadLine = nil
        }
        self.isDone = isDone
        self.startTime = Date(timeIntervalSince1970: startTimeIntervalSince1970)
        
        if let changeTime = changeTimeIntervalSince1970 {
            self.changeTime = Date(timeIntervalSince1970: changeTime)
        } else {
            self.changeTime = nil
        }
        
    }
}

extension ToDoItem {
    
    //MARK: - Work with JSON format
    
    var json: Any {
        var jsonDict = [String: Any]()
        jsonDict["id"] = self.id
        jsonDict["text"] = self.text
        jsonDict["importance"] = self.importance != .common ? self.importance.rawValue : nil
        if let deadLine = self.deadLine?.timeIntervalSince1970 {
            jsonDict["deadLine"] = deadLine + timeOffset
        }
        jsonDict["isDone"] = self.isDone
        jsonDict["startTime"] = self.startTime.timeIntervalSince1970 + timeOffset
        if let changeTime = self.changeTime?.timeIntervalSince1970 {
            jsonDict["changeTime"] = changeTime + timeOffset
        }
        return jsonDict
    }
    
    static func parse(json: Any) -> ToDoItem? {
        if let jsonDict = json as? [String: Any],
           let id = jsonDict["id"] as? String,
           let text = jsonDict["text"] as? String,
           let startTime = jsonDict["startTime"] as? Double
        {
            let importance = jsonDict["importance"] as? String
            let isDone = jsonDict["isDone"] as? Bool
            let deadLine = jsonDict["deadLine"] as? Double
            let changeTime = jsonDict["changeTime"] as? Double
            
            if let deadLine = deadLine,
               startTime >= deadLine { return nil }
            
            if let changeTime = changeTime,
               startTime >= changeTime { return nil }
            
            if let deadLine = deadLine,
               let changeTime = changeTime,
               changeTime >= deadLine { return nil }
               
            
            return ToDoItem(id: id,
                            text: text,
                            importance: importance,
                            deadLineTimeIntervalSince1970: deadLine,
                            isDone: isDone == true ? true : false,
                            startTimeIntervalSince1970: startTime,
                            changeTimeIntervalSince1970: changeTime)
        }
        return nil
    }
}

extension ToDoItem {
    
    //MARK: - Work with CSV format
    
    var csv: String {
        var csvList = [String]()
        csvList.append(self.id)
        csvList.append(self.text)
        csvList.append(importance == .common ? "" : importance.rawValue)
        
        if let deadLine = self.deadLine {
            csvList.append(String(deadLine.timeIntervalSince1970 + timeOffset))
        } else {
            csvList.append("")
        }
        
        csvList.append(self.isDone == true ? "true" : "false")
        csvList.append(String(self.startTime.timeIntervalSince1970 + timeOffset))
        
        if let changeTime = self.changeTime {
            csvList.append(String(changeTime.timeIntervalSince1970 + timeOffset))
        } else {
            csvList.append("")
        }
        
        return csvList.joined(separator: ToDoItem.splitter) + "\n"// нужен ли???
    }
    
    static func parse(csv: String) -> ToDoItem? {
        let csvList = csv.components(separatedBy: ToDoItem.splitter)
        // нужно ли каждую строчку проверять или достаточно только первую в FileCache
        if csvList.count == 7,
           csvList[0] != "",
           let startTime = Double(csvList[5])
        {
            if let deadLine = Double(csvList[3]),
               startTime >= deadLine { return nil }
            
            if let changeTime = Double(csvList[6]),
               startTime >= changeTime { return nil }
            
            if let deadLine = Double(csvList[3]),
               let changeTime = Double(csvList[6]),
               changeTime >= deadLine { return nil }
            
            return ToDoItem(id: csvList[0], // id
                            text: csvList[1], // text может ли быть пустым???
                            importance: csvList[2], // importance
                            deadLineTimeIntervalSince1970: Double(csvList[3]), // deadLine
                            isDone: csvList[4] == "true" ? true : false, // isDone
                            startTimeIntervalSince1970: startTime, // startTime
                            changeTimeIntervalSince1970: Double(csvList[6])) // changeTime
        }
        return nil
    }
}
