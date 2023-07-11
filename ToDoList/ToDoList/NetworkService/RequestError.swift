//
//  RequestError.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 07.07.2023.
//

import Foundation

enum RequestError: Error, LocalizedError, Equatable {
    case wrongRequest
    case wrongAuth
    case wrongItemId
    case serverError
    case unexpectedStatusCode(code: Int)

    var localizedDescription: String {
        switch self {
        case .wrongRequest:
            return "Error with synchronization data"
        case .wrongAuth:
            return "Wrong authorization"
        case .wrongItemId:
            return "Error 404! Possibly this item is already non-existent"
        case .serverError:
            return "Something wrong with server. The reserve copy has been created"
        case let .unexpectedStatusCode(code):
            return "Something unexpected happened. Error \(code)!!!"
        }
    }
}
