//
//  ItemResponseServer.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 06.07.2023.
//

import Foundation

struct ItemResponseServer: Codable {
    let status: String
    let revision: Int?
    let element: ToDoItemServer

    init(status: String = "ok", revision: Int? = nil, element: ToDoItemServer) {
        self.status = status
        self.revision = revision
        self.element = element
    }
}
