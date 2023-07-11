//
//  DefaultNetworkingService.swift
//  ToDoList
//
//  Created by Даниил Кизельштейн on 05.07.2023.
//

import UIKit

protocol NetworkingService {
    func fetchItems() async throws -> [ToDoItem]
    func patch(for items: [ToDoItem]) async throws -> [ToDoItem]
    func post(for toDoItem: ToDoItem) async throws
    func put(for toDoItem: ToDoItem) async throws
    func delete(for toDoItem: ToDoItem) async throws
}

final class DefaultNetworkingService: NetworkingService {

    // MARK: - Properties

    var isDirty: Bool = false

    private let session = URLSession.shared

    private var revision: Int = 0

    private let deviceId: String

    private let scheme = "https"
    private let host = "beta.mrdekk.ru"
    private let path = "/todobackend/list"

    private lazy var urlComponents: URLComponents = {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        return urlComponents
    }()

    private let timeoutForRequest: Double = 10

    // MARK: - Initializer

    init(deviceId: String) {
        self.deviceId = deviceId
    }

    // MARK: - Handlers

    func fetchItems() async throws -> [ToDoItem] {
        let url = try gatherURL()

        let (data, response) = try await session.data(for: gatherGetRequest(url: url))

        print(String(data: data, encoding: .utf8)!)
        try typeOfResponse(code: (response as? HTTPURLResponse)?.statusCode ?? 0)

        let responseServer = try JSONDecoder().decode(ListResponseServer.self, from: data)

        if let revision = responseServer.revision {
            self.revision = revision
        }

        return responseServer.list.map { gatherToDoItemFromServer($0) }
    }

    func patch(for items: [ToDoItem]) async throws -> [ToDoItem] {
        let url = try gatherURL()

        let itemsForServer = ListResponseServer(list: items.map({ gatherToDoItemForServer($0) }))

        let dataForServer = try JSONEncoder().encode(itemsForServer)

        let (data, response) = try await session.data(for: gatherPatchRequest(url: url, body: dataForServer))

        try typeOfResponse(code: (response as? HTTPURLResponse)?.statusCode ?? 0)

        let responseServer = try JSONDecoder().decode(ListResponseServer.self, from: data)

        isDirty = false

        if let revision = responseServer.revision {
            self.revision = revision
        }
        return responseServer.list.map { gatherToDoItemFromServer($0) }
    }

    func post(for toDoItem: ToDoItem) async throws {
        let url = try gatherURL()

        let toDoItemServer = ItemResponseServer(element: gatherToDoItemForServer(toDoItem))

        let dataForServer = try JSONEncoder().encode(toDoItemServer)

        let (data, response) = try await session.data(for: gatherPostRequest(url: url, body: dataForServer))

        try typeOfResponse(code: (response as? HTTPURLResponse)?.statusCode ?? 0)

        let responseServer = try JSONDecoder().decode(ItemResponseServer.self, from: data)

        if let revision = responseServer.revision {
            self.revision = revision
        }
    }

    func put(for toDoItem: ToDoItem) async throws {
        let url = try gatherURL(for: toDoItem.id)

        let toDoItemServer = ItemResponseServer(element: gatherToDoItemForServer(toDoItem))

        let dataForServer = try JSONEncoder().encode(toDoItemServer)

        let (data, response) = try await session.data(for: gatherPutRequest(url: url, body: dataForServer))

        try typeOfResponse(code: (response as? HTTPURLResponse)?.statusCode ?? 0)

        let responseServer = try JSONDecoder().decode(ItemResponseServer.self, from: data)

        if let revision = responseServer.revision {
            self.revision = revision
        }
    }

    func delete(for toDoItem: ToDoItem) async throws {
        let url = try gatherURL(for: toDoItem.id)

        let (data, response) = try await session.data(for: gatherDeleteRequest(url: url))

        try typeOfResponse(code: (response as? HTTPURLResponse)?.statusCode ?? 0)

        let responseServer = try JSONDecoder().decode(ItemResponseServer.self, from: data)

        if let revision = responseServer.revision {
            self.revision = revision
        }
    }

    private func typeOfResponse(code: Int) throws {
        switch code {
        case 200..<300:
            return
        case 400:
            throw RequestError.wrongRequest
        case 401:
            throw RequestError.wrongAuth
        case 404:
            throw RequestError.wrongItemId
        case 500..<600:
            self.isDirty = true
            throw RequestError.serverError
        default:
            return
        }
    }

    // MARK: Gather functions

    private func gatherURL(for id: String? = nil) throws -> URL {
        urlComponents.path = id != nil ? path + "/\(id ?? "")" : path

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        return url
    }

    private func gatherGetRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: timeoutForRequest)
        request.setValue("Bearer \(Session.shared.token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func gatherPatchRequest(url: URL, body: Data) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: timeoutForRequest)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(Session.shared.token)", forHTTPHeaderField: "Authorization")
        request.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = body
        return request
    }

    private func gatherPostRequest(url: URL, body: Data) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: timeoutForRequest)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Session.shared.token)", forHTTPHeaderField: "Authorization")
        request.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = body
        return request
    }

    private func gatherPutRequest(url: URL, body: Data) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: timeoutForRequest)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(Session.shared.token)", forHTTPHeaderField: "Authorization")
        request.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = body
        return request
    }

    private func gatherDeleteRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: timeoutForRequest)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(Session.shared.token)", forHTTPHeaderField: "Authorization")
        request.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
        return request
    }

    private func gatherToDoItemFromServer(_ item: ToDoItemServer) -> ToDoItem {
        return ToDoItem(
            id: item.id,
            text: item.text,
            importance: Importance(rawValue: item.importance) ?? .common,
            deadLineTimeIntervalSince1970: Double(item.deadline ?? 0) == 0 ? nil : Double(item.deadline ?? 0),
            isDone: item.isDone,
            startTimeIntervalSince1970: Double(item.startTime),
            changeTimeIntervalSince1970: Double(item.changeTime) == 0 ? nil : Double(item.changeTime))
    }

    private func gatherToDoItemForServer(_ item: ToDoItem) -> ToDoItemServer {
        return ToDoItemServer(
            id: item.id,
            text: item.text,
            importance: item.importance.rawValue,
            deadline: Int64(item.deadLine?.timeIntervalSince1970 ?? 0) == 0
            ? nil
            : Int64(item.deadLine?.timeIntervalSince1970 ?? 0),
            isDone: item.isDone,
            color: nil,
            startTime: Int64(item.startTime.timeIntervalSince1970),
            changeTime: Int64(item.changeTime?.timeIntervalSince1970 ?? 0) == 0
            ? Int64(item.startTime.timeIntervalSince1970)
            : Int64(item.changeTime?.timeIntervalSince1970 ?? 0),
            lastUpdatedBy: deviceId
        )
    }
}
