//
//  ResponseServer.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 05.07.2023.
//

import Foundation

struct ListResponseServer: Codable {
    let status: String?
    let revision: Int?
    let list: [ToDoItemServer]

    init(status: String? = nil, revision: Int? = nil, list: [ToDoItemServer]) {
        self.status = status
        self.revision = revision
        self.list = list
    }
}
