//
//  ToDoItem.swift
//  SwiftUIVersion
//
//  Created by Даниил Кизельштейн on 20.07.2023.
//

import Foundation

enum Importance: String, CaseIterable {
    case unimportant = "low"
    case common = "basic"
    case important = "important"
    }

struct ToDoItem {
    let id: String
    let text: String
    let importance: Importance
    let deadLine: Date?
    let isDone: Bool
    let startTime: Date
    let changeTime: Date?
    static let splitter: String = ","
    static let elementsOrder: String = "id,text,importance,deadLine,isDone,startTime,changeTime"

    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        deadLineTimeIntervalSince1970: Double?,
        isDone: Bool,
        startTimeIntervalSince1970: Double,
        changeTimeIntervalSince1970: Double?
    ) {

        self.id = id
        self.text = text

        self.importance = importance

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

struct ToDoList {
    static let items: [ToDoItem] = [
        .init(
            id: "1",
            text: "first",
            importance: .important,
            deadLineTimeIntervalSince1970: nil,
            isDone: false,
            startTimeIntervalSince1970: 1689766721,
            changeTimeIntervalSince1970: nil),
        .init(
            id: "2",
            text: "second",
            importance: .unimportant,
            deadLineTimeIntervalSince1970: 1689766495+10800,
            isDone: false,
            startTimeIntervalSince1970: 1689766495,
            changeTimeIntervalSince1970: nil),
        .init(
            id: "3",
            text: "Third\nThird\nThird\nThird",
            importance: .common,
            deadLineTimeIntervalSince1970: 1689766495+10800,
            isDone: false,
            startTimeIntervalSince1970: 1689766495,
            changeTimeIntervalSince1970: nil),
        .init(
            id: "4",
            text: "Fourth",
            importance: .important,
            deadLineTimeIntervalSince1970: 1689766495+10800,
            isDone: true,
            startTimeIntervalSince1970: 1689766495,
            changeTimeIntervalSince1970: nil)
    ]
}

