//
//  ToDoItemServer.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 05.07.2023.
//

import Foundation

struct ToDoItemServer: Codable {
    let id: String
    let text: String
    let importance: String
    let deadline: Int64?
    let isDone: Bool
    let color: String?
    let startTime: Int64
    let changeTime: Int64
    let lastUpdatedBy: String

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline
        case isDone = "done"
        case color
        case startTime = "created_at"
        case changeTime = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }
}
